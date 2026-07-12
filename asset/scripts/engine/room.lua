---@class Room: Object
---@field TILE_W number 宽度为多少个 Tile
---@field TILE_H number 高度为多少个 Tile
Room = Object:extend()
function Room:init()
    self.TILE_W = 20
    self.TILE_H = 11.5
    self.ROOM_PADDING_H = 0.7
    self.ROOM_PADDING_W = 1
end

---包含 padding 的实际大小, 以 Tile 为单位
---@return Size
function Room:get_real_size()
    return Size(self.TILE_W + 2 * self.ROOM_PADDING_W, self.TILE_H + 2 * self.ROOM_PADDING_H)
end

Room.instance = Room()
