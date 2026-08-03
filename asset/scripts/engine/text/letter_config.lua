---@class (partial) LetterConfig: Object
LetterConfig = Object:extend()

---@param data LetterConfigData
function LetterConfig:init(data)
    self.data = data
    data.scale = data.scale or 1
    local FONT = self.data.font_config.FONT
    self.letter = love.graphics.newText(FONT, self.data.char)
    print(data.char, FONT:getWidth(data.char), FONT:getHeight())

    local tile_scale = Tile.instance:get_scale()
    local font_scale = self.data.font_config.FONTSCALE
    local letter_width = FONT:getWidth(data.char)
    local scale = data.scale



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

---字母的颜色
---@return Color
function LetterConfig:get_colour()
    return self.data.colour
end

function LetterConfig:get_scale()
    return self.data.scale
end

function LetterConfig:get_offset()
    return self.offset
end

function LetterConfig:get_letter()
    return self.letter
end
