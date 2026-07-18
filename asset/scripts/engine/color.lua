---@class Color
Color = Color or Object:extend()

---@param r number
---@param g number
---@param b number
---@param a number
function Color:init(r, g, b, a)
    self.r = r or 0
    self.g = g or 0
    self.b = b or 0
    self.a = a or 1
    self[1] = self.r
    self[2] = self.g
    self[3] = self.b
    self[4] = self.a
end

function Color:get_r()
    return self.r
end

function Color:get_g()
    return self.g
end

function Color:get_b()
    return self.b
end

function Color:get_a()
    return self.a
end
