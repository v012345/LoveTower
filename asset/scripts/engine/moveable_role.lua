---@class MoveableRole
MoveableRole = Object:extend()

function MoveableRole:init(role_type, offset, major, xy_bond, wh_bond, r_bond, scale_bond, draw_major)
    self.role_type = role_type     --Major dictates movement, Minor is welded to some major
    self.offset = Vec2(0, 0) --Offset from Minor to Major
    self.major = nil
    self.draw_major = draw_major
    self.xy_bond = BondType.Strong
    self.wh_bond = BondType.Strong
    self.r_bond = BondType.Strong
    self.scale_bond = BondType.Strong
end

function MoveableRole:isMajor()
    return self.role_type == RoleType.Major
end
