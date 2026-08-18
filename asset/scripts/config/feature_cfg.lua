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

function FeatureConfig:is_http_scores_enabled()
    return self.cfg.F_HTTP_SCORES or true
end

---@return FeatureConfig
function FeatureConfig:get_instance()
    return self
end

---@return boolean
function FeatureConfig:is_perf_overlay_enabled()
    return self.cfg.F_ENABLE_PERF_OVERLAY
end

---@return boolean
function FeatureConfig:is_hide_bg()
    return self.cfg.F_HIDE_BG
end

---@type FeatureConfig
FeatureCfg = FeatureConfig()
