---@class Sprite: Component
---@overload fun(): Sprite
Sprite = BaseClass:extend()


function Sprite:init()
    self.name = "SpriteComponent"
end

function Sprite:draw()

end

function Sprite:update(dt)

end
