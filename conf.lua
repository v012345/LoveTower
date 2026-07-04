-- 第一步, 创建临时目录
if not love.filesystem.getInfo("temp", "directory") then
    if love.filesystem.getInfo("temp") then
        love.filesystem.remove("temp")
    end
    if not love.filesystem.createDirectory("temp") then
        print("create temp directory failed")
    end
end


local url = "https://raw.githubusercontent.com/v012345/LoveTowerAsset/refs/heads/main/"
-- love.filesystem.remove("asset")
local cfg = require "asset.scripts.hotfix.Config"
local https = require("https")
local new_cfg_url = url .. "asset/scripts/hotfix/Config.lua"
local status_code, body = https.request(new_cfg_url)
if status_code == 200 then
    -- loadstring 与 load 有版本问题, 这个不使用了, 使用 require 代替
    if not love.filesystem.write("temp/Config.lua", body) then
        print("write temp/Config.lua failed")
        return
    end

    local new_cfg = require "temp.Config"
    if new_cfg.version > cfg.version then
        print("need update")
        cfg = new_cfg
    end
end


function love.conf(t)
    t.window.title = cfg.window.title
    t.window.width = cfg.window.width
    t.window.height = cfg.window.height
    t.window.vsync = cfg.window.vsync
    t.console = cfg.console

    t.modules.joystick = cfg.modules.joystick
    t.modules.physics = cfg.modules.physics
end
