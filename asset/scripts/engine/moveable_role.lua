---@class MoveableRole
MoveableRole = Object:extend()

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

---@return boolean
function MoveableRole:is_major()
    return self.role_type == RoleType.Major
end

---@return Moveable
function MoveableRole:get_major()
    return self.major
end

---@param major Moveable|nil
function MoveableRole:set_major(major)
    self.major = major
end

---@return BondType
function MoveableRole:get_xy_bond()
    return self.xy_bond
end

---@return BondType
function MoveableRole:get_r_bond()
    return self.r_bond
end
