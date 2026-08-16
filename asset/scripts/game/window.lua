---@class Window: Object
---@field TRANS Transform 窗口变换
---@field real_size Size 窗口实际大小
---@field orig_size Size 窗口原始大小
---@field orig_scale number 窗口原始缩放
---@field orig_ratio number 窗口原始宽高比例
---@field ROOM_PADDING_W number 房间左右边距, 以地图单元格为单位
---@field ROOM_PADDING_H number 房间上下边距, 以地图单元格为单位
local Window = Object:extend()

function Window:init()
    local tile_width = GameCfg:get_tile_width()
    local tile_height = GameCfg:get_tile_height()
    local tile_scale = GameCfg:get_tile_scale()
    local tile_size = GameCfg:get_tile_size()
    -- Initialize the window
    --- 设计大小
    --- 窗口大小为 1606*941, 设计大小为 1460*840
    --- 宽高比为 1.74
    self.ROOM_PADDING_H = 0.7
    self.ROOM_PADDING_W = 1
    self.WINDOWTRANS = {
        x = 0,
        y = 0,
        w = tile_width + 2 * self.ROOM_PADDING_W,
        h = tile_height + 2 * self.ROOM_PADDING_H
    }
    self.window_prev = {
        orig_scale = tile_scale,
        w = self.WINDOWTRANS.w * tile_size * tile_scale,
        h = self.WINDOWTRANS.h * tile_size * tile_scale,
        orig_ratio = self.WINDOWTRANS.w * tile_size * tile_scale / (self.WINDOWTRANS.h * tile_size * tile_scale)
    }
end

function Window:init_room()
    self.ROOM = Node(Transform(0, 0, 0, 0))
end

---@param w number 窗口宽度以像素为单位
---@param h number 窗口高度以像素为单位
function Window:init_size(w, h)

end

---初始宽高比例
---@return number
function Window:get_orig_ratio()

end

---初始大小
---@return Size
function Window:get_orig_size()

end

---comment
---@return Size
function Window:get_real_size()

end

function Window:set_real_size(w, h)

end

---@param w number 窗口宽度
---@param h number 窗口高度
function Window:set_transform_wh(w, h)

end

function Window:update()
end

return Window


-- ---@class Room: Object
-- ---@field TILE_W number 宽度为多少个 Tile
-- ---@field TILE_H number 高度为多少个 Tile
-- ---@field root_node Node 根节点
-- ---@field root_attach Moveable 根节点附件
-- Room = Object:extend()
-- function Room:init()
--     self.TILE_W = 20
--     self.TILE_H = 11.5
--     self.ROOM_PADDING_H = 0.7
--     self.ROOM_PADDING_W = 1
--     self.root_node = nil
--     self.root_attach = nil
-- end

-- function Room:get_transform()
--     return Transform(self.ROOM_PADDING_W, self.ROOM_PADDING_H, self.TILE_W, self.TILE_H)
-- end

-- ---包含 padding 的实际大小, 以 Tile 为单位
-- ---@return Size
-- function Room:get_real_size()
--     return Size(self.TILE_W + 2 * self.ROOM_PADDING_W, self.TILE_H + 2 * self.ROOM_PADDING_H)
-- end

-- ---@param node Node 根节点
-- function Room:set_root_node(node)
--     self.root_node = node
--     self.root_node:set_container(node)
--     self.root_attach = Moveable(Transform(0, 0, node.T.w, node.T.h), node)
-- end

-- ---@return Node
-- function Room:get_root_node()
--     return self.root_node
-- end

-- ---@type Room
-- Room.instance = Room()
