App = App or {}
-- require "asset.scripts.game.app_modules.app_init"
-- require "asset.scripts.game.app_modules.app_update"        -- 导入 App:update 函数
-- require "asset.scripts.game.app_modules.app_draw"          -- 导入 App:draw 函数
-- require "asset.scripts.game.app_modules.app_splash_screen" -- 导入 App:splash_screen 函数
-- local Window = require "asset.scripts.game.window"
-- local SoundManager = require "asset.scripts.game.sound_manager"
-- local SaveManager = require "asset.scripts.game.save_manager"
-- local HttpManager = require "asset.scripts.game.http_manager"
-- local EventManager = require "asset.scripts.game.event_manager"



---在 init 之后被调用, 调用位置是 main.lua 中的 love.run -> love.load 函数
---在这里做耗时的操作
function App:start_up()
    do return end
    self.settings:load_settings()
    boot_timer("start", "settings", 0.1)
    self:init_window()

    if self.features:is_sound_thread_enabled() then
        boot_timer('window init', 'soundmanager2')
        self.SOUND_MANAGER = SoundManager()
        -- call the sound manager to prepare the thread to play sounds
        self.SOUND_MANAGER:boot()
        boot_timer('soundmanager2', 'savemanager', 0.22)
    end

    if self.features:is_cta_enabled() then
        self.settings:switch_to_demo()
    end


    boot_timer('settings', 'window init', 0.2)
    self.save_manager = SaveManager()
    self.save_manager:boot()
    boot_timer('window init', 'savemanager', 0.3)
    self.http_manager = HttpManager()
    if self.features:is_http_scores_enabled() then
        self.http_manager:boot()
    end
    boot_timer('savemanager', 'shaders', 0.4)

    --Load all shaders from resources
    self.shaders = {}
    local shader_files = love.filesystem.getDirectoryItems("asset/resources/shaders")
    for k, filename in ipairs(shader_files) do
        local extension = string.sub(filename, -3)
        if extension == '.fs' then
            local shader_name = string.sub(filename, 1, -4)
            self.shaders[shader_name] = love.graphics.newShader("asset/resources/shaders/" .. filename)
        end
    end

    boot_timer('shaders', 'controllers', 0.7)

    -- Input handler/controller for game objects
    self.controller = Controller()
    love.joystick.loadGamepadMappings("asset/resources/gamecontrollerdb.txt")
    boot_timer('controllers', 'localization', 0.8)



    local used_no = self.PROFILES:load(self.settings:get_profile_no())
    self.settings:set_profile_no(used_no)
    self:set_render_settings()
    self:set_language()
    self:init_item_prototypes()
    boot_timer('protos', 'shared sprites', 0.9)

    --For globally shared sprites
    local card_w, card_h = GameCfg:get_card_size()
    local T = Transform(0, 0, card_w, card_h)
    -- self.shared_debuff = Sprite(T, self.ASSET_ATLAS["centers"], { x = 4, y = 0 })

    boot_timer('shared sprites', 'prep stage', 0.95)
    --For the visible cursor
    self.STAGE_OBJECT_INTERRUPT = true
    self.CURSOR = Sprite(Transform(0, 0, 0.3, 0.3), self.ASSET_ATLAS['gamepad_ui'], { x = 18, y = 0 }, self.ROOM)
    self.CURSOR.states.collide.can = false
    self.STAGE_OBJECT_INTERRUPT = false

    --Create the event manager for the game
    self.event_manager = EventManager()


    self.PROFILES:set_profile_progress()
    boot_timer('prep stage', 'splash prep', 0.99)
    self:splash_screen()
    boot_timer('splash prep', 'end', 1)
end

function App:start_run()
    self.HUD = UIBox()
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
    self.controller:reset_locks()
    if new_game_obj then self.GAME = self:init_game_object() end

    self.stage = new_stage
    self.state = new_state
    self.state_complete = false
    self.settings:set_paused(false)
    self.room, self.room_attach = self.window:create_room()
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

function App:set_render_settings()
    local ts = self.settings:get_texture_scaling()
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
    self.LANG = LanguageCfg:get_cfg_item(self.settings:get_language())
    self.localization = LanguageCfg:load_localization(self.settings:get_language())
end

--- 目前默认是Windowed模式，1000x650分辨率, 使用第一个显示器, 之后要读用户设置文件中的设置
function App:init_window()
    self.window = Window(self)
    self.window:apply_window_changes(true)
end

function App:save_settings()
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



---@param ... any
function App:load(...) end

function App:update(dt) end

function App:draw() end

function App:keypressed(key) end

function App:keyreleased(key) end

function App:mousepressed(x, y, button, touch) end

function App:mousereleased(x, y, button) end

function App:mousemoved(x, y, dx, dy, istouch) end

function App:resize(w, h)
    print("App:resize", w, h)
    do return end
    -- print("love.resize", w, h)
    assert(h > 0 and w > 0, "Window size must be greater than 0, but got " .. w .. "x" .. h)
    -- 不允许窗口变成竖屏, 因为会上下溢出
    --Dont allow the screen to be too square, since pop in occurs above and below screen
    if w < h then h = w end

    -- 宽高比
    local curr_ratio = w / h
    local is_narrower = curr_ratio < App.window:get_orig_ratio()

    if is_narrower then
        -- 相对变窄了
        App.window:set_tile_scale(w / App.window:get_orig_width() * App.window:get_orig_tile_scale())
    else
        -- 相对变宽了
        App.window:set_tile_scale(h / App.window:get_orig_height() * App.window:get_orig_tile_scale())
    end


    local room = App.window.room
    if room then
        local pixels_per_tile = App.window:get_pixels_per_tile()
        local room_transform = App.room.transform
        if is_narrower then
            room.transform.x = App.window:get_room_padding_width()
            room.transform.y = (h / pixels_per_tile - room_transform.h) / 2
        else
            room.transform.y = App.window:get_room_padding_height()
            room.transform.x = (w / pixels_per_tile - room_transform.w) / 2
        end
        App.window:take_room_transform_snapshot()
    end

    App.window:save_real_size(w, h)
    App.canvas_scale = 1

    if love.system.getOS() == 'Windows' and false then --implement later if needed
        local render_w, render_h = love.window.getDesktopDimensions(App.settings.WINDOW.selected_display)
        local unscaled_dims = love.window.getFullscreenModes(App.settings.WINDOW.selected_display)[1]

        local DPI_scale = math.floor((0.5 * unscaled_dims.width / render_w + 0.5 * unscaled_dims.height / render_h) * 500 + 0.5) / 500

        if DPI_scale > 1.1 then
            App.canvas_scale = 1.5
            App.AA_CANVAS = love.graphics.newCanvas(App.window.WINDOWTRANS.real_window_w * App.canvas_scale, App.window.WINDOWTRANS.real_window_h * App.canvas_scale, { type = '2d', readable = true })
            App.AA_CANVAS:setFilter('linear', 'linear')
        else
            App.AA_CANVAS = nil
        end
    end


    App.canvas = love.graphics.newCanvas(w * App.canvas_scale, h * App.canvas_scale, { type = '2d', readable = true })
    App.canvas:setFilter("linear", "linear")
end
