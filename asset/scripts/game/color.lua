---@class Color
Color = setmetatable({}, { __call = function(...) return RGBA(...) end })


---@class RGBA
RGBA = Object:extend()

---@param r number|table|string
---@param g number|nil
---@param b number|nil
---@param a number|nil
function RGBA:init(r, g, b, a)
    if type(r) == "table" then
        self.r = r[1] or 0
        self.g = r[2] or 0
        self.b = r[3] or 0
        self.a = r[4] or 255
    elseif type(r) == "string" then
        if #r <= 6 then r = r .. "FF" end
        local _, _, R, G, B, A = r:find('(%x%x)(%x%x)(%x%x)(%x%x)')
        self.r = tonumber(R, 16) / 255 or 0
        self.g = tonumber(G, 16) / 255 or 0
        self.b = tonumber(B, 16) / 255 or 0
        self.a = tonumber(A, 16) / 255 or 255
    else
        self.r = r or 0
        self.g = g or 0
        self.b = b or 0
        self.a = a or 255
    end
    self[1] = self.r
    self[2] = self.g
    self[3] = self.b
    self[4] = self.a
end

function RGBA:get_r()
    return self.r
end

function RGBA:get_g()
    return self.g
end

function RGBA:get_b()
    return self.b
end

function RGBA:get_a()
    return self.a
end

function RGBA:__tostring()
    return string.format("RGBA(%s, %s, %s, %s)", self.r, self.g, self.b, self.a)
end

Color.MULT = RGBA('FE5F55')
Color.CHIPS = RGBA("009dff")
Color.MONEY = RGBA('f3b958')
Color.XMULT = RGBA('FE5F55')
Color.FILTER = RGBA('ff9a00')
Color.BLUE = RGBA("009dff")
Color.RED = RGBA('FE5F55')
Color.GREEN = RGBA("4BC292")
Color.PALE_GREEN = RGBA("56a887")
Color.ORANGE = RGBA("fda200")
Color.IMPORTANT = RGBA("ff9a00")
Color.GOLD = RGBA('eac058')
Color.YELLOW = { 1, 1, 0, 1 }
Color.CLEAR = { 0, 0, 0, 0 }
Color.WHITE = { 1, 1, 1, 1 }
Color.PURPLE = RGBA('8867a5')
Color.BLACK = RGBA("374244") --4f6367"),
Color.L_BLACK = RGBA("4f6367")
Color.GREY = RGBA("5f7377")
Color.CHANCE = RGBA("4BC292")
Color.JOKER_GREY = RGBA('bfc7d5')
Color.VOUCHER = RGBA("cb724c")
Color.BOOSTER = RGBA("646eb7")
Color.EDITION = { 1, 1, 1, 1 }
Color.DARK_EDITION = { 0, 0, 0, 1 }
Color.ETERNAL = RGBA('c75985')
Color.PERISHABLE = RGBA('4f5da1')
Color.RENTAL = RGBA('b18f43')
Color.DYN_UI = {
    MAIN = RGBA('374244'),
    DARK = RGBA('374244'),
    BOSS_MAIN = RGBA('374244'),
    BOSS_DARK = RGBA('374244'),
    BOSS_PALE = RGBA('374244')
}
--For other high contrast suit colours
Color.SO_1 = {
    Hearts = RGBA('f03464'),
    Diamonds = RGBA('f06b3f'),
    Spades = RGBA("403995"),
    Clubs = RGBA("235955"),
}
Color.SO_2 = {
    Hearts = RGBA('f83b2f'),
    Diamonds = RGBA('e29000'),
    Spades = RGBA("4f31b9"),
    Clubs = RGBA("008ee6"),
}
Color.SUITS = {
    Hearts = RGBA('FE5F55'),
    Diamonds = RGBA('FE5F55'),
    Spades = RGBA("374649"),
    Clubs = RGBA("424e54"),
}
Color.UI = {
    TEXT_LIGHT = { 1, 1, 1, 1 },
    TEXT_DARK = RGBA("4F6367"),
    TEXT_INACTIVE = RGBA("88888899"),
    BACKGROUND_LIGHT = RGBA("B8D8D8"),
    BACKGROUND_WHITE = { 1, 1, 1, 1 },
    BACKGROUND_DARK = RGBA("7A9E9F"),
    BACKGROUND_INACTIVE = RGBA("666666FF"),
    OUTLINE_LIGHT = RGBA("D8D8D8"),
    OUTLINE_LIGHT_TRANS = RGBA("D8D8D866"),
    OUTLINE_DARK = RGBA("7A9E9F"),
    TRANSPARENT_LIGHT = RGBA("eeeeee22"),
    TRANSPARENT_DARK = RGBA("22222222"),
    HOVER = RGBA('00000055'),
}
Color.SET = {
    Default = RGBA("cdd9dc"),
    Enhanced = RGBA("cdd9dc"),
    Joker = RGBA('424e54'),
    Tarot = RGBA('424e54'), --RGBA('29adff'),
    Planet = RGBA("424e54"),
    Spectral = RGBA('424e54'),
    Voucher = RGBA("424e54"),
}
Color.SECONDARY_SET = {
    Default = RGBA("9bb6bdFF"),
    Enhanced = RGBA("8389DDFF"),
    Joker = RGBA('708b91'),
    Tarot = RGBA('a782d1'), --RGBA('29adff'),
    Planet = RGBA('13afce'),
    Spectral = RGBA('4584fa'),
    Voucher = RGBA("fd682b"),
    Edition = RGBA("4ca893"),
}
Color.RARITY = {
    RGBA('009dff'), --RGBA("708b91"),
    RGBA("4BC292"),
    RGBA('fe5f55'),
    RGBA("b26cbb")
}
Color.BLIND = {
    Small = RGBA("50846e"),
    Big = RGBA("50846e"),
    Boss = RGBA("b44430"),
    won = RGBA("4f6367")
}
Color.HAND_LEVELS = {
    RGBA("efefef"),
    RGBA("95acff"),
    RGBA("65efaf"),
    RGBA('fae37e'),
    RGBA('ffc052'),
    RGBA('f87d75'),
    RGBA('caa0ef')
}
Color.BACKGROUND = {
    L = { 1, 1, 0, 1 },
    D = RGBA("374244"),
    C = RGBA("374244"),
    contrast = 1
}


Color.HAND_LEVELS[0] = Color.RED
Color.UI_CHIPS = Color.BLUE
Color.UI_MULT = Color.RED
