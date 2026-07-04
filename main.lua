---@type Game
local Game = require "scripts.Game"
require "scripts.managers.InputManager"
require "scripts.managers.ScenceManager"
require "scripts.spawner.EntitySpawner"
require "scripts.managers.EntityManager"
require "scripts.factory.EntityFactory"
require "scripts.managers.StateManager"
require "scripts.managers.UIManager"

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.12)
    local font = love.graphics.newFont("resource/fonts/chinese.ttf", 18)
    love.graphics.setFont(font)
    ScenceManager:load()
    EntitySpawner:load()
    EntityManager:load()
    EntityFactory:load()
    StateManager:load()
    UIManager:load()
    Game:load()
end

function love.update(dt)
    Game:update(dt)
end

function love.draw()
    Game:draw()
end

function love.keypressed(key)
    InputManager:keypressed(key)
end

function love.mousepressed(x, y, button)
    InputManager:mousepressed(x, y, button)
end
