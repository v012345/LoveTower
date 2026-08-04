---@class (partial) FontConfig : Object
local FontConfig = Object:extend()

function FontConfig:init()
    local font_table = TableParser.instance:parse("font")
    print(GameCfg:get_tile_size())
    -- for _, font_item in pairs(font_table) do
    --     print(font_item)
    --     -- self[font_item.id] = font_item
    -- end
end

FontCfg = FontConfig()
