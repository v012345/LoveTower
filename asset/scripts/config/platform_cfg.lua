---@class (partial) PlatformConfig : Object
---@field cfg PlatformConfigItem
local PlatformConfig = Object:extend()

function PlatformConfig:init()
    self.cfg = TableParser.instance:parse("platform")["1"]
end

function PlatformConfig:get_tile_size()
    return self.cfg.TILESIZE
end

function PlatformConfig:get_tile_scale()
    return self.cfg.TILESCALE
end

function PlatformConfig:get_tile_width()
    return self.cfg.TILE_W
end

function PlatformConfig:get_tile_height()
    return self.cfg.TILE_H
end

---@type PlatformConfig
PlatformCfg = PlatformConfig()
