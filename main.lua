-- require "temp.temp"

-- 调试器注入：仅在通过 Cursor 的 Love2D 调试插件启动时生效
local debugger_path = os.getenv("LOVE_DEBUGGER")
print(debugger_path)
if debugger_path then
    local f = assert(io.open(debugger_path, "r"))
    local src = f:read("*a")
    f:close()
    assert(loadstring(src, "@debugger.lua"))()
end

xpcall(function()
    require "tools.lua_table_to_csv"
end, function(err)
    print(err)
end)

local seed = os.time()
math.randomseed(seed)
love.filesystem.write("seed.md", tostring(seed))

require "asset.scripts.app"

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
function love.load(...) App:load(...) end

function love.update(dt) App:update(dt) end

function love.draw() App:draw() end

function love.keypressed(key) App:keypressed(key) end

function love.keyreleased(key) App:keyreleased(key) end

function love.mousepressed(x, y, button, touch) App:mousepressed(x, y, button, touch) end

function love.mousereleased(x, y, button) App:mousereleased(x, y, button) end

function love.mousemoved(x, y, dx, dy, istouch) App:mousemoved(x, y, dx, dy, istouch) end
