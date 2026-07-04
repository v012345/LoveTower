local https = require "https"
local new_cfg = require "temp.Config"
local old_cfg = require "asset.scripts.hotfix.Config"
print("new_cfg.version:", new_cfg.version)
print("old_cfg.version:", old_cfg.version)

-- conf.lua 中下载失败了 或 版本号小于旧的版本号, 这里也不做处理了, 直接进入游戏
if new_cfg and new_cfg.version > old_cfg.version then
    -- 先下载 Hotfix.lua 文件
    local status_code, body = https.request(
        "https://raw.githubusercontent.com/v012345/LoveTower/refs/heads/main/asset/scripts/hotfix/Hotfix.lua")
    if status_code == 200 then
        love.filesystem.createDirectory("asset/scripts/hotfix")
        love.filesystem.write("asset/scripts/hotfix/Hotfix.lua", body)
    end
    require "asset.scripts.hotfix.Hotfix"
else
    require "asset.scripts.app.Game"
end
