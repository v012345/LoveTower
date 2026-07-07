package.cpath = package.cpath .. ";c:/Users/NightOwl/.vscode/extensions/tangzx.emmylua-0.9.39-win32-x64/debugger/emmy/windows/x64/?.dll"
local dbg = require("emmy_core")
dbg.tcpListen("localhost", 9966)
require "asset.scripts.enum"
require "asset.scripts.engine"
require "bit"
require "asset.scripts.functions.misc_functions"
require "asset.scripts.functions.UI_definitions"
require "asset.scripts.main.app"

function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
    -- We don't want the first frame's dt to include time taken by love.load.
    love.timer.step()
    local dt = 0
    local dt_smooth = 1 / 100
    local run_time = 0
    -- Main loop time.
    return function()
        run_time = love.timer.getTime()
        love.event.pump()
        local _n, _a, _b, _c, _d, _e, _f, touched
        for name, a, b, c, d, e, f in love.event.poll() do
            if name == "quit" then
                if not love.quit or not love.quit() then
                    return a or 0
                end
            end
            if name == 'touchpressed' then
                touched = true
            elseif name == 'mousepressed' then
                _n, _a, _b, _c, _d, _e, _f = name, a, b, c, d, e, f
            else
                love.handlers[name](a, b, c, d, e, f)
            end
        end
        if _n then
            love.handlers.mousepressed(_a, _b, _c, touched)
        end
        dt = love.timer.step()
        dt_smooth = math.min(0.8 * dt_smooth + 0.2 * dt, 0.1)
        love.update(dt_smooth)
        if love.graphics.isActive() then
            love.draw()
            love.graphics.present()
        end

        run_time = math.min(love.timer.getTime() - run_time, 0.1)

        if run_time < 0.002 then love.timer.sleep(0.002 - run_time) end
    end
end

---@param ... any
function love.load(...)
    -- App.instance:start_up()
end

function love.update(dt)
    -- App.instance:update(dt)
end

function love.draw()
    -- App.instance:draw()
end

function love.keypressed(key)
    print(key)
end

function love.keyreleased(key)
    print(key)
end

function love.mousepressed(x, y, button, touch)
    print(x, y, button, touch)
end

function love.mousereleased(x, y, button)
    print(x, y, button)
end

function love.mousemoved(x, y, dx, dy, istouch)
    print(x, y, dx, dy, istouch)
end

function love.resize(w, h)

end
