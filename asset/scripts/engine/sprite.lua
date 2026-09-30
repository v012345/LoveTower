---@class Sprite: Component
---@field sprite_frame love.Image
---@overload fun(name: string): Sprite
Sprite = BaseClass:extend()

---@param name string
function Sprite:init(name)
    self.name = Sprite
    self.sprite_frame = nil
    self.node = Node(name)
    local transform = UITransform()
    self.node:add_component(transform)
    self.node:add_component(self)
    -- asset/resources/textures/1x/Jokers.png
end

---@param sprite_frame love.Image
function Sprite:set_sprite_frame(sprite_frame)
    self.sprite_frame = sprite_frame
    local w, h = sprite_frame:getDimensions()
    self.rect = love.graphics.newQuad(0, 0, w, h, w, h)
end

---@param atlas love.Image
---@param rect { x: number, y: number, w: number, h: number }
function Sprite:set_sprite_frame_in_atlas(atlas, rect)
    self.sprite_frame = atlas
    local w, h = atlas:getDimensions()
    self.rect = love.graphics.newQuad(rect.x, rect.y, rect.w, rect.h, w, h)
end

function Sprite:draw()
    if self.sprite_frame then
        love.graphics.draw(self.sprite_frame, self.rect, 0, 0, 0, 1, 1)
    end
end

function Sprite:update(dt)

end
