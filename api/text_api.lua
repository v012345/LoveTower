---@meta

---@class (partial) DynaText:Moveable
---@field config DynaTextConfig

---@class DynaTextConfig
---@field private data DynaTextConfigData
---@field strings StringConfig[]
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


---@class StringConfig
---@field W number
---@field H number
---@field letters DynaTextLetter[]
---@field string string
---@field W_offset number
---@field H_offset number

---@class StringConfigData
---@field prefix string
---@field suffix string
---@field scale number
---@field outer_colour? Color
---@field colour? Color
---@field ref_table table
---@field ref_value any



---@class LetterConfig
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
---@field scale number
---@field spacing number
---@field font FontConfig
---@field colour Color



---@class FontConfig
---@field file string
---@field render_scale number
---@field TEXT_HEIGHT_SCALE number
---@field TEXT_OFFSET Vec2
---@field FONTSCALE number
---@field squish number
---@field DESCSCALE number
---@field FONT love.Font


---comment
---@param config LetterConfigData
---@return LetterConfig
function LetterConfig(config) end

---@param config? DynaTextConfigData
function DynaText(config) end

---comment
---@param config DynaTextConfigData
---@return DynaTextConfig
function DynaTextConfig(config) end

---comment
---@param config StringConfigData
---@return StringConfig
function StringConfig(config) end
