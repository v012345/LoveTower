---@meta

---@class (partial) GameConfig : Object

---@class GameConfigItem
---@field VERSION string 游戏版本
---@field PITCH_MOD number 音高修正


---@class RenderConfigItem
---@field TILESIZE number
---@field TILESCALE number
---@field TILE_W number
---@field TILE_H number
---@field CARD_W number
---@field CARD_H number
---@field DRAW_HASH_BUFF number
---@field HIGHLIGHT_H number
---@field COLLISION_BUFFER number



---@class CollabsConfigItem
---@field pos table<string, {x: number, y: number}> 联名花色位置
---@field options table<string, string[]> 联名花色选项
