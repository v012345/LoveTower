---@class (partial) Sprite: Moveable
---@overload fun(T: Transform, new_sprite_atlas: AtlasConfigItem, sprite_pos: any, container: Node):Sprite
Sprite = Moveable:extend()

---
---@param _shader any
---@param _shadow_height number
---@param _send DataSendToShader[]
---@param _no_tilt boolean
---@param other_obj any
---@param ms number
---@param mr number
---@param mx number
---@param my number
---@param custom_shader boolean
---@param tilt_shadow any
function Sprite:draw_shader(_shader, _shadow_height, _send, _no_tilt, other_obj, ms, mr, mx, my, custom_shader, tilt_shadow)
    if App.settings:is_reduced_motion() then _no_tilt = true end
    local _draw_major = self.role:get_draw_major() or self
    if _shadow_height then
        self.VT.y = self.VT.y - _draw_major.shadow_parrallax.y * _shadow_height
        self.VT.x = self.VT.x - _draw_major.shadow_parrallax.x * _shadow_height
        self.VT.scale = self.VT.scale * (1 - 0.2 * _shadow_height)
    end

    if custom_shader then
        if _send then
            for k, v in ipairs(_send) do
                App.SHADERS[_shader]:send(v.name, v.val or (v.func and v.func()) or v.ref_table[v.ref_value])
            end
        end
    elseif _shader == 'vortex' then
        App.SHADERS['vortex']:send('vortex_amt', App.TIMERS.REAL - (App.vortex_time or 0))
    else
        self.args.prep_shader = self.args.prep_shader or {}
        self.args.prep_shader.cursor_pos = self.args.prep_shader.cursor_pos or {}
        self.args.prep_shader.cursor_pos[1] = _draw_major.tilt_var and _draw_major.tilt_var.mx * App.CANV_SCALE or App.CONTROLLER.cursor_position.x * App.CANV_SCALE
        self.args.prep_shader.cursor_pos[2] = _draw_major.tilt_var and _draw_major.tilt_var.my * App.CANV_SCALE or App.CONTROLLER.cursor_position.y * App.CANV_SCALE

        App.SHADERS[_shader or 'dissolve']:send('mouse_screen_pos', self.args.prep_shader.cursor_pos)
        App.SHADERS[_shader or 'dissolve']:send('screen_scale', App.window:get_pixels_per_tile() * (_draw_major.mouse_damping or 1) * App.CANV_SCALE)
        App.SHADERS[_shader or 'dissolve']:send('hovering', ((_shadow_height and not tilt_shadow) or _no_tilt) and 0 or (_draw_major.hover_tilt or 0) * (tilt_shadow or 1))
        App.SHADERS[_shader or 'dissolve']:send("dissolve", math.abs(_draw_major.dissolve or 0))
        App.SHADERS[_shader or 'dissolve']:send("time", 123.33412 * (_draw_major.id / 1.14212 or 12.5123152) % 3000)
        App.SHADERS[_shader or 'dissolve']:send("texture_details", self:get_pos_pixel())
        App.SHADERS[_shader or 'dissolve']:send("image_details", self:get_image_dims())
        App.SHADERS[_shader or 'dissolve']:send("burn_colour_1", _draw_major.dissolve_colours and _draw_major.dissolve_colours[1] or App.C.CLEAR)
        App.SHADERS[_shader or 'dissolve']:send("burn_colour_2", _draw_major.dissolve_colours and _draw_major.dissolve_colours[2] or App.C.CLEAR)
        App.SHADERS[_shader or 'dissolve']:send("shadow", (not not _shadow_height))
        if _send then App.SHADERS[_shader or 'dissolve']:send(_shader, _send) end
    end

    love.graphics.setShader(App.SHADERS[_shader or 'dissolve'], App.SHADERS[_shader or 'dissolve'])

    if other_obj then
        self:draw_from(other_obj, ms, mr, mx, my)
    else
        self:draw_self()
    end

    love.graphics.setShader()

    if _shadow_height then
        self.visible_transform.y = self.visible_transform.y + _draw_major.shadow_parrallax.y * _shadow_height
        self.visible_transform.x = self.visible_transform.x + _draw_major.shadow_parrallax.x * _shadow_height
        self.visible_transform.scale = self.visible_transform.scale / (1 - 0.2 * _shadow_height)
    end
end

function Sprite:draw_self(overlay)
    if not self.states.visible then return end
    if self.sprite_pos.x ~= self.sprite_pos_copy.x or self.sprite_pos.y ~= self.sprite_pos_copy.y then
        self:set_sprite_pos(self.sprite_pos)
    end
    prep_draw(self, 1)
    love.graphics.scale(1 / (self.scale.x / self.visible_transform.w), 1 / (self.scale.y / self.visible_transform.h))
    love.graphics.setColor(overlay or App.BRUTE_OVERLAY or App.C.WHITE)
    if self.video then
        self.video_dims = self.video_dims or {
            w = self.video:getWidth(),
            h = self.video:getHeight(),
        }
        love.graphics.draw(
            self.video,
            0, 0,
            0,
            self.VT.w / (self.T.w) / (self.video_dims.w / self.scale.x),
            self.VT.h / (self.T.h) / (self.video_dims.h / self.scale.y)
        )
    else
        love.graphics.draw(self.atlas.image, self.sprite, 0, 0, 0, self.visible_transform.w / (self.transform.w), self.visible_transform.h / (self.transform.h))
    end
    love.graphics.pop()
    add_to_drawhash(self)
    self:draw_boundingrect()
    if self.shader_tab then love.graphics.setShader() end
end

function Sprite:draw_from(other_obj, ms, mr, mx, my)
    self.ARGS.draw_from_offset = self.ARGS.draw_from_offset or {}
    self.ARGS.draw_from_offset.x = mx or 0
    self.ARGS.draw_from_offset.y = my or 0
    prep_draw(other_obj, (1 + (ms or 0)), (mr or 0), self.ARGS.draw_from_offset, true)
    love.graphics.scale(1 / (other_obj.scale_mag or other_obj.VT.scale))
    love.graphics.setColor(App.BRUTE_OVERLAY or App.C.WHITE)
    love.graphics.draw(
        self.atlas.image,
        self.sprite,
        -(other_obj.T.w / 2 - other_obj.VT.w / 2) * 10,
        0,
        0,
        other_obj.VT.w / (other_obj.T.w),
        other_obj.VT.h / (other_obj.T.h)
    )
    self:draw_boundingrect()
    love.graphics.pop()
end

function Sprite:remove()
    -- if self.video then
    --     self.video:release()
    -- end
    -- for k, v in pairs(G.ANIMATIONS) do
    --     if v == self then
    --         table.remove(G.ANIMATIONS, k)
    --     end
    -- end
    -- for k, v in pairs(G.I.SPRITE) do
    --     if v == self then
    --         table.remove(G.I.SPRITE, k)
    --     end
    -- end

    Moveable.remove(self)
end

--- ok ---


---@param T Transform
---@param new_sprite_atlas AtlasConfigItem
---@param sprite_pos {x: number, y: number, v?: number}
---@param container Node
function Sprite:init(T, new_sprite_atlas, sprite_pos, container)
    Moveable.init(self, T, container)
    self.CT = self.VT
    self.atlas = new_sprite_atlas
    self.scale = { x = self.atlas.px, y = self.atlas.py }
    self.scale_mag = math.min(self.scale.x / T.w, self.scale.y / T.h)
    self.zoom = true
    self.draw_steps = {}
    self.rets.get_pos_pixel = {}

    self:set_sprite_pos(sprite_pos)

    if getmetatable(self) == Sprite then
        table.insert(App.I.SPRITE, self)
    end
end

---@param draw_step_definitions DrawStep[]
function Sprite:define_draw_steps(draw_step_definitions)
    EMPTY(self.draw_steps)
    for k, v in ipairs(draw_step_definitions) do
        self.draw_steps[#self.draw_steps + 1] = {
            shader = v.shader or 'dissolve',
            shadow_height = v.shadow_height or nil,
            send = v.send or nil,
            no_tilt = v.no_tilt or nil,
            other_obj = v.other_obj or nil,
            ms = v.ms or nil,
            mr = v.mr or nil,
            mx = v.mx or nil,
            my = v.my or nil
        }
    end
end

---通过 name 和 sprite_pos 重新在图集中找到对应的精灵，并设置 sprite
function Sprite:reset()
    self.atlas = App.ASSET_ATLAS[self.atlas.name]
    self:set_sprite_pos(self.sprite_pos)
end

---@param sprite_pos {x: number, y: number, v?: number}
function Sprite:set_sprite_pos(sprite_pos)
    local v = sprite_pos.v
    if v then --我怎么感觉这个就给随机小丑用的呢？
        self.sprite_pos = { x = (math.random(v) - 1), y = sprite_pos.y }
    else
        self.sprite_pos = sprite_pos
    end
    self.sprite_pos_copy = { x = self.sprite_pos.x, y = self.sprite_pos.y }

    local w, h = self.atlas.image:getDimensions()
    local x = self.sprite_pos.x * self.atlas.px
    local y = self.sprite_pos.y * self.atlas.py
    self.sprite = love.graphics.newQuad(x, y, self.scale.x, self.scale.y, w, h)
    self.image_dims = { w, h }
end

function Sprite:get_pos_pixel()
    self.rets.get_pos_pixel[1] = self.sprite_pos.x
    self.rets.get_pos_pixel[2] = self.sprite_pos.y
    self.rets.get_pos_pixel[3] = self.atlas.px --self.scale.x
    self.rets.get_pos_pixel[4] = self.atlas.py --self.scale.y
    return self.rets.get_pos_pixel
end

function Sprite:get_image_dims()
    return self.image_dims
end

function Sprite:draw(overlay)
    if not self.states.visible then return end
    if self.draw_steps then
        for k, v in ipairs(self.draw_steps) do
            self:draw_shader(v.shader, v.shadow_height, v.send, v.no_tilt, v.other_obj, v.ms, v.mr, v.mx, v.my, not not v.send)
        end
    else
        self:draw_self(overlay)
    end

    add_to_drawhash(self)
    for k, v in pairs(self.children) do
        if k ~= 'h_popup' then v:draw() end
    end
    add_to_drawhash(self)
    self:draw_boundingrect()
end
