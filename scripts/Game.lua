require "scripts.managers.ScenceManager"
local WaveManager = require "scripts.spawner.EntitySpawner"
require "scripts.entity.Tower"
-- local Bullet = require "scripts.bullet"
require "scripts.managers.EntityManager"

-- 经济/塔的配置
local START_MONEY = 150
local TOWER_COST = 50
local TOWER_DEF = { range = 150, damage = 25, fireRate = 1.5, color = { 0.4, 0.8, 1.0 } }

---@class Game
Game = Game or {}

function Game:load()
    Game.KILL_REWARD = 15
    ScenceManager:loadMap("map_1") -- 生成路
    EntitySpawner:loadConfig("config_1")
    self.lives = 20          -- 漏一只 -1
    self.money = START_MONEY -- 金币



    InputManager:on(Game, "keypressed", "space", function()
        self:startNextWave()
    end)
    -- 左键放塔
    InputManager:on(Game, "mousepressed", 1, function(_, x, y)
        self:tryPlaceTower(x, y)
    end)
end

-- 开下一波：要求场上清空 且 还有波次
function Game:startNextWave()
    if EntityManager:getEnemyCount() == 0 and EntitySpawner:canStart() then
        EntitySpawner:start()
    end
end

-- 尝试在鼠标位置放塔
function Game:tryPlaceTower(px, py)
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
    EntitySpawner:update(dt)
    EntityManager:update(dt)
end

function Game:draw()
    ScenceManager:draw()
    ScenceManager:drawDebug()
    EntityManager:draw()

    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print((" 生命: %s ,金币: %s ,FPS: %s"):format(self.lives, self.money, love.timer.getFPS()), 10, 10)
    -- love.graphics.print(
    --     ("生命: %d    金币: %d    波次: %d/%d    敌人: %d   FPS: %d"):format(
    --         self.lives, self.money, self.wave.waveIndex, self.wave:totalWaves(),
    --         #self.enemies, love.timer.getFPS()
    --     ), 10, 10)

    -- love.graphics.print(("左键在空地放塔 (费用 %d)"):format(TOWER_COST), 10, 36)

    -- if #self.enemies == 0 then
    --     if self.wave:canStart() then
    --         love.graphics.print("按 [空格] 开始第 " .. (self.wave.waveIndex + 1) .. " 波", 10, 62)
    --     elseif self.wave:allWavesDone() then
    --         love.graphics.print("所有波次结束！守住了吗？", 10, 62)
    --     end
    -- end
end

return Game
