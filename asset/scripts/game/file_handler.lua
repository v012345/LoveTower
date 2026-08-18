---@class (partial) FileHandler: Object
---@overload fun(app: App):FileHandler
local FileHandler = Object:extend()

---@param app App
function FileHandler:init(app)
    self.app = app
    self.update_queued = false
    self.force = false
    self.last_sent_stage = STAGES.NONE
    self.last_sent_pause = false
    self.run = false
end

return FileHandler
