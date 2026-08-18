-- -- 第一步, 创建临时目录
-- print(love.filesystem.getSaveDirectory())
-- if not love.filesystem.getInfo("temp", "directory") then
--     if love.filesystem.getInfo("temp") then
--         love.filesystem.remove("temp")
--     end
--     if not love.filesystem.createDirectory("temp") then
--         print("create temp directory failed")
--     end
-- end

-- local https = require("https")
-- local url = "https://raw.githubusercontent.com/v012345/LoveTower/refs/heads/main/"
-- local new_cfg_url = url .. "asset/scripts/hotfix/Config.lua"
-- local status_code, body = https.request(new_cfg_url)
-- if status_code == 200 then
--     love.filesystem.write("temp/Config.lua", body)
-- end
-- local cfg = require "temp.Config"

-- -- 如果temp/Config.lua不存在, 则使用asset.scripts.hotfix.Config.lua
-- if not cfg then
--     cfg = require "asset.scripts.hotfix.Config"
-- end

-- 这里还有一个, 如果这里有一些用户自己的配置, 那么需要合并到temp/Config.lua中
-- 目前先不管, 之后再说

_RELEASE_MODE = false
_DEMO = true

function love.conf(t)
    -- t.window.title = cfg.window.title
    -- t.window.width = cfg.window.width
    -- t.window.height = cfg.window.height
    -- t.window.vsync = cfg.window.vsync
    -- t.console = cfg.console

    -- t.modules.joystick = cfg.modules.joystick
    -- t.modules.physics = cfg.modules.physics
    t.window.title = "LoveTower"
    t.console = true
    t.window.width = 500
    t.window.height = 500
    t.window.minwidth = 100
    t.window.minheight = 100

    -- 显式开启模块, 减少代码里的 nil 判断
    t.modules.audio = true    -- Enable the audio module (boolean)
    t.modules.data = true     -- Enable the data module (boolean)
    t.modules.event = true    -- Enable the event module (boolean)
    t.modules.font = true     -- Enable the font module (boolean)
    t.modules.graphics = true -- Enable the graphics module (boolean)
    t.modules.image = true    -- Enable the image module (boolean)
    t.modules.joystick = true -- Enable the joystick module (boolean)
    t.modules.keyboard = true -- Enable the keyboard module (boolean)
    t.modules.math = true     -- Enable the math module (boolean)
    t.modules.mouse = true    -- Enable the mouse module (boolean)
    t.modules.physics = true  -- Enable the physics module (boolean)
    t.modules.sound = true    -- Enable the sound module (boolean)
    t.modules.system = true   -- Enable the system module (boolean)
    t.modules.thread = true   -- Enable the thread module (boolean)
    t.modules.timer = true    -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
    t.modules.touch = true    -- Enable the touch module (boolean)
    t.modules.video = true    -- Enable the video module (boolean)
    t.modules.window = true   -- Enable the window module (boolean)
end
