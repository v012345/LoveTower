require "scripts.managers.ScenceManager"
local WaveManager = require "scripts.spawner.EntitySpawner"
require "scripts.entity.Tower"
-- local Bullet = require "scripts.bullet"
require "scripts.managers.EntityManager"

-- 经济/塔的配置
local START_MONEY = 150
local KILL_REWARD = 15
local TOWER_COST = 50
local TOWER_DEF = { range = 150, damage = 25, fireRate = 1.5, color = { 0.4, 0.8, 1.0 } }

---@class Game
local Game = {}

function Game:load()
    ScenceManager:loadMap("map_1") -- 生成路
    EntitySpawner:loadConfig("config_1")
    -- self.towerCells = {}     -- 已被塔占用的格子（"c,r" -> true）
    -- self.lives = 20          -- 漏一只 -1
    -- self.money = START_MONEY -- 金币



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
    if ScenceManager:isPath(c, r) then return end -- 路上不能放
    local cellKey = c .. "," .. r
    if ScenceManager:isTowerCell(cellKey) then return end   -- 已有塔
    -- if self.money < TOWER_COST then return end    -- 钱不够

    local x, y = ScenceManager:cellCenter(c, r)
    EntityManager:addEntity(EntityFactory:create(Tower, x, y, TOWER_DEF))
    ScenceManager:setTowerCell(cellKey, true)
    -- self.money = self.money - TOWER_COST
end

function Game:update(dt)
    EntitySpawner:update(dt)
    EntityManager:update(dt)


    -- -- 塔锁敌开火（生成的子弹交回给 Game）
    -- for _, t in ipairs(self.towers) do
    --     t:update(dt, self.enemies, function(x, y, target, damage)
    --         self.bullets[#self.bullets + 1] = Bullet.new(x, y, target, damage)
    --     end)
    -- end

    -- for i = #self.bullets, 1, -1 do
    --     local b = self.bullets[i]
    --     b:update(dt)
    --     if b.dead then table.remove(self.bullets, i) end
    -- end

    -- -- 清理敌人：漏怪扣命 / 击杀给钱
    -- for i = #self.enemies, 1, -1 do
    --     local e = self.enemies[i]
    --     if e.reachedEnd then
    --         self.lives = self.lives - 1
    --         table.remove(self.enemies, i)
    --     elseif e.dead then
    --         self.money = self.money + KILL_REWARD
    --         table.remove(self.enemies, i)
    --     end
    -- end
end

function Game:draw()
    ScenceManager:draw()
    ScenceManager:drawDebug()
    EntityManager:draw()

    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(("FPS: %s"):format(love.timer.getFPS()), 10, 10)
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
