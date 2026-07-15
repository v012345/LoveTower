---@class Alignment
Alignment = Object:extend()

function Alignment:init(type, offset, prev_type, prev_offset, lr_clamp)
    self.type = type
    self.offset = offset
    self.prev_type = prev_type
    self.prev_offset = prev_offset
    self.lr_clamp = lr_clamp or false
    self.type_list = {
        a = false,
        m = false,
        c = false,
        b = false,
        t = false,
        l = false,
        r = false,
        i = false,
    }
end

--- is methods ----

---@return boolean
function Alignment:is_changed()
    return not self.prev_offset:is_equal(self.offset) or self.prev_type ~= self.type
end

--- refresh methods ----

function Alignment:refresh_type_list()
    self.type_list.a = bit.band(self.type, AlignmentType.a) ~= 0
    self.type_list.m = bit.band(self.type, AlignmentType.m) ~= 0
    self.type_list.c = bit.band(self.type, AlignmentType.c) ~= 0
    self.type_list.b = bit.band(self.type, AlignmentType.b) ~= 0
    self.type_list.t = bit.band(self.type, AlignmentType.t) ~= 0
    self.type_list.l = bit.band(self.type, AlignmentType.l) ~= 0
    self.type_list.r = bit.band(self.type, AlignmentType.r) ~= 0
    self.type_list.i = bit.band(self.type, AlignmentType.i) ~= 0
end

function Alignment:refresh_type()
    self.prev_type = self.type
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

---@param _type AlignmentType
function Alignment:update_type(_type)
    self.type = _type or self.type
end

---@param offset Vec2
function Alignment:update_offset(offset)
    self.offset = offset and offset:clone() or self.offset
end

---@param prev_type AlignmentType
function Alignment:update_prev_type(prev_type)
    self.prev_type = prev_type or self.prev_type
end

---@param prev_offset Vec2
function Alignment:update_prev_offset(prev_offset)
    self.prev_offset = prev_offset or self.prev_offset
end

---@param lr_clamp boolean
function Alignment:update_lr_clamp(lr_clamp)
    self.lr_clamp = lr_clamp or self.lr_clamp
end

--- debug methods ----

function Alignment:__tostring()
    local type_list = ""
    for k, v in pairs(self.type_list) do
        if v then
            type_list = type_list .. k .. " "
        end
    end
    return string.format("Alignment(type=%s, offset=%s, prev_type=%s, prev_offset=%s, lr_clamp=%s)", type_list, self.offset, self.prev_type, self.prev_offset, self.lr_clamp)
end
