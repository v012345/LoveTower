---在对齐时, 描述 Moveable 的类型和位置等信息
---@class MoveableRole:GameObject
---@field private role_type RoleType
---@field private offset Vec2
---@field private major Moveable
---@field private draw_major Moveable
---@field private xy_bond BondType
---@field private wh_bond BondType
---@field private r_bond BondType
---@field private scale_bond BondType
---@overload fun(major: Moveable, role_type?: RoleType, draw_major: Moveable, offset?: Vec2, xy_bond?: BondType, wh_bond?: BondType, r_bond?: BondType, scale_bond?: BondType): MoveableRole
MoveableRole = GameObject:extend()

---@param major Moveable
---@param role_type? RoleType
---@param draw_major Moveable
---@param offset? Vec2
---@param xy_bond? BondType
---@param wh_bond? BondType
---@param r_bond? BondType
---@param scale_bond? BondType
function MoveableRole:init(major, role_type, draw_major, offset, xy_bond, wh_bond, r_bond, scale_bond)
    self.major = major
    self.role_type = role_type or RoleType.Minor          --Major dictates movement, Minor is welded to some major
    self.offset = offset and offset:clone() or Vec2(0, 0) --Offset from Minor to Major
    self.draw_major = draw_major
    self.xy_bond = xy_bond or BondType.Weak
    self.wh_bond = wh_bond or BondType.Weak
    self.r_bond = r_bond or BondType.Weak
    self.scale_bond = scale_bond or BondType.Weak
end

--- is methods ----

---@return boolean
function MoveableRole:is_major()
    return self.role_type == RoleType.Major
end

---@return boolean
function MoveableRole:is_major_nil()
    return self.major == nil
end

---@return boolean
function MoveableRole:is_minor()
    return self.role_type == RoleType.Minor
end

---@return boolean
function MoveableRole:is_glued()
    return self.role_type == RoleType.Glued
end

--- setters ----

---强制设置major
---@param major Moveable
function MoveableRole:set_major(major)
    self.major = major
end

function MoveableRole:set_offset_x(offset_x)
    self.offset.x = offset_x
end

function MoveableRole:set_offset_y(offset_y)
    self.offset.y = offset_y
end

--- getters ----

---@return Moveable
function MoveableRole:get_major()
    return self.major
end

---@return BondType
function MoveableRole:get_xy_bond()
    return self.xy_bond
end

---@return BondType
function MoveableRole:get_r_bond()
    return self.r_bond
end

---@return BondType
function MoveableRole:get_wh_bond()
    return self.wh_bond
end

---@return BondType
function MoveableRole:get_scale_bond()
    return self.scale_bond
end

---@return Moveable
function MoveableRole:get_draw_major()
    return self.draw_major
end

---@return RoleType
function MoveableRole:get_role_type()
    return self.role_type
end

---@return Vec2
function MoveableRole:get_offset()
    return self.offset
end

---当前 Node 的 x 的最终值
---@return number
function MoveableRole:get_final_x()
    return self.major.transform.x + self.offset.x
end

---当前 Node 的 y 的最终值
---@return number
function MoveableRole:get_final_y()
    return self.major.transform.y + self.offset.y
end

---- update methods ----

---如果major为nil, 则不更新major
---@param major Moveable|nil
function MoveableRole:update_major(major)
    self.major = major or self.major
end

---更新offset
---@param offset Vec2|nil
function MoveableRole:update_offset(offset)
    self.offset = offset and offset:clone() or self.offset
end

---更新xy_bond
---@param xy_bond BondType|nil
function MoveableRole:update_xy_bond(xy_bond)
    self.xy_bond = xy_bond or self.xy_bond
end

---更新wh_bond
---@param wh_bond BondType|nil
function MoveableRole:update_wh_bond(wh_bond)
    self.wh_bond = wh_bond or self.wh_bond
end

---更新r_bond
---@param r_bond BondType|nil
function MoveableRole:update_r_bond(r_bond)
    self.r_bond = r_bond or self.r_bond
end

---更新scale_bond
---@param scale_bond BondType|nil
function MoveableRole:update_scale_bond(scale_bond)
    self.scale_bond = scale_bond or self.scale_bond
end

---更新draw_major
---@param draw_major Moveable|nil
function MoveableRole:update_draw_major(draw_major)
    self.draw_major = draw_major or self.draw_major
end

---更新role_type
---@param role_type RoleType|nil
function MoveableRole:update_role_type(role_type)
    self.role_type = role_type or self.role_type
end
