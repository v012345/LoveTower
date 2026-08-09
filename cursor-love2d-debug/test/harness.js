// End-to-end test for lua/debugger.lua without the IDE.
// Simulates the debug adapter: TCP server + newline-delimited JSON protocol.
// Scenario:
//   1. breakpoint at main.lua:33 -> expect stop, frames with localsRef/upvaluesRef
//   2. query variables of top frame upvalues -> expect run_time/dt among them
//   3. stepIn -> expect stop reason "step" at main.lua:34
//   4. continue -> breakpoint hits again at :33
//   5. next (step over the getTime call) -> expect stop at :34
//   6. clear breakpoints + continue -> expect no more stops
const net = require('net');
const path = require('path');
const { spawn } = require('child_process');

const PORT = 56790;
const PROJECT = path.resolve(__dirname, '..', '..');
const DEBUGGER_LUA = path.resolve(__dirname, '..', 'lua', 'debugger.lua');
const LOVE = 'C:/Program Files/LOVE/lovec.exe';
const BP_LINE = 33;

let game;
let phase = 'wait-bp1';
let failed = false;
let seq = 0;
const pending = new Map();

function fail(msg) {
    console.error('FAIL: ' + msg);
    failed = true;
    cleanup();
}

function cleanup() {
    if (game && !game.killed) game.kill();
    setTimeout(() => process.exit(failed ? 1 : 0), 500);
}

let sendFn;

function request(msg) {
    return new Promise((resolve) => {
        const s = ++seq;
        pending.set(s, resolve);
        sendFn({ ...msg, seq: s });
    });
}

async function onStopped(msg) {
    const top = msg.frames && msg.frames[0];
    console.log(`[harness] STOP phase=${phase} reason=${msg.reason} top=${top && top.source}:${top && top.line}`);

    if (phase === 'wait-bp1') {
        if (msg.reason !== 'breakpoint' || top.line !== BP_LINE) return fail('bp1: wrong stop');
        if (typeof top.localsRef !== 'number') return fail('bp1: no localsRef');
        // upvalues of the main-loop closure should contain run_time / dt
        if (!top.upvaluesRef) return fail('bp1: no upvaluesRef');
        const reply = await request({ command: 'variables', ref: top.upvaluesRef });
        const names = reply.variables.map((v) => v.name);
        console.log('[harness] upvalues:', names.join(', '));
        if (!names.includes('run_time') || !names.includes('dt')) return fail('bp1: expected upvalues missing');
        // expand a table: love.handlers is not local here; instead test locals of frame 0
        const locals = await request({ command: 'variables', ref: top.localsRef });
        console.log('[harness] locals:', locals.variables.map((v) => `${v.name}=${v.value}`).join(', ') || '(none)');
        phase = 'wait-step-in';
        sendFn({ command: 'stepIn' });
    } else if (phase === 'wait-step-in') {
        if (msg.reason !== 'step') return fail('stepIn: wrong reason ' + msg.reason);
        if (top.line !== BP_LINE + 1) return fail(`stepIn: expected line ${BP_LINE + 1}, got ${top.line}`);
        console.log('[harness] stepIn OK ->', top.line);
        phase = 'wait-bp2';
        sendFn({ command: 'continue' });
    } else if (phase === 'wait-bp2') {
        if (msg.reason !== 'breakpoint' || top.line !== BP_LINE) return fail('bp2: wrong stop');
        phase = 'wait-step-over';
        sendFn({ command: 'next' });
    } else if (phase === 'wait-step-over') {
        if (msg.reason !== 'step') return fail('stepOver: wrong reason ' + msg.reason);
        if (top.line !== BP_LINE + 1) return fail(`stepOver: expected line ${BP_LINE + 1}, got ${top.line}`);
        console.log('[harness] stepOver OK ->', top.line);
        phase = 'wait-quiet';
        sendFn({ command: 'setBreakpoints', source: 'main.lua', lines: [] });
        sendFn({ command: 'continue' });
        setTimeout(() => {
            if (phase === 'wait-quiet') {
                console.log('PASS: breakpoints, variables, stepIn, stepOver all OK');
                cleanup();
            }
        }, 2000);
    } else {
        return fail('unexpected stop in phase ' + phase);
    }
}

const server = net.createServer((sock) => {
    console.log('[harness] game connected');
    let buf = '';
    sendFn = (msg) => sock.write(JSON.stringify(msg) + '\n');

    sock.on('data', (d) => {
        buf += d.toString('utf8');
        let idx;
        while ((idx = buf.indexOf('\n')) >= 0) {
            const line = buf.slice(0, idx);
            buf = buf.slice(idx + 1);
            if (!line.trim()) continue;
            const msg = JSON.parse(line);
            if (msg.event === 'connected') {
                sendFn({ command: 'setBreakpoints', source: 'main.lua', lines: [BP_LINE] });
                sendFn({ command: 'start', stopOnEntry: false });
            } else if (msg.event === 'reply') {
                const r = pending.get(msg.seq);
                if (r) { pending.delete(msg.seq); r(msg); }
            } else if (msg.event === 'stopped') {
                onStopped(msg).catch((e) => fail(e.message));
            }
        }
    });
    sock.on('error', () => {});
});

server.listen(PORT, '127.0.0.1', () => {
    console.log('[harness] listening on ' + PORT + ', spawning game');
    game = spawn(LOVE, [PROJECT], {
        cwd: PROJECT,
        env: { ...process.env, LOVE_DEBUGGER: DEBUGGER_LUA, LOVE_DEBUGGER_PORT: String(PORT) },
    });
    game.stdout.on('data', (d) => {
        const s = d.toString();
        if (s.includes('[dbg]') || s.includes('[love2d-debug]')) process.stdout.write('[game] ' + s);
    });
    game.stderr.on('data', (d) => process.stderr.write('[game:err] ' + d.toString()));
    game.on('exit', (code) => console.log('[harness] game exited ' + code));
});

setTimeout(() => fail('timeout after 40s in phase ' + phase), 40000);
