local Map = require "scripts.managers.ScenceManager"
local WaveManager = require "scripts.managers.EntitySpawner"
local Tower = require "scripts.tower"
local Bullet = require "scripts.bullet"

-- 经济/塔的配置
local START_MONEY = 150
local KILL_REWARD = 15
local TOWER_COST = 50
local TOWER_DEF = { range = 150, damage = 25, fireRate = 1.5, color = { 0.4, 0.8, 1.0 } }

---@class Game
local Game = {}

function Game:load()
    Map:load("map_1") -- 生成路
    self.path = Map:getPathPixels()

    self.enemies = {}          -- 场上所有敌人
    self.towers = {}           -- 所有塔
    self.bullets = {}          -- 所有子弹
    self.towerCells = {}       -- 已被塔占用的格子（"c,r" -> true）
    self.lives = 20            -- 漏一只 -1
    self.money = START_MONEY   -- 金币

    -- 波次管理器：每生成一只就塞进 enemies
    self.wave = WaveManager.new(self.path, function(enemy)
        self.enemies[#self.enemies + 1] = enemy
    end)

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
    if #self.enemies == 0 and self.wave:canStart() then
        self.wave:start()
    end
end

-- 尝试在鼠标位置放塔
function Game:tryPlaceTower(px, py)
    local c, r = Map:pixelToCell(px, py)
    if not Map:inBounds(c, r) then return end
    if Map:isPath(c, r) then return end -- 路上不能放
    local cellKey = c .. "," .. r
    if self.towerCells[cellKey] then return end -- 已有塔
    if self.money < TOWER_COST then return end  -- 钱不够

    local x, y = Map:cellCenter(c, r)
    self.towers[#self.towers + 1] = Tower.new(x, y, TOWER_DEF)
    self.towerCells[cellKey] = true
    self.money = self.money - TOWER_COST
end

function Game:update(dt)
    self.wave:update(dt)

    for _, e in ipairs(self.enemies) do
        e:update(dt)
    end

    -- 塔锁敌开火（生成的子弹交回给 Game）
    for _, t in ipairs(self.towers) do
        t:update(dt, self.enemies, function(x, y, target, damage)
            self.bullets[#self.bullets + 1] = Bullet.new(x, y, target, damage)
        end)
    end

    for i = #self.bullets, 1, -1 do
        local b = self.bullets[i]
        b:update(dt)
        if b.dead then table.remove(self.bullets, i) end
    end

    -- 清理敌人：漏怪扣命 / 击杀给钱
    for i = #self.enemies, 1, -1 do
        local e = self.enemies[i]
        if e.reachedEnd then
            self.lives = self.lives - 1
            table.remove(self.enemies, i)
        elseif e.dead then
            self.money = self.money + KILL_REWARD
            table.remove(self.enemies, i)
        end
    end
end

function Game:draw()
    Map:draw()

    for _, t in ipairs(self.towers) do t:draw() end
    for _, e in ipairs(self.enemies) do e:draw() end
    for _, b in ipairs(self.bullets) do b:draw() end

    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        ("生命: %d    金币: %d    波次: %d/%d    敌人: %d   FPS: %d"):format(
            self.lives, self.money, self.wave.waveIndex, self.wave:totalWaves(),
            #self.enemies, love.timer.getFPS()
        ), 10, 10)

    love.graphics.print(("左键在空地放塔 (费用 %d)"):format(TOWER_COST), 10, 36)

    if #self.enemies == 0 then
        if self.wave:canStart() then
            love.graphics.print("按 [空格] 开始第 " .. (self.wave.waveIndex + 1) .. " 波", 10, 62)
        elseif self.wave:allWavesDone() then
            love.graphics.print("所有波次结束！守住了吗？", 10, 62)
        end
    end
end

return Game
