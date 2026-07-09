---@class App: Object
---@field CANVAS Canvas
---@field ROOM   Node   房间, 就是游戏的主场景, 一切节点的根节点
---@field jiggle number 震动, 用于屏幕震动, 如果是 0 则不震动, 需要震动的时候加一个值, 震动过程会逐渐减小到 0
---@field I NodeList
---@field under_overlay boolean 是否显示底层覆盖?????? 不知道是什么东西
---@field TILESCALE number 地图缩放比例
---@field STAGE_OBJECT_INTERRUPT boolean 不知道具体作用是什么
---@field STAGE_OBJECTS Node[][] 场景中使用到的所有 Node , 当 STAGE 改变时, 可以通过这里删除所有 Node
App = Object:extend()

function App:init()
    self.ID = 0 -- ID 生成器
    self.DEBUG = true
    self.under_overlay = false

    self.CANVAS = love.graphics.newCanvas(500, 500, { type = '2d', readable = true })
    self.CANVAS:setFilter('linear', 'linear')
    self.SETTINGS = {
        paused = false,
    }

    self.STAGE_OBJECT_INTERRUPT = false
    self.STAGES = {
        MAIN_MENU = 1,
        RUN = 2,
        SANDBOX = 3
    }
    self.STAGE_OBJECTS = { {}, {}, {} }
    self.STAGE = self.STAGES.MAIN_MENU

    self.DRAW_HASH = {}
    self.MOVEABLES = {} -- 所有 Moveable 的列表, 包括 Moveable 的子类

    --- 就是当前类的实例
    self.I = {
        NODE = {},
        MOVEABLE = {},
        UIBOX = {},
        SPRITE = {},
        CARD = {},
        CARDAREA = {},
    }
    self.ROOM_PADDING_H = 0.7
    self.ROOM_PADDING_W = 1
    self.TILE_W = 20
    self.TILE_H = 11.5
    self.TILESCALE = 3.65
end
