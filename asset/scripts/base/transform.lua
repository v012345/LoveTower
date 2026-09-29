---这个东西的 x , y , w , h 的单位好像是 Tile 啊, 不是像素
---@class Transform @overload fun(x?: number, y?: number, w?: number, h?: number, r?: number, scale?: number): Transform
---@field x number
---@field y number
---@field w number
---@field h number
---@field r number
---@field scale number
---@operator call: Transform
Transform = Transform or {}
Transform.__index = Transform

setmetatable(Transform, {
    __call = function(_, x, y, w, h, r, scale)
        local obj = setmetatable({}, Transform)
        obj.x = x or 0
        obj.y = y or 0
        obj.w = w or 1
        obj.h = h or 1
        obj.r = r or 0
        obj.scale = scale or 1
        return obj
    end,
    __tostring = function(self)
        return "Transform(" .. self.x .. ", " .. self.y .. ", " .. self.w .. ", " .. self.h .. ", " .. self.r .. ", " .. self.scale .. ")"
    end,
})

function Transform:copy(transform)
    self.x = transform.x
    self.y = transform.y
    self.w = transform.w
    self.h = transform.h
    self.r = transform.r
    self.scale = transform.scale
end

function Transform:clone()
    return Transform(self.x, self.y, self.w, self.h, self.r, self.scale)
end
