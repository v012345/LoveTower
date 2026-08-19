---@class AtlasConfigItem
---@field Id string
---@field name string
---@field path string[]
---@field dpiscale number[]
---@field is_animation boolean
---@field py number 图集中每个元素的高度（像素）
---@field px number 图集中每个元素的宽度（像素）
---@field frames number
---@field image love.Image

---@class (partial) AtlasConfig : Object
---@field cfg table<string, AtlasConfigItem>
local AtlasConfig = Object:extend()

function AtlasConfig:init()
    local atlas_rows = TableParser.instance:parse("atlas")
    self.cfg = {}
    for id, row in pairs(atlas_rows) do
        self.cfg[id] = setmetatable({
            image = nil,
        }, { __index = row })
    end
end

function AtlasConfig:get_cfg()
    return self.cfg
end

---@type AtlasConfig
AtlasCfg = AtlasConfig()
