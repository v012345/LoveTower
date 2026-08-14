---@class AtlasConfigItem
---@field Id string
---@field name string
---@field path string[]
---@field dpiscale number[]
---@field is_animation boolean
---@field py number
---@field px number
---@field frames number

---@class (partial) AtlasConfig : Object
---@field cfg table<string, AtlasConfigItem>
local AtlasConfig = Object:extend()

function AtlasConfig:init()
    self.cfg = TableParser.instance:parse("atlas")
end

---@type AtlasConfig
AtlasCfg = AtlasConfig()
