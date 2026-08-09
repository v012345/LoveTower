import {
    LoggingDebugSession,
    InitializedEvent,
    OutputEvent,
    TerminatedEvent,
    StoppedEvent,
    ContinuedEvent,
    Thread,
    StackFrame,
    Source,
    Breakpoint,
} from '@vscode/debugadapter';
import { DebugProtocol } from '@vscode/debugprotocol';
import { ChildProcess, spawn } from 'child_process';
import * as net from 'net';
import * as path from 'path';

interface LaunchArgs extends DebugProtocol.LaunchRequestArguments {
    projectRoot: string;
    lovePath?: string;
    args?: string[];
    port?: number;
    stopOnEntry?: boolean;
}

const ADAPTER_VERSION = '0.2.0';

interface GameFrame {
    name: string;
    source: string;
    line: number;
    localsRef: number;
    upvaluesRef: number;
}

interface GameVariable {
    name: string;
    value: string;
    type: string;
    ref: number;
}

const THREAD_ID = 1;

export class LoveDebugSession extends LoggingDebugSession {
    private game?: ChildProcess;
    private server?: net.Server;
    private conn?: net.Socket;
    private recvBuf = '';
    private projectRoot = '';
    /** absolute client path -> breakpoint lines */
    private breakpoints = new Map<string, number[]>();
    private configurationDone = false;
    private started = false;
    private stopOnEntry = false;
    private frames: GameFrame[] = [];
    private nextSeq = 1;
    private pending = new Map<number, (msg: any) => void>();

    constructor(private extensionPath: string) {
        super();
        this.setDebuggerLinesStartAt1(true);
        this.setDebuggerColumnsStartAt1(true);
    }

    // ---------- path mapping ----------

    /** absolute client path -> source id used by the game (relative, /, lowercase) */
    private toGameSource(absPath: string): string {
        return path
            .relative(this.projectRoot, absPath)
            .replace(/\\/g, '/')
            .toLowerCase();
    }

    /** love chunk source ("@asset/scripts/game.lua") -> absolute client path */
    private toClientPath(gameSource: string): string | undefined {
        if (!gameSource.startsWith('@')) {
            return undefined;
        }
        return path.join(this.projectRoot, gameSource.slice(1));
    }

    // ---------- game connection ----------

    private sendToGame(msg: object): void {
        this.conn?.write(JSON.stringify(msg) + '\n');
    }

    /** Send a command and wait for the game's reply (matched by seq) */
    private requestFromGame(msg: Record<string, unknown>, timeoutMs = 3000): Promise<any> {
        return new Promise((resolve) => {
            if (!this.conn) {
                resolve(undefined);
                return;
            }
            const seq = this.nextSeq++;
            const timer = setTimeout(() => {
                this.pending.delete(seq);
                resolve(undefined);
            }, timeoutMs);
            this.pending.set(seq, (reply) => {
                clearTimeout(timer);
                this.pending.delete(seq);
                resolve(reply);
            });
            this.sendToGame({ ...msg, seq });
        });
    }

    private onGameData(data: Buffer): void {
        this.recvBuf += data.toString('utf8');
        let idx: number;
        while ((idx = this.recvBuf.indexOf('\n')) >= 0) {
            const line = this.recvBuf.slice(0, idx);
            this.recvBuf = this.recvBuf.slice(idx + 1);
            if (line.trim().length === 0) {
                continue;
            }
            try {
                this.onGameMessage(JSON.parse(line));
            } catch {
                this.sendEvent(
                    new OutputEvent(`[love2d-debug] bad message from game: ${line}\n`, 'stderr')
                );
            }
        }
    }

    private onGameMessage(msg: any): void {
        switch (msg.event) {
            case 'connected':
                this.trySendStart();
                break;
            case 'reply': {
                const resolver = this.pending.get(msg.seq);
                if (resolver) {
                    resolver(msg);
                }
                break;
            }
            case 'stopped': {
                this.frames = msg.frames ?? [];
                const event = new StoppedEvent(
                    msg.reason ?? 'breakpoint',
                    THREAD_ID
                ) as DebugProtocol.StoppedEvent;
                if (msg.text) {
                    event.body.description = 'Lua error';
                    event.body.text = msg.text;
                    this.sendEvent(new OutputEvent(`[love2d-debug] error: ${msg.text}\n`, 'stderr'));
                }
                this.sendEvent(event);
                break;
            }
            case 'continued':
                this.sendEvent(new ContinuedEvent(THREAD_ID, true));
                break;
        }
    }

    /** Send cached breakpoints + start once both the game is connected and configuration is done */
    private trySendStart(): void {
        if (!this.conn || !this.configurationDone || this.started) {
            return;
        }
        this.started = true;
        for (const [absPath, lines] of this.breakpoints) {
            this.sendToGame({
                command: 'setBreakpoints',
                source: this.toGameSource(absPath),
                lines,
            });
        }
        this.sendToGame({ command: 'start', stopOnEntry: this.stopOnEntry });
    }

    // ---------- DAP requests ----------

    protected initializeRequest(
        response: DebugProtocol.InitializeResponse,
        _args: DebugProtocol.InitializeRequestArguments
    ): void {
        response.body = {
            supportsConfigurationDoneRequest: true,
            supportsTerminateRequest: true,
        };
        this.sendResponse(response);
        this.sendEvent(new InitializedEvent());
    }

    protected launchRequest(
        response: DebugProtocol.LaunchResponse,
        args: LaunchArgs
    ): void {
        this.projectRoot = args.projectRoot;
        this.stopOnEntry = args.stopOnEntry ?? false;
        const lovePath = args.lovePath || 'lovec';
        const debuggerLua = path.join(this.extensionPath, 'lua', 'debugger.lua');
        const port = args.port ?? 56789;

        this.server = net.createServer((socket) => {
            if (this.conn) {
                socket.destroy();
                return;
            }
            this.conn = socket;
            this.sendEvent(
                new OutputEvent('[love2d-debug] game connected to adapter\n', 'console')
            );
            socket.setNoDelay(true);
            socket.on('data', (d) => this.onGameData(d));
            socket.on('close', () => {
                this.conn = undefined;
            });
            socket.on('error', () => {
                this.conn = undefined;
            });
        });

        this.server.on('error', (err) => {
            this.sendEvent(
                new OutputEvent(`[love2d-debug] TCP server error: ${err.message}\n`, 'stderr')
            );
        });

        this.server.listen(port, '127.0.0.1', () => {
            this.sendEvent(
                new OutputEvent(
                    `[love2d-debug] adapter v${ADAPTER_VERSION} listening on port ${port}\n`,
                    'console'
                )
            );
            this.game = spawn(lovePath, [args.projectRoot, ...(args.args ?? [])], {
                cwd: args.projectRoot,
                env: {
                    ...process.env,
                    LOVE_DEBUGGER: debuggerLua,
                    LOVE_DEBUGGER_PORT: String(port),
                },
            });

            this.game.stdout?.on('data', (data: Buffer) => {
                this.sendEvent(new OutputEvent(data.toString(), 'stdout'));
            });
            this.game.stderr?.on('data', (data: Buffer) => {
                this.sendEvent(new OutputEvent(data.toString(), 'stderr'));
            });
            this.game.on('error', (err) => {
                this.sendEvent(
                    new OutputEvent(`Failed to start ${lovePath}: ${err.message}\n`, 'stderr')
                );
                this.sendEvent(new TerminatedEvent());
            });
            this.game.on('exit', (code) => {
                this.sendEvent(new OutputEvent(`Game exited with code ${code}\n`, 'console'));
                this.sendEvent(new TerminatedEvent());
            });

            this.sendResponse(response);
        });
    }

    protected setBreakPointsRequest(
        response: DebugProtocol.SetBreakpointsResponse,
        args: DebugProtocol.SetBreakpointsArguments
    ): void {
        const clientPath = args.source.path;
        const lines = (args.breakpoints ?? []).map((bp) => bp.line);

        if (clientPath) {
            this.breakpoints.set(clientPath, lines);
            if (this.started) {
                this.sendToGame({
                    command: 'setBreakpoints',
                    source: this.toGameSource(clientPath),
                    lines,
                });
            }
        }

        response.body = {
            breakpoints: lines.map((line) => new Breakpoint(true, line) as DebugProtocol.Breakpoint),
        };
        this.sendResponse(response);
    }

    protected configurationDoneRequest(
        response: DebugProtocol.ConfigurationDoneResponse,
        _args: DebugProtocol.ConfigurationDoneArguments
    ): void {
        this.configurationDone = true;
        this.trySendStart();
        this.sendResponse(response);
    }

    protected threadsRequest(response: DebugProtocol.ThreadsResponse): void {
        response.body = { threads: [new Thread(THREAD_ID, 'main')] };
        this.sendResponse(response);
    }

    protected stackTraceRequest(
        response: DebugProtocol.StackTraceResponse,
        _args: DebugProtocol.StackTraceArguments
    ): void {
        const stackFrames = this.frames.map((f, i) => {
            const clientPath = this.toClientPath(f.source);
            const source = clientPath
                ? new Source(path.basename(clientPath), clientPath)
                : undefined;
            return new StackFrame(i, f.name, source, f.line);
        });
        response.body = { stackFrames, totalFrames: stackFrames.length };
        this.sendResponse(response);
    }

    protected scopesRequest(
        response: DebugProtocol.ScopesResponse,
        args: DebugProtocol.ScopesArguments
    ): void {
        const frame = this.frames[args.frameId];
        const scopes: DebugProtocol.Scope[] = [];
        if (frame) {
            scopes.push({
                name: 'Locals',
                variablesReference: frame.localsRef,
                expensive: false,
            });
            if (frame.upvaluesRef > 0) {
                scopes.push({
                    name: 'Upvalues',
                    variablesReference: frame.upvaluesRef,
                    expensive: false,
                });
            }
        }
        response.body = { scopes };
        this.sendResponse(response);
    }

    protected async variablesRequest(
        response: DebugProtocol.VariablesResponse,
        args: DebugProtocol.VariablesArguments
    ): Promise<void> {
        const reply = await this.requestFromGame({
            command: 'variables',
            ref: args.variablesReference,
        });
        const gameVars: GameVariable[] = reply?.variables ?? [];
        response.body = {
            variables: gameVars.map((v) => ({
                name: v.name,
                value: v.value,
                type: v.type,
                variablesReference: v.ref,
            })),
        };
        this.sendResponse(response);
    }

    protected continueRequest(
        response: DebugProtocol.ContinueResponse,
        _args: DebugProtocol.ContinueArguments
    ): void {
        this.frames = [];
        this.sendToGame({ command: 'continue' });
        response.body = { allThreadsContinued: true };
        this.sendResponse(response);
    }

    protected nextRequest(
        response: DebugProtocol.NextResponse,
        _args: DebugProtocol.NextArguments
    ): void {
        this.frames = [];
        this.sendToGame({ command: 'next' });
        this.sendResponse(response);
    }

    protected stepInRequest(
        response: DebugProtocol.StepInResponse,
        _args: DebugProtocol.StepInArguments
    ): void {
        this.frames = [];
        this.sendToGame({ command: 'stepIn' });
        this.sendResponse(response);
    }

    protected stepOutRequest(
        response: DebugProtocol.StepOutResponse,
        _args: DebugProtocol.StepOutArguments
    ): void {
        this.frames = [];
        this.sendToGame({ command: 'stepOut' });
        this.sendResponse(response);
    }

    protected pauseRequest(
        response: DebugProtocol.PauseResponse,
        _args: DebugProtocol.PauseArguments
    ): void {
        this.sendToGame({ command: 'pause' });
        this.sendResponse(response);
    }

    protected disconnectRequest(
        response: DebugProtocol.DisconnectResponse,
        _args: DebugProtocol.DisconnectArguments
    ): void {
        if (this.game && !this.game.killed) {
            this.game.kill();
        }
        this.conn?.destroy();
        this.server?.close();
        this.sendResponse(response);
    }
}
