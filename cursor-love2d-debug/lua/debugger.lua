-- Love2D debugger runtime (game side)
-- Injected via LOVE_DEBUGGER env var, loaded at the top of main.lua.
-- Talks to the debug adapter over TCP using newline-delimited JSON.

local port = tonumber(os.getenv("LOVE_DEBUGGER_PORT")) or 56789
local socket = require("socket")

-- Line hooks never fire inside JIT-compiled traces, so JIT must stay off
-- for the whole debug session.
if jit then jit.off() end

-- stdout is piped to the adapter; without this, print() output would sit in
-- a 4KB buffer and appear in the debug console with a long delay
pcall(function() io.stdout:setvbuf("no") end)

--------------------------------------------------------------------------
-- Minimal JSON (encode + decode), enough for the debugger protocol
--------------------------------------------------------------------------
local json = {}
do
    local escape_map = {
        ['"'] = '\\"', ["\\"] = "\\\\", ["\b"] = "\\b", ["\f"] = "\\f",
        ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t",
    }
    local function escape_char(c)
        return escape_map[c] or string.format("\\u%04x", c:byte())
    end
    local function encode_string(s)
        return '"' .. s:gsub('[%c"\\]', escape_char) .. '"'
    end
    local function is_array(t)
        local n = 0
        for k in pairs(t) do
            if type(k) ~= "number" then return false end
            n = n + 1
        end
        return n == #t
    end

    function json.encode(v)
        local tv = type(v)
        if v == nil then
            return "null"
        elseif tv == "boolean" then
            return tostring(v)
        elseif tv == "number" then
            if v ~= v or v == math.huge or v == -math.huge then return "null" end
            return string.format("%.14g", v)
        elseif tv == "string" then
            return encode_string(v)
        elseif tv == "table" then
            local parts = {}
            if is_array(v) then
                for i = 1, #v do parts[#parts + 1] = json.encode(v[i]) end
                return "[" .. table.concat(parts, ",") .. "]"
            end
            for k, val in pairs(v) do
                parts[#parts + 1] = encode_string(tostring(k)) .. ":" .. json.encode(val)
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
        return "null"
    end

    local str, pos

    local function skip_ws()
        pos = str:find("[^ \t\r\n]", pos) or #str + 1
    end

    local function utf8_char(code)
        if code < 0x80 then
            return string.char(code)
        elseif code < 0x800 then
            return string.char(0xC0 + math.floor(code / 0x40), 0x80 + code % 0x40)
        else
            return string.char(
                0xE0 + math.floor(code / 0x1000),
                0x80 + math.floor(code / 0x40) % 0x40,
                0x80 + code % 0x40)
        end
    end

    local decode_value

    local function decode_string()
        local out, i = {}, pos + 1
        while true do
            local c = str:sub(i, i)
            if c == "" then error("unterminated string") end
            if c == '"' then
                pos = i + 1
                break
            elseif c == "\\" then
                local esc = str:sub(i + 1, i + 1)
                if esc == "u" then
                    out[#out + 1] = utf8_char(tonumber(str:sub(i + 2, i + 5), 16) or 0x3F)
                    i = i + 6
                else
                    local map = { b = "\b", f = "\f", n = "\n", r = "\r", t = "\t" }
                    out[#out + 1] = map[esc] or esc
                    i = i + 2
                end
            else
                out[#out + 1] = c
                i = i + 1
            end
        end
        return table.concat(out)
    end

    local function decode_number()
        local num = str:match("^-?%d+%.?%d*[eE]?[%+%-]?%d*", pos)
        pos = pos + #num
        return tonumber(num)
    end

    local function decode_array()
        local arr = {}
        pos = pos + 1
        skip_ws()
        if str:sub(pos, pos) == "]" then pos = pos + 1 return arr end
        while true do
            arr[#arr + 1] = decode_value()
            skip_ws()
            local c = str:sub(pos, pos)
            pos = pos + 1
            if c == "]" then break end
            if c ~= "," then error("expected , or ] in array") end
            skip_ws()
        end
        return arr
    end

    local function decode_object()
        local obj = {}
        pos = pos + 1
        skip_ws()
        if str:sub(pos, pos) == "}" then pos = pos + 1 return obj end
        while true do
            if str:sub(pos, pos) ~= '"' then error("expected string key") end
            local key = decode_string()
            skip_ws()
            if str:sub(pos, pos) ~= ":" then error("expected :") end
            pos = pos + 1
            skip_ws()
            obj[key] = decode_value()
            skip_ws()
            local c = str:sub(pos, pos)
            pos = pos + 1
            if c == "}" then break end
            if c ~= "," then error("expected , or } in object") end
            skip_ws()
        end
        return obj
    end

    decode_value = function()
        local c = str:sub(pos, pos)
        if c == '"' then return decode_string() end
        if c == "{" then return decode_object() end
        if c == "[" then return decode_array() end
        if c == "t" then pos = pos + 4 return true end
        if c == "f" then pos = pos + 5 return false end
        if c == "n" then pos = pos + 4 return nil end
        return decode_number()
    end

    function json.decode(s)
        str, pos = s, 1
        skip_ws()
        local ok, result = pcall(decode_value)
        str = nil
        if not ok then return nil end
        return result
    end
end

--------------------------------------------------------------------------
-- Connection
--------------------------------------------------------------------------
local sock = socket.tcp()
sock:settimeout(3)
local ok, err = sock:connect("127.0.0.1", port)
if not ok then
    print("[love2d-debug] cannot connect to adapter on port " .. port .. ": " .. tostring(err))
    return
end
sock:setoption("tcp-nodelay", true)

local function send(msg)
    sock:send(json.encode(msg) .. "\n")
end

local partial_buf = ""
-- timeout: number of seconds, or nil for blocking
local function receive_msg(timeout)
    sock:settimeout(timeout)
    local line, rerr, partial = sock:receive("*l", partial_buf)
    if line then
        partial_buf = ""
        return json.decode(line)
    end
    if rerr == "timeout" then
        partial_buf = partial or ""
        return nil
    end
    return nil, rerr -- closed / other error
end

--------------------------------------------------------------------------
-- Breakpoints
--------------------------------------------------------------------------
-- breakpoints[normalized_source][line] = true
local breakpoints = {}
-- quick reject: any breakpoint on this line number in any file?
local bp_lines = {}
local bp_count = 0

-- Sources arrive from the adapter already normalized: relative to project
-- root, forward slashes, lowercase. Love chunk names look like
-- "@asset/scripts/game.lua"; normalize the same way for matching.
local source_cache = {}
local function normalize_source(source)
    local cached = source_cache[source]
    if cached then return cached end
    local s = source
    if s:sub(1, 1) == "@" then s = s:sub(2) end
    s = s:gsub("\\", "/"):lower()
    source_cache[source] = s
    return s
end

local function rebuild_bp_lines()
    bp_lines = {}
    bp_count = 0
    for _, lines in pairs(breakpoints) do
        for line in pairs(lines) do
            bp_lines[line] = true
            bp_count = bp_count + 1
        end
    end
end

local function set_breakpoints(source, lines)
    if #lines == 0 then
        breakpoints[source] = nil
    else
        local t = {}
        for _, l in ipairs(lines) do t[l] = true end
        breakpoints[source] = t
    end
    rebuild_bp_lines()
end

--------------------------------------------------------------------------
-- Variable registry (valid only while paused)
--------------------------------------------------------------------------
local registry = {} -- ref id -> { kind = "varlist"|"table", ... }
local next_ref = 0

local function register(entry)
    next_ref = next_ref + 1
    registry[next_ref] = entry
    return next_ref
end

local function clear_registry()
    registry = {}
    next_ref = 0
end

local function describe(v)
    local tv = type(v)
    local ok, s = pcall(tostring, v)
    s = ok and s or "<tostring error>"
    if tv == "string" then
        if #s > 200 then s = s:sub(1, 200) .. "..." end
        s = '"' .. s .. '"'
    end
    local ref = 0
    if tv == "table" then
        ref = register({ kind = "table", value = v })
    end
    return { value = s, type = tv, ref = ref }
end

local function var_entry(name, value)
    local d = describe(value)
    return { name = name, value = d.value, type = d.type, ref = d.ref }
end

-- Serve a "variables" request for a registered reference
local function get_variables(ref)
    local entry = registry[ref]
    local vars = {}
    if not entry then return vars end

    if entry.kind == "varlist" then
        for _, item in ipairs(entry.list) do
            vars[#vars + 1] = var_entry(item.name, item.value)
        end
    elseif entry.kind == "table" then
        local t = entry.value
        local count = 0
        local array_len = #t
        for i = 1, array_len do
            vars[#vars + 1] = var_entry("[" .. i .. "]", t[i])
            count = count + 1
            if count >= 500 then break end
        end
        if count < 500 then
            -- non-array keys, sorted for stable display
            local keys = {}
            for k in pairs(t) do
                local is_arr = type(k) == "number" and k >= 1 and k <= array_len and k % 1 == 0
                if not is_arr then keys[#keys + 1] = k end
            end
            pcall(table.sort, keys, function(a, b) return tostring(a) < tostring(b) end)
            for _, k in ipairs(keys) do
                local name = type(k) == "string" and k or "[" .. tostring(k) .. "]"
                vars[#vars + 1] = var_entry(name, t[k])
                count = count + 1
                if count >= 500 then
                    vars[#vars + 1] = { name = "...", value = "(truncated at 500 entries)", type = "", ref = 0 }
                    break
                end
            end
        end
    end
    return vars
end

--------------------------------------------------------------------------
-- Stack collection (frames + eagerly captured locals/upvalues)
--------------------------------------------------------------------------
-- start_level is relative to the caller of collect_stack
local function collect_stack(start_level)
    local frames = {}
    local level = start_level + 1 -- account for collect_stack itself
    while #frames < 128 do
        local info = debug.getinfo(level, "Slnf")
        if not info then break end

        local locals = {}
        local j = 1
        while true do
            local name, value = debug.getlocal(level, j)
            if not name then break end
            -- skip internal temporaries like "(for index)"
            if name:sub(1, 1) ~= "(" then
                locals[#locals + 1] = { name = name, value = value }
            end
            j = j + 1
        end

        local upvalues = {}
        if info.func then
            local k = 1
            while true do
                local name, value = debug.getupvalue(info.func, k)
                if not name then break end
                upvalues[#upvalues + 1] = { name = name, value = value }
                k = k + 1
            end
        end

        frames[#frames + 1] = {
            name = info.name or (info.what == "main" and "(main chunk)" or "(anonymous)"),
            source = info.source or "?",
            line = info.currentline or 0,
            localsRef = register({ kind = "varlist", list = locals }),
            upvaluesRef = #upvalues > 0 and register({ kind = "varlist", list = upvalues }) or 0,
        }
        level = level + 1
    end
    return frames
end

--------------------------------------------------------------------------
-- Pause loop: block the game and serve adapter commands
--------------------------------------------------------------------------
local detached = false

local function detach()
    if detached then return end
    detached = true
    debug.sethook()
    pcall(function() sock:close() end)
    print("[love2d-debug] detached")
end

local handle_command -- forward declaration

-- Stepping state
local step_mode = nil -- nil | "in" | "over" | "out"
local step_depth = 0

-- After resuming, LuaJIT fires the line event for the pause position a
-- second time; remember where we paused so that event can be ignored.
local just_resumed = false
local last_pause_source = nil
local last_pause_line = nil

-- stack_offset: levels between the paused game code and this function's caller
-- trim_internal: drop leading non-game frames (love internals / C) so the
-- top frame points at actual game code (used for error breaks)
local function pause(reason, stack_offset, text, trim_internal)
    step_mode = nil
    local frames = collect_stack(stack_offset + 1)
    if trim_internal then
        while #frames > 1 and frames[1].source:sub(1, 1) ~= "@" do
            table.remove(frames, 1)
        end
    end
    if frames[1] then
        last_pause_source = frames[1].source
        last_pause_line = frames[1].line
    end
    send({ event = "stopped", reason = reason, frames = frames, text = text })
    while true do
        local msg, rerr = receive_msg(nil)
        if rerr then
            detach()
            return
        end
        if msg then
            local action = handle_command(msg)
            if action == "resume" then break end
        end
    end
    just_resumed = true
    clear_registry()
end

handle_command = function(msg)
    local cmd = msg.command
    if cmd == "setBreakpoints" then
        set_breakpoints(msg.source, msg.lines or {})
    elseif cmd == "continue" then
        return "resume"
    elseif cmd == "stepIn" then
        step_mode = "in"
        return "resume"
    elseif cmd == "next" then
        step_mode = "over"
        step_depth = 0
        return "resume"
    elseif cmd == "stepOut" then
        step_mode = "out"
        step_depth = 0
        return "resume"
    elseif cmd == "variables" then
        send({ event = "reply", seq = msg.seq, variables = get_variables(msg.ref) })
    elseif cmd == "pause" then
        return "pause"
    end
end

--------------------------------------------------------------------------
-- Break on runtime errors: wrap love.errorhandler. The message handler
-- runs before the stack unwinds, so the full stack is still inspectable.
-- The game may install its own handler at any time, so re-wrap whenever
-- the current handler is not ours.
--------------------------------------------------------------------------
local wrapped_handler = nil

local function ensure_error_handler()
    if not love then return end
    local current = love.errorhandler or love.errhand
    if current == wrapped_handler and wrapped_handler ~= nil then return end
    local orig = current
    wrapped_handler = function(msg)
        if not detached then
            debug.sethook() -- no hook events while paused on an error
            pause("exception", 2, tostring(msg), true)
        end
        if orig then return orig(msg) end
    end
    love.errorhandler = wrapped_handler
end

--------------------------------------------------------------------------
-- Debug hook
--------------------------------------------------------------------------
local stop_next_line = false
local poll_counter = 0
local last_poll = 0

local function hook(event, line)
    if event == "call" or event == "tail call" then
        if step_mode == "over" or step_mode == "out" then
            -- LuaJIT fires "call" for C functions but never "return", so
            -- C functions must not be counted towards the depth
            local info = debug.getinfo(2, "S")
            if not info or info.what ~= "C" then
                step_depth = step_depth + 1
            end
        end
        return
    elseif event == "return" or event == "tail return" then
        if step_mode == "over" or step_mode == "out" then
            local info = debug.getinfo(2, "S")
            if not info or info.what ~= "C" then
                step_depth = step_depth - 1
            end
        end
        return
    elseif event ~= "line" then
        return
    end

    if just_resumed then
        just_resumed = false
        if line == last_pause_line then
            local info = debug.getinfo(2, "S")
            if info.source == last_pause_source then
                return -- duplicate line event for the position we paused at
            end
        end
    end

    if stop_next_line then
        stop_next_line = false
        -- caller of hook is the game code: offset 2 = pause caller (hook) + game
        pause("entry", 2)
        return
    end

    -- Breakpoints take priority even while stepping (e.g. stepping over a
    -- call that contains a breakpoint)
    if bp_count > 0 and bp_lines[line] then
        local info = debug.getinfo(2, "S")
        local bps = breakpoints[normalize_source(info.source)]
        if bps and bps[line] then
            pause("breakpoint", 2)
            return
        end
    end

    if step_mode == "in"
        or (step_mode == "over" and step_depth <= 0)
        or (step_mode == "out" and step_depth < 0) then
        pause("step", 2)
        return
    end

    -- Periodically poll for adapter commands (new breakpoints, pause request)
    poll_counter = poll_counter + 1
    if poll_counter >= 2000 then
        poll_counter = 0
        local now = os.clock()
        if now - last_poll >= 0.05 then
            last_poll = now
            ensure_error_handler()
            while true do
                local msg, rerr = receive_msg(0)
                if rerr then
                    detach()
                    return
                end
                if not msg then break end
                local action = handle_command(msg)
                if action == "pause" then
                    pause("pause", 2)
                    return
                end
            end
        end
    end
end

--------------------------------------------------------------------------
-- Handshake: wait for the adapter to send breakpoints and "start"
--------------------------------------------------------------------------
send({ event = "connected" })

while true do
    local msg, rerr = receive_msg(10)
    if rerr then
        print("[love2d-debug] adapter connection lost during handshake")
        detach()
        return
    end
    if msg then
        if msg.command == "start" then
            if msg.stopOnEntry then stop_next_line = true end
            break
        end
        handle_command(msg)
    end
end

ensure_error_handler()
debug.sethook(hook, "crl")
print("[love2d-debug] connected to adapter, debugging active")
