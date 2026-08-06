---@class (partial) TagConfig : Object
local TagConfig = Object:extend()

function TagConfig:init()
    local tag_rows = TableParser.instance:parse("tag")
    self.tag_config = TableParser.instance:parse("tag_config")

    self.tag = {}
    for id, row in pairs(tag_rows) do
        -- 可写外壳: 读不到的字段回退到只读配置行, 运行时字段写在外壳上, 不污染配置表
        self.tag[id] = setmetatable({
            config = self.tag_config[id],
        }, { __index = row })
    end
end

---@type TagConfig
TagCfg = TagConfig()
