---@class (partial) HttpManager:Object
local HttpManager = Object:extend()

function HttpManager:init()
    self.thread = love.thread.newThread('asset/scripts/game/threads/http.lua')
    self.out_channel = love.thread.getChannel('http_request')
    self.in_channel = love.thread.getChannel('http_response')
end

---启动存档管理器
---@param cb? function 进度回调
function HttpManager:boot(cb)
    self.thread:start()
end

return HttpManager
