// Drive the REAL compiled adapter (out/loveDebugSession.js) over the DAP
// wire protocol, replicating the exact message flow VS Code / Cursor uses.
const { PassThrough } = require('stream');
const path = require('path');
const { LoveDebugSession } = require('../out/loveDebugSession');

const EXT_PATH = path.resolve(__dirname, '..');
const PROJECT = 'c:\\Users\\NightOwl\\Desktop\\LoveTower'; // lowercase drive like VS Code
const BP_PATH = PROJECT + '\\asset\\scripts\\game\\app.lua';
const BP_LINE = 199; // inside App:update, runs every frame
const MAIN_BP_PATH = PROJECT + '\\main.lua';
const MAIN_BP_LINE = 34;

const toAdapter = new PassThrough();
const fromAdapter = new PassThrough();

const session = new LoveDebugSession(EXT_PATH);
session.setRunAsServer(true);
session.start(toAdapter, fromAdapter);

let seq = 1;
function send(type, command, args, extra) {
    const msg = { seq: seq++, type, command, ...(extra || {}) };
    if (type === 'request') msg.arguments = args;
    const json = JSON.stringify(msg);
    toAdapter.write(`Content-Length: ${Buffer.byteLength(json)}\r\n\r\n${json}`);
}
const request = (command, args) => send('request', command, args);

let failed = false;
let done = false;
function finish(ok, msg) {
    if (done) return;
    done = true;
    failed = !ok;
    console.log((ok ? 'PASS: ' : 'FAIL: ') + msg);
    request('disconnect', {});
    setTimeout(() => process.exit(failed ? 1 : 0), 1500);
}

// --- parse DAP messages from adapter ---
let buf = Buffer.alloc(0);
fromAdapter.on('data', (chunk) => {
    buf = Buffer.concat([buf, chunk]);
    while (true) {
        const headerEnd = buf.indexOf('\r\n\r\n');
        if (headerEnd < 0) break;
        const m = /Content-Length: (\d+)/.exec(buf.slice(0, headerEnd).toString());
        const len = parseInt(m[1], 10);
        if (buf.length < headerEnd + 4 + len) break;
        const body = buf.slice(headerEnd + 4, headerEnd + 4 + len).toString('utf8');
        buf = buf.slice(headerEnd + 4 + len);
        onMessage(JSON.parse(body));
    }
});

let stoppedCount = 0;

function onMessage(msg) {
    if (msg.type === 'event' && msg.event === 'output') {
        const t = msg.body.output.trim();
        if (t.includes('love2d-debug') || t.includes('exited')) console.log('[output]', t);
        return;
    }
    if (msg.type === 'response') {
        console.log('[response]', msg.command, msg.success ? 'ok' : 'FAILED', msg.command === 'setBreakpoints' ? JSON.stringify(msg.body) : '');
        return;
    }
    if (msg.type !== 'event') return;
    console.log('[event]', msg.event, msg.event === 'stopped' ? JSON.stringify(msg.body) : '');

    if (msg.event === 'initialized') {
        // VS Code order: setBreakpoints per file, then configurationDone
        request('setBreakpoints', {
            source: { name: 'app.lua', path: BP_PATH },
            breakpoints: [{ line: BP_LINE }],
            lines: [BP_LINE],
        });
        request('setBreakpoints', {
            source: { name: 'main.lua', path: MAIN_BP_PATH },
            breakpoints: [{ line: MAIN_BP_LINE }],
            lines: [MAIN_BP_LINE],
        });
        request('configurationDone', {});
    } else if (msg.event === 'stopped') {
        stoppedCount++;
        request('threads', {});
        request('stackTrace', { threadId: 1 });
        setTimeout(() => request('continue', { threadId: 1 }), 200);
        if (stoppedCount >= 2) finish(true, 'breakpoints hit through real DAP flow');
    } else if (msg.event === 'terminated') {
        finish(false, 'game terminated before breakpoint');
    }
}

// VS Code sends initialize, then launch right after the response,
// with setBreakpoints/configurationDone following the initialized event.
request('initialize', { clientID: 'vscode', adapterID: 'love2d', pathFormat: 'path', linesStartAt1: true, columnsStartAt1: true });
request('launch', { type: 'love2d', request: 'launch', name: 'Debug Love2D', projectRoot: PROJECT, lovePath: 'lovec' });

setTimeout(() => finish(false, 'timeout: no breakpoint hit in 30s'), 30000);
