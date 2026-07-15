---@class MoveableRole
MoveableRole = Object:extend()

function MoveableRole:initMoveableRole(role_type, major, draw_major, offset, xy_bond, wh_bond, r_bond, scale_bond)
    self.role_type = role_type   --Major dictates movement, Minor is welded to some major
    self.offset = offset:clone() --Offset from Minor to Major
    self.major = major
    self.draw_major = draw_major
    self.xy_bond = xy_bond
    self.wh_bond = wh_bond
    self.r_bond = r_bond
    self.scale_bond = scale_bond
end

function MoveableRole:isMajor()
    return self.role_type == RoleType.Major
end
