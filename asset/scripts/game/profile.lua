---@class (partial) Profile: Object
local Profile = Object:extend()


function Profile:init()
    self.data = {}
    for i = 1, 3, 1 do
        self.data[i] = self:create_empty_profile() -- 初始化三个玩家的数据
    end
end

---@param no number The profile number, 1, 2 or 3.
---@return number no The profile number, 1, 2 or 3.
function Profile:load(no)
    if not self.data[no] then no = 1 end
    local profile = self.data[no]
    --Load the settings file
    local info = get_compressed(no .. "/profile.jkr")

    if info then
        --加载本地文件
        local data = STR_UNPACK(info)
        --这里应该做差异对比, 不应该直接覆盖
        for k, v in pairs(data) do
            profile[k] = v
        end
    end
    return no
end

---@private
---@return ProfileItem item
function Profile:create_empty_profile()
    return {
        MEMORY = {
            deck = 'Red Deck',
            stake = 1,
        },
        stake = 1,

        high_scores = {
            hand = { label = 'Best Hand', amt = 0 },
            furthest_round = { label = 'Highest Round', amt = 0 },
            furthest_ante = { label = 'Highest Ante', amt = 0 },
            most_money = { label = 'Most Money', amt = 0 },
            boss_streak = { label = 'Most Bosses in a Row', amt = 0 },
            collection = { label = 'Collection', amt = 0, tot = 1 },
            win_streak = { label = 'Best Win Streak', amt = 0 },
            current_streak = { label = '', amt = 0 },
            poker_hand = { label = 'Most Played Hand', amt = 0 }
        },

        career_stats = {
            c_round_interest_cap_streak = 0,
            c_dollars_earned = 0,
            c_shop_dollars_spent = 0,
            c_tarots_bought = 0,
            c_planets_bought = 0,
            c_playing_cards_bought = 0,
            c_vouchers_bought = 0,
            c_tarot_reading_used = 0,
            c_planetarium_used = 0,
            c_shop_rerolls = 0,
            c_cards_played = 0,
            c_cards_discarded = 0,
            c_losses = 0,
            c_wins = 0,
            c_rounds = 0,
            c_hands_played = 0,
            c_face_cards_played = 0,
            c_jokers_sold = 0,
            c_cards_sold = 0,
            c_single_hand_round_streak = 0,
        },
        progress = {

        },
        joker_usage = {},
        consumeable_usage = {},
        voucher_usage = {},
        hand_usage = {},
        deck_usage = {},
        deck_stakes = {},
        challenges_unlocked = nil,
        challenge_progress = {
            completed = {},
            unlocked = {}
        }
    }
end

return Profile
