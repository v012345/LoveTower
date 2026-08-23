---@class Velocity : GameObject
Velocity = GameObject:extend()

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

function Velocity:get_r()
    return self.r
end

function Velocity:get_scale()
    return self.scale
end

function Velocity:get_mag()
    return self.mag
end

function Velocity:set_r(r)
    self.r = r
end
