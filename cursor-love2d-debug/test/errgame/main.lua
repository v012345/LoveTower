if os.getenv("LOVE_DEBUGGER") then
    local f = assert(io.open(os.getenv("LOVE_DEBUGGER"), "r"))
    local src = f:read("*a")
    f:close()
    assert(loadstring(src, "@debugger.lua"))()
end

local t = 0
local cfg = { 10, 20, name = "tower", nested = { x = 1, y = 2 } }
function love.update(dt)
    t = t + dt + (cfg.nested.x - 1)
    if t > 1 then
        crash_here() -- undefined global -> runtime error
    end
end
