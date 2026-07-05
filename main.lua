package.cpath = package.cpath ..
";c:/Users/NightOwl/.vscode/extensions/tangzx.emmylua-0.9.39-win32-x64/debugger/emmy/windows/x64/?.dll"
local dbg = require("emmy_core")
dbg.tcpListen("localhost", 9966)
require "asset.scripts.enum"
require "bit"
require "asset.scripts.engine.object"
require "asset.scripts.engine.controller"
require "asset.scripts.functions.misc_functions"
require "asset.scripts.functions.UI_definitions"
require "asset.scripts.main.app"
require "asset.scripts.engine.node"
require "asset.scripts.engine.moveable"
require "asset.scripts.engine.ui"

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

function love.load()
    App.instance:start_up()
end

function love.update(dt)
    App.instance:update(dt)
end

function love.draw()
    App.instance:draw()
end

function love.resize(w, h)
    if w / h < 1 then -- Dont allow the screen to be too square, since pop in occurs above and below screen
        h = w / 1
    end

    -- When the window is resized, this code resizes the Canvas, then places the 'room' or gamearea into the middle without streching it
    if w / h < App.instance.window_prev.orig_ratio then
        App.instance.TILESCALE = App.instance.window_prev.orig_scale * w / App.instance.window_prev.w
    else
        App.instance.TILESCALE = App.instance.window_prev.orig_scale * h / App.instance.window_prev.h
    end

    if App.instance.ROOM then
        App.instance.ROOM.T.w = App.instance.TILE_W
        App.instance.ROOM.T.h = App.instance.TILE_H
        App.instance.ROOM_ATTACH.T.w = App.instance.TILE_W
        App.instance.ROOM_ATTACH.T.h = App.instance.TILE_H

        if w / h < App.instance.window_prev.orig_ratio then
            App.instance.ROOM.T.x = App.instance.ROOM_PADDING_W
            App.instance.ROOM.T.y = (h / (App.instance.TILESIZE * App.instance.TILESCALE) - (App.instance.ROOM.T.h + App.instance.ROOM_PADDING_H)) /
                2 + App.instance.ROOM_PADDING_H / 2
        else
            App.instance.ROOM.T.y = App.instance.ROOM_PADDING_H
            App.instance.ROOM.T.x = (w / (App.instance.TILESIZE * App.instance.TILESCALE) - (App.instance.ROOM.T.w + App.instance.ROOM_PADDING_W)) /
                2 + App.instance.ROOM_PADDING_W / 2
        end

        App.instance.ROOM_ORIG = { x = App.instance.ROOM.T.x, y = App.instance.ROOM.T.y, r = App.instance.ROOM.T.r }

        if App.instance.buttons then App.instance.buttons:recalculate() end
        if App.instance.HUD then App.instance.HUD:recalculate() end
    end

    App.instance.WINDOWTRANS = {
        x = 0,
        y = 0,
        w = App.instance.TILE_W + 2 * App.instance.ROOM_PADDING_W,
        h = App.instance.TILE_H + 2 * App.instance.ROOM_PADDING_H,
        real_window_w = w,
        real_window_h = h
    }

    App.instance.CANV_SCALE = 1

    if love.system.getOS() == 'Windows' and false then -- implement later if needed
        local render_w, render_h = love.window.getDesktopDimensions(App.instance.SETTINGS.WINDOW.selcted_display)
        local unscaled_dims = love.window.getFullscreenModes(App.instance.SETTINGS.WINDOW.selcted_display)[1]

        local DPI_scale = math.floor(
                (0.5 * unscaled_dims.width / render_w + 0.5 * unscaled_dims.height / render_h) * 500 + 0.5
            )
            / 500

        if DPI_scale > 1.1 then
            App.instance.CANV_SCALE = 1.5

            App.instance.AA_CANVAS = love.graphics.newCanvas(
                App.instance.WINDOWTRANS.real_window_w * App.instance.CANV_SCALE, App.instance.WINDOWTRANS
                .real_window_h
                * App.instance.CANV_SCALE, {
                    type = '2d',
                    readable = true
                })
            App.instance.AA_CANVAS:setFilter('linear', 'linear')
        else
            App.instance.AA_CANVAS = nil
        end
    end

    App.instance.CANVAS = love.graphics.newCanvas(w * App.instance.CANV_SCALE, h * App.instance.CANV_SCALE,
        { type = '2d', readable = true })
    App.instance.CANVAS:setFilter('linear', 'linear')
end
