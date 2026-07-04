---@type Game
local Game = require("scripts/game")
require "scripts.managers.InputManager"

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.12)
    local font = love.graphics.newFont("resource/fonts/chinese.ttf", 18)
    love.graphics.setFont(font)
    Game:load()
end

function love.update(dt) Game:update(dt) end

function love.draw() Game:draw() end

function love.keypressed(key)
    InputManager:keypressed(key)
end
