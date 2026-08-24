local Settings = require "asset.scripts.game.settings"
local Timer = require "asset.scripts.game.timer"
local Metrics = require "asset.scripts.game.metrics"
local Profile = require "asset.scripts.game.profile"
local Color = require "asset.scripts.game.color"
local Performance = require "asset.scripts.game.performance"
local FileHandler = require "asset.scripts.game.file_handler"

---在这里不要做耗时的操作
function App:init()
    self.features = FeatureCfg:get_instance()
    --计时器
    self.TIMERS = Timer()
    self.frames = self.TIMERS:get_frames()
    self.exp_times = self.TIMERS:get_exp_times()

    --SETTINGS 设置管理器
    self.settings = Settings()

    -- 联名花色配置
    self.COLLABS = GameCfg:get_collabs()

    --玩家成就记录
    self.METRICS = Metrics()

    --玩家数据(最多支持保持三个玩家)
    self.PROFILES = Profile()


    self.STATES = STATES
    self.STAGES = STAGES
    self.STAGE_OBJECTS = { {}, {}, {} }
    self.stage = self.STAGES.MAIN_MENU
    self.state = self.STATES.SPLASH
    self.TAROT_INTERRUPT = nil
    self.STATE_COMPLETE = false

    self.DEBUG = true
    self.VIBRATION = 0
    self.under_overlay = false

    self.canvas = love.graphics.newCanvas(500, 500, { type = '2d', readable = true })
    self.canvas:setFilter('linear', 'linear')


    --- 碰撞缓冲区, 在缓冲什么?
    self.COLLISION_BUFFER = 0.05

    --- 刷新 major 缓存, 用于优化 major 的渲染? 不知道具体作用是什么
    self.REFRESH_FRAME_MAJOR_CACHE = 0

    self.FRAMES = {
        DRAW = 0,
        MOVE = 0
    }

    self.STAGE_OBJECT_INTERRUPT = false

    self.DRAW_HASH = {}
    self.MOVEABLES = {}
    self.ANIMATIONS = {}

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

    self.Performance = Performance(self)
    self.FILE_HANDLER = FileHandler(self)
    self.SPEEDFACTOR = 1
    self.ACC = 0
    self.ANIMATION_FPS = 10
end
