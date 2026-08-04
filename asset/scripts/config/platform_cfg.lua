---@class (partial) PlatformConfig : Object
---@field cfg PlatformConfigItem
local PlatformConfig = Object:extend()

function PlatformConfig:init()
    local os = love.system.getOS()
    local platform_table = TableParser.instance:parse("platform")
    self.cfg = platform_table[os] or platform_table['Windows']
end

---@return PlatformConfigItem
function PlatformConfig:get_cfg()
    return self.cfg
end

---@type PlatformConfig
PlatformCfg = PlatformConfig()
