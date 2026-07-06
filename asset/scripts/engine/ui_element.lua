---@class UIElement : Moveable
---@field parent Node 父元素
---@field UIT UIT
---@field UIBox UIBox
---@field ARGS table
---@field content_dimensions Size
UIElement = Moveable:extend()

---@param parent Node
---@param new_UIBox UIBox
---@param new_UIT UIT
---@param config UIConfig
function UIElement:init(parent, new_UIBox, new_UIT, config)
    self.parent = parent
    self.UIT = new_UIT
    self.UIBox = new_UIBox
    self.config = config or {}
    if self.config and self.config.object then self.config.object.parent = self end
    self.children = {}
    self.ARGS = self.ARGS or {}
    self.content_dimensions = { w = 0, h = 0 }
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
    print('UIElement:draw_self')
    if not self.states.visible then
        if self.config.force_focus then add_to_drawhash(self) end
        return
    end

    if self.config.force_focus or self.config.force_collision or self.config.button_UIE or self.config.button or self.states.collide.can then
        add_to_drawhash(self)
    end

    local button_active = true
    local parallax_dist = 1.5
    local button_being_pressed = false



    -- 透明度大于0.01时，绘制
    if self.config.colour[4] > 0.01 then
        if self.UIT == UIT.B or self.UIT == UIT.C or self.UIT == UIT.R or self.UIT == UIT.ROOT then
            prep_draw(self, 1)
            love.graphics.scale(button_being_pressed and 0.985 or 1)
            local collided_button = self.config.button_UIE or self
            self.ARGS.button_colours = self.ARGS.button_colours or {}
            self.ARGS.button_colours[1] = self.config.button_delay and
                mix_colours(self.config.colour, Color.L_BLACK, 0.5) or self.config.colour
            self.ARGS.button_colours[2] = (((collided_button.config.hover and collided_button.states.hover.is) or (collided_button.last_clicked and collided_button.last_clicked > G.TIMERS.REAL - 0.1)) and G.C.UI.HOVER or nil)
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
                        self:draw_pixellated_rect('fill', parallax_dist, nil,
                            self.config.progress_bar.ref_table[self.config.progress_bar.ref_value] /
                            self.config.progress_bar.max)
                    else
                        self:draw_pixellated_rect('fill', parallax_dist)
                    end
                else
                    love.graphics.rectangle('fill', 0, 0, self.VT.w * G.TILESIZE, self.VT.h * G.TILESIZE)
                end
            end
            love.graphics.pop()
        end
    end

    self:draw_boundingrect()
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
