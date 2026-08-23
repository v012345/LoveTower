---@class (partial) StakeConfig : GameObject
local StakeConfig = GameObject:extend()

function StakeConfig:init()
    local stake_rows = TableParser.instance:parse("stake")
    self.stakes = {}
    for id, row in pairs(stake_rows) do
        -- 可写外壳: 读不到的字段回退到只读配置行, 运行时字段写在外壳上, 不污染配置表
        self.stakes[id] = setmetatable({
            unlocked = row.unlocked,
        }, { __index = row })
    end
end

function StakeConfig:get_stakes()
    return self.stakes
end

---@type StakeConfig
StakeCfg = StakeConfig()
