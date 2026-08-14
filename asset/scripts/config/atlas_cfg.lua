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

function AtlasConfig:get_cfg()
    return self.cfg
end

---@type AtlasConfig
AtlasCfg = AtlasConfig()
