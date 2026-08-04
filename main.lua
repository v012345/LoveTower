package.cpath = package.cpath .. ";c:/Users/NightOwl/.vscode/extensions/tangzx.emmylua-0.9.40-win32-x64/debugger/emmy/windows/x64/?.dll"
local dbg = require("emmy_core")
dbg.tcpListen("localhost", 9966)

love.timer.sleep(0.1) -- 等待调试器连接




require "bit"
require "asset.scripts.libs"
require "asset.scripts.base"
require "asset.scripts.core"
require "asset.scripts.table"
require "asset.scripts.enum"
require "asset.scripts.engine"
require "asset.scripts.functions.misc_functions"
require "asset.scripts.functions.UI_definitions"
require "asset.scripts.main"

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
    App.instance:start_up()
end

function love.update(dt)
    App.instance:update(dt)
end

function love.draw()
    App.instance:draw()
end

function love.keypressed(key)
    print(key)
end

function love.keyreleased(key)
    print(key)
end

function love.mousepressed(x, y, button, touch)
    print(x, y, button, touch)
    -- print(Timer.instance.TOTAL)
end

function love.mousereleased(x, y, button)
    print(x, y, button)
end

function love.mousemoved(x, y, dx, dy, istouch)
    -- print(x, y, dx, dy, istouch)
end

---也可以手动调用 love.resize(w, h) 来调整窗口大小
---Called when the window is resized, for example if the user resizes the window, or if love.window.setMode is called with an unsupported width or height in fullscreen and the window chooses the closest appropriate size.
---[api reference](https://love2d.org/wiki/love.resize)
---@param w number
---@param h number
function love.resize(w, h)
    assert(h > 0 and w > 0, "Window size must be greater than 0, but got " .. w .. "x" .. h)
    -- 不允许窗口变成竖屏, 因为会出现上下弹出
    --Dont allow the screen to be too square, since pop in occurs above and below screen
    if w < h then h = w end

    -- 宽高比
    local curr_ratio = w / h
    local orig_size = Window.instance:get_orig_size()
    local orig_ratio = Window.instance:get_orig_ratio()
    local orig_tile_scale = Tile.instance:get_init_scale()

    if curr_ratio < orig_ratio then -- 相对变窄了
        Tile.instance:set_scale(orig_tile_scale * w / orig_size.w)
    else                            -- 相对变宽了
        Tile.instance:set_scale(orig_tile_scale * h / orig_size.h)
    end


    App.instance.CANV_SCALE = 1

    local room = Room.instance:get_root_node()
    if room then
        local pixels_per_tile = Tile.instance:get_pixels_per_tile()
        local room_transform = Room.instance:get_transform()
        if curr_ratio < orig_ratio then
            room.T.x = room_transform.x
            room.T.y = (h / (pixels_per_tile) - room_transform.h) / 2
        else
            room.T.y = room_transform.y
            room.T.x = (w / (pixels_per_tile) - room_transform.w) / 2
        end

        -- G.ROOM_ORIG = {
        --     x = G.ROOM.T.x,
        --     y = G.ROOM.T.y,
        --     r = G.ROOM.T.r
        -- }
    end

    Window.instance:set_real_size(w, h)
    App.instance.CANVAS = love.graphics.newCanvas(w * App.instance.CANV_SCALE, h * App.instance.CANV_SCALE, { type = '2d', readable = true })
    App.instance.CANVAS:setFilter('linear', 'linear')
end
