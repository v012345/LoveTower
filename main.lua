local hotfix = require "asset.scripts.hotfix.Hotfix"
local t = 0

function love.load()
    hotfix:load()
end

function love.update(dt)
    hotfix:update(dt)
    t = t + dt * 0.1
    hotfix:setProgress(t)
end

function love.draw()
    hotfix:draw()
end
