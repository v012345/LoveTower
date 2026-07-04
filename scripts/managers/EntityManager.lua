EntityManager = EntityManager or {}

function EntityManager:load()
    self.enemies = {}
end

function EntityManager:update(dt)
    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt)
    end
end

function EntityManager:draw()
    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end
end

function EntityManager:destroy()
end

function EntityManager:getEnemyCount()
    return #self.enemies
end

function EntityManager:addEntity(entity)
    self.enemies[#self.enemies + 1] = entity
end

return EntityManager
