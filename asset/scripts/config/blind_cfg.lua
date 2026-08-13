---@class Blind
---@field Id string ID
---@field defeated boolean 是否已击败
---@field mult number 倍数
---@field vars string[] 变量
---@field debuff_text string 减益文本
---@field debuff table 减益
---@field name string 名称
---@field pos Vec2 位置
---@field dollars number 美元
---@field order number 顺序
---@field is_boss boolean 是否是is_boss
---@field boss_colour string Boss颜色
---@field boss {showdown:boolean,min:number,max:number} Boss

---@class (partial) BlindConfig : Object
---@field blinds table<string, Blind> 盲注
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

---@return table<string, Blind>
function BlindConfig:get_blinds()
    return self.blinds
end

---@type BlindConfig
BlindCfg = BlindConfig()
