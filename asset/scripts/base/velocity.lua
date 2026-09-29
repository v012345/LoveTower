---@class Velocity @overload fun(x?: number, y?: number, r?: number, scale?: number, mag?: number): Velocity
---@field x number 速度x
---@field y number 速度y
---@field r number 速度r
---@field scale number 速度scale
---@field mag number 速度mag
---@operator call: Velocity
Velocity = Velocity or {}
Velocity.__index = Velocity

setmetatable(Velocity, {
    __call = function(_, x, y, r, scale, mag)
        local obj = setmetatable({}, Velocity)
        obj.x = x or 0
        obj.y = y or 0
        obj.r = r or 0
        obj.scale = scale or 0
        obj.mag = mag or 0
        return obj
    end,
    __tostring = function(self)
        return "Velocity(" .. self.x .. ", " .. self.y .. ", " .. self.r .. ", " .. self.scale .. ", " .. self.mag .. ")"
    end,
})

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
