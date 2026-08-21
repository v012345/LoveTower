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
            self.children.front:set_role({ major = self, role_type = 'Glued', draw_major = self })
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
                self.children.center:set_role({ major = self, role_type = 'Glued', draw_major = self })
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
            self.children.back:set_role({ major = self, role_type = 'Glued', draw_major = self })
        end
    end
end

---@param layer 'both' | 'shadow' | 'card'
function Card:draw(layer)
    layer = layer or 'both'
    self.hover_tilt = 1
    if not self.states.visible then return end

    if (layer == 'card' or layer == 'both') then
        if self.sprite_facing == 'front' then
            print('front')
        end
        add_to_drawhash(self)
        self:draw_boundingrect()
    end
end
