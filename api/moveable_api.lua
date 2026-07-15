---@meta

---@class Moveable: Node
---@field velocity { x: number, y: number, r: number, scale: number, mag: number } 速度
---@field shadow_parrallax Coordinate 阴影的偏移, 受主场景就是 ROOM 影响
---@field role MoveableRole 在 Moveable 中初始化
---@field alignment Alignment
---@field pinch { x: boolean, y: boolean } 快速完成过渡
---@field last_moved number 上次移动时间
---@field last_aligned number 上次对齐时间
---@field static_rotation boolean 是否静态旋转?
---@field offset Coordinate 偏移
---@field Mid Moveable 对齐参考点, 用于在 align_to_major() 中确定"用对象的哪个部分去对齐"
---@field shadow_height number 阴影高度??
---@field VT Transform 缓动变换成使用, 引擎会自动计算到 T
---@field layered_parallax Coordinate 分层偏移????


---@class MoveableRole: Object
---@field role_type  RoleType
---@field offset     Vec2
---@field major      Moveable | nil
---@field draw_major Moveable
---@field xy_bond    BondType
---@field wh_bond    BondType
---@field r_bond     BondType
---@field scale_bond BondType

---@param role_type RoleType
---@param offset Vec2
---@param major Moveable | nil
---@param xy_bond BondType
---@param wh_bond BondType
---@param r_bond BondType
---@param scale_bond BondType
---@param draw_major Moveable
---@return MoveableRole
function MoveableRole(role_type, offset, major, xy_bond, wh_bond, r_bond, scale_bond, draw_major) end
