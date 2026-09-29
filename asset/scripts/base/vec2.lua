---@alias Point Vec2
---@class Vec2 @overload fun(x?: number, y?: number): Vec2
---@field x number
---@field y number
---@operator call: Vec2
Vec2 = Vec2 or {}
Vec2.__index = Vec2

setmetatable(Vec2, {
    __call = function(_, x, y)
        local obj = setmetatable({}, Vec2)
        obj.x = x or 0
        obj.y = y or 0
        return obj
    end,
    __tostring = function(self)
        return "Vec2(" .. self.x .. ", " .. self.y .. ")"
    end,
})

function Vec2:clone()
    return Vec2(self.x, self.y)
end

---@param other Vec2
---@return boolean
function Vec2:is_equal(other)
    return self.x == other.x and self.y == other.y
end
