---@class (partial) LetterConfig: Object
LetterConfig = Object:extend()

---@param data LetterConfigData
function LetterConfig:init(data)
    self.data = data
    local FONT = self.data.font_config.FONT
    self.letter = love.graphics.newText(FONT, self.data.char)
    self.offset = Vec2()
    self.dims = Vec2()
    return self
end

function LetterConfig:__tostring()
    return string.format([[LetterConfig:
    char: %s
    scale: %s
    colour: %s
    offset: %s]], self.data.char, self.data.scale, self.data.colour, self.offset)
end

function LetterConfig:get_colour()
    return self.data.colour
end

function LetterConfig:get_scale()
    return self.data.scale
end

function LetterConfig:get_offset()
    return self.offset
end
