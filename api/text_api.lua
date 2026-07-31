---@meta

---@class (partial) DynaText:Moveable
---@field config TextConfig

---@class TextConfig
---@field X number
---@field Y number
---@field W number string 中的字符串在经过 init_string 后, 计算出的最大宽度
---@field H number
---@field scale number
---@field string string[]|DynaTextConfigString[] 要显示的字符串
---@field maxw? number 如果设置了, 则当字符串的宽度大于 maxw 时, 会自动缩放字符串, 以适应到 maxw 的宽度
---@field colours Color[]
---@field float boolean
---@field shadow boolean 是否显示阴影
---@field silent boolean
---@field pop_in number
---@field pop_out number
---@field pop_in_rate number
---@field bump_rate number
---@field bump_amount number
---@field font FontConfig
---@field x_offset number
---@field y_offset number
---@field pop_delay number
---@field text_rot number
---@field reset_pop_in boolean
---@field spacing number 字符间距
---@field random_element boolean 这个完全就是为了`错印小丑`准备的




---@class DynaTextConfigString
---@field ref_table table 引用表
---@field ref_value string 引用值
---@field prefix string
---@field suffix string
---@field scale number 此字符串的自己的缩放比例
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
---@field FONT love.Font


---@class DynaTextString
---@field letters DynaTextLetter[]
---@field string string
---@field W_offset number 让字符串在水平方向上居中的偏移量
---@field H_offset number 让字符串在垂直方向上居中的偏移量
---@field W number letters 中的字符串在经过 update_text 后, 计算出的以 Tile 为单位的字符串的宽度
---@field H number letters 中的字符串在经过 update_text 后, 计算出的以 Tile 为单位的字符串的高度


---@class DynaTextLetter
---@field letter love.Text
---@field char string
---@field scale number
---@field offset Vec2
---@field dims Vec2
---@field pop_in number
---@field prefix Color|nil 如果当前字符是前缀字符, 则此颜色会应用到当前字符
---@field suffix Color|nil 如果当前字符是后缀字符, 则此颜色会应用到当前字符
---@field colour Color|nil
---@field r number

---@param config? DynaTextConfig
function DynaText(config) end

---可以理解为一个状态机
---@class TextConfigData
---@field shadow boolean
---@field scale number
---@field pop_in_rate number
---@field bump_rate number
---@field bump_amount number
---@field font FontConfig
---@field string string[] 待定, 最终需要被处理成 DynaTextString[]
---@field text_offset Vec2
---@field colours Color[]
---@field created_time number
---@field silent boolean
---@field pop_in boolean
---@field W number
---@field H number
---@field focused_string number
---@field maxw number
---@field pop_out_time number
---@field pop_out boolean
---@field reset_pop_in boolean
---@field pop_cycle boolean
---@field rotate number
---@field quiver table
---@field pulse table

---comment
---@param config TextConfigData
---@return TextConfig
function TextConfig(config) end
