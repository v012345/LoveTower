---@class Tile: Object
---@field private init_scale number 初始缩放,用于窗口大小变化时, 计算新的缩放
local Tile = Object:extend()

function Tile:init()
    self.TRANS = Transform(0, 0, 0, 0)
    self.real_size = Size(0, 0)
    self.orig_size = Size(0, 0)
    self.orig_scale = 0

    self.TILESCALE = 3.65
    self.TILESIZE = 20
    self.init_scale = self.TILESCALE
end

function Tile:get_init_scale()
    return self.init_scale
end

---@return number
function Tile:get_scale()
    return self.TILESCALE
end

function Tile:set_scale(scale)
    self.TILESCALE = scale
end

return Tile
