---@class (partial) CardConfig : Object
local CardConfig = Object:extend()

function CardConfig:init()
    self.cards = TableParser.instance:parse("card")
end

function CardConfig:get_cards()
    return self.cards
end

---@type CardConfig
CardCfg = CardConfig()
