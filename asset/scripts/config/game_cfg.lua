---@class (partial) GameConfig : GameObject
---@field game_cfg GameConfigItem 游戏配置
---@field render_cfg RenderConfigItem 渲染配置
---@field collabs_cfg CollabsConfigItem 联名花色配置
local GameConfig = GameObject:extend()

function GameConfig:init()
    self.game_cfg = TableParser.instance:parse("game")["1"]
    self.render_cfg = TableParser.instance:parse("render")["1"]
    ---@type table<string, string[]>
    local collabs = TableParser.instance:parse("collabs")["1"]
    self.collabs_cfg = {
        pos = { Jack = { x = 0, y = 0 }, Queen = { x = 1, y = 0 }, King = { x = 2, y = 0 } },
        options = collabs
    }
end

function GameConfig:get_card_size()
    return self.render_cfg.CARD_W, self.render_cfg.CARD_H
end

function GameConfig:get_tile_size()
    return self.render_cfg.TILESIZE
end

function GameConfig:get_tile_scale()
    return self.render_cfg.TILESCALE
end

function GameConfig:get_tile_width()
    return self.render_cfg.TILE_W
end

function GameConfig:get_tile_height()
    return self.render_cfg.TILE_H
end

function GameConfig:get_version()
    return self.game_cfg.VERSION
end

function GameConfig:get_starting_params()
    return {
        dollars = 4,
        hand_size = 8,
        discards = 3,
        hands = 4,
        reroll_cost = 5,
        joker_slots = 5,
        ante_scaling = 1,
        consumable_slots = 2,
        no_faces = false,
        erratic_suits_and_ranks = false,
    }
end

function GameConfig:get_collabs()
    return self.collabs_cfg
end

function GameConfig:create_game_object()
    return {
        won = false,
        round_scores = {
            furthest_ante = { label = 'Ante', amt = 0 },
            furthest_round = { label = 'Round', amt = 0 },
            hand = { label = 'Best Hand', amt = 0 },
            poker_hand = { label = 'Most Played Hand', amt = 0 },
            new_collection = { label = 'New Discoveries', amt = 0 },
            cards_played = { label = 'Cards Played', amt = 0 },
            cards_discarded = { label = 'Cards Discarded', amt = 0 },
            times_rerolled = { label = 'Times Rerolled', amt = 0 },
            cards_purchased = { label = 'Cards Purchased', amt = 0 },
        },
        joker_usage = {},
        consumeable_usage = {},
        hand_usage = {},
        last_tarot_planet = nil,
        win_ante = 8,
        stake = 1,
        modifiers = {},
        starting_params = self:get_starting_params(),
        banned_keys = {},
        round = 0,
        probabilities = {
            normal = 1,
        },
        bosses_used = nil,
        pseudorandom = {},
        starting_deck_size = 52,
        ecto_minus = 1,
        pack_size = 2,
        skips = 0,
        STOP_USE = 0,
        edition_rate = 1,
        joker_rate = 20,
        tarot_rate = 4,
        planet_rate = 4,
        spectral_rate = 0,
        playing_card_rate = 0,
        consumeable_buffer = 0,
        joker_buffer = 0,
        discount_percent = 0,
        interest_cap = 25,
        interest_amount = 1,
        inflation = 0,
        hands_played = 0,
        unused_discards = 0,
        perishable_rounds = 5,
        rental_rate = 3,
        blind = nil,
        chips = 0,
        chips_text = '0',
        voucher_text = '',
        dollars = 0,
        max_jokers = 0,
        bankrupt_at = 0,
        current_boss_streak = 0,
        base_reroll_cost = 5,
        blind_on_deck = nil,
        sort = 'desc',
        previous_round = {
            dollars = 4
        },
        tags = {},
        tag_tally = 0,
        pool_flags = {},
        used_jokers = {},
        used_vouchers = {},
        current_round = {
            current_hand = {
                chips = 0,
                chip_text = '0',
                mult = 0,
                mult_text = '0',
                chip_total = 0,
                chip_total_text = '',
                handname = "",
                hand_level = ''
            },
            used_packs = {},
            cards_flipped = 0,
            round_text = 'Round ',
            idol_card = { suit = 'Spades', rank = 'Ace' },
            mail_card = { rank = 'Ace' },
            ancient_card = { suit = 'Spades' },
            castle_card = { suit = 'Spades' },
            hands_left = 0,
            hands_played = 0,
            discards_left = 0,
            discards_used = 0,
            dollars = 0,
            reroll_cost = 5,
            reroll_cost_increase = 0,
            jokers_purchased = 0,
            free_rerolls = 0,
            round_dollars = 0,
            dollars_to_be_earned = '!!!',
            most_played_poker_hand = 'High Card',
        },
        round_resets = {
            hands = 1,
            discards = 1,
            reroll_cost = 1,
            temp_reroll_cost = nil,
            temp_handsize = nil,
            ante = 1,
            blind_ante = 1,
            blind_states = { Small = 'Select', Big = 'Upcoming', Boss = 'Upcoming' },
            loc_blind_states = { Small = '', Big = '', Boss = '' },
            blind_choices = { Small = 'bl_small', Big = 'bl_big' },
            boss_rerolled = false,
        },
        round_bonus = {
            next_hands = 0,
            discards = 0,
        },
        shop = {
            joker_max = 2,
        },
        cards_played = {
            ['Ace'] = { suits = {}, total = 0 },
            ['2'] = { suits = {}, total = 0 },
            ['3'] = { suits = {}, total = 0 },
            ['4'] = { suits = {}, total = 0 },
            ['5'] = { suits = {}, total = 0 },
            ['6'] = { suits = {}, total = 0 },
            ['7'] = { suits = {}, total = 0 },
            ['8'] = { suits = {}, total = 0 },
            ['9'] = { suits = {}, total = 0 },
            ['10'] = { suits = {}, total = 0 },
            ['Jack'] = { suits = {}, total = 0 },
            ['Queen'] = { suits = {}, total = 0 },
            ['King'] = { suits = {}, total = 0 },
        },
        hands = {
            ["Flush Five"] = { visible = false, order = 1, mult = 16, chips = 160, s_mult = 16, s_chips = 160, level = 1, l_mult = 3, l_chips = 50, played = 0, played_this_round = 0, example = { { 'S_A', true }, { 'S_A', true }, { 'S_A', true }, { 'S_A', true }, { 'S_A', true } } },
            ["Flush House"] = { visible = false, order = 2, mult = 14, chips = 140, s_mult = 14, s_chips = 140, level = 1, l_mult = 4, l_chips = 40, played = 0, played_this_round = 0, example = { { 'D_7', true }, { 'D_7', true }, { 'D_7', true }, { 'D_4', true }, { 'D_4', true } } },
            ["Five of a Kind"] = { visible = false, order = 3, mult = 12, chips = 120, s_mult = 12, s_chips = 120, level = 1, l_mult = 3, l_chips = 35, played = 0, played_this_round = 0, example = { { 'S_A', true }, { 'H_A', true }, { 'H_A', true }, { 'C_A', true }, { 'D_A', true } } },
            ["Straight Flush"] = { visible = true, order = 4, mult = 8, chips = 100, s_mult = 8, s_chips = 100, level = 1, l_mult = 4, l_chips = 40, played = 0, played_this_round = 0, example = { { 'S_Q', true }, { 'S_J', true }, { 'S_T', true }, { 'S_9', true }, { 'S_8', true } } },
            ["Four of a Kind"] = { visible = true, order = 5, mult = 7, chips = 60, s_mult = 7, s_chips = 60, level = 1, l_mult = 3, l_chips = 30, played = 0, played_this_round = 0, example = { { 'S_J', true }, { 'H_J', true }, { 'C_J', true }, { 'D_J', true }, { 'C_3', false } } },
            ["Full House"] = { visible = true, order = 6, mult = 4, chips = 40, s_mult = 4, s_chips = 40, level = 1, l_mult = 2, l_chips = 25, played = 0, played_this_round = 0, example = { { 'H_K', true }, { 'C_K', true }, { 'D_K', true }, { 'S_2', true }, { 'D_2', true } } },
            ["Flush"] = { visible = true, order = 7, mult = 4, chips = 35, s_mult = 4, s_chips = 35, level = 1, l_mult = 2, l_chips = 15, played = 0, played_this_round = 0, example = { { 'H_A', true }, { 'H_K', true }, { 'H_T', true }, { 'H_5', true }, { 'H_4', true } } },
            ["Straight"] = { visible = true, order = 8, mult = 4, chips = 30, s_mult = 4, s_chips = 30, level = 1, l_mult = 3, l_chips = 30, played = 0, played_this_round = 0, example = { { 'D_J', true }, { 'C_T', true }, { 'C_9', true }, { 'S_8', true }, { 'H_7', true } } },
            ["Three of a Kind"] = { visible = true, order = 9, mult = 3, chips = 30, s_mult = 3, s_chips = 30, level = 1, l_mult = 2, l_chips = 20, played = 0, played_this_round = 0, example = { { 'S_T', true }, { 'C_T', true }, { 'D_T', true }, { 'H_6', false }, { 'D_5', false } } },
            ["Two Pair"] = { visible = true, order = 10, mult = 2, chips = 20, s_mult = 2, s_chips = 20, level = 1, l_mult = 1, l_chips = 20, played = 0, played_this_round = 0, example = { { 'H_A', true }, { 'D_A', true }, { 'C_Q', false }, { 'H_4', true }, { 'C_4', true } } },
            ["Pair"] = { visible = true, order = 11, mult = 2, chips = 10, s_mult = 2, s_chips = 10, level = 1, l_mult = 1, l_chips = 15, played = 0, played_this_round = 0, example = { { 'S_K', false }, { 'S_9', true }, { 'D_9', true }, { 'H_6', false }, { 'D_3', false } } },
            ["High Card"] = { visible = true, order = 12, mult = 1, chips = 5, s_mult = 1, s_chips = 5, level = 1, l_mult = 1, l_chips = 10, played = 0, played_this_round = 0, example = { { 'S_A', true }, { 'D_Q', false }, { 'D_9', false }, { 'C_4', false }, { 'D_3', false } } },
        }
    }
end

---@type GameConfig
GameCfg = GameConfig()
