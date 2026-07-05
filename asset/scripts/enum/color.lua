require "asset.scripts.functions.misc_functions"

Enum = Enum or {}
Enum.Color = {
    MULT = HEX('FE5F55'),
    CHIPS = HEX("009dff"),
    MONEY = HEX('f3b958'),
    XMULT = HEX('FE5F55'),
    FILTER = HEX('ff9a00'),
    BLUE = HEX("009dff"),
    RED = HEX('FE5F55'),
    GREEN = HEX("4BC292"),
    PALE_GREEN = HEX("56a887"),
    ORANGE = HEX("fda200"),
    IMPORTANT = HEX("ff9a00"),
    GOLD = HEX('eac058'),
    YELLOW = { 1, 1, 0, 1 },
    CLEAR = { 0, 0, 0, 0 },
    WHITE = { 1, 1, 1, 1 },
    PURPLE = HEX('8867a5'),
    BLACK = HEX("374244"), --4f6367"),
    L_BLACK = HEX("4f6367"),
    GREY = HEX("5f7377"),
    CHANCE = HEX("4BC292"),
    JOKER_GREY = HEX('bfc7d5'),
    VOUCHER = HEX("cb724c"),
    BOOSTER = HEX("646eb7"),
    EDITION = { 1, 1, 1, 1 },
    DARK_EDITION = { 0, 0, 0, 1 },
    ETERNAL = HEX('c75985'),
    PERISHABLE = HEX('4f5da1'),
    RENTAL = HEX('b18f43'),
    DYN_UI = {
        MAIN = HEX('374244'),
        DARK = HEX('374244'),
        BOSS_MAIN = HEX('374244'),
        BOSS_DARK = HEX('374244'),
        BOSS_PALE = HEX('374244')
    },
    --For other high contrast suit colours
    SO_1 = {
        Hearts = HEX('f03464'),
        Diamonds = HEX('f06b3f'),
        Spades = HEX("403995"),
        Clubs = HEX("235955"),
    },
    SO_2 = {
        Hearts = HEX('f83b2f'),
        Diamonds = HEX('e29000'),
        Spades = HEX("4f31b9"),
        Clubs = HEX("008ee6"),
    },
    SUITS = {
        Hearts = HEX('FE5F55'),
        Diamonds = HEX('FE5F55'),
        Spades = HEX("374649"),
        Clubs = HEX("424e54"),
    },
    UI = {
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
    },
    SET = {
        Default = HEX("cdd9dc"),
        Enhanced = HEX("cdd9dc"),
        Joker = HEX('424e54'),
        Tarot = HEX('424e54'), --HEX('29adff'),
        Planet = HEX("424e54"),
        Spectral = HEX('424e54'),
        Voucher = HEX("424e54"),
    },
    SECONDARY_SET = {
        Default = HEX("9bb6bdFF"),
        Enhanced = HEX("8389DDFF"),
        Joker = HEX('708b91'),
        Tarot = HEX('a782d1'), --HEX('29adff'),
        Planet = HEX('13afce'),
        Spectral = HEX('4584fa'),
        Voucher = HEX("fd682b"),
        Edition = HEX("4ca893"),
    },
    RARITY = {
        HEX('009dff'), --HEX("708b91"),
        HEX("4BC292"),
        HEX('fe5f55'),
        HEX("b26cbb")
    },
    BLIND = {
        Small = HEX("50846e"),
        Big = HEX("50846e"),
        Boss = HEX("b44430"),
        won = HEX("4f6367")
    },
    HAND_LEVELS = {
        HEX("efefef"),
        HEX("95acff"),
        HEX("65efaf"),
        HEX('fae37e'),
        HEX('ffc052'),
        HEX('f87d75'),
        HEX('caa0ef')
    },
    BACKGROUND = {
        L = { 1, 1, 0, 1 },
        D = HEX("374244"),
        C = HEX("374244"),
        contrast = 1
    }
}

Enum.Color.HAND_LEVELS[0] = Enum.Color.RED
Enum.Color.UI_CHIPS = copy_table(Enum.Color.BLUE)
Enum.Color.UI_MULT = copy_table(Enum.Color.RED)
