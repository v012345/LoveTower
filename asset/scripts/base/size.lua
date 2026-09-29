---尺寸
---@class Size @overload fun(w?: number, h?: number): Size
---@field w number
---@field h number
---@operator call: Size
Size = Size or {}
Size.__index = Size

setmetatable(Size, {
    __call = function(_, w, h)
        local obj = setmetatable({}, Size)
        obj.w = w or 0
        obj.h = h or 0
        return obj
    end,
    __tostring = function(self)
        return "Size(" .. self.w .. ", " .. self.h .. ")"
    end,
})

function Size:clone()
    return Size(self.w, self.h)
end

function Size:set(w, h)
    self.w = w
    self.h = h
end
