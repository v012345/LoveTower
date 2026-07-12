---尺寸
---@class Size
---@field w number
---@field h number
Size = Object:extend()

---@param w? number
---@param h? number
function Size:init(w, h)
    self.w = w or 0
    self.h = h or 0
end

function Size:clone()
    return Size(self.w, self.h)
end

function Size:set(w, h)
    self.w = w
    self.h = h
end
