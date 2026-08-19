---@class Transform:Object
---@overload fun(x?: number, y?: number, w?: number, h?: number, r?: number, scale?: number): Transform
Transform = Object:extend()

---@param x? number
---@param y? number
---@param w? number
---@param h? number
---@param r? number
---@param scale? number
function Transform:init(x, y, w, h, r, scale)
    self.x = x or 0
    self.y = y or 0
    self.w = w or 1
    self.h = h or 1
    self.r = r or 0
    self.scale = scale or 1
end

function Transform:clone()
    return Transform(self.x, self.y, self.w, self.h, self.r, self.scale)
end
