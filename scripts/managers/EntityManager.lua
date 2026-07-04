EntityManager = EntityManager or {}

function EntityManager:load()
    self.enemies = {}
end

function EntityManager:update(dt)
end

function EntityManager:draw()
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
