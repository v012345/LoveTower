function App:load_window_system(window_manager)
    self.window_manager = window_manager
    self.get_window_manager = function()
        return self.window_manager
    end
end

function App:get_window_manager()
    error("window manager is not loaded")
end