---@class Vec2
Vec2 = Object:extend()

function Vec2:init(x, y)
    self.x = x or 0
    self.y = y or 0
end

function Vec2:clone()
    return Vec2(self.x, self.y)
end

---@param other Vec2
---@return boolean
function Vec2:is_equal(other)
    return self.x == other.x and self.y == other.y
end

function Vec2:__tostring()
    return "Vec2(" .. self.x .. ", " .. self.y .. ")"
end
