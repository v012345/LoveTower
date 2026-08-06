---@class (partial) TagConfig : Object
local TagConfig = Object:extend()

function TagConfig:init()
    self.tag = TableParser.instance:parse("tag")
    self.tag_config = TableParser.instance:parse("tag_config")
    for _, tag in pairs(self.tag) do
        -- print(tag.Id)
        tag.config = self.tag_config[tag.Id]
    end
    print()
    print()
    print()
end

---@type TagConfig
TagCfg = TagConfig()
