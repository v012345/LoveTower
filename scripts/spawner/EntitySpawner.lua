local Enemy = require "scripts.entity.Enemy"

---@class EntitySpawner : ISpawner
EntitySpawner = EntitySpawner or {}
EntitySpawner.__index = EntitySpawner


function EntitySpawner:load()

end

function EntitySpawner:loadConfig(configId)
    -- 波次配置：每波 = { count 数量, interval 出怪间隔(秒), hp, speed, color }
    -- 想加难度/改节奏，只动这张表
    self.WAVES = {
        { count = 5,  interval = 1.0, hp = 80,  speed = 110, color = { 1.0, 0.4, 0.4 } },
        { count = 8,  interval = 0.8, hp = 120, speed = 120, color = { 1.0, 0.7, 0.3 } },
        { count = 12, interval = 0.6, hp = 160, speed = 130, color = { 0.8, 0.4, 1.0 } },
    }
end

-- path:    路径点像素列表
-- onSpawn: function(enemy) 生成一只敌人时回调给 Game，由 Game 收进列表
function EntitySpawner.new(path, onSpawn)
    return setmetatable({
        path = path,
        onSpawn = onSpawn,
        waveIndex = 0,    -- 当前第几波（0 = 还没开始）
        spawning = false, -- 是否正在出怪
        spawnedCount = 0, -- 本波已出怪数
        timer = 0,        -- 距离下一只的倒计时
    }, EntitySpawner)
end

function EntitySpawner:totalWaves()
    return #self.WAVES
end

-- 是否允许开下一波（没在出怪 且 还有波次）
function EntitySpawner:canStart()
    -- return not self.spawning 
    -- and self.waveIndex < #self.WAVES
    return true
end

function EntitySpawner:allWavesDone()
    return self.waveIndex >= #self.WAVES and not self.spawning
end

function EntitySpawner:start()
    if not self:canStart() then return end
    self.waveIndex = self.waveIndex + 1
    self.spawnedCount = 0
    self.timer = 0 -- 立刻出第一只
    self.spawning = true
end

function EntitySpawner:update(dt)
    if not self.spawning then return end

    local wave = self.WAVES[self.waveIndex]
    self.timer = self.timer - dt
    if self.timer <= 0 then
        self.timer = wave.interval
        self.spawnedCount = self.spawnedCount + 1
        EntityManager:addEntity(EntityFactory:create(Enemy))

        if self.spawnedCount >= wave.count then
            self.spawning = false -- 本波出完
        end
    end
end

return EntitySpawner
