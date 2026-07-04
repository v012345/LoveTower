-- 第一步, 创建临时目录
print(love.filesystem.getSaveDirectory())
if not love.filesystem.getInfo("temp", "directory") then
    if love.filesystem.getInfo("temp") then
        love.filesystem.remove("temp")
    end
    if not love.filesystem.createDirectory("temp") then
        print("create temp directory failed")
    end
end

local https = require("https")
local url = "https://raw.githubusercontent.com/v012345/LoveTower/refs/heads/main/"
local new_cfg_url = url .. "asset/scripts/hotfix/Config.lua"
local status_code, body = https.request(new_cfg_url)
if status_code == 200 then
    love.filesystem.write("temp/Config.lua", body)
end
local cfg = require "temp.Config"

-- 如果temp/Config.lua不存在, 则使用asset.scripts.hotfix.Config.lua
if not cfg then
    cfg = require "asset.scripts.hotfix.Config"
end

-- 这里还有一个, 如果这里有一些用户自己的配置, 那么需要合并到temp/Config.lua中
-- 目前先不管, 之后再说

function love.conf(t)
    t.window.title = cfg.window.title
    t.window.width = cfg.window.width
    t.window.height = cfg.window.height
    t.window.vsync = cfg.window.vsync
    t.console = cfg.console

    t.modules.joystick = cfg.modules.joystick
    t.modules.physics = cfg.modules.physics
end
