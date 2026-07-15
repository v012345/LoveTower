---@class Alignment
Alignment = Object:extend()

function Alignment:init(type, offset, prev_type, prev_offset, lr_clamp)
    self.type = type
    self.offset = offset
    self.prev_type = prev_type
    self.prev_offset = prev_offset
    self.lr_clamp = lr_clamp or false
end

--- getters ----

---@return AlignmentType
function Alignment:get_type()
    return self.type
end

---@return Vec2
function Alignment:get_offset()
    return self.offset
end

---@return AlignmentType
function Alignment:get_prev_type()
    return self.prev_type
end

---@return Vec2
function Alignment:get_prev_offset()
    return self.prev_offset
end

---@return boolean
function Alignment:get_lr_clamp()
    return self.lr_clamp
end

--- setters ----

---@param _type AlignmentType
function Alignment:set_type(_type)
    self.type = _type
end

---@param offset Vec2
function Alignment:set_offset(offset)
    self.offset = offset
end

function Alignment:set_prev_type(prev_type)
    self.prev_type = prev_type
end

---@param prev_offset Vec2
function Alignment:set_prev_offset(prev_offset)
    self.prev_offset = prev_offset
end

---@param lr_clamp boolean
function Alignment:set_lr_clamp(lr_clamp)
    self.lr_clamp = lr_clamp
end

--- update methods ----

function Alignment:update_type(_type)
    self.type = _type or self.type
end

function Alignment:update_offset(offset)
    self.offset = offset or self.offset
end

function Alignment:update_prev_type(prev_type)
    self.prev_type = prev_type or self.prev_type
end

function Alignment:update_prev_offset(prev_offset)
    self.prev_offset = prev_offset or self.prev_offset
end

function Alignment:update_lr_clamp(lr_clamp)
    self.lr_clamp = lr_clamp or self.lr_clamp
end
