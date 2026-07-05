-- 进到这里说明所有的资源都下载完了


---@class App:Object
App = Object:extend()

function App:init()
    self.ID = 0 -- ID 生成器
    self.VERSION = "0.0.1"

    --||||||||||||||||||||||||||||||
    --         Feature Flags
    --||||||||||||||||||||||||||||||
    self.F_QUIT_BUTTON = true             --Include the main menu 'Quit' button
    self.F_SKIP_TUTORIAL = false          --Completely skip the tutorial on fresh save
    self.F_BASIC_CREDITS = false          --Remove references to Daniel Linssens itch.io
    self.F_EXTERNAL_LINKS = true          --Remove all references to any external links (mainly for console)
    self.F_ENABLE_PERF_OVERLAY = false    --Disable debugging tool for performance of each frame
    self.F_NO_SAVING = false              --Disables all 'run' saving
    self.F_MUTE = false                   --Force mute all sounds
    self.F_SOUND_THREAD = true            --Have sound in a separate thread entirely - if not sounds will run on main thread
    self.F_VIDEO_SETTINGS = true          --Let the player change their video settings
    self.F_CTA = false                    --Call to Action video for the Demo - keep this as false
    self.F_VERBOSE = true                 --Extra debug information on screen and in the console
    self.F_HTTP_SCORES = false            --Include HTTP scores to fetch/set high scores
    self.F_RUMBLE = nil                   --Add rumble to the primary controller - adjust this for amount of rumble
    self.F_CRASH_REPORTS = false          --Send Crash reports over the internet
    self.F_NO_ERROR_HAND = false          --Hard crash without error message screen
    self.F_SWAP_AB_PIPS = false           --Swapping button pips for A and B buttons (mainly for switch)
    self.F_SWAP_AB_BUTTONS = false        --Swapping button function for A and B buttons (mainly for switch)
    self.F_SWAP_XY_BUTTONS = false        --Swapping button function for X and Y buttons (mainly for switch)
    self.F_NO_ACHIEVEMENTS = false        --Disable achievements
    self.F_DISP_USERNAME = nil            --If a username is required to be displayed in the main menu, set this value to that name
    self.F_ENGLISH_ONLY = nil             --Disable language selection - only in english
    self.F_GUIDE = false                  --Replace back/select button with 'guide' button
    self.F_JAN_CTA = false                --Call to action for Jan demo
    self.F_HIDE_BG = false                --Hiding the game objects when paused
    self.F_TROPHIES = false               --use 'trophy' terminology instead of 'achievemnt'
    self.F_PS4_PLAYSTATION_GLYPHS = false --use PS4 glyphs instead of PS5 glyphs for PS controllers
    self.F_LOCAL_CLIPBOARD = false
    self.F_SAVE_TIMER = 30
    self.F_MOBILE_UI = false
    self.F_HIDE_BETA_LANGS = nil


    -- if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' then
    --     love.event.quit()
    -- end


    if love.system.getOS() == 'Windows' then
        self.F_DISCORD = true
        self.F_SAVE_TIMER = 5
        self.F_ENGLISH_ONLY = false
        self.F_CRASH_REPORTS = false
    end

    if love.system.getOS() == 'OS X' then
        self.F_SAVE_TIMER = 5
        self.F_DISCORD = true
        self.F_ENGLISH_ONLY = false
        self.F_CRASH_REPORTS = false
    end

    if love.system.getOS() == 'Nintendo Switch' then
        self.F_HIDE_BETA_LANGS = true
        self.F_BASIC_CREDITS = true
        self.F_NO_ERROR_HAND = true
        self.F_QUIT_BUTTON = false
        self.F_SKIP_TUTORIAL = false
        self.F_ENABLE_PERF_OVERLAY = false
        self.F_NO_SAVING = false
        self.F_MUTE = false
        self.F_SOUND_THREAD = true
        self.F_SWAP_AB_PIPS = true
        self.F_SWAP_AB_BUTTONS = false
        self.F_SWAP_XY_BUTTONS = true
        self.F_VIDEO_SETTINGS = false
        self.F_RUMBLE = 0.7
        self.F_CTA = false
        self.F_VERBOSE = false
        self.F_NO_ACHIEVEMENTS = true
        self.F_ENGLISH_ONLY = nil

        self.F_EXTERNAL_LINKS = false
        self.F_HIDE_BG = true
    end

    if love.system.getOS() == 'ps4' or love.system.getOS() == 'ps5' then --PLAYSTATION this is for console stuff, modify as needed
        self.F_HIDE_BETA_LANGS = true
        self.F_NO_ERROR_HAND = true
        self.F_QUIT_BUTTON = false
        self.F_SKIP_TUTORIAL = false
        self.F_ENABLE_PERF_OVERLAY = false
        self.F_NO_SAVING = false
        self.F_MUTE = false
        self.F_SOUND_THREAD = true
        self.F_VIDEO_SETTINGS = false
        self.F_RUMBLE = 0.5
        self.F_CTA = false
        self.F_VERBOSE = false

        self.F_GUIDE = true
        self.F_PS4_PLAYSTATION_GLYPHS = false

        self.F_EXTERNAL_LINKS = false
        self.F_HIDE_BG = true
        --self.F_LOCAL_CLIPBOARD = true
    end

    if love.system.getOS() == 'xbox' then
        self.F_HIDE_BETA_LANGS = true
        self.F_NO_ERROR_HAND = true
        self.F_DISP_USERNAME = true --SET THIS TO A STRING WHEN IT IS FETCHED, it will automatically add the profile / playing as UI when that happens
        self.F_SKIP_TUTORIAL = false
        self.F_ENABLE_PERF_OVERLAY = false
        self.F_NO_SAVING = false
        self.F_MUTE = false
        self.F_SOUND_THREAD = true
        self.F_VIDEO_SETTINGS = false
        self.F_RUMBLE = 1.0
        self.F_CTA = false
        self.F_VERBOSE = false
        self.F_EXTERNAL_LINKS = false
        self.F_HIDE_BG = true
    end

    --||||||||||||||||||||||||||||||
    --             Time
    --||||||||||||||||||||||||||||||
    self.SEED = os.time()
    self.TIMERS = {
        TOTAL = 0,
        REAL = 0,
        REAL_SHADER = 0,
        UPTIME = 0,
        BACKGROUND = 0
    }
    self.FRAMES = {
        DRAW = 0,
        MOVE = 0
    }
    self.exp_times = { xy = 0, scale = 0, r = 0 }
    --||||||||||||||||||||||||||||||
    --           SETTINGS
    --||||||||||||||||||||||||||||||
    self.SETTINGS = {
        COMP = {
            name = '',
            prev_name = '',
            submission_name = nil,
            score = 0,
        },
        DEMO = {
            total_uptime = 0,
            timed_CTA_shown = false,
            win_CTA_shown = false,
            quit_CTA_shown = false
        },
        ACHIEVEMENTS_EARNED = {},
        crashreports = false,
        colourblind_option = false,
        language = 'en-us',
        screenshake = true,
        run_stake_stickers = false,
        rumble = self.F_RUMBLE,
        play_button_pos = 2,
        GAMESPEED = 1,
        paused = false,
        SOUND = {
            volume = 50,
            music_volume = 100,
            game_sounds_volume = 100,
        },
        WINDOW = {
            screenmode = 'Borderless',
            vsync = 1,
            selected_display = 1,
            display_names = { '[NONE]' },
            DISPLAYS = {
                {
                    name = '[NONE]',
                    screen_res = { w = 1000, h = 650 },
                }
            },
        },
        CUSTOM_DECK = {
            Collabs = {
                Spades = 'default',
                Hearts = 'default',
                Clubs = 'default',
                Diamonds = 'default',
            }
        },
        GRAPHICS = {
            texture_scaling = 2,
            shadows = 'On',
            crt = 70,
            bloom = 1
        },
    }

    self.COLLABS = {
        pos = { Jack = { x = 0, y = 0 }, Queen = { x = 1, y = 0 }, King = { x = 2, y = 0 } },
        options = {
            Spades = {
                'default',
                'collab_TW',
                'collab_CYP',
                'collab_SK',
                'collab_DS',
                'collab_AC',
                'collab_STP',
            },
            Hearts = {
                'default',
                'collab_AU',
                'collab_TBoI',
                'collab_CL',
                'collab_D2',
                'collab_CR',
                'collab_BUG',
            },
            Clubs = {
                'default',
                'collab_VS',
                'collab_STS',
                'collab_PC',
                'collab_WF',
                'collab_FO',
                'collab_DBD'
            },
            Diamonds = {
                'default',
                'collab_DTD',
                'collab_SV',
                'collab_EG',
                'collab_XR',
                'collab_C7',
                'collab_R'
            }
        },
    }

    self.METRICS = {
        cards = {
            used = {},
            bought = {},
            appeared = {},
        },
        decks = {
            chosen = {},
            win = {},
            lose = {}
        },
        bosses = {
            faced = {},
            win = {},
            lose = {},
        }
    }

    --||||||||||||||||||||||||||||||
    --           PROFILES
    --||||||||||||||||||||||||||||||
    self.PROFILES = {
        {},
        {},
        {},
    }

    --||||||||||||||||||||||||||||||
    --        RENDER SCALE
    --||||||||||||||||||||||||||||||
    self.TILESIZE = 20
    self.TILESCALE = 3.65
    self.TILE_W = 20
    self.TILE_H = 11.5
    self.DRAW_HASH_BUFF = 2
    self.CARD_W = 2.4 * 35 / 41
    self.CARD_H = 2.4 * 47 / 41
    self.HIGHLIGHT_H = 0.2 * self.CARD_H
    self.COLLISION_BUFFER = 0.05

    self.PITCH_MOD = 1

    --||||||||||||||||||||||||||||||
    --        GAMESTATES
    --||||||||||||||||||||||||||||||
    self.STATES = {
        SELECTING_HAND = 1,
        HAND_PLAYED = 2,
        DRAW_TO_HAND = 3,
        GAME_OVER = 4,
        SHOP = 5,
        PLAY_TAROT = 6,
        BLIND_SELECT = 7,
        ROUND_EVAL = 8,
        TAROT_PACK = 9,
        PLANET_PACK = 10,
        MENU = 11,
        TUTORIAL = 12,
        SPLASH = 13, --DO NOT CHANGE, this has a dependency in the SOUND_MANAGER
        SANDBOX = 14,
        SPECTRAL_PACK = 15,
        DEMO_CTA = 16,
        STANDARD_PACK = 17,
        BUFFOON_PACK = 18,
        NEW_ROUND = 19,
    }

    self.STAGES = {
        MAIN_MENU = 1,
        RUN = 2,
        SANDBOX = 3
    }
    self.STAGE_OBJECTS = {
        {}, {}, {}
    }
    self.STAGE = self.STAGES.MAIN_MENU
    self.STATE = self.STATES.SPLASH
    self.TAROT_INTERRUPT = nil
    self.STATE_COMPLETE = false

    --||||||||||||||||||||||||||||||
    --          INSTANCES
    --||||||||||||||||||||||||||||||
    self.ARGS = {}
    self.FUNCS = {}
    self.I = {
        NODE = {},
        MOVEABLE = {},
        SPRITE = {},
        UIBOX = {},
        POPUP = {},
        CARD = {},
        CARDAREA = {},
        ALERT = {}
    }
    self.ANIMATION_ATLAS = {}
    self.ASSET_ATLAS = {}
    self.MOVEABLES = {}
    self.ANIMATIONS = {}
    self.DRAW_HASH = {}

    --||||||||||||||||||||||||||||||
    --        CONSTANTS
    --||||||||||||||||||||||||||||||
    self.MIN_CLICK_DIST = 0.9
    self.MIN_HOVER_TIME = 0.1
    self.DEBUG = false
    self.ANIMATION_FPS = 10
    self.VIBRATION = 0
    self.CHALLENGE_WINS = 5

    --||||||||||||||||||||||||||||||
    --        COLOURS
    --||||||||||||||||||||||||||||||
    self.C = {
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
    self.C.HAND_LEVELS[0] = self.C.RED
    self.C.UI_CHIPS = copy_table(self.C.BLUE)
    self.C.UI_MULT = copy_table(self.C.RED)

    self.handlist = {
        "Flush Five",
        "Flush House",
        "Five of a Kind",
        "Straight Flush",
        "Four of a Kind",
        "Full House",
        "Flush",
        "Straight",
        "Three of a Kind",
        "Two Pair",
        "Pair",
        "High Card",
    }
    self.button_mapping = {
        a = self.F_SWAP_AB_BUTTONS and 'b' or nil,
        b = self.F_SWAP_AB_BUTTONS and 'a' or nil,
        y = self.F_SWAP_XY_BUTTONS and 'x' or nil,
        x = self.F_SWAP_XY_BUTTONS and 'y' or nil,
    }
    self.keybind_mapping = { {
        a = 'dpleft',
        d = 'dpright',
        w = 'dpup',
        s = 'dpdown',
        x = 'x',
        c = 'y',
        space = 'a',
        shift = 'b',
        esc = 'start',
        q = 'triggerleft',
        e = 'triggerright',
    } }
end

---@param new_stage number
---@param new_state number
---@param new_game_obj boolean
function App:prep_stage(new_stage, new_state, new_game_obj)
    local locks = Controller.instance.locks
    for k, _ in pairs(locks) do
        locks[k] = nil
    end
    if new_game_obj then self.GAME = self:init_game_object() end
    self.STAGE = new_stage
    self.STATE = new_state
    self.STATE_COMPLETE = false
    self.SETTINGS.paused = false
    ---@type Node
    self.ROOM = Node({
        T = {
            x = self.ROOM_PADDING_W,
            y = self.ROOM_PADDING_H,
            w = self.TILE_W,
            h = self.TILE_H
        }
    })
    self.ROOM.jiggle = 0
    self.ROOM.states.drag.can = false
    self.ROOM:set_container(self.ROOM)


    self.ROOM_ATTACH = Moveable({
        T = {
            x = 0,
            y = 0,
            w = self.TILE_W,
            h = self.TILE_H
        }
    })
    self.ROOM_ATTACH.states.drag.can = false
    self.ROOM_ATTACH:set_container(self.ROOM)
    love.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

---@return table
function App:init_game_object()
    return {}
end

function App:update(dt)
    -- print("game update", dt)
end

function App:draw() end

function App:start_up()
    self.SETTINGS.version = self.VERSION
    self.SETTINGS.paused = nil
    local new_colour_proto = self.C["SO_" .. (self.SETTINGS.colourblind_option and 2 or 1)]
    self.C.SUITS.Hearts = new_colour_proto.Hearts
    self.C.SUITS.Diamonds = new_colour_proto.Diamonds
    self.C.SUITS.Spades = new_colour_proto.Spades
    self.C.SUITS.Clubs = new_colour_proto.Clubs
    boot_timer('start', 'settings', 0.1)
    boot_timer('settings', 'window init', 0.2)

    self:init_window()
    self.STAGE_OBJECT_INTERRUPT =true
    self.STAGE_OBJECT_INTERRUPT =false

    self:splash_screen()
end

function App:init_window()
    self.ROOM_PADDING_H = 0.7
    self.ROOM_PADDING_W = 1
    self.WINDOWTRANS = {
        x = 0,
        y = 0,
        w = self.TILE_W + 2 * self.ROOM_PADDING_W,
        h = self.TILE_H + 2 * self.ROOM_PADDING_H
    }
    self.window_prev = {
        orig_scale = self.TILESCALE,
        w = self.WINDOWTRANS.w * self.TILESIZE * self.TILESCALE,
        h = self.WINDOWTRANS.h * self.TILESIZE * self.TILESCALE,
        orig_ratio = self.WINDOWTRANS.w * self.TILESIZE * self.TILESCALE
            / (self.WINDOWTRANS.h * self.TILESIZE
                * self.TILESCALE)
    }
    self.SETTINGS.QUEUED_CHANGE = self.SETTINGS.QUEUED_CHANGE or {}
    self.SETTINGS.QUEUED_CHANGE.screenmode = self.SETTINGS.WINDOW.screenmode
    self:apply_window_changes()
end

function App:apply_window_changes()
    --Set the screenmode setting from Windowed, Fullscreen or Borderless
    self.SETTINGS.WINDOW.screenmode = (self.SETTINGS.QUEUED_CHANGE and self.SETTINGS.QUEUED_CHANGE.screenmode) or
        self.SETTINGS.WINDOW.screenmode or 'Windowed'

    --Set the monitor the window should be rendered to
    self.SETTINGS.WINDOW.selected_display = (self.SETTINGS.QUEUED_CHANGE and self.SETTINGS.QUEUED_CHANGE.selected_display) or
        self.SETTINGS.WINDOW.selected_display or 1

    --Set the screen resolution
    self.SETTINGS.WINDOW.DISPLAYS[self.SETTINGS.WINDOW.selected_display].screen_res = {
        w = (self.SETTINGS.QUEUED_CHANGE and self.SETTINGS.QUEUED_CHANGE.screenres and self.SETTINGS.QUEUED_CHANGE.screenres.w) or
            (self.SETTINGS.screen_res and self.SETTINGS.screen_res.w) or love.graphics.getWidth(),
        h = (self.SETTINGS.QUEUED_CHANGE and self.SETTINGS.QUEUED_CHANGE.screenres and self.SETTINGS.QUEUED_CHANGE.screenres.h) or
            (self.SETTINGS.screen_res and self.SETTINGS.screen_res.h) or love.graphics.getHeight()
    }

    --Set the vsync value, 0 is off 1 is on
    self.SETTINGS.WINDOW.vsync = (self.SETTINGS.QUEUED_CHANGE and self.SETTINGS.QUEUED_CHANGE.vsync) or
        self.SETTINGS.WINDOW.vsync or
        1

    love.window.updateMode(
        (self.SETTINGS.QUEUED_CHANGE and self.SETTINGS.QUEUED_CHANGE.screenmode == 'Windowed') and
        love.graphics.getWidth() *
        0.8 or self.SETTINGS.WINDOW.DISPLAYS[self.SETTINGS.WINDOW.selected_display].screen_res.w,
        (self.SETTINGS.QUEUED_CHANGE and self.SETTINGS.QUEUED_CHANGE.screenmode == 'Windowed') and
        love.graphics.getHeight() * 0.8 or
        self.SETTINGS.WINDOW.DISPLAYS[self.SETTINGS.WINDOW.selected_display].screen_res.h,
        {
            fullscreen = self.SETTINGS.WINDOW.screenmode ~= 'Windowed',
            fullscreentype = (self.SETTINGS.WINDOW.screenmode == 'Borderless' and 'desktop') or
                (self.SETTINGS.WINDOW.screenmode == 'Fullscreen' and 'exclusive') or nil,
            vsync = self.SETTINGS.WINDOW.vsync,
            resizable = true,
            display = self.SETTINGS.WINDOW.selected_display,
            highdpi = (love.system.getOS() == 'OS X')
        })
    self.SETTINGS.QUEUED_CHANGE = {}
end

function App:save_settings()
end

function App:splash_screen()
    self:main_menu()
end

function App:main_menu()
    self:prep_stage(self.STAGES.MAIN_MENU, self.STATES.MENU, true)
end

-- print("game load")
-- -- function love.load()
-- -- UIManager:openView(HomeView)
-- -- end
-- require "asset.scripts.manager.UIManager"
-- require "asset.scripts.view.HomeView"
-- UIManager:openView(HomeView)
-- App = App or {}
-- App.needUpdate = {
--     UIManager
-- }
-- App.needDraw = {
--     UIManager
-- }

-- function App:update(dt)
--     for _, system in ipairs(App.needUpdate) do
--         system:update(dt)
--     end
-- end

-- function App:draw()
--     for _, system in ipairs(App.needDraw) do
--         system:draw()
--     end
-- end

-- require "scripts.managers.ScenceManager"
-- require "scripts.entity.Tower"
-- require "scripts.managers.EntityManager"
-- require "scripts.spawner.EntitySpawner"
-- require "scripts.managers.StateManager"
-- require "scripts.managers.UIManager"

-- -- 经济配置（塔的属性/价格现在由 UIManager 的塔目录管理）
-- local START_MONEY = 150

-- ---@class App
-- App = App or {}

-- function App:load()
--     ScenceManager:loadMap("map_1")        -- 生成路
--     EntitySpawner:loadConfig("config_1")  -- 波次配置

--     self.font = love.graphics.newFont("resource/fonts/chinese.ttf", 18)
--     self.bigFont = love.graphics.newFont("resource/fonts/chinese.ttf", 52)

--     self:resetRound() -- 初始化本局数据

--     -- 输入只注册一次
--     InputManager:on(App, "keypressed", "space", function() self:onSpace() end)
--     InputManager:on(App, "keypressed", "r", function() self:restart() end)
--     InputManager:on(App, "mousepressed", 1, function(_, x, y)
--         if UIManager:handleClick(x, y) then return end -- 点在工具栏上
--         self:tryPlaceTower(x, y)
--     end)
--     InputManager:on(App, "mousepressed", 2, function() UIManager:deselect() end) -- 右键取消选中

--     StateManager:set(StateManager.MENU)
-- end

-- -- 重置一局的所有游戏数据（开局 / 重开都用）
-- function App:resetRound()
--     App.KILL_REWARD = 15
--     self.lives = 20
--     self.money = START_MONEY
--     EntityManager:load()                 -- 清空所有实体
--     EntitySpawner:loadConfig("config_1") -- 波次归零
--     ScenceManager:clearTowers()          -- 清空塔占格
-- end

-- function App:restart()
--     self:resetRound()
--     StateManager:set(StateManager.PLAYING)
-- end

-- -- 空格：菜单里开始游戏；游戏中开下一波
-- function App:onSpace()
--     if StateManager:is(StateManager.MENU) then
--         StateManager:set(StateManager.PLAYING)
--         self:startNextWave()
--     elseif StateManager:is(StateManager.PLAYING) then
--         self:startNextWave()
--     end
-- end

-- -- 开下一波：要求场上清空 且 还有波次
-- function App:startNextWave()
--     if EntityManager:getEnemyCount() == 0 and EntitySpawner:canStart() then
--         EntitySpawner:start()
--     end
-- end

-- -- 尝试在鼠标位置放塔（用 UI 里当前选中的塔类型）
-- function App:tryPlaceTower(px, py)
--     if not StateManager:is(StateManager.PLAYING) then return end

--     local sel = UIManager:getSelected()
--     if not sel then return end -- 没在工具栏选塔

--     local c, r = ScenceManager:pixelToCell(px, py)
--     if not ScenceManager:inBounds(c, r) then return end
--     if ScenceManager:isPath(c, r) then return end         -- 路上不能放
--     local cellKey = c .. "," .. r
--     if ScenceManager:isTowerCell(cellKey) then return end -- 已有塔
--     if self.money < sel.cost then return end              -- 钱不够

--     local x, y = ScenceManager:cellCenter(c, r)
--     EntityManager:addEntity(EntityFactory:create(Tower, x, y, sel.def))
--     ScenceManager:setTowerCell(cellKey, true)
--     self.money = self.money - sel.cost
-- end

-- function App:update(dt)
--     if not StateManager:is(StateManager.PLAYING) then return end

--     EntitySpawner:update(dt)
--     EntityManager:update(dt)

--     -- 输赢判定
--     if self.lives <= 0 then
--         StateManager:set(StateManager.LOSE)
--     elseif EntitySpawner:allWavesDone() and EntityManager:getEnemyCount() == 0 then
--         StateManager:set(StateManager.WIN)
--     end
-- end

-- function App:draw()
--     ScenceManager:draw()
--     EntityManager:draw()
--     UIManager:drawGhost() -- 放置预览（地图之上、工具栏之下）

--     -- 顶部简要信息
--     love.graphics.setColor(1, 1, 1)
--     love.graphics.print(
--         ("波次: %d/%d    敌人: %d    FPS: %d"):format(
--             EntitySpawner.waveIndex, EntitySpawner:totalWaves(),
--             EntityManager:getEnemyCount(), love.timer.getFPS()
--         ), 10, 10)

--     if StateManager:is(StateManager.PLAYING)
--         and EntityManager:getEnemyCount() == 0 and EntitySpawner:canStart() then
--         love.graphics.print("按 [空格] 开始第 " .. (EntitySpawner.waveIndex + 1) .. " 波", 10, 36)
--     end

--     UIManager:draw() -- 底部工具栏

--     local state = StateManager.current
--     if state == StateManager.MENU then
--         self:drawOverlay("塔防 LoveTower", "按 [空格] 开始游戏")
--     elseif state == StateManager.WIN then
--         self:drawOverlay("胜  利 !", "成功守住了！按 [R] 再玩一局")
--     elseif state == StateManager.LOSE then
--         self:drawOverlay("失  败 ...", "防线被突破了 按 [R] 再玩一局")
--     end
-- end

-- -- 居中的半透明覆盖层 + 大标题 + 副标题
-- function App:drawOverlay(title, subtitle)
--     local w, h = love.graphics.getDimensions() -- 窗口宽高
--     love.graphics.setColor(0, 0, 0, 0.6)
--     love.graphics.rectangle("fill", 0, 0, w, h)

--     love.graphics.setColor(1, 1, 1)
--     love.graphics.setFont(self.bigFont)
--     love.graphics.printf(title, 0, h / 2 - 80, w, "center")
--     love.graphics.setFont(self.font)
--     love.graphics.printf(subtitle, 0, h / 2 + 20, w, "center")
-- end

--


---@diagnostic disable-next-line: duplicate-set-field
function love.update(dt)
    App:update(dt)
end

---@diagnostic disable-next-line: duplicate-set-field
function love.draw()
    App:draw()
end

---@return number
function App:generate_id()
    self.ID = self.ID + 1
    return self.ID
end

---@type App
App.instance = App()

return App
