---@class (partial) Profile: Object
---@field data ProfileItem[] 所有玩家的数据(最多三个玩家)


---@class ProfileItem
---@field MEMORY {deck: string, stake: number} 记忆, 用于存储玩家的游戏数据
---@field stake number 当前赌注
---@field high_scores {hand: {label: string, amt: number}, furthest_round: {label: string, amt: number}, furthest_ante: {label: string, amt: number}, most_money: {label: string, amt: number}, boss_streak: {label: string, amt: number}, collection: {label: string, amt: number, tot: number}, win_streak: {label: string, amt: number}, current_streak: {label: string, amt: number}, poker_hand: {label: string, amt: number}} 最高得分
---@field career_stats {c_round_interest_cap_streak: number, c_dollars_earned: number, c_shop_dollars_spent: number, c_tarots_bought: number, c_planets_bought: number, c_playing_cards_bought: number, c_vouchers_bought: number, c_tarot_reading_used: number, c_planetarium_used: number, c_shop_rerolls: number, c_cards_played: number, c_cards_discarded: number, c_losses: number, c_wins: number, c_rounds: number, c_hands_played: number, c_face_cards_played: number, c_jokers_sold: number, c_cards_sold: number, c_single_hand_round_streak: number} 职业统计
---@field progress {joker_stickers: {tally: number, of: number}, deck_stakes: {tally: number, of: number}, challenges: {tally: number, of: number}} 进度
---@field joker_usage {tally: number, of: number} 使用次数
---@field consumeable_usage {tally: number, of: number} 消耗品使用次数
---@field voucher_usage {tally: number, of: number} 优惠券使用次数
---@field hand_usage {tally: number, of: number} 手牌使用次数
---@field deck_usage {tally: number, of: number} 牌组使用次数
---@field deck_stakes {tally: number, of: number} 牌组赌注
---@field challenges_unlocked nil 挑战解锁
---@field challenge_progress {completed: {label: string, amt: number}[], unlocked: {label: string, amt: number}[]} 挑战进度
