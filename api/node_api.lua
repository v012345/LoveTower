---@meta

---@class (partial) Node: Object
---@field id number 唯一ID
---@field transform Transform The transform of the node | Transform: 位置/大小/旋转 {x, y, w, h, r, scale}  (逻辑坐标)
---@field collision_transform Transform 碰撞检测的transform, 与 transform 相同
---@field states NodeStates 节点状态
---@field frame FrameCounter 帧计数器, 用于记录绘制和移动的帧数
---@field children Children 子节点
---@field container Node 就是父节点, 子节点会被父节点影响
---@field config table 当前节点的元数据
---@field under_overlay boolean 是否在覆盖层?
---@field click_offset Vec2 Create the offset tables, used to determine things like drag offset and 3d shader effects
---@field hover_offset Vec2 Create the offset tables, used to determine things like drag offset and 3d shader effects
---@field created_on_pause boolean 是否在暂停时创建, 如果 true, 这个节点在暂停时也会正常移动, 即使 App.TIMERS.TOTAL 不增加
---@field args table Store all argument tables here for reuse, because Lua likes to generate garbage
---@field rets table Store all return tables here for reuse, because Lua likes to generate garbage
---@field CALCING boolean 是否正在计算, Moveable 的 move 方法会设置这个为 true
---@field jiggle number 震动, 用于屏幕震动, 如果是 0 则不震动, 需要震动的时候加一个值, 震动过程会逐渐减小到 0

---@class FrameCounter
---@field draw number 绘制帧数
---@field move number 移动帧数

---@class NodeStates
---@field visible boolean 节点是否可见
---@field collide { can: boolean, is: boolean }
---@field focus { can: boolean, is: boolean }
---@field hover { can: boolean, is: boolean }
---@field click { can: boolean, is: boolean }
---@field drag { can: boolean, is: boolean }
---@field release_on { can: boolean, is: boolean }


--- 包括 `悬浮弹窗` `拖拽弹窗` `警告弹窗`, 以及 `粒子效果`
---@class Children
---@field h_popup? UIBox 悬浮弹窗
---@field d_popup? UIBox 拖拽弹窗
---@field alert?   UIBox 警告弹窗
---@field particle_effect? Particles 粒子效果
