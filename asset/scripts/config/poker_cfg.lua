---@class (partial) PokerConfig : GameObject
local PokerConfig = GameObject:extend()

function PokerConfig:init()
    self.cards = TableParser.instance:parse("poker")
end

function PokerConfig:get_pokers()
    return self.cards
end

---@type PokerConfig
PokerCfg = PokerConfig()
