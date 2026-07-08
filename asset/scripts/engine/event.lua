---@class Event : Object
Event = Object:extend()

---@param config EventConfig
---@return Event
function Event:init(config)
    -- assert(config.trigger, "Event trigger is required")
    -- assert(config.timer, "timer is required")
    -- assert(config.func, "func is required")
    self.trigger = config.trigger
    self.timer = config.timer
    self.time = self:timer()
    self.func = config.func
    self.blocking = config.blocking or true
    self.blockable = config.blockable or true
    self.complete = false
    self.start_timer = config.start_timer or false
    self.delay = config.delay or 0
    self.no_delete = config.no_delete
    -- self.created_on_pause = config.pause_force or G.SETTINGS.paused
    if self.trigger == self.ease then
        self.ease_params = {
            type = config.ease or 'lerp',
            ref_table = config.ref_table,
            ref_value = config.ref_value,
            start_val = config.ref_table[config.ref_value],
            end_val = config.ease_to,
            start_time = nil,
            end_time = nil,
        }
        self.func = config.func or function(t) return t end
    end
    if self.trigger == self.condition then
        self.condition_params = {
            ref_table = config.ref_table,
            ref_value = config.ref_value,
            stop_val = config.stop_val,
        }
        self.func = config.func or function() return self.condition_params.ref_table[self.condition_params.ref_value] == self.condition_params.stop_val end
    end
    return self
end

---@param status EventStatus
---@return nil
function Event:handle(status)
    status.blocking, status.completed = self.blocking, self.complete
    if self.created_on_pause == false and G.SETTINGS.paused then
        status.pause_skip = true
        return
    end
    if not self.start_timer then
        self.time = G.TIMERS[self.timer]
        self.start_timer = true
    end
    self:trigger(status)
    if status.completed then self.complete = true end
end

---@private
---@param status EventStatus
---@return nil
function Event:after(status)
    if self.time + self.delay <= G.TIMERS[self.timer] then
        status.time_done = true
        status.completed = self.func()
    end
end

---@private
---@param status EventStatus
---@return nil
function Event:ease(status)
    if not self.ease.start_time then
        self.ease.start_time = G.TIMERS[self.timer]
        self.ease.end_time = G.TIMERS[self.timer] + self.delay
        self.ease.start_val = self.ease.ref_table[self.ease.ref_value]
    end
    if not self.complete then
        if self.ease.end_time >= G.TIMERS[self.timer] then
            local percent_done = ((self.ease.end_time - G.TIMERS[self.timer]) / (self.ease.end_time - self.ease.start_time))

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
    if self.time + self.delay <= G.TIMERS[self.timer] then
        status.time_done = true
    end
end

---@private
---@param status EventStatus
---@return nil
function Event:immediate(status)
    status.completed = self.func()
    status.time_done = true
end
