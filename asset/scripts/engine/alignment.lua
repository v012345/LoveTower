---@class Alignment
Alignment = Object:extend()

function Alignment:init(type, offset, prev_type, prev_offset, lr_clamp)
    self.type = type
    self.offset = offset
    self.prev_type = prev_type
    self.prev_offset = prev_offset
    self.lr_clamp = lr_clamp or false
end
