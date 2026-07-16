---@class Velocity
Velocity = Object:extend()

function Velocity:init(x, y, r, scale, mag)
    self.x = x
    self.y = y
    self.r = r
    self.scale = scale
    self.mag = mag
end

function Velocity:get_x()
    return self.x
end
