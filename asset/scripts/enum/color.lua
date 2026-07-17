require "asset.scripts.functions.misc_functions"

---@class Color
Color = Color or Object:extend()


Color.MULT = HEX('FE5F55')
Color.CHIPS = HEX("009dff")
Color.MONEY = HEX('f3b958')
Color.XMULT = HEX('FE5F55')
Color.FILTER = HEX('ff9a00')
Color.BLUE = HEX("009dff")
Color.RED = HEX('FE5F55')
Color.GREEN = HEX("4BC292")
Color.PALE_GREEN = HEX("56a887")
Color.ORANGE = HEX("fda200")
Color.IMPORTANT = HEX("ff9a00")
Color.GOLD = HEX('eac058')
Color.YELLOW = { 1, 1, 0, 1 }
Color.CLEAR = { 0, 0, 0, 0 }
Color.WHITE = { 1, 1, 1, 1 }
Color.PURPLE = HEX('8867a5')
Color.BLACK = HEX("374244") --4f6367"),
Color.L_BLACK = HEX("4f6367")
Color.GREY = HEX("5f7377")
Color.CHANCE = HEX("4BC292")
Color.JOKER_GREY = HEX('bfc7d5')
Color.VOUCHER = HEX("cb724c")
Color.BOOSTER = HEX("646eb7")
Color.EDITION = { 1, 1, 1, 1 }
Color.DARK_EDITION = { 0, 0, 0, 1 }
Color.ETERNAL = HEX('c75985')
Color.PERISHABLE = HEX('4f5da1')
Color.RENTAL = HEX('b18f43')
Color.DYN_UI = {
    MAIN = HEX('374244'),
    DARK = HEX('374244'),
    BOSS_MAIN = HEX('374244'),
    BOSS_DARK = HEX('374244'),
    BOSS_PALE = HEX('374244')
}
--For other high contrast suit colours
Color.SO_1 = {
    Hearts = HEX('f03464'),
    Diamonds = HEX('f06b3f'),
    Spades = HEX("403995"),
    Clubs = HEX("235955"),
}
Color.SO_2 = {
    Hearts = HEX('f83b2f'),
    Diamonds = HEX('e29000'),
    Spades = HEX("4f31b9"),
    Clubs = HEX("008ee6"),
}
Color.SUITS = {
    Hearts = HEX('FE5F55'),
    Diamonds = HEX('FE5F55'),
    Spades = HEX("374649"),
    Clubs = HEX("424e54"),
}
Color.UI = {
    TEXT_LIGHT = { 1, 1, 1, 1 },
    TEXT_DARK = HEX("4F6367"),
    TEXT_INACTIVE = HEX("88888899"),
    BACKGROUND_LIGHT = HEX("B8D8D8"),
    BACKGROUND_WHITE = { 1, 1, 1, 1 },
    BACKGROUND_DARK = HEX("7A9E9F"),
    BACKGROUND_INACTIVE = HEX("666666FF"),
    OUTLINE_LIGHT = HEX("D8D8D8"),
    OUTLINE_LIGHT_TRANS = HEX("D8D8D866"),
    OUTLINE_DARK = HEX("7A9E9F"),
    TRANSPARENT_LIGHT = HEX("eeeeee22"),
    TRANSPARENT_DARK = HEX("22222222"),
    HOVER = HEX('00000055'),
}
Color.SET = {
    Default = HEX("cdd9dc"),
    Enhanced = HEX("cdd9dc"),
    Joker = HEX('424e54'),
    Tarot = HEX('424e54'), --HEX('29adff'),
    Planet = HEX("424e54"),
    Spectral = HEX('424e54'),
    Voucher = HEX("424e54"),
}
Color.SECONDARY_SET = {
    Default = HEX("9bb6bdFF"),
    Enhanced = HEX("8389DDFF"),
    Joker = HEX('708b91'),
    Tarot = HEX('a782d1'), --HEX('29adff'),
    Planet = HEX('13afce'),
    Spectral = HEX('4584fa'),
    Voucher = HEX("fd682b"),
    Edition = HEX("4ca893"),
}
Color.RARITY = {
    HEX('009dff'), --HEX("708b91"),
    HEX("4BC292"),
    HEX('fe5f55'),
    HEX("b26cbb")
}
Color.BLIND = {
    Small = HEX("50846e"),
    Big = HEX("50846e"),
    Boss = HEX("b44430"),
    won = HEX("4f6367")
}
Color.HAND_LEVELS = {
    HEX("efefef"),
    HEX("95acff"),
    HEX("65efaf"),
    HEX('fae37e'),
    HEX('ffc052'),
    HEX('f87d75'),
    HEX('caa0ef')
}
Color.BACKGROUND = {
    L = { 1, 1, 0, 1 },
    D = HEX("374244"),
    C = HEX("374244"),
    contrast = 1
}


Color.HAND_LEVELS[0] = Color.RED
Color.UI_CHIPS = copy_table(Color.BLUE)
Color.UI_MULT = copy_table(Color.RED)
