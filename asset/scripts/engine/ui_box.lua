---@class UIBox: Moveable
---@field UIRoot UIElement
UIBox = Moveable:extend()
---@param args {T: Transform|number[], definition: table, config: table}
function UIBox:init(args)
    Moveable.init(self, args.T)
    self.draw_layers = {} --if we need to explicitly change the draw order of the UIEs
    if getmetatable(self) == UIBox then
        table.insert(App.instance.I.UIBOX, self)
    end
end

function UIBox:get_UIE_by_ID(id, node)
end

function UIBox:calculate_xywh(node, _T, recalculate, _scale)
end

function UIBox:remove_group(node, group)
end

function UIBox:get_group(node, group, ingroup)
end

function UIBox:set_parent_child(node, parent)
end

function UIBox:remove()
end

function UIBox:draw()
    for k, v in pairs(self.children) do
        if k ~= 'h_popup' and k ~= 'alert' then v:draw() end
    end
    if self.states.visible then
        add_to_drawhash(self)
        self.UIRoot:draw_self()
        self.UIRoot:draw_children()
        for k, v in ipairs(self.draw_layers) do
            if v.draw_self then v:draw_self() else v:draw() end
            if v.draw_children then v:draw_children() end
        end
    end
    if self.children.alert then self.children.alert:draw() end
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
