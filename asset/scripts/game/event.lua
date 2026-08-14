---@class Event : Object
Event = Object:extend()

---@param config EventConfig|nil
---@return nil
function Event:init(config)
    config = config or {}
    self.trigger = config.trigger or Event.immediate
    self.func = config.func or function() return true end
    self.timer = config.timer or Timer.instance:get_total_timer()
    self.time = self:timer()
    self.blocking = config.blocking or true
    self.blockable = config.blockable
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

---如果 time_done 和 completed 都为 true，则认为事件已经完成, 会从队列中移除
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

---条件触发器不关心时间，只要条件没有达成，就会每帧触发。
---@private
---@param status EventStatus
---@return nil
function Event:condition(status)
    if not self.complete then status.completed = self.func() end
    status.time_done = true
end

--- After event will trigger after the delay time.
---@private
---@param status EventStatus
---@return nil
function Event:after(status)
    if self.time + self.delay <= self.timer() then
        status.time_done = true
        status.completed = self.func()
    end
end

---立即执行 func，等 delay 后才移除（可阻塞后续事件）
---@private
---@param status EventStatus
---@return nil
function Event:before(status)
    if not self.complete then status.completed = self.func() end
    if self.time + self.delay <= self:timer() then
        status.time_done = true
    end
end

---@private
---@param status EventStatus
---@return nil
function Event:ease(status)
    if not self.ease.start_time then
        self.ease.start_time = self.timer()
        self.ease.end_time = self.timer() + self.delay
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
