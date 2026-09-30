---@class (partial) App
---@field window_manager WindowManager
function App:install_window_manager(window_manager)
    ---@type WindowManager
    self.window_manager = window_manager
end

---@return WindowManager
function App:get_window_manager()
    return self.window_manager
end
