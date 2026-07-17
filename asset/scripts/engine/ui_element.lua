---@class UIElement
UIElement = Moveable:extend()

---@param parent Moveable
---@param new_UIBox UIBox
---@param new_UIT UIT
---@param config UIConfig
function UIElement:init(parent, new_UIBox, new_UIT, config)
    Moveable.init(self, Transform(0, 0, 0, 0), Room.instance:get_root_node())
    self.parent = parent
    self.UIT = new_UIT
    self.UIBox = new_UIBox
    self.config = config or {}
    if self.config and self.config.object then self.config.object.parent = self end
    self.children = {}
    self.ARGS = self.ARGS or {}
    self.content_dimensions = { w = 0, h = 0 }
end

function UIElement:set_values(T, recalculate)

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
    if not self.states.visible then
        if self.config.force_focus then
            add_to_drawhash(self)
        end
        return
    end
    if self.config.force_focus or self.config.force_collision or self.config.button_UIE or self.config.button or self.states.collide.can then
        add_to_drawhash(self)
    end

    local button_active = true
    local parallax_dist = 1.5
    local button_being_pressed = false

    --按钮效果
    if (self.config.button or self.config.button_UIE) then
        self.layered_parallax.x = ((self.parent and self.parent ~= self.UIBox and self.parent.layered_parallax.x or 0) + (self.config.shadow and 0.4 * self.shadow_parrallax.x or 0) / Tile.instance.TILESIZE)
        self.layered_parallax.y = ((self.parent and self.parent ~= self.UIBox and self.parent.layered_parallax.y or 0) + (self.config.shadow and 0.4 * self.shadow_parrallax.y or 0) / Tile.instance.TILESIZE)
        if self.config.button and ((self.last_clicked and self.last_clicked > Timer.instance.REAL - 0.1) or ((self.config.button and (self.states.hover.is or self.states.drag.is)) and Controller.instance.is_cursor_down)) then
            self.layered_parallax.x = self.layered_parallax.x - parallax_dist * self.shadow_parrallax.x / Tile.instance.TILESIZE * (self.config.button_dist or 1)
            self.layered_parallax.y = self.layered_parallax.y - parallax_dist * self.shadow_parrallax.y / Tile.instance.TILESIZE * (self.config.button_dist or 1)
            parallax_dist = 0
            button_being_pressed = true
        end
        if self.config.button_UIE and not self.config.button_UIE.config.button then button_active = false end
    end


    if self.config.colour:get_a() > 0.01 then
        if self.UIT == UIT.T and self.config.scale then

        end
    end
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

function UIElement:__tostring()
    return "UIElement(" .. self.ID .. ")"
end
