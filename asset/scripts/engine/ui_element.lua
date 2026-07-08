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
    Moveable.init(self, Transform(0, 0, 0, 0))
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
    local button_active = true
    if self.UIT == UIT.T then
        do
            return
        end
      

        if (self.config.button_UIE and button_active) or (not self.config.button_UIE and self.config.shadow and G.SETTINGS.GRAPHICS.shadows == 'On') then
            prep_draw(self, 0.97)
            if self.config.vert then
                love.graphics.translate(0, self.VT.h); love.graphics.rotate(-math.pi / 2)
            end
            if (self.config.shadow or (self.config.button_UIE and button_active)) and G.SETTINGS.GRAPHICS.shadows == 'On' then
                love.graphics.setColor(0, 0, 0, 0.3 * self.config.colour[4])
                love.graphics.draw(
                    self.config.text_drawable,
                    (self.config.lang.font.TEXT_OFFSET.x + (self.config.vert and -self.ARGS.text_parallax.sy or self.ARGS.text_parallax.sx)) * (self.config.scale or 1) * self.config.lang.font.FONTSCALE / G.TILESIZE,
                    (self.config.lang.font.TEXT_OFFSET.y + (self.config.vert and self.ARGS.text_parallax.sx or self.ARGS.text_parallax.sy)) * (self.config.scale or 1) * self.config.lang.font.FONTSCALE / G.TILESIZE,
                    0,
                    (self.config.scale) * self.config.lang.font.squish * self.config.lang.font.FONTSCALE / G.TILESIZE,
                    (self.config.scale) * self.config.lang.font.FONTSCALE / G.TILESIZE
                )
            end
            love.graphics.pop()
        end

        prep_draw(self, 1)
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
            self.config.lang.font.TEXT_OFFSET.x * (self.config.scale) * self.config.lang.font.FONTSCALE / G.TILESIZE,
            self.config.lang.font.TEXT_OFFSET.y * (self.config.scale) * self.config.lang.font.FONTSCALE / G.TILESIZE,
            0,
            (self.config.scale) * self.config.lang.font.squish * self.config.lang.font.FONTSCALE / G.TILESIZE,
            (self.config.scale) * self.config.lang.font.FONTSCALE / G.TILESIZE
        )
        love.graphics.pop()
        self.config.object:draw()
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
