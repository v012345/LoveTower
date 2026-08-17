---@class (partial) Event : Object
Event = Object:extend()

---@enum EventTrigger 触发器函数
EventTrigger = {
    immediate = Event.immediate,
    condition = Event.condition,
    after = Event.after,
    before = Event.before,
    ease = Event.ease,
}

---@private 由 Object 的 __call 方法调用, 不对外
---@param config EventConfig
function Event:init(config)
    self.trigger = config.trigger or EventTrigger.immediate
    self.blocking = config.blocking
    self.blockable = config.blockable
    self.complete = false
    self.start_timer = config.start_timer
    self.func = config.func or function() return true end
    self.delay = config.delay or 0
    self.no_delete = config.no_delete
    self.created_on_pause = config.pause_force or App.SETTINGS:is_paused()
    self.timer = config.timer or (self.created_on_pause and App.TIMERS:get_real_timer()) or App.TIMERS:get_total_timer()

    -- 这两个要特殊处理一个
    if self.trigger == EventTrigger.ease then
        self.ease_params = {
            type = config.ease or 'lerp',
            ref_table = config.ref_table,
            ref_value = config.ref_value,
            start_val = config.start_val,
            end_val = config.ease_to,
            start_time = nil,
            end_time = nil,
        }
        self.func = config.func or function(t) return t end
    elseif self.trigger == EventTrigger.condition then
        self.condition_params = {
            ref_table = config.ref_table,
            ref_value = config.ref_value,
            stop_val = config.stop_val,
        }
        self.func = config.func or function() return self.condition.ref_table[self.condition.ref_value] == self.condition.stop_val end
    end


    self.time = self:timer()
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
    if not self.ease_params.start_time then
        self.ease_params.start_time = self.timer()
        self.ease_params.end_time = self.timer() + self.delay
        self.ease_params.start_val = self.ease_params.ref_table[self.ease_params.ref_value]
    end
    if not self.complete then
        if self.ease_params.end_time >= self:timer() then
            local percent_done = ((self.ease_params.end_time - self:timer()) / (self.ease_params.end_time - self.ease_params.start_time))

            if self.ease_params.type == 'lerp' then
                self.ease_params.ref_table[self.ease_params.ref_value] = self.func(percent_done * self.ease_params.start_val + (1 - percent_done) * self.ease_params.end_val)
            end
            if self.ease_params.type == 'elastic' then
                percent_done = -math.pow(2, 10 * percent_done - 10) * math.sin((percent_done * 10 - 10.75) * 2 * math.pi / 3);
                self.ease_params.ref_table[self.ease_params.ref_value] = self.func(percent_done * self.ease_params.start_val + (1 - percent_done) * self.ease_params.end_val)
            end
            if self.ease_params.type == 'quad' then
                percent_done = percent_done * percent_done;
                self.ease_params.ref_table[self.ease_params.ref_value] = self.func(percent_done * self.ease_params.start_val + (1 - percent_done) * self.ease_params.end_val)
            end
        else
            self.ease_params.ref_table[self.ease_params.ref_value] = self.func(self.ease_params.end_val)
            self.complete = true
            status.completed = true
            status.time_done = true
        end
    end
end

---创建一个事件对象
---@param config? EventConfig
---@return Event
function Event:new(config)
    return Event(config or {})
end
