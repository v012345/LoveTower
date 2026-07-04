---@class Event : Object
Event = Object:extend()
function Event:init(config)

end

---@class EventManager : Object
EventManager = Object:extend()
function EventManager:init()

end

EventManager.instance = EventManager()
