---@class (partial) DynaText: Moveable
DynaText = Moveable:extend()


---@private 初始化在 __call 中被调用
---@param data DynaTextData
function DynaText:init(data)
    Moveable.init(self, Transform(), Room.instance:get_root_node())
    self.data = data
    self.config = DynaTextConfig(data.dyna_text_config_data)
    self.T.w = self.config.W
    self.T.h = self.config.H
    self.text_offset = {
        x = self.font.TEXT_OFFSET.x * self.config.scale + (self.config.x_offset or 0),
        y = self.font.TEXT_OFFSET.y * self.config.scale + (self.config.y_offset or 0),
    }

    self.created_time = Timer.instance.REAL
    self.start_pop_in = self.config.pop_in

    self.focused_string = 1
    if #self.strings > 1 then
        self.pop_delay = self.config.pop_delay or 1.5
        self:pop_out(4)
    end



    self.T.r = self.config.text_rot or 0

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
    self:align_letters()
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

function DynaText:pop_out(pop_out_timer)
    self.config.pop_out = pop_out_timer or 1
    self.pop_out_time = Timer.instance.REAL + (self.pop_delay or 0)
end

function DynaText:pop_in(pop_in_timer)
    self.reset_pop_in = true
    self.config.pop_out = nil
    self.config.pop_in = pop_in_timer or 0
    self.created_time = Timer.instance.REAL

    for k, letter in ipairs(self.strings[self.focused_string].letters) do
        letter.pop_in = 0
    end

    self:update_text()
end

function DynaText:align_letters()
    if self.pop_cycle then
        self.focused_string = (self.config.random_element and math.random(1, #self.strings)) or self.focused_string == #self.strings and 1 or self.focused_string + 1
        self.pop_cycle = false
        for k, letter in ipairs(self.strings[self.focused_string].letters) do
            letter.pop_in = 0
        end
        self.config.pop_in = 0.1
        self.config.pop_out = nil
        self.created_time = Timer.instance.REAL
    end
    self.string = self.strings[self.focused_string].string
    for k, letter in ipairs(self.strings[self.focused_string].letters) do
        if self.config.pop_out then
            letter.pop_in = math.min(1, math.max((self.config.min_cycle_time or 1) - (Timer.instance.REAL - self.pop_out_time) * self.config.pop_out / (self.config.min_cycle_time or 1), 0))
            letter.pop_in = letter.pop_in * letter.pop_in
            if k == #self.strings[self.focused_string].letters and letter.pop_in <= 0 and #self.strings > 1 then self.pop_cycle = true end
        elseif self.config.pop_in then
            local prev_pop_in = letter.pop_in
            letter.pop_in = math.min(1, math.max((Timer.instance.REAL - self.config.pop_in - self.created_time) * #self.string * self.pop_in_rate - k + 1, self.config.min_cycle_time == 0 and 1 or 0))
            letter.pop_in = letter.pop_in * letter.pop_in
            if prev_pop_in <= 0 and letter.pop_in > 0 and not self.silent and
                (#self.string < 10 or k % 2 == 0) then
                if self.T.x > App.instance.ROOM.T.w + 2 or
                    self.T.y > App.instance.ROOM.T.h + 2 or
                    self.T.x < -2 or
                    self.T.y < -2 then else
                    play_sound('paper1', 0.45 + 0.05 * math.random() + (0.3 / #self.string) * k + (self.config.pitch_shift or 0))
                end
            end
            if k == #self.strings[self.focused_string].letters and letter.pop_in >= 1 then
                if #self.strings > 1 then
                    self.pop_delay = (Timer.instance.REAL - self.config.pop_in - self.created_time + (self.config.pop_delay or 1.5))
                    self:pop_out(4)
                else
                    self.config.pop_in = nil
                end
            end
        end
        letter.r = 0
        letter.scale = 1
        if self.config.rotate then letter.r = (self.config.rotate == 2 and -1 or 1) * (0.2 * (- #self.strings[self.focused_string].letters / 2 - 0.5 + k) / (#self.strings[self.focused_string].letters) + (G.SETTINGS.reduced_motion and 0 or 1) * 0.02 * math.sin(2 * G.TIMERS.REAL + k)) end
        if self.config.pulse then
            letter.scale = letter.scale + (G.SETTINGS.reduced_motion and 0 or 1) * (1 / self.config.pulse.width) * self.config.pulse.amount * (math.max(
                math.min((self.config.pulse.start - G.TIMERS.REAL) * self.config.pulse.speed + k + self.config.pulse.width,
                    (G.TIMERS.REAL - self.config.pulse.start) * self.config.pulse.speed - k + self.config.pulse.width + 2),
                0))
            letter.r = letter.r + (G.SETTINGS.reduced_motion and 0 or 1) * (letter.scale - 1) * (0.02 * (- #self.strings[self.focused_string].letters / 2 - 0.5 + k))
            if self.config.pulse.start > G.TIMERS.REAL + 2 * self.config.pulse.speed * #self.strings[self.focused_string].letters then
                self.config.pulse = nil
            end
        end
        if self.config.quiver then
            letter.scale = letter.scale + (G.SETTINGS.reduced_motion and 0 or 1) * (0.1 * self.config.quiver.amount)
            letter.r = letter.r + (G.SETTINGS.reduced_motion and 0 or 1) * 0.3 * self.config.quiver.amount * (
                math.sin(41.12342 * G.TIMERS.REAL * self.config.quiver.speed + k * 1223.2) +
                math.cos(63.21231 * G.TIMERS.REAL * self.config.quiver.speed + k * 1112.2) * math.sin(36.1231 * G.TIMERS.REAL * self.config.quiver.speed) +
                math.cos(95.123 * G.TIMERS.REAL * self.config.quiver.speed + k * 1233.2) -
                math.sin(30.133421 * G.TIMERS.REAL * self.config.quiver.speed + k * 123.2))
        end
        if self.config.float then letter.offset.y = (Settings.instance.reduced_motion and 0 or 1) * math.sqrt(self.scale) * (2 + (self.font.FONTSCALE / Tile.instance.TILESIZE) * 2000 * math.sin(2.666 * Timer.instance.REAL + 200 * k)) + 60 * (letter.scale - 1) end
        if self.config.bump then letter.offset.y = (Settings.instance.reduced_motion and 0 or 1) * self.bump_amount * math.sqrt(self.scale) * 7 * math.max(0, (5 + self.bump_rate) * math.sin(self.bump_rate * Timer.instance.REAL + 200 * k) - 3 - self.bump_rate) end
    end
end

function DynaText:set_quiver(amt)
    self.config.quiver = {
        speed = 0.5,
        amount = amt or 0.7,
        silent = false
    }
end

function DynaText:pulse(amt)
    self.config.pulse = {
        speed = 40,
        width = 2.5,
        start = Timer.instance.REAL,
        amount = amt or 0.2,
        silent = false
    }
end

function DynaText:draw()
    if self.children.particle_effect then self.children.particle_effect:draw() end

    if self.config.shadow then
        prep_draw(self, 1)
        love.graphics.translate(self.strings[self.focused_string].W_offset + self.text_offset.x * self.font.FONTSCALE / Tile.instance.TILESIZE, self.strings[self.focused_string].H_offset + self.text_offset.y * self.font.FONTSCALE / Tile.instance.TILESIZE)
        if self.config.spacing then love.graphics.translate(self.config.spacing * self.font.FONTSCALE / Tile.instance.TILESIZE, 0) end
        if self.config.shadow_colour then
            love.graphics.setColor(self.config.shadow_colour)
        else
            love.graphics.setColor(0, 0, 0, 0.3 * self.colours[1][4])
        end
        for k, letter in ipairs(self.strings[self.focused_string].letters) do
            local real_pop_in = self.config.min_cycle_time == 0 and 1 or letter.pop_in
            love.graphics.draw(
                letter.letter,
                0.5 * (letter.dims.x - letter.offset.x) * self.font.FONTSCALE / Tile.instance.TILESIZE - self.shadow_parrallax.x * self.config.scale / (Tile.instance.TILESIZE),
                0.5 * (letter.dims.y) * self.font.FONTSCALE / Tile.instance.TILESIZE - self.shadow_parrallax.y * self.config.scale / (Tile.instance.TILESIZE),
                letter.r or 0,
                real_pop_in * self.config.scale * self.font.FONTSCALE / Tile.instance.TILESIZE,
                real_pop_in * self.config.scale * self.font.FONTSCALE / Tile.instance.TILESIZE,
                0.5 * letter.dims.x / self.config.scale,
                0.5 * letter.dims.y / self.config.scale
            )
            love.graphics.translate(letter.dims.x * self.font.FONTSCALE / Tile.instance.TILESIZE, 0)
        end
        love.graphics.pop()
    end

    prep_draw(self, 1)
    do
        local tile_size = Tile.instance.TILESIZE
        love.graphics.translate(self.strings[self.focused_string].W_offset + self.text_offset.x * self.font.FONTSCALE / tile_size, self.strings[self.focused_string].H_offset + self.text_offset.y * self.font.FONTSCALE / tile_size)
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
