---@class (partial) StringConfig: GameObject
StringConfig = GameObject:extend()

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
    self.W_offset = 0
    self.H_offset = 0
    return self
end
