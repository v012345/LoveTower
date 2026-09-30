---comment
---@param ui_root_node Node
function App:load_ui_system(ui_root_node)
    self.ui_root_node = ui_root_node
end

function App:get_ui_root_node()
    return self.ui_root_node
end
