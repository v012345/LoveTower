---@class (partial) BlindConfig : Object
local BlindConfig = Object:extend()

function BlindConfig:init()
    local blind_rows = TableParser.instance:parse("blind")


    self.blinds = {}
    for id, row in pairs(blind_rows) do
        self.blinds[id] = setmetatable({
            defeated = row.defeated,
        }, { __index = row })
    end
end

function BlindConfig:get_blinds()
    return self.blinds
end

---@type BlindConfig
BlindCfg = BlindConfig()
