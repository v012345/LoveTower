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

Room.instance = Room()
