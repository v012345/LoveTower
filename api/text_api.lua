---@class DynaText : Moveable
---@field config DynaTextConfig
---@field shadow boolean
---@field scale number
---@field pop_in_rate number
---@field bump_rate number
---@field bump_amount number
---@field font FontConfig
---@field colours Color[]
---@field strings DynaTextString[]

---@class DynaTextConfig
---@field X number
---@field Y number
---@field W number
---@field H number
---@field scale number
---@field string string[]
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
---@field x_offset number
---@field y_offset number
---@field pop_delay number
---@field text_rot number
---@field reset_pop_in boolean




---@class FontConfig
---@field file string
---@field render_scale number
---@field TEXT_HEIGHT_SCALE number
---@field TEXT_OFFSET Vec2
---@field FONTSCALE number
---@field squish number
---@field DESCSCALE number


---@class DynaTextString
---@field letters string
---@field string string
---@field W_offset number
---@field H_offset number


---@param config? DynaTextConfig
function DynaText(config) end
