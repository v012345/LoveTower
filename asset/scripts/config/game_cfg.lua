---@class (partial) GameConfig : Object
---@field cfg GameConfigItem
local GameConfig = Object:extend()

function GameConfig:init()
    self.cfg = TableParser.instance:parse("game")["1"]
end

function GameConfig:get_cfg()
    return self.cfg
end

function GameConfig:get_tile_size()
    return self.cfg.TILESIZE
end

function GameConfig:get_tile_scale()
    return self.cfg.TILESCALE
end

function GameConfig:get_tile_width()
    return self.cfg.TILE_W
end

function GameConfig:get_tile_height()
    return self.cfg.TILE_H
end

function GameConfig:get_version()
    return self.cfg.VERSION
end

---@type GameConfig
GameCfg = GameConfig()
