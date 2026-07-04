package.cpath = package.cpath
    .. ";c:/Users/NightOwl/.vscode/extensions/tangzx.emmylua-0.9.39-win32-x64/debugger/emmy/windows/x64/?.dll"
local dbg = require("emmy_core")
-- print("EmmyLua Debugger: game listens on 9966, press F5 in VS Code to attach", dbg)
dbg.tcpListen("localhost", 9965)
-- dbg.tcpListen('localhost', 9966)

local https = require "https"
local new_cfg = require "temp.Config"
local old_cfg = require "asset.scripts.hotfix.Config"
print("new_cfg.version:", new_cfg.version)
print("old_cfg.version:", old_cfg.version)
require "asset.scripts.engine.object"
require "asset.scripts.functions.misc_functions"
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

function love.load()
    App.instance:start_up()
end

function love.update(dt)
    App.instance:update(dt)
end

function love.draw()
    App.instance:draw()
end

-- require "asset.scripts.hotfix.Hotfix"
-- conf.lua 中下载失败了 或 版本号小于旧的版本号, 这里也不做处理了, 直接进入游戏
-- if new_cfg and new_cfg.version > old_cfg.version then
--     -- 先下载 Hotfix.lua 文件
--     local status_code, body = https.request(
--         "https://raw.githubusercontent.com/v012345/LoveTower/refs/heads/main/asset/scripts/hotfix/Hotfix.lua")
--     if status_code == 200 then
--         love.filesystem.createDirectory("asset/scripts/hotfix")
--         love.filesystem.write("asset/scripts/hotfix/Hotfix.lua", body)
--     end
--     require "asset.scripts.hotfix.Hotfix"
-- else
--     require "asset.scripts.app.Game"
-- end
