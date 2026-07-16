---@class UIBox

UIBox = Moveable:extend()
---@param T Transform
---@param definition UIDdefinition
---@param config UIConfig
function UIBox:init(T, definition, config)
    Moveable.init(self, T, Room.instance:get_root_node())
    self.UIRoot = UIElement(nil, self, UIT.T, definition.config)
    if getmetatable(self) == UIBox then
        table.insert(App.instance.I.UIBOX, self)
    end
end

function UIBox:get_UIE_by_ID(id, node)
end

function UIBox:calculate_xywh(node, _T, recalculate, _scale)
    self.UIRoot:set_values(self.T)
end

function UIBox:remove_group(node, group)
end

function UIBox:get_group(node, group, ingroup)
end

---@param node UIDdefinition
function UIBox:set_parent_child(node, parent)

end

function UIBox:remove()
end

function UIBox:draw()
    --- 先画子元素
    -- for _, v in pairs(self.children) do
    --     v:draw()
    -- end
    -- if self.states.visible then
    --     self.UIRoot:draw_self()
    --     self.UIRoot:draw_children()
    --     for k, v in ipairs(self.draw_layers) do
    --         if v.draw_self then v:draw_self() else v:draw() end
    --         if v.draw_children then v:draw_children() end
    --     end
    -- end
    self:draw_boundingrect()
end

function UIBox:recalculate()
end

function UIBox:move(dt)
end

function UIBox:drag(offset)
end

function UIBox:add_child(node, parent)
end

function UIBox:set_container(container)
end

function UIBox:print_topology(indent)
end

function UIBox:__tostring()
    return "UIBox(" .. self.ID .. ")"
end
