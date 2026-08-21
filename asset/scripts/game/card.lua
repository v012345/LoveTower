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

    if getmetatable(self) == Card then
        table.insert(App.I.CARD, self)
    end
end

