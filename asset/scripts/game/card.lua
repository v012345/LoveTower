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
    print(_center)
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
