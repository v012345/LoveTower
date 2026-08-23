---@class (partial) SaveManager : GameObject
local SaveManager = GameObject:extend()

function SaveManager:init()

end

---启动存档管理器
---@param cb? function 进度回调
function SaveManager:boot(cb)
    self.thread = love.thread.newThread('asset/scripts/game/threads/save.lua')
    self.channel = love.thread.getChannel('save_request')
    self.thread:start(2)
end

return SaveManager
