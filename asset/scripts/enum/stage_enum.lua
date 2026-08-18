---@enum STAGES
STAGES = {
    NONE = 0,      -- 无阶段
    MAIN_MENU = 1, -- 主菜单
    RUN = 2,       -- 游戏进行中
    SANDBOX = 3    -- 沙盒模式
}

---@enum STATES
STATES = {
    SELECTING_HAND = 1, -- 选择手牌
    HAND_PLAYED = 2,    -- 手牌已使用
    DRAW_TO_HAND = 3,   -- 抽牌到手牌
    GAME_OVER = 4,      -- 游戏结束
    SHOP = 5,           -- 商店
    PLAY_TAROT = 6,     -- 玩塔罗牌
    BLIND_SELECT = 7,   -- 选择盲注
    ROUND_EVAL = 8,     -- 回合评估
    TAROT_PACK = 9,     -- 塔罗牌包
    PLANET_PACK = 10,   -- 星球包
    MENU = 11,          -- 菜单
    TUTORIAL = 12,      -- 教程
    SPLASH = 13,        --DO NOT CHANGE, this has a dependency in the SOUND_MANAGER
    SANDBOX = 14,       -- 沙盒
    SPECTRAL_PACK = 15, -- 光谱包
    DEMO_CTA = 16,      -- 演示CTA
    STANDARD_PACK = 17, -- 标准包
    BUFFOON_PACK = 18,  -- 小丑包
    NEW_ROUND = 19,     -- 新回合
}
