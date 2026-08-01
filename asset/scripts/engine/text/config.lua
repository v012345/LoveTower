---@class (partial) DynaTextConfig: Object
DynaTextConfig = Object:extend()

---@param data DynaTextConfigData
function DynaTextConfig:init(data)
    self.data = data
    self.string_configs = {}
    data.spacing = data.spacing or 0
    data.pop_in_rate = data.pop_in_rate or 3
    data.bump_rate = data.bump_rate or 2.666
    data.bump_amount = data.bump_amount or 1
    data.font = data.font or Language.instance.LANG.font
    data.string_config_datas = data.string_config_datas or {}
    data.colours = data.colours or { Color.RED }
    data.silent = data.silent or false
    data.W = 0
    data.H = 0
    for k, v in ipairs(data.string_config_datas) do
        self.string_configs[k] = StringConfig(v)
    end


    if self.data.maxw and self.data.W > self.data.maxw then
        local old_scale = self.data.scale
        local new_scale = self.data.scale * (self.data.maxw / self.data.W)
        for k, v in ipairs(self.strings) do
            for _, letter in ipairs(v.letters) do
                letter.dims.x = letter.dims.x * new_scale / old_scale
            end
        end
        self.data.scale = new_scale
    end



    for k, v in ipairs(self.strings) do
        v.W_offset = 0.5 * (self.data.W - v.W)
        v.H_offset = 0.5 * (self.data.H - v.H + (self.data.offset_y or 0))
    end
    return self.data
end

---@class (partial) StringConfig: Object
StringConfig = Object:extend()

---@param config StringConfigData
function StringConfig:init(config)
    self.data = config
    config.prefix = config.prefix or ''
    config.suffix = config.suffix or ''
    config.scale = config.scale or 1
    config.outer_colour = config.outer_colour or nil
    config.colour = config.colour or nil
    config.ref_table = config.ref_table or {}
    config.ref_value = config.ref_value or nil
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
