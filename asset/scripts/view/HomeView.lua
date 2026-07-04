


local bg= love.graphics.newImage("resource/image/view/HomePageBg.png")
local iw, ih = bg:getDimensions()
love.graphics.draw(bg, 0, 0, 0, 1, 1)

return {
    draw = function()
        love.graphics.draw(bg, 0, 0, 0, 1, 1)
    end
}   