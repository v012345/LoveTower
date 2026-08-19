---@class Alignment
---@overload fun(type: AlignmentType, offset: Vec2, prev_type: AlignmentType, prev_offset: Vec2, lr_clamp: boolean): Alignment
Alignment = Object:extend()

---@param type AlignmentType
---@param offset Vec2
---@param prev_type AlignmentType
---@param prev_offset Vec2
---@param lr_clamp boolean
function Alignment:init(type, offset, prev_type, prev_offset, lr_clamp)
    assert(offset:is(Vec2))
    assert(prev_offset:is(Vec2))
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
    if not self.prev_offset.is_equal then
        print("1")
    end
end

--- is methods ----

---@return boolean
function Alignment:is_changed()
    if not self.prev_offset.is_equal then
        print("1")
    end
    return not self.prev_offset:is_equal(self.offset) or self.prev_type ~= self.type
end

---不强制对齐
---@return boolean
function Alignment:is_a()
    return self.type_list.a
end

---水平居中对齐
---@return boolean
function Alignment:is_m()
    return self.type_list.m
end

---垂直居中对齐
---@return boolean
function Alignment:is_c()
    return self.type_list.c
end

---底部对齐
---@return boolean
function Alignment:is_b()
    return self.type_list.b
end

---顶部对齐
---@return boolean
function Alignment:is_t()
    return self.type_list.t
end

---左对齐
---@return boolean
function Alignment:is_l()
    return self.type_list.l
end

---右对齐
---@return boolean
function Alignment:is_r()
    return self.type_list.r
end

---当非中心对齐时, 是不是在对齐对象的内部
---@return boolean
function Alignment:is_i()
    return self.type_list.i
end

--- refresh methods ----

function Alignment:refresh()
    self.type_list.a = bit.band(self.type, AlignmentType.a) ~= 0
    self.type_list.m = bit.band(self.type, AlignmentType.m) ~= 0
    self.type_list.c = bit.band(self.type, AlignmentType.c) ~= 0
    self.type_list.b = bit.band(self.type, AlignmentType.b) ~= 0
    self.type_list.t = bit.band(self.type, AlignmentType.t) ~= 0
    self.type_list.l = bit.band(self.type, AlignmentType.l) ~= 0
    self.type_list.r = bit.band(self.type, AlignmentType.r) ~= 0
    self.type_list.i = bit.band(self.type, AlignmentType.i) ~= 0
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
    self.offset = offset:clone()
end

function Alignment:set_prev_type(prev_type)
    self.prev_type = prev_type
end

---@param prev_offset Vec2
function Alignment:set_prev_offset(prev_offset)
    self.prev_offset = prev_offset:clone()
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

-- _G.Alignment = setmetatable({}, {
--     __call = function(self, type, offset, prev_type, prev_offset, lr_clamp)
--         return setmetatable({}, {
--             __index = Alignment(type, offset, prev_type, prev_offset, lr_clamp),
--             __newindex = function(self, k, v)
--                 if k == "prev_offset" then
--                     error("Attempt to modify a read-only table")
--                     -- else
--                     -- self.k = v
--                 end
--             end,
--         })
--     end
-- })
