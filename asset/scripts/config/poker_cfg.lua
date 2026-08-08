---@class (partial) PokerConfig : Object
local PokerConfig = Object:extend()

function PokerConfig:init()
    self.cards = TableParser.instance:parse("poker")
end

function PokerConfig:get_cards()
    return self.cards
end

---@type PokerConfig
PokerCfg = PokerConfig()
