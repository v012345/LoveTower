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
        table.insert(App.instance.I.MOVEABLE, self)
    end
end

function DynaText:update(dt)
    self:update_text()
end

function DynaText:update_text(first_pass)
    first_pass = false
    if self.T then
        if (self.T.w ~= self.config.W or self.T.h ~= self.config.H) and (not first_pass or self.reset_pop_in) then
            self.ui_object_updated = true
            self.non_recalc = self.config.non_recalc
        end
        self.T.w = self.config.W
        self.T.h = self.config.H
    end

    self.reset_pop_in = false
    self.start_pop_in = false
end

function DynaText:draw()
    prep_draw(self, 1)
    do
        local tile_size = Tile.instance.TILESIZE
        local cur_string = self.config.string_configs[self.data.focused_string]
        love.graphics.translate(cur_string.W_offset + self.text_offset.x * self.font.FONTSCALE / tile_size, self.strings[self.focused_string].H_offset + self.text_offset.y * self.font.FONTSCALE / tile_size)
        if self.config.spacing then love.graphics.translate(self.config.spacing * self.font.FONTSCALE / tile_size, 0) end
        self.ARGS.draw_shadow_norm = self.ARGS.draw_shadow_norm or {}
        local _shadow_norm = self.ARGS.draw_shadow_norm
        _shadow_norm.x = self.shadow_parrallax.x / math.sqrt(self.shadow_parrallax.y * self.shadow_parrallax.y + self.shadow_parrallax.x * self.shadow_parrallax.x) * self.font.FONTSCALE / tile_size
        _shadow_norm.y = self.shadow_parrallax.y / math.sqrt(self.shadow_parrallax.y * self.shadow_parrallax.y + self.shadow_parrallax.x * self.shadow_parrallax.x) * self.font.FONTSCALE / tile_size
        for k, letter in ipairs(self.strings[self.focused_string].letters) do
            local real_pop_in = self.config.min_cycle_time == 0 and 1 or letter.pop_in
            love.graphics.setColor(letter.prefix or letter.suffix or letter.colour or self.colours[k % #self.colours + 1])
            love.graphics.draw(
                letter.letter,
                0.5 * (letter.dims.x - letter.offset.x) * self.font.FONTSCALE / tile_size + _shadow_norm.x,
                0.5 * (letter.dims.y - letter.offset.y) * self.font.FONTSCALE / tile_size + _shadow_norm.y,
                letter.r or 0,
                real_pop_in * letter.scale * self.config.scale * self.font.FONTSCALE / tile_size,
                real_pop_in * letter.scale * self.config.scale * self.font.FONTSCALE / tile_size,
                0.5 * letter.dims.x / (self.config.scale),
                0.5 * letter.dims.y / (self.config.scale)
            )
            love.graphics.translate(letter.dims.x * self.font.FONTSCALE / tile_size, 0)
        end
    end
    love.graphics.pop()

    add_to_drawhash(self)
    self:draw_boundingrect()
end

function DynaText:__tostring()
    return "DynaText:" .. self.ID
end
