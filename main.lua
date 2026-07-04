local https = require "https"
local new_cfg = require "temp.Config"
local old_cfg = require "asset.scripts.hotfix.Config"

-- conf.lua 中下载失败了, 这里也不做处理了, 直接进入游戏
if not new_cfg then
    require "asset.scripts.app.Game"
    return
end


if new_cfg.version > old_cfg.version then
    -- 先下载 Hotfix.lua 文件
    local status_code, body = https.request(
        "https://raw.githubusercontent.com/v012345/LoveTowerAsset/refs/heads/main/asset/scripts/hotfix/Hotfix.lua")
    if status_code == 200 then
        love.filesystem.createDirectory("asset/scripts/hotfix")
        love.filesystem.write("asset/scripts/hotfix/Hotfix.lua", body)
        print("update success", body)
    end
else
    require "asset.scripts.app.Game"
    return
end



local hotfix = require "asset.scripts.hotfix.Hotfix"
local t = 0
function love.load()
    local cfg = require "asset.scripts.hotfix.Config"
    print(cfg.version)
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
