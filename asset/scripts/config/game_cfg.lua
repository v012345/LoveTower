---@class (partial) GameConfig : Object
---@field game_cfg GameConfigItem 游戏配置
---@field render_cfg RenderConfigItem 渲染配置
---@field collabs_cfg CollabsConfigItem 联名花色配置
local GameConfig = Object:extend()

function GameConfig:init()
    self.game_cfg = TableParser.instance:parse("game")["1"]
    self.render_cfg = TableParser.instance:parse("render")["1"]
    ---@type table<string, string[]>
    local collabs = TableParser.instance:parse("collabs")["1"]
    self.collabs_cfg = {
        pos = { Jack = { x = 0, y = 0 }, Queen = { x = 1, y = 0 }, King = { x = 2, y = 0 } },
        options = collabs
    }
end

function GameConfig:get_card_size()
    return self.render_cfg.CARD_W, self.render_cfg.CARD_H
end

function GameConfig:get_tile_size()
    return self.render_cfg.TILESIZE
end

function GameConfig:get_tile_scale()
    return self.render_cfg.TILESCALE
end

function GameConfig:get_tile_width()
    return self.render_cfg.TILE_W
end

function GameConfig:get_tile_height()
    return self.render_cfg.TILE_H
end


function GameConfig:get_version()
    return self.game_cfg.VERSION
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
    return self.collabs_cfg
end

---@type GameConfig
GameCfg = GameConfig()
