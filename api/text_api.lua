---@class (partial) DynaText:Moveable
---@field config DynaTextConfig
---@field shadow boolean 是否显示阴影
---@field scale number
---@field pop_in_rate number
---@field bump_rate number
---@field bump_amount number
---@field font FontConfig
---@field colours Color[]
---@field strings DynaTextString[] 用来存储 Config.string 处理后的结果

---@class DynaTextConfig
---@field X number
---@field Y number
---@field W number
---@field H number
---@field scale number
---@field string string[]|DynaTextConfigString[]
---@field maxw number
---@field colours Color[]
---@field float boolean
---@field shadow boolean 是否显示阴影
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




---@class DynaTextConfigString
---@field ref_table table 引用表
---@field ref_value string 引用值
---@field prefix string
---@field suffix string
---@field scale number
---@field outer_colour Color
---@field colour Color
---@field string string 如果 ref_table[ref_value] 不存在, 则使用此 string


---@class FontConfig
---@field file string
---@field render_scale number
---@field TEXT_HEIGHT_SCALE number
---@field TEXT_OFFSET Vec2
---@field FONTSCALE number
---@field squish number
---@field DESCSCALE number


---@class DynaTextString
---@field letters DynaTextLetter[]
---@field string string
---@field W_offset number
---@field H_offset number

---@class DynaTextLetter
---@field letter love.Text
---@field char string
---@field scale number
---@field offset Vec2
---@field dims Vec2
---@field pop_in number
---@field prefix string
---@field suffix string
---@field colour Color

---@param config? DynaTextConfig
function DynaText(config) end
