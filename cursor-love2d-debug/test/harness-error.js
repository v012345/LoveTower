// Verify break-on-error: run errgame, expect a stopped event with
// reason "exception" pointing at the crash line in main.lua.
const net = require('net');
const path = require('path');
const { spawn } = require('child_process');

const PORT = 56791;
const PROJECT = path.resolve(__dirname, 'errgame');
const DEBUGGER_LUA = path.resolve(__dirname, '..', 'lua', 'debugger.lua');
const LOVE = 'C:/Program Files/LOVE/lovec.exe';

let game;
let failed = false;

function cleanup(code) {
    if (game && !game.killed) game.kill();
    setTimeout(() => process.exit(code), 500);
}

let seq = 0;
const pending = new Map();

const server = net.createServer((sock) => {
    let buf = '';
    const send = (msg) => sock.write(JSON.stringify(msg) + '\n');
    const request = (msg) =>
        new Promise((resolve) => {
            const s = ++seq;
            pending.set(s, resolve);
            send({ ...msg, seq: s });
        });

    async function onStopped(msg) {
        const top = msg.frames && msg.frames[0];
        console.log(`stopped: reason=${msg.reason} text=${msg.text} top=${top && top.source}:${top && top.line}`);
        if (!(msg.reason === 'exception' && /crash_here/.test(msg.text || '') && top && top.line === 13)) {
            console.error('FAIL: unexpected stop');
            return cleanup(1);
        }
        // expand upvalues -> find cfg table -> expand it -> expand nested
        const ups = await request({ command: 'variables', ref: top.upvaluesRef });
        const cfg = ups.variables.find((v) => v.name === 'cfg');
        if (!cfg || !cfg.ref) { console.error('FAIL: cfg upvalue missing/not expandable'); return cleanup(1); }
        const cfgVars = (await request({ command: 'variables', ref: cfg.ref })).variables;
        console.log('cfg =', cfgVars.map((v) => `${v.name}=${v.value}`).join(', '));
        const names = cfgVars.map((v) => v.name);
        if (!(names.includes('[1]') && names.includes('[2]') && names.includes('name') && names.includes('nested'))) {
            console.error('FAIL: cfg entries wrong');
            return cleanup(1);
        }
        const nested = cfgVars.find((v) => v.name === 'nested');
        const nestedVars = (await request({ command: 'variables', ref: nested.ref })).variables;
        console.log('cfg.nested =', nestedVars.map((v) => `${v.name}=${v.value}`).join(', '));
        if (nestedVars.length !== 2) { console.error('FAIL: nested expand wrong'); return cleanup(1); }
        console.log('PASS: exception break + table expansion work');
        cleanup(0);
    }

    sock.on('data', (d) => {
        buf += d.toString('utf8');
        let idx;
        while ((idx = buf.indexOf('\n')) >= 0) {
            const line = buf.slice(0, idx);
            buf = buf.slice(idx + 1);
            if (!line.trim()) continue;
            const msg = JSON.parse(line);
            if (msg.event === 'connected') {
                send({ command: 'start', stopOnEntry: false });
            } else if (msg.event === 'reply') {
                const r = pending.get(msg.seq);
                if (r) { pending.delete(msg.seq); r(msg); }
            } else if (msg.event === 'stopped') {
                onStopped(msg).catch((e) => { console.error('FAIL: ' + e.message); cleanup(1); });
            }
        }
    });
    sock.on('error', () => {});
});

server.listen(PORT, '127.0.0.1', () => {
    game = spawn(LOVE, [PROJECT], {
        cwd: PROJECT,
        env: { ...process.env, LOVE_DEBUGGER: DEBUGGER_LUA, LOVE_DEBUGGER_PORT: String(PORT) },
    });
    game.stderr.on('data', (d) => process.stderr.write('[game:err] ' + d.toString()));
    game.on('exit', (code) => console.log('game exited ' + code));
});

setTimeout(() => { console.error('FAIL: timeout'); cleanup(1); }, 20000);
