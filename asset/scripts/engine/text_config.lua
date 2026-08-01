---@class (partial) DynaTextConfig: Object
DynaTextConfig = Object:extend()

---@class (partial) StringConfig: Object
StringConfig = Object:extend()

---@class (partial) LetterConfig: Object
LetterConfig = Object:extend()

---@param config LetterConfigData
function LetterConfig:init(config)

end

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
    self.strings = {}
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
    for k, v in ipairs(config.strings) do
        local part_a = 0       -- 前缀的索引
        local part_b = 1000000 -- 后缀的索引
        local new_string = nil
        local outer_colour = nil
        local inner_colour = nil
        local part_scale = 1 -- 此字符串的自己的缩放比例, 来自己 DynaTextConfigString 的 scale 属性
        -- 如果 v 是一个表, 就把 v 解出来, 转为一个字符串

        new_string = v.prefix .. tostring(v.ref_table[v.ref_value]) .. v.suffix
        part_a = #v.prefix
        part_b = #new_string - #v.suffix
        part_scale = v.scale
        outer_colour = v.outer_colour or nil
        inner_colour = v.colour or nil


        self.strings[k] = {
            string = new_string,
            letters = {},
            W = 0,
            H = 0,
            W_offset = 0,
            H_offset = 0,
        }
        self.strings[k].string = new_string
        local tempW = 0
        local tempH = 0
        local current_letter = 1 -- 当前字符的索引
        local font_scale = self.font.FONTSCALE

        for _, c in utf8.chars(new_string) do
            local letters = {}
            ---@type DynaTextLetter
            local let_tab = {
                letter = love.graphics.newText(self.font.FONT, c),
                char = c,
                scale = part_scale,
                r = 0,
                offset = { x = 0, y = 0 },
                dims = {
                    x = (self.font.FONT:getWidth(c) * part_scale + 2.7 * self.config.spacing) * self.config.scale,
                    y = self.font.FONT:getHeight() * part_scale * self.font.TEXT_HEIGHT_SCALE * self.config.scale
                },
                pop_in = 1,
                prefix = current_letter <= part_a and outer_colour or nil,
                suffix = current_letter > part_b and outer_colour or nil,
                colour = inner_colour or nil
            }

            tempW = tempW + let_tab.dims.x * font_scale / Tile.instance.TILESIZE
            tempH = math.max(let_tab.dims.y * font_scale / Tile.instance.TILESIZE, tempH)
            letters[current_letter] = let_tab
            self.strings[k].letters = letters
            current_letter = current_letter + 1
        end

        self.strings[k].W = tempW
        self.strings[k].H = tempH
        -- self.config.W 和 self.config.H 是所有字符串中最大的宽度和高度

        if self.strings[k].W > self.config.W then
            self.config.W = self.strings[k].W
        end
        if self.strings[k].H > self.config.H then
            self.config.H = self.strings[k].H
        end
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
