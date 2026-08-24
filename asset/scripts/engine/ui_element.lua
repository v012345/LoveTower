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
            self.ARGS.text_parallax = self.ARGS.text_parallax or {}
            self.ARGS.text_parallax.sx = -self.shadow_parrallax.x * 0.5 / (self.config.scale * self.config.lang.font.FONTSCALE)
            self.ARGS.text_parallax.sy = -self.shadow_parrallax.y * 0.5 / (self.config.scale * self.config.lang.font.FONTSCALE)
            if (self.config.button_UIE and button_active) or (not self.config.button_UIE and self.config.shadow and App.settings.GRAPHICS.shadows == 'On') then
                prep_draw(self, 0.97)
                do
                    if self.config.vert then
                        love.graphics.translate(0, self.VT.h)
                        love.graphics.rotate(-math.pi / 2)
                    end
                    if (self.config.shadow or (self.config.button_UIE and button_active)) and App.settings.GRAPHICS.shadows == 'On' then
                        love.graphics.setColor(0, 0, 0, 0.3 * self.config.colour:get_a())
                        love.graphics.draw(
                            self.config.text_drawable,
                            (self.config.lang.font.TEXT_OFFSET.x + (self.config.vert and -self.ARGS.text_parallax.sy or self.ARGS.text_parallax.sx)) * (self.config.scale or 1) * self.config.lang.font.FONTSCALE / Tile.instance.TILESIZE,
                            (self.config.lang.font.TEXT_OFFSET.y + (self.config.vert and self.ARGS.text_parallax.sx or self.ARGS.text_parallax.sy)) * (self.config.scale or 1) * self.config.lang.font.FONTSCALE / Tile.instance.TILESIZE,
                            0,
                            (self.config.scale) * self.config.lang.font.squish * self.config.lang.font.FONTSCALE / Tile.instance.TILESIZE,
                            (self.config.scale) * self.config.lang.font.FONTSCALE / Tile.instance.TILESIZE
                        )
                    end
                end
                love.graphics.pop()
            end
            prep_draw(self, 1)
            do
                if self.config.vert then
                    love.graphics.translate(0, self.VT.h); love.graphics.rotate(-math.pi / 2)
                end
                if not button_active then
                    love.graphics.setColor(Color.UI.TEXT_INACTIVE)
                else
                    love.graphics.setColor(self.config.colour)
                end
                love.graphics.draw(
                    self.config.text_drawable,
                    self.config.lang.font.TEXT_OFFSET.x * (self.config.scale) * self.config.lang.font.FONTSCALE / Tile.instance.TILESIZE,
                    self.config.lang.font.TEXT_OFFSET.y * (self.config.scale) * self.config.lang.font.FONTSCALE / Tile.instance.TILESIZE,
                    0,
                    (self.config.scale) * self.config.lang.font.squish * self.config.lang.font.FONTSCALE / Tile.instance.TILESIZE,
                    (self.config.scale) * self.config.lang.font.FONTSCALE / Tile.instance.TILESIZE)
            end
            love.graphics.pop()
        elseif self.UIT == UIT.B or self.UIT == UIT.C or self.UIT == UIT.R or self.UIT == UIT.ROOT then
            prep_draw(self, 1)
            do
                love.graphics.scale(1 / (Tile.instance.TILESIZE))
                if self.config.shadow and App.settings.GRAPHICS.shadows == 'On' then
                    love.graphics.scale(0.98)
                    if self.config.shadow_colour then
                        love.graphics.setColor(self.config.shadow_colour)
                    else
                        love.graphics.setColor(0, 0, 0, 0.3 * self.config.colour:get_a())
                    end
                    if self.config.r and self.VT.w > 0.01 then
                        self:draw_pixellated_rect('shadow', parallax_dist)
                    else
                        love.graphics.rectangle('fill', -self.shadow_parrallax.x * parallax_dist, -self.shadow_parrallax.y * parallax_dist, self.VT.w * Tile.instance.TILESIZE, self.VT.h * Tile.instance.TILESIZE)
                    end
                    love.graphics.scale(1 / 0.98)
                end
                love.graphics.scale(button_being_pressed and 0.985 or 1)
                if self.config.emboss then
                    love.graphics.setColor(darken(self.config.colour, self.states.hover.is and 0.5 or 0.3, true))
                    self:draw_pixellated_rect('emboss', parallax_dist, self.config.emboss)
                end
                local collided_button = self.config.button_UIE or self
                self.ARGS.button_colours = self.ARGS.button_colours or {}
                self.ARGS.button_colours[1] = self.config.button_delay and mix_colours(self.config.colour, Color.L_BLACK, 0.5) or self.config.colour
                self.ARGS.button_colours[2] = (((collided_button.config.hover and collided_button.states.hover.is) or (collided_button.last_clicked and collided_button.last_clicked > Timer.instance.REAL - 0.1)) and Color.UI.HOVER or nil)
                for k, v in ipairs(self.ARGS.button_colours) do
                    love.graphics.setColor(v)
                    if self.config.r and self.VT.w > 0.01 then
                        if self.config.button_delay then
                            love.graphics.setColor(Color.GREY)
                            self:draw_pixellated_rect('fill', parallax_dist)
                            love.graphics.setColor(v)
                            self:draw_pixellated_rect('fill', parallax_dist, nil, self.config.button_delay_progress)
                        elseif self.config.progress_bar then
                            love.graphics.setColor(self.config.progress_bar.empty_col or Color.GREY)
                            self:draw_pixellated_rect('fill', parallax_dist)
                            love.graphics.setColor(self.config.progress_bar.filled_col or Color.BLUE)
                            self:draw_pixellated_rect('fill', parallax_dist, nil, self.config.progress_bar.ref_table[self.config.progress_bar.ref_value] / self.config.progress_bar.max)
                        else
                            self:draw_pixellated_rect('fill', parallax_dist)
                        end
                    else
                        love.graphics.rectangle('fill', 0, 0, self.VT.w * Tile.instance.TILESIZE, self.VT.h * Tile.instance.TILESIZE)
                    end
                end
            end
            love.graphics.pop()
        elseif self.UIT == UIT.O and self.config.object then
            --Draw the outline for highlighted objext
            if self.config.focus_with_object and self.config.object.states.focus.is then
                self.object_focus_timer = self.object_focus_timer or Timer.instance.REAL
                local lw = 50 * math.max(0, self.object_focus_timer - Timer.instance.REAL + 0.3) ^ 2
                prep_draw(self, 1)
                do
                    love.graphics.scale((1) / (Tile.instance.TILESIZE))
                    love.graphics.setLineWidth(lw + 1.5)
                    love.graphics.setColor(adjust_alpha(Color.WHITE, 0.2 * lw, true))
                    self:draw_pixellated_rect('fill', parallax_dist)
                    love.graphics.setColor(self.config.colour:get_a() > 0 and mix_colours(Color.WHITE, self.config.colour, 0.8) or Color.WHITE)
                    self:draw_pixellated_rect('line', parallax_dist)
                end
                love.graphics.pop()
            else
                self.object_focus_timer = nil
            end
            self.config.object:draw()
        end
    end

    --Draw the outline of the object
    if self.config.outline and self.config.outline_colour[4] > 0.01 then
        if self.config.outline then
            prep_draw(self, 1)
            do
                love.graphics.scale(1 / (Tile.instance.TILESIZE))
                love.graphics.setLineWidth(self.config.outline)
                if self.config.line_emboss then
                    love.graphics.setColor(darken(self.config.outline_colour, self.states.hover.is and 0.5 or 0.3, true))
                    self:draw_pixellated_rect('line_emboss', parallax_dist, self.config.line_emboss)
                end
                love.graphics.setColor(self.config.outline_colour)
                if self.config.r and self.VT.w > 0.01 then
                    self:draw_pixellated_rect('line', parallax_dist)
                else
                    love.graphics.rectangle('line', 0, 0, self.VT.w * Tile.instance.TILESIZE, self.VT.h * Tile.instance.TILESIZE)
                end
            end
            love.graphics.pop()
        end
    end

    --Draw the outline for highlighted buttons
    if self.states.focus.is then
        self.focus_timer = self.focus_timer or Timer.instance.REAL
        local lw = 50 * math.max(0, self.focus_timer - Timer.instance.REAL + 0.3) ^ 2
        prep_draw(self, 1)
        do
            love.graphics.scale((1) / (Tile.instance.TILESIZE))
            love.graphics.setLineWidth(lw + 1.5)
            love.graphics.setColor(adjust_alpha(Color.WHITE, 0.2 * lw, true))
            self:draw_pixellated_rect('fill', parallax_dist)
            love.graphics.setColor(self.config.colour:get_a() > 0 and mix_colours(Color.WHITE, self.config.colour, 0.8) or Color.WHITE)
            self:draw_pixellated_rect('line', parallax_dist)
        end
        love.graphics.pop()
    else
        self.focus_timer = nil
    end

    --Draw the 'chosen triangle'
    if self.config.chosen then
        prep_draw(self, 0.98)
        love.graphics.scale(1 / (Tile.instance.TILESIZE))
        if self.config.shadow and App.settings.GRAPHICS.shadows == 'On' then
            love.graphics.setColor(0, 0, 0, 0.3 * self.config.colour:get_a())
            love.graphics.polygon("fill", get_chosen_triangle_from_rect(self.layered_parallax.x - self.shadow_parrallax.x * parallax_dist * 0.5, self.layered_parallax.y - self.shadow_parrallax.y * parallax_dist * 0.5, self.VT.w * Tile.instance.TILESIZE, self.VT.h * Tile.instance.TILESIZE, self.config.chosen == 'vert'))
        end
        love.graphics.pop()

        prep_draw(self, 1)
        love.graphics.scale(1 / (Tile.instance.TILESIZE))
        love.graphics.setColor(Color.RED)
        love.graphics.polygon("fill", get_chosen_triangle_from_rect(self.layered_parallax.x, self.layered_parallax.y, self.VT.w * Tile.instance.TILESIZE, self.VT.h * Tile.instance.TILESIZE, self.config.chosen == 'vert'))
        love.graphics.pop()
    end
    self:draw_boundingrect()
end

function UIElement:draw_pixellated_rect(_type, _parallax, _emboss, _progress)
end

function UIElement:update(dt)
    if self.UIT == UIT.T then self:update_text() end
    if self.UIT == UIT.O then self:update_object() end
    -- 很奇怪, Moveable 没有 update 方法
    Node.update(self, dt)
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
