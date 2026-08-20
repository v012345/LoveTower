---@meta

---游戏瓦片坐标
---@class Point
---@field x number
---@field y number

---@class Vec2
---@field x number
---@field y number

---@param x? number
---@param y? number
---@return Vec2
function Vec2(x, y) end

---@class Velocity: Object
---@field x number 速度x
---@field y number 速度y
---@field r number 速度r
---@field scale number 速度scale
---@field mag number 速度mag

---@return Velocity
function Velocity(x, y, r, scale, mag) end
