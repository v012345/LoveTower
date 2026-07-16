---@meta

---@class Moveable: Node
---field T Transform 变换 {x, y, w, h, r, scale} (逻辑坐标), 显式声明避免 glue_to_major 中 self.T = major_tab.T 的循环推断
---@field velocity Velocity 速度
---@field shadow_parrallax Coordinate 阴影的偏移, 受主场景就是 ROOM 影响
---@field role MoveableRole 在 Moveable 中初始化
---@field alignment Alignment
---@field pinch { x: boolean, y: boolean } 快速完成过渡
---@field last_moved number 上次移动时间
---@field last_aligned number 上次对齐时间
---@field static_rotation boolean 是否静态旋转?
---@field offset Coordinate 偏移
---@field Mid Moveable 在水平和垂直居中对齐时, 参考的中心点, 就是以哪个 Node 当作中心点, 一般默认为自己,
---@field shadow_height number 阴影高度??
---@field VT Transform 缓动变换成使用, 引擎会自动计算到 T
---@field layered_parallax Coordinate 分层偏移????


---@class MoveableRole: Object
---@field private role_type  RoleType
---@field private offset     Vec2
---@field private major      Moveable
---@field private draw_major Moveable
---@field private xy_bond    BondType
---@field private wh_bond    BondType
---@field private r_bond     BondType
---@field private scale_bond BondType

---@param role_type? RoleType
---@param major? Moveable
---@param draw_major? Moveable
---@param offset? Vec2
---@param xy_bond? BondType
---@param wh_bond? BondType
---@param r_bond? BondType
---@param scale_bond? BondType
---@return MoveableRole
function MoveableRole(major, role_type, draw_major, offset, xy_bond, wh_bond, r_bond, scale_bond) end
