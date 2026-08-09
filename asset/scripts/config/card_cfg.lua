---@class (partial) CardConfig : Object
local CardConfig = Object:extend()

function CardConfig:init()
    self.c_base = {
        max = 500,
        freq = 1,
        line = 'base',
        name = "Default Base",
        pos = { x = 1, y = 0 },
        set = "Default",
        label = 'Base Card',
        effect = "Base",
        cost_mult = 1.0,
        config = {}
    }
    self.soul = { pos = { x = 0, y = 1 } }
    self.undiscovered_joker = { pos = { x = 5, y = 3 } }
    self.undiscovered_tarot = { pos = { x = 6, y = 3 } }

    self.card_config = TableParser.instance:parse("card_config")
    self.unlock_condition = TableParser.instance:parse("unlock_condition")

    local jokers = TableParser.instance:parse("joker")
    local booster_packs = TableParser.instance:parse("booster_pack")
    local editions = TableParser.instance:parse("edition")
    local spectral = TableParser.instance:parse("spectral")
    local backs = TableParser.instance:parse("back")
    local vouchers = TableParser.instance:parse("voucher")
    local tarots = TableParser.instance:parse("tarot")
    local enhanced = TableParser.instance:parse("enhanced")
    local planets = TableParser.instance:parse("planet")

    self.planets = {}
    for id, row in pairs(planets) do
        self.planets[id] = setmetatable({
            config = self.card_config[id],
            discovered = row.discovered,
        }, { __index = row })
    end

    self.enhanced = {}
    for id, row in pairs(enhanced) do
        self.enhanced[id] = setmetatable({
            config = self.card_config[id],
        }, { __index = row })
    end

    self.tarots = {}
    for id, row in pairs(tarots) do
        self.tarots[id] = setmetatable({
            config = self.card_config[id],
            discovered = row.discovered,
        }, { __index = row })
    end

    self.vouchers = {}
    for id, row in pairs(vouchers) do
        self.vouchers[id] = setmetatable({
            config = self.card_config[id],
            discovered = row.discovered,
            unlocked = row.unlocked,
        }, { __index = row })
    end

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
