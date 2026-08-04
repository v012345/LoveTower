---@class App: Object
---@field CANVAS Canvas
---@field ROOM {Node: Node, ORIG: {x: number, y: number, r: number}}   房间, 就是游戏的主场景, 一切节点的根节点
---@field jiggle number 震动, 用于屏幕震动, 如果是 0 则不震动, 需要震动的时候加一个值, 震动过程会逐渐减小到 0
---@field I NodeList
---@field under_overlay boolean 是否显示底层覆盖?????? 不知道是什么东西
---@field TILESCALE number 地图缩放比例
---@field TILESIZE number 地图单元格大小
---@field STAGE_OBJECT_INTERRUPT boolean 不知道具体作用是什么
---@field STAGE_OBJECTS Node[][] 场景中使用到的所有 Node , 当 STAGE 改变时, 可以通过这里删除所有 Node
---@field fbf boolean frame by frame 模式, 如果为 true, 则每帧都渲染, 否则每秒渲染 60 帧, 和 new_frame 配合使用
---@field new_frame boolean 是否是新的一帧, 如果为 true, 则渲染新的一帧, 否则渲染旧的一帧, 和 fbf 配合使用
---@field MOVEABLES Moveable[] 所有 Moveable 的列表, 包括 Moveable 的子类
---@field STAGE STAGES 当前场景
---@field STATE STATES 当前状态
---@field ROOM_PADDING_W number 房间左右边距, 以地图单元格为单位
---@field ROOM_PADDING_H number 房间上下边距, 以地图单元格为单位
---@field TILE_W number 地图单元格宽度, 以像素为单位
---@field TILE_H number 地图单元格高度, 以像素为单位
---@field WINDOW WINDOW 窗口变换和真实大小
App = Object:extend()



function App:init()
    self.ID = 0 -- ID 生成器
    self.DEBUG = true
    self.under_overlay = false

    self.CANVAS = love.graphics.newCanvas(500, 500, { type = '2d', readable = true })
    self.CANVAS:setFilter('linear', 'linear')
    self.SETTINGS = {
        reduced_motion = false, --- 是否减少动画效果, 如果为 true, 则减少动画效果
        paused = false,
        QUEUED_CHANGE = {},
        WINDOW = {
            screenmode = 'Windowed',
            vsync = 1,
            selected_display = 1,
            display_names = { '[NONE]' },
            DISPLAYS = {
                {
                    name = '[NONE]',
                    screen_res = { w = 1000, h = 650 },
                }
            },
        }
    }
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
end

---@param new_stage    STAGES
---@param new_state    STATES
---@param new_game_obj boolean
function App:prep_stage(new_stage, new_state, new_game_obj)
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
end

function App:update(dt)
    -- do return end
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
    -- do return end
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

--- 在 init 之后被调用, 调用位置是 main.lua 中的 love.run -> love.load 函数
function App:start_up()
    -- do return end
    boot_timer("start", "settings", 0.1)
    self:init_window()
    boot_timer('settings', 'window init', 0.2)

    boot_timer('window init', 'savemanager', 0.3)

    boot_timer('savemanager', 'shaders', 0.4)

    boot_timer('shaders', 'controllers', 0.7)

    boot_timer('controllers', 'localization', 0.8)

    boot_timer('protos', 'shared sprites', 0.9)

    boot_timer('shared sprites', 'prep stage', 0.95)

    boot_timer('prep stage', 'splash prep', 1)

    boot_timer('splash prep', 'end', 1)

    print(TableParser.instance:parse("font"))
    -- self:splash_screen()
    -- self.test = DynaText()
    DynaText(
        {
            dyna_text_config_data = {
                string = { "shared stage" },
                colours = { Color.RED },
                shadow = true,
                float = true,
                maxw = 2.5,
                scale = 0.75
            },
            X = 0,
            Y = 0,
        })
    -- love.resize(love.graphics.getWidth(), love.graphics.getHeight())
    -- print(LetterConfig({
    --     font_config = Language.instance.LANG.font,
    --     char = "a",
    --     scale = 1,
    --     colour = Color.RED,
    --     spacing = 0
    -- }))
end

function App:set_language()
end

--- 目前默认是Windowed模式，1000x650分辨率, 使用第一个显示器, 之后要读用户设置文件中的设置
function App:init_window()
    local room_size = Room.instance:get_real_size()
    local tile_size = Tile.instance:get_pixels_per_tile()

    Window.instance:init_size(room_size.w * tile_size, room_size.h * tile_size)
    Window.instance:set_transform_wh(room_size.w, room_size.h)
    local real_size = Window.instance:get_real_size()
    --- 设置窗口大小, 会影响 love.graphics.getWidth(), love.graphics.getHeight()
    love.window.updateMode(
        real_size.w, real_size.h,
        {
            fullscreen = false,
            fullscreentype = nil,
            vsync = 1,
            resizable = true,
            display = 1,
            highdpi = false
        }
    )
end

function App:apply_window_changes()
end

function App:save_settings()
end

function App:splash_screen()
    -- 直接跳转到主菜单
    self:main_menu()
end

function App:main_menu()
    self:prep_stage(STAGES.MAIN_MENU, STATES.MENU, true)

    --- 创建主菜单场景
    local room = Room.instance:get_root_node()
    local asset_atli = Config.instance:get_asset_atli()
    local img = Sprite(Transform(-30, -13, room.T.w + 60, room.T.h + 22), asset_atli["ui_1"], { x = 2, y = 0 })
    UIBox(
        Transform(0, 0, 2, 2),
        UIBox_button(
            { label = { "Background" }, button = "DT_toggle_background", minw = 1.7, minh = 0.4, scale = 0.35 }
        ), { align = "cl", minw = 5, minh = 1 }
    )

    --- 创建主菜单场景
end

---@return number
function App:generate_id()
    self.ID = self.ID + 1
    return self.ID
end

---@class App
App.instance = App()

