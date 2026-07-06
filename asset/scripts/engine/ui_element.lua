---@class UIElement : Moveable
UIElement = Moveable:extend()
function UIElement:init(parent, new_UIBox, new_UIT, config)
end

function UIElement:set_values(_T, recalculate)
end

function UIElement:print_topology(indent)
end

function UIElement:initialize_VT()
end

function UIElement:juice_up(amount, rot_amt)
end

function UIElement:can_drag()
end

function UIElement:draw()
end

---画子元素
---@return nil
function UIElement:draw_children()
    if self.states.visible then
        for k, v in pairs(self.children) do
            if not v.config.draw_layer and k ~= 'h_popup' and k ~= 'alert' then
                if v.draw_self and not v.config.draw_after then v:draw_self() else v:draw() end
                if v.draw_children then v:draw_children() end
                if v.draw_self and v.config.draw_after then v:draw_self() else v:draw() end
            end
        end
    end
end

function UIElement:set_wh()
end

function UIElement:align(x, y)
end

function UIElement:set_alignments()

end

function UIElement:update_text()
end

function UIElement:update_object()
end

function UIElement:draw_self()
end

function UIElement:draw_pixellated_rect(_type, _parallax, _emboss, _progress)
end

function UIElement:update(dt)
end

function UIElement:collides_with_point(cursor_trans)
end

function UIElement:click()
end

function UIElement:put_focused_cursor()
end

function UIElement:remove()
end

function UIElement:hover()

end

function UIElement:stop_hover()

end

function UIElement:release(other)

end
