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
local EventManager = require "asset.scripts.game.event_manager"

---在这里不要做耗时的操作
function App:init()
    self.Features = FeatureCfg:get_instance()
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


    self.STATES = STATES
    self.STAGES = STAGES
    self.STAGE_OBJECTS = { {}, {}, {} }
    self.STAGE = self.STAGES.MAIN_MENU
    self.STATE = self.STATES.SPLASH
    self.TAROT_INTERRUPT = nil
    self.STATE_COMPLETE = false










    self.DEBUG = true
    self.VIBRATION = 0
    self.under_overlay = false

    self.CANVAS = love.graphics.newCanvas(500, 500, { type = '2d', readable = true })
    self.CANVAS:setFilter('linear', 'linear')

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

    self.ARGS = {}
    --- 就是当前类的实例
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


    self.fbf = false       -- frame by frame 模式, 如果为 true, 则每帧都渲染, 否则每秒渲染 60 帧
    self.new_frame = false -- 是否是新的一帧, 如果为 true, 则渲染新的一帧, 否则渲染旧的一帧


    self.PROGRESS = {
        joker_stickers = { tally = 0, of = 0 },
        deck_stakes = { tally = 0, of = 0 },
        challenges = { tally = 0, of = 0 },
    }
    self.C = Color
end

---在 init 之后被调用, 调用位置是 main.lua 中的 love.run -> love.load 函数
---在这里做耗时的操作
function App:start_up()
    self.SETTINGS:load_settings()
    boot_timer("start", "settings", 0.1)
    self:init_window()

    if self.Features:is_sound_thread_enabled() then
        boot_timer('window init', 'soundmanager2')
        self.SOUND_MANAGER = SoundManager()
        -- call the sound manager to prepare the thread to play sounds
        self.SOUND_MANAGER:boot()
        boot_timer('soundmanager2', 'savemanager', 0.22)
    end

    if self.Features:is_cta_enabled() then
        self.SETTINGS:switch_to_demo()
    end




    boot_timer('settings', 'window init', 0.2)
    self.SAVE_MANAGER = SaveManager()
    self.SAVE_MANAGER:boot()
    boot_timer('window init', 'savemanager', 0.3)
    self.HTTP_MANAGER = HttpManager()
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
    --For the visible cursor
    self.STAGE_OBJECT_INTERRUPT = true
    self.CURSOR = Sprite(Transform(0, 0, 0.3, 0.3), self.ASSET_ATLAS['gamepad_ui'], { x = 18, y = 0 }, self.ROOM)
    self.CURSOR.states.collide.can = false
    self.STAGE_OBJECT_INTERRUPT = false

    --Create the event manager for the game
    self.E_MANAGER = EventManager()
    self.SPEEDFACTOR = 1

    self.PROFILES:set_profile_progress()
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
    self.ROOM, self.ROOM_ATTACH = self.window:create_room()
    love.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

function App:init_game_object()
    local bosses_used = {}
    for k, v in pairs(self.P_BLINDS) do
        if v.is_boss then bosses_used[k] = 0 end
    end
    local object = GameCfg:create_game_object()
    object.bosses_used = bosses_used
    return object
end

function App:update(dt)
    nuGC(nil, nil, true)
    self.FRAMES.MOVE = self.FRAMES.MOVE + 1
    self:timer_checkpoint('start->discovery', 'update')
    if not self.SETTINGS:is_tutorial_complete() then self.FUNCS.tutorial_controller() end
    self:timer_checkpoint('tallies', 'update')
    self:modulate_sound(dt)
    self:timer_checkpoint('sounds', 'update')
    self.window:update_canvas_juice(dt)
    self:timer_checkpoint('canvas and juice', 'update')

    --Smooth out the dts to avoid any big jumps

    self.TIMERS:update_real_time(dt)
    self.TIMERS:set_real_shader_time(self.SETTINGS:is_reduced_motion() and 300 or self.TIMERS:get_real_time())
    self.TIMERS:update_time(dt)
    self.SETTINGS:update_demo_total_time(dt)
    self.TIMERS:update_background_time(dt * (self.ARGS.spin and self.ARGS.spin.amount or 0))
    self.real_dt = dt
    if self.real_dt > 0.05 then Log:warn('LONG DT @ ' .. math.floor(self.TIMERS.REAL) .. ': ' .. self.real_dt) end


    if not self.fbf or self.new_frame then
        self.new_frame = false
        self:set_alerts()
        self:timer_checkpoint('alerts', 'update')
        local http_resp = self.HTTP_MANAGER.in_channel:pop()
        if http_resp then
            self.ARGS.HIGH_SCORE_RESPONSE = http_resp
        end

        --暂停游戏时, dt 为 0
        if self.SETTINGS:is_paused() then dt = 0 end


        self.TIMERS:update_game_time(dt)
        self.E_MANAGER:update(self.real_dt)
        -- Smooth.instance:update(Timer.instance.real_dt)
        for k, v in pairs(self.MOVEABLES) do
            if v.FRAME.MOVE < self.FRAMES.MOVE then
                v:move(Smooth.instance.move_dt)
            end
        end
        for k, v in pairs(self.MOVEABLES) do
            -- v:update(dt * Timer.instance.SPEEDFACTOR)
            v.states.collide.is = false
        end
    end
    -- Controller.instance:update(Timer.instance.real_dt)
end

function App:draw()
    self.FRAMES.DRAW = self.FRAMES.DRAW + 1
    --draw the room
    reset_drawhash()
    if self.OVERLAY_TUTORIAL and not self.OVERLAY_MENU then self.under_overlay = true end
    self:timer_checkpoint('start->canvas', 'draw')
    love.graphics.setCanvas({ self.CANVAS })
    love.graphics.push()
    do
        love.graphics.scale(self.CANV_SCALE)

        love.graphics.setShader()
        love.graphics.clear(0, 0, 0, 1)

        if self.SPLASH_BACK then
            if self.debug_background_toggle then
                love.graphics.clear({ 0, 1, 0, 1 })
            else
                love.graphics.push()
                self.SPLASH_BACK:translate_container()
                self.SPLASH_BACK:draw()
                love.graphics.pop()
            end
        end
        if not self.debug_UI_toggle then
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
            if self.SPLASH_LOGO then
                love.graphics.push()
                self.SPLASH_LOGO:translate_container()
                self.SPLASH_LOGO:draw()
                love.graphics.pop()
            end
            if self.debug_splash_size_toggle then
                for k, v in pairs(self.I.CARDAREA) do
                    if not v.parent then
                        love.graphics.push()
                        v:translate_container()
                        v:draw()
                        love.graphics.pop()
                    end
                end
            else
                if not self.OVERLAY_MENU or not self.Features:is_hide_bg() then
                    self:timer_checkpoint('primatives', 'draw')
                    for k, v in pairs(self.I.UIBOX) do
                        if not v.attention_text and not v.parent and v ~= self.OVERLAY_MENU and v ~= self.screenwipe and v ~= self.OVERLAY_TUTORIAL and v ~= self.debug_tools and v ~= self.online_leaderboard and v ~= self.achievement_notification then
                            love.graphics.push()
                            v:translate_container()
                            v:draw()
                            love.graphics.pop()
                        end
                    end
                    self:timer_checkpoint('uiboxes', 'draw')
                    for k, v in pairs(self.I.CARDAREA) do
                        if not v.parent then
                            love.graphics.push()
                            v:translate_container()
                            v:draw()
                            love.graphics.pop()
                        end
                    end
                    for k, v in pairs(self.I.CARD) do
                        if not v.parent and v ~= self.CONTROLLER.dragging.target and v ~= self.CONTROLLER.focused.target then
                            love.graphics.push()
                            v:translate_container()
                            v:draw()
                            love.graphics.pop()
                        end
                    end
                    for k, v in pairs(self.I.UIBOX) do
                        if v.attention_text and v ~= self.debug_tools and v ~= self.online_leaderboard and v ~= self.achievement_notification then
                            love.graphics.push()
                            v:translate_container()
                            v:draw()
                            love.graphics.pop()
                        end
                    end

                    if self.SPLASH_FRONT then
                        love.graphics.push()
                        self.SPLASH_FRONT:translate_container()
                        self.SPLASH_FRONT:draw()
                        love.graphics.pop()
                    end
                    self.under_overlay = false
                    if self.OVERLAY_TUTORIAL then
                        love.graphics.push()
                        self.OVERLAY_TUTORIAL:translate_container()
                        self.OVERLAY_TUTORIAL:draw()
                        love.graphics.pop()

                        if self.OVERLAY_TUTORIAL.highlights then
                            for k, v in ipairs(self.OVERLAY_TUTORIAL.highlights) do
                                love.graphics.push()
                                v:translate_container()
                                v:draw()
                                --- 这里我需要再看一下, 这个 draw_children 是什么意思
                                if v.draw_children then
                                    v:draw_self()
                                    v:draw_children()
                                end
                                love.graphics.pop()
                            end
                        end
                    end
                end

                if self.OVERLAY_MENU or not self.Features:is_hide_bg() then
                    if self.OVERLAY_MENU and self.OVERLAY_MENU ~= self.CONTROLLER.dragging.target then
                        love.graphics.push()
                        self.OVERLAY_MENU:translate_container()
                        self.OVERLAY_MENU:draw()
                        love.graphics.pop()
                    end
                end

                if self.debug_tools then
                    if self.debug_tools ~= self.CONTROLLER.dragging.target then
                        love.graphics.push()
                        self.debug_tools:translate_container()
                        self.debug_tools:draw()
                        love.graphics.pop()
                    end
                end

                self.ALERT_ON_SCREEN = false
                for k, v in pairs(self.I.ALERT) do
                    love.graphics.push()
                    v:translate_container()
                    v:draw()
                    self.ALERT_ON_SCREEN = true
                    love.graphics.pop()
                end

                if self.CONTROLLER.dragging.target and self.CONTROLLER.dragging.target ~= self.CONTROLLER.focused.target then
                    love.graphics.push()
                    self.CONTROLLER.dragging.target:translate_container()
                    self.CONTROLLER.dragging.target:draw()
                    love.graphics.pop()
                end

                if self.CONTROLLER.focused.target and getmetatable(self.CONTROLLER.focused.target) == Card and (self.CONTROLLER.focused.target.area ~= self.hand or self.CONTROLLER.focused.target == self.CONTROLLER.dragging.target) then
                    love.graphics.push()
                    self.CONTROLLER.focused.target:translate_container()
                    self.CONTROLLER.focused.target:draw()
                    love.graphics.pop()
                end

                for k, v in pairs(self.I.POPUP) do
                    love.graphics.push()
                    v:translate_container()
                    v:draw()
                    love.graphics.pop()
                end

                if self.achievement_notification then
                    love.graphics.push()
                    self.achievement_notification:translate_container()
                    self.achievement_notification:draw()
                    love.graphics.pop()
                end

                if self.screenwipe then
                    love.graphics.push()
                    self.screenwipe:translate_container()
                    self.screenwipe:draw()
                    love.graphics.pop()
                end
                love.graphics.push()
                local pixels_per_tile = self.window:get_pixels_per_tile()
                love.graphics.translate(-self.CURSOR.T.w * pixels_per_tile / 2, -self.CURSOR.T.h * pixels_per_tile / 2)
                self.CURSOR:draw()
                love.graphics.pop()
                self:timer_checkpoint('rest', 'draw')
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
    self.window = Window(self)
    self.window:apply_window_changes(true)
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
        --准备好场景了
        self:prep_stage(STAGES.MAIN_MENU, STATES.SPLASH, true)



        self.E_MANAGER:add_event(Event({
            func = function()
                self.TIMERS.TOTAL = 0
                self.TIMERS.REAL = 0
                --Prep the splash screen shaders for both the background(colour swirl) and the foreground(white flash), starting at black
                self.SPLASH_BACK = Sprite(Transform(-30, -13, self.ROOM.T.w + 60, self.ROOM.T.h + 22), self.ASSET_ATLAS["ui_1"], { x = 2, y = 0 })
                self.SPLASH_BACK:define_draw_steps({ {
                    shader = 'splash',
                    send = {
                        { name = 'time',        ref_table = self.TIMERS,                     ref_value = 'REAL' },
                        { name = 'vort_speed',  val = 1 },
                        { name = 'colour_1',    ref_table = self.C,                          ref_value = 'BLUE' },
                        { name = 'colour_2',    ref_table = self.C,                          ref_value = 'WHITE' },
                        { name = 'mid_flash',   val = 0 },
                        { name = 'vort_offset', val = (2 * 90.15315131 * os.time()) % 100000 },
                    }
                } })
                self.SPLASH_BACK:set_alignment({
                    major = self.ROOM_ATTACH,
                    type = 'cm',
                    offset = Coordinate(0, 0)
                })
                self.SPLASH_FRONT = Sprite(Transform(0, -20, self.ROOM.T.w * 2, self.ROOM.T.h * 4), self.ASSET_ATLAS["ui_1"], { x = 2, y = 0 })
                self.SPLASH_FRONT:define_draw_steps({ {
                    shader = 'flash',
                    send = {
                        { name = 'time',      ref_table = self.TIMERS, ref_value = 'REAL' },
                        { name = 'mid_flash', val = 1 }
                    }
                } })
                self.SPLASH_FRONT:set_alignment({
                    major = self.ROOM_ATTACH,
                    type = 'cm',
                    offset = Coordinate(0, 0)
                })

                --spawn in splash card
                local SC = nil
                self.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = (function()
                        local SC_scale = 1.2
                        SC = Card(self.ROOM.T.w / 2 - SC_scale * G.CARD_W / 2, 10. + self.ROOM.T.h / 2 - SC_scale * G.CARD_H / 2, SC_scale * G.CARD_W, SC_scale * G.CARD_H, G.P_CARDS.empty, G.P_CENTERS['j_joker'])
                        SC.T.y = self.ROOM.T.h / 2 - SC_scale * G.CARD_H / 2
                        SC.ambient_tilt = 1
                        SC.states.drag.can = false
                        SC.states.hover.can = false
                        SC.no_ui = true
                        self.VIBRATION = self.VIBRATION + 2
                        play_sound('whoosh1', 0.7, 0.2)
                        play_sound('introPad1', 0.704, 0.6)
                        return true;
                    end)
                }))

                --dissolve fool card and start to fade in the vortex
                self.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 1.8,
                    func = (function() --|||||||||||
                        SC:start_dissolve({ self.C.WHITE, self.C.WHITE }, true, 12, true)
                        play_sound('magic_crumple', 1, 0.5)
                        play_sound('splash_buildup', 1, 0.7)
                        return true;
                    end)
                }))

                --create all the cards and suck them in
                function make_splash_card(args)
                    args = args or {}
                    local angle = math.random() * 2 * 3.14
                    local card_size = (args.scale or 1.5) * (math.random() + 1)
                    local card_pos = args.card_pos or {
                        x = (18 + card_size) * math.sin(angle),
                        y = (18 + card_size) * math.cos(angle)
                    }
                    local card = Card(card_pos.x + G.ROOM.T.w / 2 - G.CARD_W * card_size / 2,
                        card_pos.y + G.ROOM.T.h / 2 - G.CARD_H * card_size / 2,
                        card_size * G.CARD_W, card_size * G.CARD_H, pseudorandom_element(G.P_CARDS), G.P_CENTERS.c_base)
                    if math.random() > 0.8 then
                        card.sprite_facing = 'back'; card.facing = 'back'
                    end
                    card.no_shadow = true
                    card.states.hover.can = false
                    card.states.drag.can = false
                    card.vortex = true and not args.no_vortex
                    card.T.r = angle
                    return card, card_pos
                end

                G.vortex_time = G.TIMERS.REAL
                local temp_del = nil

                for i = 1, 200 do
                    temp_del = temp_del or 3
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        blockable = false,
                        delay = temp_del,
                        func = (function()
                            local card, card_pos = make_splash_card({ scale = 2 - i / 300 })
                            local speed = math.max(2. - i * 0.005, 0.001)
                            ease_value(card.T, 'scale', -card.T.scale, nil, nil, nil, 1. * speed, 'elastic')
                            ease_value(card.T, 'x', -card_pos.x, nil, nil, nil, 0.9 * speed)
                            ease_value(card.T, 'y', -card_pos.y, nil, nil, nil, 0.9 * speed)
                            local temp_pitch = i * 0.007 + 0.6
                            local temp_i = i
                            G.E_MANAGER:add_event(Event({
                                blockable = false,
                                func = (function()
                                    if card.T.scale <= 0 then
                                        if temp_i < 30 then
                                            play_sound('whoosh1', temp_pitch + math.random() * 0.05, 0.25 * (1 - temp_i / 50))
                                        end

                                        if temp_i == 15 then
                                            play_sound('whoosh_long', 0.9, 0.7)
                                        end
                                        G.VIBRATION = G.VIBRATION + 0.1
                                        card:remove()
                                        return true
                                    end
                                end)
                            }))
                            return true
                        end)
                    }))
                    temp_del = temp_del + math.max(1 / (i), math.max(0.2 * (170 - i) / 500, 0.016))
                end

                --when faded to white, spit out the 'Fool's' cards and slowly have them settle in to place
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 2.,
                    func = (function()
                        G.SPLASH_BACK:remove()
                        G.SPLASH_BACK = G.SPLASH_FRONT
                        G.SPLASH_FRONT = nil
                        G:main_menu('splash')
                        return true;
                    end)
                }))
                return true
            end
        }))
    end
end

---调制声音
---@param dt number
function App:modulate_sound(dt)
    -- 先不实现, 默认不调制声音
end

---设置提示, 类似新点系统
function App:set_alerts()
    -- 先不实现, 默认不设置提示
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

---@param label? string
---@param type string
---@param reset? boolean
function App:timer_checkpoint(label, type, reset)
    self.PREV_GARB = self.PREV_GARB or 0
    if not self.Features:is_perf_overlay_enabled() then return end

    G.check = G.check or {
        draw = {
            checkpoint_list = {},
            checkpoints = 0,
            last_time = 0,
        },
        update = {
            checkpoint_list = {},
            checkpoints = 0,
            last_time = 0,
        }
    }
    local cp = G.check[type]
    if reset then
        cp.last_time = love.timer.getTime()
        cp.checkpoints = 0
        return
    end

    cp.checkpoint_list[cp.checkpoints + 1] = cp.checkpoint_list[cp.checkpoints + 1] or {}
    cp.checkpoints = cp.checkpoints + 1
    cp.checkpoint_list[cp.checkpoints].label = label .. ': ' .. (collectgarbage("count") - G.PREV_GARB)
    cp.checkpoint_list[cp.checkpoints].time = love.timer.getTime()
    cp.checkpoint_list[cp.checkpoints].TTC = cp.checkpoint_list[cp.checkpoints].time - cp.last_time
    cp.checkpoint_list[cp.checkpoints].trend = cp.checkpoint_list[cp.checkpoints].trend or {}
    cp.checkpoint_list[cp.checkpoints].states = cp.checkpoint_list[cp.checkpoints].states or {}
    table.insert(cp.checkpoint_list[cp.checkpoints].trend, 1, cp.checkpoint_list[cp.checkpoints].TTC)
    table.insert(cp.checkpoint_list[cp.checkpoints].states, 1, G.STATE)
    cp.checkpoint_list[cp.checkpoints].trend[401] = nil
    cp.checkpoint_list[cp.checkpoints].states[401] = nil
    cp.last_time = cp.checkpoint_list[cp.checkpoints].time
    G.PREV_GARB = collectgarbage("count")
    local av = 0
    for k, v in ipairs(cp.checkpoint_list[cp.checkpoints].trend) do
        av = av + v / #cp.checkpoint_list[cp.checkpoints].trend
    end
    cp.checkpoint_list[cp.checkpoints].average = av
end

---@type App
_G["App"] = App()
