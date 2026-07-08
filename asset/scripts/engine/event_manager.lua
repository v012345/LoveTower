---@class EventManager : Object
EventManager = Object:extend()

---@private
---@return nil
function EventManager:init()
    self.queues = {
        unlock = {},
        base = {},
        tutorial = {},
        achievement = {},
        other = {}
    }
    self.status = {
        blocking = false,
        completed = false,
        time_done = false,
        pause_skip = false
    }
    self.queue_timer = Timer.instance.REAL
    self.queue_dt = 1 / 60
    self.queue_last_processed = Timer.instance.REAL
end

---@private
---@return nil
function EventManager:reset_status()
    self.status.blocking = false
    self.status.completed = false
    self.status.time_done = false
    self.status.pause_skip = false
end

---comment
---@param event Event
---@param queue "unlock" | "base" | "tutorial" | "achievement" | "other"
---@param front boolean
function EventManager:add_event(event, queue, front)
    if event:is(Event) then
        if front then
            table.insert(self.queues[queue], 1, event)
        else
            self.queues[queue][#self.queues[queue] + 1] = event
        end
    end
end

function EventManager:clear_queue(queue, exception)
    if not queue then
        --clear all queues
        for k, v in pairs(self.queues) do
            local i = 1
            while i <= #v do
                if not v[i].no_delete then
                    table.remove(v, i) -- remove 可以避免索引错乱
                else
                    i = i + 1
                end
            end
        end
    elseif exception then --clear all but exception
        for k, v in pairs(self.queues) do
            if k ~= exception then
                local i = 1
                while i <= #v do
                    if not v[i].no_delete then
                        table.remove(v, i)
                    else
                        i = i + 1
                    end
                end
            end
        end
    else
        local i = 1
        while i <= #self.queues[queue] do
            if not self.queues[queue][i].no_delete then
                table.remove(self.queues[queue], i)
            else
                i = i + 1
            end
        end
    end
end

function EventManager:update(dt, forced)
    self.queue_timer = self.queue_timer + dt
    if self.queue_timer >= self.queue_last_processed + self.queue_dt or forced then
        self.queue_last_processed = self.queue_last_processed + (forced and 0 or self.queue_dt)
        for k, v in pairs(self.queues) do
            local blocked = false
            local i = 1
            while i <= #v do
                self:reset_status()
                local results = self.status
                if (not blocked or not v[i].blockable) then v[i]:handle(results) end
                if results.pause_skip then
                    i = i + 1
                else
                    if not blocked and results.blocking then blocked = true end
                    if results.completed and results.time_done then
                        table.remove(v, i)
                    else
                        i = i + 1
                    end
                end
            end
        end
    end
end
