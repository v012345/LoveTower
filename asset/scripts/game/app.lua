---@class (partial) App: Object
local App = Object:extend()
local Settings = require "asset.scripts.game.settings"
local Window = require "asset.scripts.game.window"
local Controller = require "asset.scripts.game.controller"
function App:init()
    --Feature Flags, 用于控制是否启用某些功能
    self.feature_flags = PlatformCfg:get_cfg()


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
    --SETTINGS 设置管理器
    self.SETTINGS = Settings()

    -- 联名花色配置
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

    self.PROFILES = {
        {},
        {},
        {},
    }



    do return end
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

    self.ROOM = {
        Node = nil,
        ORIG = Transform(),
    }


    self.PROGRESS = {
        joker_stickers = { tally = 0, of = 0 },
        deck_stakes = { tally = 0, of = 0 },
        challenges = { tally = 0, of = 0 },
    }
end

--- 在 init 之后被调用, 调用位置是 main.lua 中的 love.run -> love.load 函数
function App:start_up()
    self.SETTINGS:load_settings()
    boot_timer("start", "settings", 0.1)
    self:init_window()

    if self.feature_flags.F_SOUND_THREAD then
        boot_timer('window init', 'soundmanager2')
        -- call the sound manager to prepare the thread to play sounds
        self.SOUND_MANAGER = {
            thread = love.thread.newThread('asset/scripts/game/sound_manager.lua'),
            channel = love.thread.getChannel('sound_request'),
            load_channel = love.thread.getChannel('load_channel')
        }
        self.SOUND_MANAGER.thread:start(1)
        -- print("start sound manager")
        Log:info("start sound manager")

        local sound_loaded, prev_file = false, 'none'
        -- while not sound_loaded and false do
        while not sound_loaded do
            -- Monitor the channel for any new requests
            -- local request = self.SOUND_MANAGER.load_channel:pop() -- Value from channel
            local request = self.SOUND_MANAGER.load_channel:demand() -- Value from channel
            Log:info("request", request)
            if request then
                -- If the request is for an update to the music track, handle it here
                if request == 'finished' then
                    sound_loaded = true
                else
                    boot_timer(request, prev_file, 0.22)
                    prev_file = request
                end
            end
            -- love.timer.sleep(0.001)
        end

        boot_timer('soundmanager2', 'savemanager', 0.22)
    end



    -- Input handler/controller for game objects
    self.CONTROLLER = Controller()
    boot_timer('settings', 'window init', 0.2)

    boot_timer('window init', 'savemanager', 0.3)

    boot_timer('savemanager', 'shaders', 0.4)

    boot_timer('shaders', 'controllers', 0.7)

    boot_timer('controllers', 'localization', 0.8)
    self:init_item_prototypes()
    boot_timer('protos', 'shared sprites', 0.9)

    boot_timer('shared sprites', 'prep stage', 0.95)

    boot_timer('prep stage', 'splash prep', 1)
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
    self.SETTINGS.paused = false
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
        if v.boss then bosses_used[k] = 0 end
    end
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

function App:set_language()
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
