---@class (partial) AtlasConfig : Object
local AtlasConfig = Object:extend()

function AtlasConfig:init()
    self.cfg = TableParser.instance:parse("atlas")
end

---@type AtlasConfig
AtlasCfg = AtlasConfig()
