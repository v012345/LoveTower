---@meta

---@class (partial) DynaText:Moveable
---@field config TextConfig

---@class DynaTextConfig
---@field private data DynaTextConfigData
---@field strings DynaTextString[]
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

---@param config? DynaTextConfigData
function DynaText(config) end

---可以理解为一个状态机
---@class DynaTextConfigData
---@field spacing? number 字符间距, 默认值为 0
---@field pop_in_rate? number 弹入速度, 默认值为 3
---@field bump_rate? number 震动速度, 默认值为 2.666
---@field bump_amount? number 震动幅度, 默认值为 1
---@field font? love.Font 字体, 默认值为 Language.instance.LANG.font
---@field shadow boolean
---@field scale number
---@field strings StringConfigData[]
---@field text_offset Vec2
---@field colours Color[]
---@field created_time number
---@field silent boolean
---@field pop_in boolean
---@field W? number 内部计算, 不需要给出
---@field H? number 内部计算, 不需要给出
---@field focused_string number
---@field maxw number
---@field pop_out_time number
---@field pop_out boolean
---@field reset_pop_in boolean
---@field pop_cycle boolean
---@field rotate number
---@field quiver table
---@field pulse table
---@field ref_table table 引用表

---@class StringConfigData
---@field prefix string
---@field suffix string
---@field scale number
---@field outer_colour? Color
---@field colour? Color
---@field ref_table table
---@field ref_value any

---comment
---@param config DynaTextConfigData
---@return DynaTextConfig
function DynaTextConfig(config) end
