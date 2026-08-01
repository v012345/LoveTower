---@class (partial) DynaTextConfig: Object
DynaTextConfig = Object:extend()

---@param data DynaTextConfigData
function DynaTextConfig:init(data)
    self.data = data
    data.shadow = data.shadow or false
    data.scale = data.scale or 1
    data.pop_in_rate = data.pop_in_rate or 3
    data.bump_rate = data.bump_rate or 2.666
    data.bump_amount = data.bump_amount or 1
    data.font_config = data.font_config or Language.instance.LANG.font
    data.string_config_datas = data.string_config_datas or { {
        font_config = Language.instance.LANG.font,
        prefix = "",
        suffix = "",
        ref_table = { [""] = "HELLO WORLD" },
        ref_value = "",
        scale = 1,
        colour = Color.RED,
        spacing = data.spacing,
        pop_in = data.pop_in
    } }

    self.string_configs = {}
    for k, v in ipairs(data.string_config_datas) do
        self.string_configs[k] = StringConfig(v)
    end
    return self.data
end

---@class (partial) StringConfig: Object
StringConfig = Object:extend()

---@param data StringConfigData
function StringConfig:init(data)
    self.data = data
    self.string = data.prefix .. data.ref_table[data.ref_value] .. data.suffix
    self.letters = {}
    for i, c in utf8.chars(self.string) do
        self.letters[i] = LetterConfig({
            font_config = data.font_config,
            char = c,
            scale = data.scale,
            colour = data.colour,
            spacing = data.spacing,
            pop_in = data.pop_in,
        })
    end
end

---@class (partial) LetterConfig: Object
LetterConfig = Object:extend()

---@param data LetterConfigData
function LetterConfig:init(data)
    self.data = data
    local FONT = self.data.font_config.FONT
    self.letter = love.graphics.newText(FONT, self.data.char)
    self.offset = Vec2()
    self.dims = Vec2()
end

function LetterConfig:__tostring()
    return string.format([[LetterConfig:
    char: %s
    scale: %s
    colour: %s
    offset: %s]], self.data.char, self.data.scale, self.data.colour, self.offset)
end
