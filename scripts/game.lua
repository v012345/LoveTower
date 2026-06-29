local Map = require("scripts/map")
local WaveManager = require("scripts/wave")

---@class Game
local Game = {}

function Game:load()
    Map:load() -- 生成路
    self.path = Map:getPathPixels()

    self.enemies = {} -- 场上所有敌人
    self.lives = 20   -- 漏一只 -1

    -- 波次管理器：每生成一只就塞进 enemies
    self.wave = WaveManager.new(self.path, function(enemy)
        self.enemies[#self.enemies + 1] = enemy
    end)
end

-- 开下一波：要求场上清空 且 还有波次
function Game:startNextWave()
    if #self.enemies == 0 and self.wave:canStart() then
        self.wave:start()
    end
end

function Game:update(dt)
    self.wave:update(dt)

    -- 倒序遍历，方便边走边删
    for i = #self.enemies, 1, -1 do
        local e = self.enemies[i]
        e:update(dt)
        if e.reachedEnd then
            self.lives = self.lives - 1
            table.remove(self.enemies, i)
        elseif e.dead then
            table.remove(self.enemies, i)
        end
    end
end

function Game:keypressed(key)
    if key == "space" then
        self:startNextWave()
    end
end

function Game:draw()
    Map:draw()

    for _, e in ipairs(self.enemies) do
        e:draw()
    end

    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        ("生命: %d    波次: %d/%d    场上敌人: %d   FPS: %d"):format(
            self.lives, self.wave.waveIndex, self.wave:totalWaves(),
            #self.enemies, love.timer.getFPS()
        ), 10, 10)

    if #self.enemies == 0 then
        if self.wave:canStart() then
            love.graphics.print("按 [空格] 开始第 " .. (self.wave.waveIndex + 1) .. " 波", 10, 36)
        elseif self.wave:allWavesDone() then
            love.graphics.print("所有波次结束！(还没有塔，敌人全跑到终点了~ 第四步来造塔)", 10, 36)
        end
    end
end

return Game
