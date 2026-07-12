---@class Room: Object
---@field TILE_W number 宽度为多少个 Tile
---@field TILE_H number 高度为多少个 Tile
---@field root_node Node 根节点
---@field root_attach Moveable 根节点附件
Room = Object:extend()
function Room:init()
    self.TILE_W = 20
    self.TILE_H = 11.5
    self.ROOM_PADDING_H = 0.7
    self.ROOM_PADDING_W = 1
    self.root_node = nil
    self.root_attach = nil
end

function Room:get_transform()
    return Transform(self.ROOM_PADDING_W, self.ROOM_PADDING_H, self.TILE_W, self.TILE_H)
end

---包含 padding 的实际大小, 以 Tile 为单位
---@return Size
function Room:get_real_size()
    return Size(self.TILE_W + 2 * self.ROOM_PADDING_W, self.TILE_H + 2 * self.ROOM_PADDING_H)
end

---@param node Node 根节点
function Room:set_root_node(node)
    self.root_node = node
    self.root_node:set_container(node)
    self.root_attach = Moveable(Transform(0, 0, node.T.w, node.T.h))
    self.root_attach:set_container(node)
end

---@return Node
function Room:get_root_node()
    return self.root_node
end

---@type Room
Room.instance = Room()
