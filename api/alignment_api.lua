---@meta

---@class Alignment: Object
---@field private type AlignmentType
---@field private offset Vec2
---@field private prev_type AlignmentType
---@field private prev_offset Vec2
---@field private lr_clamp boolean

---@param type AlignmentType
---@param offset Vec2
---@param prev_type AlignmentType
---@param prev_offset Vec2
---@param lr_clamp boolean
---@return Alignment
function Alignment(type, offset, prev_type, prev_offset, lr_clamp) end
