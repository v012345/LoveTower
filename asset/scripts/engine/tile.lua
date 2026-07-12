---@class Tile: Object
---@field private init_scale number 初始缩放,用于窗口大小变化时, 计算新的缩放
Tile = Object:extend()
function Tile:init()
    self.TRANS = Transform(0, 0, 0, 0)
    self.real_size = Size(0, 0)
    self.orig_size = Size(0, 0)
    self.orig_scale = 0

    self.TILE_W = 20
    self.TILE_H = 11.5
    self.TILESCALE = 3.65
    self.TILESIZE = 20
    self.init_scale = self.TILESCALE
end

function Tile:get_init_scale()
    return Size(self.TILE_W, self.TILE_H)
end

function Tile:set_scale(scale)
    self.TILESCALE = scale
end

---每个 Tile 以像素为单位的大小, Tile 就是方形的!
---@return number
function Tile:get_pixels_per_tile()
    return self.TILESCALE * self.TILESIZE
end

Tile.instance = Tile()
