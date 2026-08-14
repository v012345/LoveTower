---@class (partial) SoundManager:Object
local SoundManager = Object:extend()

function SoundManager:init()

end

---启动声音管理器
---@param cb? function 声音加载进度回调
function SoundManager:boot(cb)
    self.SOUND_MANAGER = {
        thread = love.thread.newThread('asset/scripts/game/sound_manager.lua'),
        channel = love.thread.getChannel('sound_request'),
        load_channel = love.thread.getChannel('load_channel')
    }
    self.SOUND_MANAGER.thread:start(1)
    -- print("start sound manager")
    Log:info("start sound manager")

    local sound_loaded, prev_file = false, 'none'
    -- while not sound_loaded and false do
    while not sound_loaded do
        -- Monitor the channel for any new requests
        -- local request = self.SOUND_MANAGER.load_channel:pop() -- Value from channel
        local request = self.SOUND_MANAGER.load_channel:demand() -- Value from channel
        -- Log:info("request", request)
        if request then
            -- If the request is for an update to the music track, handle it here
            if request == 'finished' then
                sound_loaded = true
            else
                cb and cb()
                prev_file = request
            end
        end
        -- love.timer.sleep(0.001)
    end
end

return SoundManager
