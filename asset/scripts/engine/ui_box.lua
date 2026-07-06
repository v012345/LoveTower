---@class UIBox: Moveable
---@field UIRoot UIElement
UIBox = Moveable:extend()
---@param args {T: Transform, definition: UIDdefinition, config: UIConfig}
function UIBox:init(args)
    Moveable.init(self, args.T)
    self.UIRoot = UIElement(nil, self, UIT.T, args.definition.config)
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
    self.UIRoot:draw_self()
    self.UIRoot:draw_children()
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
