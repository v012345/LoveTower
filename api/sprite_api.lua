---@class (partial) Sprite: Moveable
---@field atlas AtlasConfigItem
---@field draw_steps DrawStep[]

---@class DataSendToShader
---@field name string
---@field val? any
---@field ref_table? table
---@field ref_value?string

---@class DrawStep
---@field shader string
---@field send? DataSendToShader[]
---@field shadow_height? number
---@field ms? number
---@field mr? number
---@field mx? number
---@field my? number
---@field no_tilt? boolean
---@field other_obj? Sprite 在概率是一个 Sprite
