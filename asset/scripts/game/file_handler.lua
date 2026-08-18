---@class (partial) FileHandler: Object
---@overload fun():FileHandler
local FileHandler = Object:extend()

function FileHandler:init()
    self.update_queued = false
    self.force = false
    self.last_sent_stage = STAGES.NONE
    self.last_sent_pause = false
    self.run = false
end

return FileHandler
