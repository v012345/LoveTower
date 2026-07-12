---@class Config: Object
Config = Object:extend()

function Config:init()
    local asset_atli = require "asset.scripts.config.asset_atli"
    self.asset_atli = {}
    for i = 1, #asset_atli do
        local asset = asset_atli[i]
        self.asset_atli[asset.name] = {
            name = asset.name,
            image = love.graphics.newImage(asset.path, { mipmaps = true, dpiscale = 1 }),
            px = asset.px,
            py = asset.py
        }
    end
end

function Config:get_asset_atli()
    return self.asset_atli
end

---@type Config
Config.instance = Config()
