---@class Event : Object
Event = Object:extend()

---@param config EventConfig
---@return nil
function Event:init(config)
    self.trigger = config.trigger or EventTrigger.immediate
    if config.blocking ~= nil then
        self.blocking = config.blocking
    else
        self.blocking = true
    end
    if config.blockable ~= nil then
        self.blockable = config.blockable
    else
        self.blockable = true
    end
    self.complete = false
    self.start_timer = config.start_timer or false
    self.func = config.func or function() return true end
    self.delay = config.delay or 0
    self.no_delete = config.no_delete
    self.created_on_pause = config.pause_force or G.SETTINGS.paused
    self.timer = config.timer or (self.created_on_pause and 'REAL') or 'TOTAL'

    if self.trigger == EventTrigger.ease then
        self.ease = {
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
    if self.trigger == EventTrigger.condition then
        self.condition = {
            ref_table = config.ref_table,
            ref_value = config.ref_value,
            stop_val = config.stop_val,
        }
        self.func = config.func or function() return self.condition.ref_table[self.condition.ref_value] == self.condition.stop_val end
    end
    self.time = G.TIMERS[self.timer]
end

---@param _results EventStatus
---@return nil
function Event:handle(_results)
    _results.blocking, _results.completed = self.blocking, self.complete
    if self.created_on_pause == false and G.SETTINGS.paused then
        _results.pause_skip = true
        return
    end
    if not self.start_timer then
        self.time = G.TIMERS[self.timer]
        self.start_timer = true
    end
    if self.trigger == EventTrigger.after then
        self:after(_results)
    end
    if self.trigger == EventTrigger.ease then
        self:ease(_results)
    end
    if self.trigger == EventTrigger.condition then
        self:condition(_results)
    end
    if self.trigger == EventTrigger.before then
        self:before(_results)
    end
    if self.trigger == EventTrigger.immediate then
        self:immediate(_results)
    end
    if _results.completed then self.complete = true end
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
