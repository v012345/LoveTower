---@meta

---@class (partial) GameConfig : Object

---@class GameConfigItem
---@field VERSION string 游戏版本


---@class RenderConfigItem
---@field TILESIZE number
---@field TILESCALE number
---@field TILE_W number
---@field TILE_H number
---@field CARD_W number
---@field CARD_H number


---@class CollabsConfigItem
---@field pos table<string, {x: number, y: number}> 联名花色位置
---@field options table<string, string[]> 联名花色选项