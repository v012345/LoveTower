---@class DynaText : Moveable
---@field config DynaTextConfig
---@field shadow boolean
---@field scale number
---@field pop_in_rate number
---@field bump_rate number
---@field bump_amount number
---@field font FontConfig
---@field colours Color[]

---@class DynaTextConfig
---@field scale number
---@field string string|table
---@field maxw number
---@field colours Color[]
---@field float boolean
---@field shadow boolean
---@field silent boolean
---@field pop_in number
---@field pop_in_rate number
---@field bump_rate number
---@field bump_amount number
---@field font FontConfig



---@class FontConfig
---@field file string
---@field render_scale number
---@field TEXT_HEIGHT_SCALE number
---@field TEXT_OFFSET Vec2
---@field FONTSCALE number
---@field squish number
---@field DESCSCALE number

---@param config DynaTextConfig
function DynaText(config) end
