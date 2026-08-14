---@class (partial) FeatureConfig : Object
---@field cfg FeatureConfigItem
local FeatureConfig = Object:extend()

function FeatureConfig:init()
    local os = love.system.getOS()
    local feature_table = TableParser.instance:parse("feature")
    self.cfg = feature_table[os] or feature_table['Windows']
end

---@return FeatureConfigItem
function FeatureConfig:get_cfg()
    return self.cfg
end

---@return boolean
function FeatureConfig:is_cta_enabled()
    return self.cfg.F_CTA
end

---@return boolean
function FeatureConfig:is_sound_thread_enabled()
    return self.cfg.F_SOUND_THREAD
end

---@type FeatureConfig
FeatureCfg = FeatureConfig()
