require "scripts.managers.ScenceManager"
require "scripts.entity.Tower"
require "scripts.managers.EntityManager"
require "scripts.spawner.EntitySpawner"
require "scripts.managers.StateManager"

-- 经济/塔的配置
local START_MONEY = 150
local TOWER_COST = 50
local TOWER_DEF = { range = 150, damage = 25, fireRate = 1.5, color = { 0.4, 0.8, 1.0 } }

---@class Game
Game = Game or {}

function Game:load()
    ScenceManager:loadMap("map_1")        -- 生成路
    EntitySpawner:loadConfig("config_1")  -- 波次配置

    self.font = love.graphics.newFont("resource/fonts/chinese.ttf", 18)
    self.bigFont = love.graphics.newFont("resource/fonts/chinese.ttf", 52)

    self:resetRound() -- 初始化本局数据

    -- 输入只注册一次
    InputManager:on(Game, "keypressed", "space", function() self:onSpace() end)
    InputManager:on(Game, "keypressed", "r", function() self:restart() end)
    InputManager:on(Game, "mousepressed", 1, function(_, x, y) self:tryPlaceTower(x, y) end)

    StateManager:set(StateManager.MENU)
end

-- 重置一局的所有游戏数据（开局 / 重开都用）
function Game:resetRound()
    Game.KILL_REWARD = 15
    self.lives = 20
    self.money = START_MONEY
    EntityManager:load()                 -- 清空所有实体
    EntitySpawner:loadConfig("config_1") -- 波次归零
    ScenceManager:clearTowers()          -- 清空塔占格
end

function Game:restart()
    self:resetRound()
    StateManager:set(StateManager.PLAYING)
end

-- 空格：菜单里开始游戏；游戏中开下一波
function Game:onSpace()
    if StateManager:is(StateManager.MENU) then
        StateManager:set(StateManager.PLAYING)
        self:startNextWave()
    elseif StateManager:is(StateManager.PLAYING) then
        self:startNextWave()
    end
end

-- 开下一波：要求场上清空 且 还有波次
function Game:startNextWave()
    if EntityManager:getEnemyCount() == 0 and EntitySpawner:canStart() then
        EntitySpawner:start()
    end
end

-- 尝试在鼠标位置放塔
function Game:tryPlaceTower(px, py)
    if not StateManager:is(StateManager.PLAYING) then return end

    local c, r = ScenceManager:pixelToCell(px, py)
    if not ScenceManager:inBounds(c, r) then return end
    if ScenceManager:isPath(c, r) then return end         -- 路上不能放
    local cellKey = c .. "," .. r
    if ScenceManager:isTowerCell(cellKey) then return end -- 已有塔
    if self.money < TOWER_COST then return end            -- 钱不够

    local x, y = ScenceManager:cellCenter(c, r)
    EntityManager:addEntity(EntityFactory:create(Tower, x, y, TOWER_DEF))
    ScenceManager:setTowerCell(cellKey, true)
    self.money = self.money - TOWER_COST
end

function Game:update(dt)
    if not StateManager:is(StateManager.PLAYING) then return end

    EntitySpawner:update(dt)
    EntityManager:update(dt)

    -- 输赢判定
    if self.lives <= 0 then
        StateManager:set(StateManager.LOSE)
    elseif EntitySpawner:allWavesDone() and EntityManager:getEnemyCount() == 0 then
        StateManager:set(StateManager.WIN)
    end
end

function Game:draw()
    ScenceManager:draw()
    EntityManager:draw()

    -- 常驻 HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        ("生命: %d    金币: %d    波次: %d/%d    敌人: %d    FPS: %d"):format(
            self.lives, self.money, EntitySpawner.waveIndex, EntitySpawner:totalWaves(),
            EntityManager:getEnemyCount(), love.timer.getFPS()
        ), 10, 10)

    local state = StateManager.current
    if state == StateManager.MENU then
        self:drawOverlay("塔防 LoveTower", "按 [空格] 开始游戏")
    elseif state == StateManager.PLAYING then
        love.graphics.print("左键在空地放塔 (费用 " .. TOWER_COST .. ")", 10, 36)
        if EntityManager:getEnemyCount() == 0 and EntitySpawner:canStart() then
            love.graphics.print("按 [空格] 开始第 " .. (EntitySpawner.waveIndex + 1) .. " 波", 10, 62)
        end
    elseif state == StateManager.WIN then
        self:drawOverlay("胜  利 !", "成功守住了！按 [R] 再玩一局")
    elseif state == StateManager.LOSE then
        self:drawOverlay("失  败 ...", "防线被突破了 按 [R] 再玩一局")
    end
end

-- 居中的半透明覆盖层 + 大标题 + 副标题
function Game:drawOverlay(title, subtitle)
    local w, h = love.graphics.getDimensions() -- 窗口宽高
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, w, h)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.bigFont)
    love.graphics.printf(title, 0, h / 2 - 80, w, "center")
    love.graphics.setFont(self.font)
    love.graphics.printf(subtitle, 0, h / 2 + 20, w, "center")
end

return Game
