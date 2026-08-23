---@class (partial) FontConfig : GameObject
---@field ids string[]
---@field cfg_items FontConfigItem[]
local FontConfig = GameObject:extend()

function FontConfig:init()
    self.ids = {}
    self.cfg_items = {}
    ---@type FontConfigItem[]
    local font_table = TableParser.instance:parse("font")
    local tile_size = GameCfg:get_tile_size()
    for _, font_item in pairs(font_table) do
        self.ids[#self.ids + 1] = font_item.Id

        local cfg_item = {}
        for key, value in pairs(font_item) do
            cfg_item[key] = value
        end
        cfg_item.FONT = love.graphics.newFont(font_item.file, font_item.render_scale * tile_size)
        self.cfg_items[font_item.Id] = cfg_item
    end
end

function FontConfig:get_ids()
    return self.ids
end

---@param id string
---@return FontConfigItem
function FontConfig:get_cfg_item(id)
    return self.cfg_items[id]
end

---@type FontConfig
FontCfg = FontConfig()
