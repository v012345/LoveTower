---@class (partial) GameConfig : Object
---@field cfg GameConfigItem
local GameConfig = Object:extend()

function GameConfig:init()
    self.cfg = TableParser.instance:parse("game")["1"]
    local collabs = TableParser.instance:parse("collabs")["1"]
    self.collabs = {
        pos = { Jack = { x = 0, y = 0 }, Queen = { x = 1, y = 0 }, King = { x = 2, y = 0 } },
        options = collabs
    }
end

function GameConfig:get_card_size()
    return self.cfg.CARD_W, self.cfg.CARD_H
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

function GameConfig:get_starting_params()
    return {
        dollars = 4,
        hand_size = 8,
        discards = 3,
        hands = 4,
        reroll_cost = 5,
        joker_slots = 5,
        ante_scaling = 1,
        consumable_slots = 2,
        no_faces = false,
        erratic_suits_and_ranks = false,
    }
end

function GameConfig:get_collabs()
    return self.collabs
end

---@type GameConfig
GameCfg = GameConfig()
