---@class (partial) DynaText: Moveable
DynaText = Moveable:extend()


---@private 初始化在 __call 中被调用
---@param data DynaTextData
function DynaText:init(data)
    Moveable.init(self, Transform(), Room.instance:get_root_node())
    self.data = data
    data.focused_string = data.focused_string or 1
    self.config = DynaTextConfig(data.dyna_text_config_data)
    self.states.hover.can = false
    self.states.click.can = false
    self.states.collide.can = false
    self.states.drag.can = false
    self.states.release_on.can = false

    self:set_role {
        wh_bond = 'Weak',
        scale_bond = 'Weak'
    }

    if getmetatable(self) == DynaText then
        table.insert(App.I.MOVEABLE, self)
    end
end

function DynaText:update(dt)
    self:update_text()
end

function DynaText:update_text(first_pass)
    first_pass = false
    -- if self.T then
    --     if (self.T.w ~= self.config.W or self.T.h ~= self.config.H) and (not first_pass or self.reset_pop_in) then
    --         self.ui_object_updated = true
    --         self.non_recalc = self.config.non_recalc
    --     end
    --     self.T.w = self.config.W
    --     self.T.h = self.config.H
    -- end

    self.reset_pop_in = false
    self.start_pop_in = false
end

function DynaText:draw()
    if self.children.particle_effect then self.children.particle_effect:draw() end

    prep_draw(self, 1)
    do
        local tile_size = Tile.instance.TILESIZE
        local cur_string = self.config.string_configs[self.data.focused_string]
        local text_offset = self.config:get_text_offset()
        local font_scale = self.config:get_font_config().FONTSCALE
        love.graphics.translate(cur_string.W_offset + text_offset.x * font_scale / tile_size, cur_string.H_offset + text_offset.y * font_scale / tile_size)
        love.graphics.translate(self.config:get_spacing() * font_scale / tile_size, 0)

        for k, letter in ipairs(cur_string.letters) do
            local real_pop_in = letter.pop_in
            love.graphics.setColor(letter:get_colour())
            love.graphics.draw(
                letter:get_letter(),
                0.5 * (letter.dims.x - letter.offset.x) * font_scale / tile_size,
                0.5 * (letter.dims.y - letter.offset.y) * font_scale / tile_size,
                letter.r or 0,
                real_pop_in * letter.scale * self.config:get_scale() * font_scale / tile_size,
                real_pop_in * letter.scale * self.config:get_scale() * font_scale / tile_size,
                0.5 * letter.dims.x / (self.config:get_scale()),
                0.5 * letter.dims.y / (self.config:get_scale())
            )
            love.graphics.translate(letter.dims.x * font_scale / tile_size, 0)
        end
    end
    love.graphics.pop()

    add_to_drawhash(self)
    self:draw_boundingrect()
end

function DynaText:__tostring()
    return "DynaText:" .. self.ID
end
