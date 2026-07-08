--- 说明:



---@class EventManager : Object
---@field private queues table<string, Event[]>
---@field private status EventStatus
---@field private queue_dt number
---@field private queue_last_processed number
---@field private queue_timer number
---@field private reset_status function
---@field public clear_queue function
---@field public update function
---@field public process_queue function
---@field public init function
EventManager = Object:extend()


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

---@return EventStatus
function EventManager:reset_status()
    self.status.blocking = false
    self.status.completed = false
    self.status.time_done = false
    self.status.pause_skip = false
    return self.status
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

---不要手动调用, 由 App 调用
---@public
---@param dt number
---@return nil
function EventManager:update(dt)
    self.queue_timer = self.queue_timer + dt
    local next_process_time = self.queue_last_processed + self.queue_dt
    if self.queue_timer >= next_process_time then
        self.queue_last_processed = next_process_time
        self:process_queue()
    end
end

---可以手动调用, 来强制处理队列
---@public
---@return nil
function EventManager:process_queue()
    for _, queue in pairs(self.queues) do
        local blocked = false
        local i = 1
        while i <= #queue do
            local results = self:reset_status()
            if (not blocked or not queue[i].blockable) then
                queue[i]:handle(results)
            end
            if not blocked and results.blocking then
                blocked = true
            end
            if results.completed and results.time_done then
                table.remove(queue, i)
            else
                i = i + 1
            end
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
