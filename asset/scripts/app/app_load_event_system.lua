function App:load_event_system(event_system)
    self.event_system = event_system
    self.get_event_system = function()
        return self.event_system
    end
end

function App:get_event_system()
    error("event system is not loaded")
end
