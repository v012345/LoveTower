---坐标
---@class Coordinate
---@field x number
---@field y number
Coordinate = Object:extend()

---@param x? number
---@param y? number
function Coordinate:init(x, y)
    self.x = x or 0
    self.y = y or 0
end

function Coordinate:clone()
    return Coordinate(self.x, self.y)
end
