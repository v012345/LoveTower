
function App:load_event_queue_system(event_queue_manager)
    self.event_queue_manager = event_queue_manager
    self.get_event_queue_manager = function()
        return self.event_queue_manager
    end
end

function App:get_event_queue_manager()
    error("event queue manager is not loaded")
end
