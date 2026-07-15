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

    self.ROOM = {
        Node = nil,
        ORIG = Transform(),
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
end
