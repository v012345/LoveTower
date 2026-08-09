---@class (partial) CardConfig : Object
local CardConfig = Object:extend()

function CardConfig:init()
    local jokers = TableParser.instance:parse("joker")
    local booster_packs = TableParser.instance:parse("booster_pack")
    local editions = TableParser.instance:parse("edition")
    local spectral = TableParser.instance:parse("spectral")
    local backs = TableParser.instance:parse("back")
    self.card_config = TableParser.instance:parse("card_config")
    self.unlock_condition = TableParser.instance:parse("unlock_condition")

    self.backs = {}
    for id, row in pairs(backs) do
        self.backs[id] = setmetatable({
            config = self.card_config[id],
            discovered = row.discovered,
            unlocked = row.unlocked,
            omit = row.omit,
        }, { __index = row })
    end

    self.spectral = {}
    for id, row in pairs(spectral) do
        self.spectral[id] = setmetatable({
            config = self.card_config[id],
            discovered = row.discovered,
            hidden = row.hidden,
        }, { __index = row })
    end

    self.editions = {}
    for id, row in pairs(editions) do
        self.editions[id] = setmetatable({
            config = self.card_config[id],
            discovered = row.discovered,
        }, { __index = row })
    end

    self.booster_packs = {}
    for id, row in pairs(booster_packs) do
        self.booster_packs[id] = setmetatable({
            config = self.card_config[id],
            discovered = row.discovered,
        }, { __index = row })
    end

    self.jokers = {}
    for id, row in pairs(jokers) do
        -- 可写外壳: 读不到的字段回退到只读配置行, 运行时字段写在外壳上, 不污染配置表
        self.jokers[id] = setmetatable({
            config = self.card_config[id],
            unlock_condition = self.unlock_condition[id],
            discovered = row.discovered,
            unlocked = row.unlocked,
        }, { __index = row })
    end
end

-- function CardConfig:get_tags()
--     return self.tags
-- end

---@type CardConfig
CardCfg = CardConfig()
