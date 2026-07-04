---@class HomeView : IView
HomeView = HomeView or {}
HomeView.__index = HomeView
function HomeView.new()
    return setmetatable({
        bg = love.graphics.newImage("asset/resource/view/HomePageBg.png"),
    }, HomeView)
end

function HomeView:load()
end

function HomeView:draw()
    -- local iw, ih = self.bg:getDimensions()
    love.graphics.draw(self.bg, 0, 0)
end

function HomeView:update(dt)
end

-- local bg= love.graphics.newImage("resource/image/view/HomePageBg.png")
--
-- love.graphics.draw(bg, 0, 0, 0, 1, 1)

-- return {
--     draw = function()
--         love.graphics.draw(bg, 0, 0, 0, 1, 1)
--     end
-- }
