local new_cfg = require "temp.Config"
if new_cfg then
    print("download new Hotfix.lua")
end

local hotfix = require "asset.scripts.hotfix.Hotfix"
local t = 0
local https = require "https"
print(love.filesystem.createDirectory("asset/scripts/hotfix"))
function love.load()
    hotfix:load()
    if new_cfg then
        local status_code, body = https.request(
            "https://raw.githubusercontent.com/v012345/LoveTowerAsset/refs/heads/main/asset/scripts/hotfix/Config.lua")
        print(status_code, body)
        if status_code == 200 then
            -- print(love.filesystem.getInfo("asset/scripts/hotfix", "directory"))
            print(love.filesystem.createDirectory("asset/scripts/hotfix"))

            love.filesystem.write("asset/scripts/hotfix/Config.lua", body)
        end
    end
end

function love.update(dt)
    hotfix:update(dt)
    t = t + dt * 0.1
    hotfix:setProgress(t)
end

function love.draw()
    hotfix:draw()
end
