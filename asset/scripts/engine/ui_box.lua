---@class UIBox: Moveable
---@field UIRoot UIElement
UIBox = Moveable:extend()
---@param args {T: Transform, definition: UIDdefinition, config: UIConfig}
function UIBox:init(args)
    Moveable.init(self, args.T)
    self.draw_layers = {} --if we need to explicitly change the draw order of the UIEs
    self.definition = args.definition
    self:set_parent_child(self.definition, nil)

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

---@param node UIDdefinition
function UIBox:set_parent_child(node, parent)
    print(debug.traceback())
    print(parent)
    ---@type UIElement
    local UIE = UIElement(parent, self, node.n, node.config)

    --set the group of the element
    if parent and parent.config then
        if parent.config.group then
            if UIE.config then
                UIE.config.group = parent.config.group
            else
                UIE.config = { group = parent.config.group }
            end
        end

        --set the button for the element
        if parent.config.button then
            if UIE.config then
                UIE.config.button_UIE = parent
            else
                UIE.config = { button_UIE = parent }
            end
        end
        if parent.config.button_UIE then
            if UIE.config then
                UIE.config.button_UIE = parent.config.button_UIE
            else
                UIE.config = { button = parent.config.button }
            end
        end
    end


    if node.n and node.n == UIT.O and UIE.config.button then
        UIE.config.object.states.click.can = false
    end

    --current node is a container
    if (node.n and node.n == UIT.C or node.n == UIT.R or node.n == UIT.ROOT) and node.nodes then
        for k, v in pairs(node.nodes) do
            self:set_parent_child(v, UIE)
        end
    end

    if not parent then
        self.UIRoot = UIE
        self.UIRoot.parent = self
    else
        table.insert(parent.children, UIE)
    end
    if node.config and node.config.mid then
        self.Mid = UIE
    end
end

function UIBox:remove()
end

function UIBox:draw()
    print(self.ID)
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
