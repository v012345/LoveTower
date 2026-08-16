---@class (partial) App: Object
local App = Object:extend()
local Settings = require "asset.scripts.game.settings"
local Window = require "asset.scripts.game.window"
local Controller = require "asset.scripts.game.controller"
local Timer = require "asset.scripts.game.timer"
local Metrics = require "asset.scripts.game.metrics"
local Profile = require "asset.scripts.game.profile"
local Color = require "asset.scripts.game.color"
local SoundManager = require "asset.scripts.game.sound_manager"
local SaveManager = require "asset.scripts.game.save_manager"
local HttpManager = require "asset.scripts.game.http_manager"
local Tile = require "asset.scripts.game.tile"

---在这里不要做耗时的操作
function App:init()
    self.Features = FeatureCfg
    --计时器
    self.TIMERS = Timer()
    self.FRAMES = self.TIMERS:get_frames()
    self.exp_times = self.TIMERS:get_exp_times()

    --SETTINGS 设置管理器
    self.SETTINGS = Settings()

    -- 联名花色配置
    self.COLLABS = GameCfg:get_collabs()

    --玩家成就记录
    self.METRICS = Metrics()

    --玩家数据(最多支持保持三个玩家)
    self.PROFILES = Profile()















    self.ID = 0 -- ID 生成器
    self.DEBUG = true
    self.under_overlay = false

    self.CANVAS = love.graphics.newCanvas(500, 500, { type = '2d', readable = true })
    self.CANVAS:setFilter('linear', 'linear')
    --- 设计大小
    --- 窗口大小为 1606*941, 设计大小为 1460*840
    --- 宽高比为 1.74
    self.ROOM_PADDING_H = 0.7
    self.ROOM_PADDING_W = 1


    self.WINDOW = {
        TRANS = Transform(0, 0, 0, 0),
        real_size = Size(0, 0),
        orig_size = Size(0, 0),
        orig_scale = self.TILESCALE,
    }


    --- 碰撞缓冲区, 在缓冲什么?
    self.COLLISION_BUFFER = 0.05

    --- 刷新 major 缓存, 用于优化 major 的渲染? 不知道具体作用是什么
    self.REFRESH_FRAME_MAJOR_CACHE = 0

    self.FRAMES = {
        DRAW = 0,
        MOVE = 0
    }

    self.STAGE_OBJECT_INTERRUPT = false


    self.STAGE_OBJECTS = { {}, {}, {} }
    -- 0: 主菜单; 1: 游戏进行中; 2: 沙盒模式
    self.STAGE = STAGES.MAIN_MENU
    self.STATE = STATES.SPLASH

    self.DRAW_HASH = {}
    self.MOVEABLES = {}

    --- 就是当前类的实例
    self.I = {
        NODE = {},
        MOVEABLE = {},
        UIBOX = {},
        SPRITE = {},
        CARD = {},
        CARDAREA = {},
        POPUP = {},
    }


    self.fbf = false       -- frame by frame 模式, 如果为 true, 则每帧都渲染, 否则每秒渲染 60 帧
    self.new_frame = false -- 是否是新的一帧, 如果为 true, 则渲染新的一帧, 否则渲染旧的一帧


    self.PROGRESS = {
        joker_stickers = { tally = 0, of = 0 },
        deck_stakes = { tally = 0, of = 0 },
        challenges = { tally = 0, of = 0 },
    }
    self.C = Color
    self.SOUND_MANAGER = SoundManager()
    self.SAVE_MANAGER = SaveManager()
    self.HTTP_MANAGER = HttpManager()
    self.Tile = Tile()
end

---在 init 之后被调用, 调用位置是 main.lua 中的 love.run -> love.load 函数
---在这里做耗时的操作
function App:start_up()
    self.SETTINGS:load_settings()
    boot_timer("start", "settings", 0.1)
    self:init_window()

    if self.Features:is_sound_thread_enabled() then
        boot_timer('window init', 'soundmanager2')
        -- call the sound manager to prepare the thread to play sounds
        self.SOUND_MANAGER:boot()
        boot_timer('soundmanager2', 'savemanager', 0.22)
    end

    if self.Features:is_cta_enabled() then
        self.SETTINGS:switch_to_demo()
    end



    boot_timer('settings', 'window init', 0.2)

    self.SAVE_MANAGER:boot()
    boot_timer('window init', 'savemanager', 0.3)
    if self.Features:is_http_scores_enabled() then
        self.HTTP_MANAGER:boot()
    end
    boot_timer('savemanager', 'shaders', 0.4)

    --Load all shaders from resources
    self.SHADERS = {}
    local shader_files = love.filesystem.getDirectoryItems("asset/resources/shaders")
    for k, filename in ipairs(shader_files) do
        local extension = string.sub(filename, -3)
        if extension == '.fs' then
            local shader_name = string.sub(filename, 1, -4)
            self.SHADERS[shader_name] = love.graphics.newShader("asset/resources/shaders/" .. filename)
        end
    end

    boot_timer('shaders', 'controllers', 0.7)

    -- Input handler/controller for game objects
    self.CONTROLLER = Controller()
    love.joystick.loadGamepadMappings("asset/resources/gamecontrollerdb.txt")
    boot_timer('controllers', 'localization', 0.8)



    local used_no = self.PROFILES:load(self.SETTINGS:get_profile_no())
    self.SETTINGS:set_profile_no(used_no)
    self:set_render_settings()
    self:set_language()
    self:init_item_prototypes()
    boot_timer('protos', 'shared sprites', 0.9)

    --For globally shared sprites
    local card_w, card_h = GameCfg:get_card_size()
    local T = Transform(0, 0, card_w, card_h)
    self.shared_debuff = Sprite(T, self.ASSET_ATLAS["centers"], { x = 4, y = 0 })

    boot_timer('shared sprites', 'prep stage', 0.95)

    boot_timer('prep stage', 'splash prep', 0.99)
    self:splash_screen()
    boot_timer('splash prep', 'end', 1)
end

--- 打开保存进度开关, 在 update 中保存
function App:save_progress()

end

function App:init_item_prototypes()
    self.P_SEALS = SealCfg:get_seals()
    self.P_TAGS = TagCfg:get_tags()
    --- 之后也要进入配置表
    self.tag_undiscovered = { name = 'Not Discovered', order = 1, config = { type = '' }, pos = { x = 3, y = 4 } }
    self.P_STAKES = StakeCfg:get_stakes()
    self.P_BLINDS = BlindCfg:get_blinds()
    --- 之后也要进入配置表
    self.b_undiscovered = { name = 'Undiscovered', debuff_text = 'Defeat this blind to discover', pos = { x = 0, y = 30 } }
    self.P_CARDS = PokerCfg:get_pokers()
    self.P_LOCKS = LockCfg:get_locks()


    -- print("init_item_prototypes")
end

---@param new_stage STAGES 新的阶段
---@param new_state STATES 新的状态
---@param new_game_obj boolean 是否是新的一局游戏
function App:prep_stage(new_stage, new_state, new_game_obj)
    self.CONTROLLER:reset_locks()
    if new_game_obj then self.GAME = self:init_game_object() end

    self.STAGE = new_stage
    self.STATE = new_state
    self.STATE_COMPLETE = false
    self.SETTINGS:set_paused(false)
    -- 窗口大小是 self.TILE_W + 2 * self.ROOM_PADDING_W 和 self.TILE_H + 2 * self.ROOM_PADDING_H
    -- ROOM 大小是 self.TILE_W 和 self.TILE_H, 正好嵌入 Padding 矩形里

    local transform = Room.instance:get_transform()
    local root_node = Node(transform)
    Room.instance:set_root_node(root_node)
    love.resize(love.graphics.getWidth(), love.graphics.getHeight())
    -- Particles(Transform(1, 1, 0, 0), nil, { timer = 0.003 })
end

function App:init_game_object()
    local bosses_used = {}
    for k, v in pairs(self.P_BLINDS) do
        if v.is_boss then bosses_used[k] = 0 end
    end
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
        starting_params = GameCfg:get_starting_params(),
        banned_keys = {},
        round = 0,
        probabilities = {
            normal = 1,
        },
        bosses_used = bosses_used,
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

function App:update(dt)
    do return end
    self.FRAMES.MOVE = self.FRAMES.MOVE + 1
    Timer.instance:update_real_time(dt)
    if not self.fbf or self.new_frame then
        self.new_frame = false
        Timer.instance:update_game_time(dt)
        EventManager.instance:update(Timer.instance.real_dt)
        Smooth.instance:update(Timer.instance.real_dt)
        for k, v in pairs(self.MOVEABLES) do
            if v.FRAME.MOVE < self.FRAMES.MOVE then
                v:move(Smooth.instance.move_dt)
            end
        end
        for k, v in pairs(self.MOVEABLES) do
            v:update(dt * Timer.instance.SPEEDFACTOR)
            v.states.collide.is = false
        end
    end
    Controller.instance:update(Timer.instance.real_dt)
end

function App:draw()
    do return end
    love.graphics.setCanvas({ self.CANVAS })
    love.graphics.push()
    love.graphics.scale(1)

    love.graphics.setShader()
    love.graphics.clear(0, 0, 0, 1)

    do -- Draw the room
        for k, v in pairs(self.I.NODE) do
            if not v.parent then
                love.graphics.push()
                v:translate_container()
                v:draw()
                love.graphics.pop()
            end
        end
        for k, v in pairs(self.I.MOVEABLE) do
            if not v.parent then
                love.graphics.push()
                v:translate_container()
                v:draw()
                love.graphics.pop()
            end
        end
        for k, v in pairs(self.I.UIBOX) do
            if not v.parent then
                love.graphics.push()
                v:translate_container()
                v:draw()
                love.graphics.pop()
            end
        end
    end

    love.graphics.pop()

    love.graphics.setCanvas(self.AA_CANVAS)
    love.graphics.push()
    love.graphics.setColor(Color.WHITE)
    love.graphics.draw(self.CANVAS, 0, 0)
    love.graphics.pop()

    love.graphics.setCanvas()
    love.graphics.setShader()
end

function App:set_render_settings()
    local ts = self.SETTINGS:get_texture_scaling()
    --Set fiter to linear interpolation and nearest, best for pixel art
    local filter = ts == 1 and 'nearest' or 'linear'
    love.graphics.setDefaultFilter(filter, filter, 1)
    love.graphics.setLineStyle("rough")
    self.ANIMATION_ATLAS = {}
    self.ASSET_ATLAS = {}
    local atli = AtlasCfg:get_cfg()
    for _, atlas in pairs(atli) do
        if atlas.is_animation then
            self.ANIMATION_ATLAS[atlas.Id] = atlas
        else
            self.ASSET_ATLAS[atlas.Id] = atlas
        end
        atlas.image = love.graphics.newImage(atlas.path[ts], { mipmaps = true, dpiscale = atlas.dpiscale[ts] })
    end
    for _, v in pairs(self.I.SPRITE) do
        v:reset()
    end
end

function App:set_language()
    self.LANG = LanguageCfg:get_cfg_item(self.SETTINGS:get_language())
    self.localization = LanguageCfg:load_localization(self.SETTINGS:get_language())
end

--- 目前默认是Windowed模式，1000x650分辨率, 使用第一个显示器, 之后要读用户设置文件中的设置
function App:init_window()
    self.window = Window()
    self:apply_window_changes(true)
end

function App:save_settings()
end

function App:splash_screen()
    --If the skip splash screen option is set, immediately go to the main menu here
    if self.SETTINGS:is_skip_splash() then
        -- 直接跳转到主菜单
        self:main_menu()
    else
        Log:info("splash screen")
        self:prep_stage(STAGES.MAIN_MENU, STATES.SPLASH, true)
    end
end

function App:main_menu()
    self:prep_stage(STAGES.MAIN_MENU, STATES.MENU, true)

    --- 创建主菜单场景
    -- local room = Room.instance:get_root_node()
    -- local asset_atli = Config.instance:get_asset_atli()
    -- local img = Sprite(Transform(-30, -13, room.T.w + 60, room.T.h + 22), asset_atli["ui_1"], { x = 2, y = 0 })
    -- UIBox(
    --     Transform(0, 0, 2, 2),
    --     UIBox_button(
    --         { label = { "Background" }, button = "DT_toggle_background", minw = 1.7, minh = 0.4, scale = 0.35 }
    --     ), { align = "cl", minw = 5, minh = 1 }
    -- )

    --- 创建主菜单场景
end

---@return number
function App:generate_id()
    self.ID = self.ID + 1
    return self.ID
end

---Applies all window changes, including updates to the screenmode, selected display, resolution and vsync.\
---These changes are all defined in the G.SETTINGS.QUEUED_CHANGE table. Any unchanged settings use the previous value
---@param _initial boolean 是否是初始化
function App:apply_window_changes(_initial)
    -- print("apply_window_changes")
    local settings = self.SETTINGS.data
    --Set the screenmode setting from Windowed, Fullscreen or Borderless
    settings.WINDOW.screenmode = settings.QUEUED_CHANGE.screenmode or settings.WINDOW.screenmode

    --Set the monitor the window should be rendered to
    settings.WINDOW.selected_display = settings.QUEUED_CHANGE.selected_display or settings.WINDOW.selected_display

    --Set the screen resolution
    settings.WINDOW.DISPLAYS[settings.WINDOW.selected_display].screen_res = {
        w = settings.QUEUED_CHANGE.screenres.w or love.graphics.getWidth(),
        h = settings.QUEUED_CHANGE.screenres.h or love.graphics.getHeight()
    }

    --Set the vsync value, 0 is off 1 is on
    settings.WINDOW.vsync = settings.QUEUED_CHANGE.vsync or settings.WINDOW.vsync
    local screenmode = settings.WINDOW.screenmode
    local display = settings.WINDOW.DISPLAYS[settings.WINDOW.selected_display]
    local window_width = screenmode == 'Windowed' and love.graphics.getWidth() * 0.8 or display.screen_res.w
    local window_height = screenmode == 'Windowed' and love.graphics.getHeight() * 0.8 or display.screen_res.h
    love.window.updateMode(window_width, window_height, {
        fullscreen = screenmode ~= 'Windowed',
        fullscreentype = (screenmode == 'Borderless' and 'desktop') or (screenmode == 'Fullscreen' and 'exclusive') or nil,
        vsync = settings.WINDOW.vsync,
        resizable = true,
        display = settings.WINDOW.selected_display,
        highdpi = (love.system.getOS() == 'OS X')
    })
    self.SETTINGS:reset_queued_change()
    if not _initial then
        love.resize(love.graphics.getWidth(), love.graphics.getHeight())
        -- G:save_settings()
    end
    do return end
    -- 这里还用不上, 之后再说
    if G.OVERLAY_MENU then
        local tab_but = G.OVERLAY_MENU:get_UIE_by_ID('tab_but_Video')
        G.FUNCS.change_tab(tab_but)
    end
end

function App:set_profile_progress()

end

---@type App
_G["App"] = App()
