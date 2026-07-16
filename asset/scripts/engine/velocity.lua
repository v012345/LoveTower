---@class Velocity
Velocity = Object:extend()

function Velocity:init(x, y, r, scale, mag)
    self.x = x or 0
    self.y = y or 0
    self.r = r or 0
    self.scale = scale or 0
    self.mag = mag or 0
end

function Velocity:get_x()
    return self.x
end
