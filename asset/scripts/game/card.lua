---@class Card: Moveable
---@overload fun(T: Transform, card: any, center: any, params: any, container: Node): Card
Card = Moveable:extend()


---comment
---@param T Transform
---@param card any
---@param center any
---@param params table
---@param container Node
function Card:init(T, card, center, params, container)
    self.params = (type(params) == 'table') and params or {}
    Moveable.init(self, T, container)
    self.CT = self.VT
    self.config = {
        card = card or {},
        center = center
    }
    self.children = {}
    self:set_ability(center, true)
    self.sprite_facing = 'front'

    if getmetatable(self) == Card then
        table.insert(App.I.CARD, self)
    end
end

---设置卡牌的能力
function Card:set_ability(center, initial, delay_sprites)
    if delay_sprites then
        App.E_MANAGER:add_event(Event({
            func = function()
                if not self.REMOVED then
                    self:set_sprites(center)
                end
                return true
            end
        }))
    else
        self:set_sprites(center)
    end
end

function Card:set_sprites(_center, _front)
    if _front then
        local _atlas, _pos = get_front_spriteinfo(_front)
        if self.children.front then
            self.children.front.atlas = _atlas
            self.children.front:set_sprite_pos(_pos)
        else
            self.children.front = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, _atlas, _pos)
            self.children.front.states.hover = self.states.hover
            self.children.front.states.click = self.states.click
            self.children.front.states.drag = self.states.drag
            self.children.front.states.collide.can = false
            self.children.front:set_role({ major = self, role_type = RoleType.Glued, draw_major = self })
        end
    end
    if _center then
        if _center.set then
            if self.children.center then
                self.children.center.atlas = App.ASSET_ATLAS[(_center.atlas or (_center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher') and _center.set) or 'centers']
                self.children.center:set_sprite_pos(_center.pos)
            else
                if _center.set == 'Joker' and not _center.unlocked and not self.params.bypass_discovery_center then
                    self.children.center = Sprite(self.T, App.ASSET_ATLAS["Joker"], LockCfg:get_cfg_by_id("j_locked").pos, App.ROOM)
                elseif self.config.center.set == 'Voucher' and not self.config.center.unlocked and not self.params.bypass_discovery_center then
                    self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["Voucher"], G.v_locked.pos)
                elseif self.config.center.consumeable and self.config.center.demo then
                    self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["Tarot"], G.c_locked.pos)
                elseif not self.params.bypass_discovery_center and (_center.set == 'Edition' or _center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher' or _center.set == 'Booster') and not _center.discovered then
                    self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[_center.atlas or _center.set],
                        (_center.set == 'Joker' and G.j_undiscovered.pos) or
                        (_center.set == 'Edition' and G.j_undiscovered.pos) or
                        (_center.set == 'Tarot' and G.t_undiscovered.pos) or
                        (_center.set == 'Planet' and G.p_undiscovered.pos) or
                        (_center.set == 'Spectral' and G.s_undiscovered.pos) or
                        (_center.set == 'Voucher' and G.v_undiscovered.pos) or
                        (_center.set == 'Booster' and G.booster_undiscovered.pos))
                elseif _center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher' then
                    self.children.center = Sprite(self.T, App.ASSET_ATLAS[_center.set], self.config.center.pos, App.ROOM)
                else
                    self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[_center.atlas or 'centers'], _center.pos)
                end
                self.children.center.states.hover = self.states.hover
                self.children.center.states.click = self.states.click
                self.children.center.states.drag = self.states.drag
                self.children.center.states.collide.can = false
                self.children.center:set_role({ major = self, role_type = RoleType.Glued, draw_major = self })
            end
            if _center.name == 'Half Joker' and (_center.discovered or self.bypass_discovery_center) then
                self.children.center.scale.y = self.children.center.scale.y / 1.7
            end
            if _center.name == 'Photograph' and (_center.discovered or self.bypass_discovery_center) then
                self.children.center.scale.y = self.children.center.scale.y / 1.2
            end
            if _center.name == 'Square Joker' and (_center.discovered or self.bypass_discovery_center) then
                self.children.center.scale.y = self.children.center.scale.x
            end
        end

        if _center.soul_pos then
            self.children.floating_sprite = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS['Joker'], self.config.center.soul_pos)
            self.children.floating_sprite.role.draw_major = self
            self.children.floating_sprite.states.hover.can = false
            self.children.floating_sprite.states.click.can = false
        end

        if not self.children.back then
            self.children.back = Sprite(self.T, App.ASSET_ATLAS["centers"], self.params.bypass_back or (self.playing_card and App.GAME[self.back].pos or CardCfg:get_back_by_id("b_red").pos), App.ROOM)
            self.children.back.states.hover = self.states.hover
            self.children.back.states.click = self.states.click
            self.children.back.states.drag = self.states.drag
            self.children.back.states.collide.can = false
            self.children.back:set_role({ major = self, role_type = RoleType.Glued, draw_major = self })
        end
    end
end

---@param layer 'both' | 'shadow' | 'card'
function Card:draw(layer)
    layer = layer or 'both'
    self.hover_tilt = 1
    if not self.states.visible then return end

    if (layer == 'card' or layer == 'both') then
        -- tilt used by dissolve shader (splash ambient_tilt / hover)
        self.tilt_var = self.tilt_var or { mx = 0, my = 0, dx = 0, dy = 0, amt = 0 }
        local tilt_factor = 0.3
        if self.ambient_tilt then
            local tilt_angle = App.TIMERS.REAL * (1.56 + (self.ID / 1.14212) % 1) + self.ID / 1.35122
            local ppt = App.window:get_pixels_per_tile()
            self.tilt_var.mx = ((0.5 + 0.5 * self.ambient_tilt * math.cos(tilt_angle)) * self.VT.w + self.VT.x + App.ROOM.T.x) * ppt
            self.tilt_var.my = ((0.5 + 0.5 * self.ambient_tilt * math.sin(tilt_angle)) * self.VT.h + self.VT.y + App.ROOM.T.y) * ppt
            self.tilt_var.amt = self.ambient_tilt * (0.5 + math.cos(tilt_angle)) * tilt_factor
        end

        -- center/front/back 不能走下面的通用 children 循环，原版用 shader 单独画
        if self.sprite_facing == 'front' then
            if self.children.center then
                self.children.center:draw_shader('dissolve')
            end
            if self.children.front then
                self.children.front:draw_shader('dissolve')
            end
        elseif self.sprite_facing == 'back' then
            if self.children.back then
                self.children.back:draw_shader('dissolve')
            end
        end

        for k, v in pairs(self.children) do
            if k ~= 'focused_ui' and k ~= "front" and k ~= "back" and k ~= "soul_parts" and k ~= "center" and k ~= 'floating_sprite' and k ~= "shadow" and k ~= "use_button" and k ~= 'buy_button' and k ~= 'buy_and_use_button' and k ~= "debuff" and k ~= 'price' and k ~= 'particles' and k ~= 'h_popup' then v:draw() end
        end
        add_to_drawhash(self)
        self:draw_boundingrect()
    end
end

function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice)
    local dissolve_time = 0.7 * (dissolve_time_fac or 1)
    self.dissolve = 0
    self.dissolve_colours = dissolve_colours or { App.C.BLACK, App.C.ORANGE, App.C.RED, App.C.GOLD, App.C.JOKER_GREY }
    if not no_juice then self:juice_up() end
    local childParts = Particles(Transform(), {
        timer_type = 'TOTAL',
        timer = 0.01 * dissolve_time,
        scale = 0.1,
        speed = 2,
        lifespan = 0.7 * dissolve_time,
        attach = self,
        colours = self.dissolve_colours,
        fill = true
    }, App.ROOM)
    App.E_MANAGER:add_event(Event({
        trigger = EventTrigger.after,
        blockable = false,
        delay = 0.7 * dissolve_time,
        func = (function()
            childParts:fade(0.3 * dissolve_time)
            return true
        end)
    }))
    if not silent then
        App.E_MANAGER:add_event(Event({
            blockable = false,
            func = (function()
                play_sound('whoosh2', math.random() * 0.2 + 0.9, 0.5)
                play_sound('crumple' .. math.random(1, 5), math.random() * 0.2 + 0.9, 0.5)
                return true
            end)
        }))
    end
    App.E_MANAGER:add_event(Event({
        trigger = EventTrigger.ease,
        blockable = false,
        ref_table = self,
        ref_value = 'dissolve',
        ease_to = 1,
        delay = 1 * dissolve_time,
        func = (function(t) return t end)
    }))
    App.E_MANAGER:add_event(Event({
        trigger = EventTrigger.after,
        blockable = false,
        delay = 1.05 * dissolve_time,
        func = (function()
            self:remove()
            return true
        end)
    }))
    App.E_MANAGER:add_event(Event({
        trigger = EventTrigger.after,
        blockable = false,
        delay = 1.051 * dissolve_time,
    }))
end
