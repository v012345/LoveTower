---@class Config: Object
Config = Object:extend()

function Config:init()
    self.asset_atli = require "asset.scripts.config.asset_atli"
end

function Config:get_asset_atli()
    return self.asset_atli
end

---@type Config
Config.instance = Config()
