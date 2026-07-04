local https = require "https"
if Global.need_update then
    local status_code, body = https.request(
        "https://raw.githubusercontent.com/v012345/LoveTowerAsset/refs/heads/main/asset/scripts/hotfix/Config.lua")
    if status_code == 200 then
        love.filesystem.createDirectory("asset/scripts/hotfix")
        love.filesystem.write("asset/scripts/hotfix/Config.lua", body)
        print("update success",body)
    end
end



local hotfix = require "asset.scripts.hotfix.Hotfix"
local t = 0
function love.load()
    hotfix:load()
end

function love.update(dt)
    hotfix:update(dt)
    t = t + dt * 0.1
    hotfix:setProgress(t)
end

function love.draw()
    hotfix:draw()
end
