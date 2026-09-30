---@class Sprite: Component
---@field sprite_frame love.Image
---@overload fun(): Sprite
Sprite = BaseClass:extend()


function Sprite:init()
    self.name = "SpriteComponent"
    self.sprite_frame = nil
    -- asset/resources/textures/1x/Jokers.png
end

function Sprite:set_sprite_frame(sprite_frame)
    self.sprite_frame = sprite_frame
    local w, h = sprite_frame:getDimensions()
    self.sprite = love.graphics.newQuad(0, 0, w, h, w, h)
end

function Sprite:set_sprite_frame_in_atlas(atlas, rect)
    self.sprite_frame = atlas
    local w, h = atlas:getDimensions()
    self.sprite = love.graphics.newQuad(rect.x, rect.y, rect.w, rect.h, w, h)
end

function Sprite:draw()
    if self.sprite_frame then
        love.graphics.draw(self.sprite_frame, self.sprite, 0, 0, 0, 1, 1)
    end
end

function Sprite:update(dt)

end
