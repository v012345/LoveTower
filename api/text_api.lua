---@meta

---@class (partial) DynaText:Moveable
---@field config DynaTextConfig
---@field data DynaTextData

---@class DynaTextData
---@field dyna_text_config_data DynaTextConfigData
---@field X number
---@field Y number

---@class DynaTextConfig
---@field private data DynaTextConfigData
---@field string_configs StringConfig[]
---@field x_offset number
---@field y_offset number
---@field pop_delay number
---@field text_rot number
---@field reset_pop_in boolean
---@field spacing number 字符间距
---@field random_element boolean 这个完全就是为了`错印小丑`准备的


---可以理解为一个状态机
---@class DynaTextConfigData
---@field spacing? number 字符间距, 默认值为 0
---@field pop_in_rate? number 弹入速度, 默认值为 3
---@field bump_rate? number 震动速度, 默认值为 2.666
---@field bump_amount? number 震动幅度, 默认值为 1
---@field font? FontConfig 字体, 默认值为 Language.instance.LANG.font
---@field shadow boolean
---@field scale number
---@field string_config_datas StringConfigData[]
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


---@class StringConfig
---@field W number
---@field H number
---@field letters LetterConfig[]
---@field string string
---@field W_offset number
---@field H_offset number

---@class StringConfigData
---@field font_config FontConfig
---@field prefix string
---@field suffix string
---@field ref_table table
---@field ref_value any
---@field scale number
---@field colour Color
---@field pop_in number
---@field spacing number



---@class LetterConfig
---@field data LetterConfigData
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


---@class LetterConfigData
---@field char string
---@field scale number
---@field spacing number
---@field font_config FontConfig
---@field colour Color
---@field pop_in number



---@class FontConfig
---@field file string
---@field render_scale number
---@field TEXT_HEIGHT_SCALE number
---@field TEXT_OFFSET Vec2
---@field FONTSCALE number
---@field squish number
---@field DESCSCALE number
---@field FONT love.Font

---@param config? DynaTextData
function DynaText(config) end

---comment
---@param config DynaTextConfigData
---@return DynaTextConfig
function DynaTextConfig(config) end

---comment
---@param config LetterConfigData
---@return LetterConfig
function LetterConfig(config) end

---comment
---@param config StringConfigData
---@return StringConfig
function StringConfig(config) end
