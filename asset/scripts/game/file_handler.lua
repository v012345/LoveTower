---@class (partial) FileHandler: Object
---@overload fun(app: App):FileHandler
local FileHandler = Object:extend()

---@private
---@param app App
function FileHandler:init(app)
    self.app = app
    self.update_queued = false
    self.force = false
    self.last_sent_stage = STAGES.NONE
    self.last_sent_pause = false
    self.run = false
    self.last_sent_time = 0
end

function FileHandler:is_need_save()
    if self.update_queued then
        if self.force then return true end

        if self.last_sent_stage ~= self.app.STAGE then return true end

        if (self.last_sent_pause ~= self.app.SETTINGS:is_paused()) and self.run then return true end

        if self.last_sent_time < (self.app.TIMERS.UPTIME - self.app.Features:get_save_timer()) then return true end
    end

    return false
end

return FileHandler
