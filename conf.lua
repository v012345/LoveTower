-- -- 这里可以做点好玩的东西
love.filesystem.remove("asset")
local cfg = require "asset.scripts.hotfix.Love2dConfig"
local https = require("https")
local version = require "asset.scripts.hotfix.Version"
print(version)
local version_url =
"https://raw.githubusercontent.com/v012345/LoveTowerAsset/refs/heads/main/asset/scripts/hotfix/Version.lua"
local config_url =
"https://raw.githubusercontent.com/v012345/LoveTowerAsset/refs/heads/main/asset/scripts/hotfix/Love2dConfig.lua"
local status_code, body = https.request(version_url)
if status_code == 200 then
    if not love.filesystem.getInfo("temp") then
        if not love.filesystem.createDirectory("temp") then
            print("创建目录失败")
        end
    end
    -- loadstring 与 load 有版本问题, 这个不使用了, 使用 require 代替
    if not love.filesystem.write("temp/Version.lua", body) then
        print("写入文件失败")
    end
    local new_version = require "temp.Version"
    if new_version > version then
        print("new_version ~= version")
        local status_code, body = https.request(config_url)
        if status_code == 200 then
            if not love.filesystem.getInfo("temp") then
                if not love.filesystem.createDirectory("temp") then
                    print("创建目录失败")
                end
            end
        end
        if not love.filesystem.write("temp/Love2dConfig.lua", body) then
            print("写入文件失败")
        end
        cfg = require "temp.Love2dConfig"
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
