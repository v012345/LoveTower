---@class (partial) SealConfig : Object
local SealConfig = Object:extend()

function SealConfig:init()
    local seal_rows = TableParser.instance:parse("seal")
    self.seals = {}
    for id, row in pairs(seal_rows) do
        -- 可写外壳: 读不到的字段回退到只读配置行, 运行时字段写在外壳上, 不污染配置表
        self.seals[id] = setmetatable({
            discovered = row.discovered,
        }, { __index = row })
    end
end

function SealConfig:get_seals()
    return self.seals
end

---@type SealConfig
SealCfg = SealConfig()
