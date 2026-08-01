---@class (partial) DynaTextConfig: Object
DynaTextConfig = Object:extend()

---@class (partial) StringConfig: Object
StringConfig = Object:extend()

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

---@param config DynaTextConfigData
function DynaTextConfig:init(config)
    self.data = config
    self.string_configs = {}
    config.spacing = config.spacing or 0
    config.pop_in_rate = config.pop_in_rate or 3
    config.bump_rate = config.bump_rate or 2.666
    config.bump_amount = config.bump_amount or 1
    config.font = config.font or Language.instance.LANG.font
    config.strings = config.strings or {}
    config.colours = config.colours or { Color.RED }
    config.silent = config.silent or false
    config.W = 0
    config.H = 0
    for k, v in ipairs(config.string_config_datas) do
      self.string_configs[k] = StringConfig(v)
    end


    if self.config.maxw and self.config.W > self.config.maxw then
        local old_scale = self.config.scale
        local new_scale = self.config.scale * (self.config.maxw / self.config.W)
        for k, v in ipairs(self.strings) do
            for _, letter in ipairs(v.letters) do
                letter.dims.x = letter.dims.x * new_scale / old_scale
            end
        end
        self.config.scale = new_scale
    end



    for k, v in ipairs(self.strings) do
        v.W_offset = 0.5 * (self.config.W - v.W)
        v.H_offset = 0.5 * (self.config.H - v.H + (self.config.offset_y or 0))
    end
    return self.config
end
