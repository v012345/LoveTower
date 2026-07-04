EntityManager = EntityManager or {}

function EntityManager:load()
    self.enemies = {}
    self.towers = {}  -- 所有塔
    self.bullets = {} -- 所有子弹
end

function EntityManager:update(dt)
    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt)
    end
    for _, tower in ipairs(self.towers) do
        tower:update(dt)
    end
    for _, bullet in ipairs(self.bullets) do
        bullet:update(dt)
    end
end

function EntityManager:draw()
    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end
    for _, tower in ipairs(self.towers) do
        tower:draw()
    end
    for _, bullet in ipairs(self.bullets) do
        bullet:draw()
    end
end

function EntityManager:destroy()
end

function EntityManager:getEnemyCount()
    return #self.enemies
end

---@param entity IEntity
function EntityManager:addEntity(entity)
    if entity.isEnemy then
        self.enemies[#self.enemies + 1] = entity
    elseif entity.isTower then
        self.towers[#self.towers + 1] = entity
    elseif entity.isBullet then
        self.bullets[#self.bullets + 1] = entity
    end
end

return EntityManager
