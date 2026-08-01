---@class (partial) DynaTextConfig: Object
DynaTextConfig = Object:extend()

---@param data DynaTextConfigData
function DynaTextConfig:init(data)
    self.data = data
    self.string_configs = {}
    for k, v in ipairs(data.string_config_datas) do
        self.string_configs[k] = StringConfig(v)
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
