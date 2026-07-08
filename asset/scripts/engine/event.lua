---@class Event : Object
Event = Object:extend()

---@param config EventConfig|nil
---@return nil
function Event:init(config)
    config = config or {}
    self.trigger = config.trigger or Event.immediate
    self.func = config.func or function() return true end
    self.timer = config.timer or Timer.instance:getTotalTimer()
    self.time = self:timer()
    self.blocking = config.blocking or true
    self.blockable = config.blockable or true
    self.complete = false
    self.start_timer = config.start_timer or false
    self.delay = config.delay or 0
    self.no_delete = config.no_delete
    self.created_on_pause = config.pause_force or G.SETTINGS.paused
    self.ease_params = {
        type = config.ease or 'lerp',
        ref_table = config.ref_table,
        ref_value = config.ref_value,
        start_val = config.start_val,
        end_val = config.ease_to,
        start_time = nil,
        end_time = nil,
    }
    self.condition_params = {
        ref_table = config.ref_table,
        ref_value = config.ref_value,
        stop_val = config.stop_val,
    }
end

---@param status EventStatus
---@return nil
function Event:handle(status)
    status.blocking, status.completed = self.blocking, self.complete
    self:trigger(status)
    self.complete = status.completed
end

---@private
---@param status EventStatus
---@return nil
function Event:immediate(status)
    status.completed = self.func()
    status.time_done = true
end

---@private
---@param status EventStatus
---@return nil
function Event:after(status)
    if self.time + self.delay <= self:timer() then
        status.time_done = true
        status.completed = self.func()
    end
end

---@private
---@param status EventStatus
---@return nil
function Event:ease(status)
    if not self.ease.start_time then
        self.ease.start_time = self:timer()
        self.ease.end_time = self:timer() + self.delay
        self.ease.start_val = self.ease.ref_table[self.ease.ref_value]
    end
    if not self.complete then
        if self.ease.end_time >= self:timer() then
            local percent_done = ((self.ease.end_time - self:timer()) / (self.ease.end_time - self.ease.start_time))

            if self.ease.type == 'lerp' then
                self.ease.ref_table[self.ease.ref_value] = self.func(percent_done * self.ease.start_val + (1 - percent_done) * self.ease.end_val)
            end
            if self.ease.type == 'elastic' then
                percent_done = -math.pow(2, 10 * percent_done - 10) * math.sin((percent_done * 10 - 10.75) * 2 * math.pi / 3);
                self.ease.ref_table[self.ease.ref_value] = self.func(percent_done * self.ease.start_val + (1 - percent_done) * self.ease.end_val)
            end
            if self.ease.type == 'quad' then
                percent_done = percent_done * percent_done;
                self.ease.ref_table[self.ease.ref_value] = self.func(percent_done * self.ease.start_val + (1 - percent_done) * self.ease.end_val)
            end
        else
            self.ease.ref_table[self.ease.ref_value] = self.func(self.ease.end_val)
            self.complete = true
            status.completed = true
            status.time_done = true
        end
    end
end

---@private
---@param status EventStatus
---@return nil
function Event:condition(status)
    if not self.complete then status.completed = self.func() end
    status.time_done = true
end

---@private
---@param status EventStatus
---@return nil
function Event:before(status)
    if not self.complete then status.completed = self.func() end
    if self.time + self.delay <= self:timer() then
        status.time_done = true
    end
end
