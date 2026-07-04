function boot_timer(_label, _next, progress)
    progress = progress or 0
    local realw, realh = love.window.getMode()
    love.graphics.setCanvas()
    love.graphics.push()
    love.graphics.setShader()
    love.graphics.clear(0,0,0,1)
    love.graphics.setColor(0.6, 0.8, 0.9,1)
    if progress > 0 then love.graphics.rectangle('fill', realw/2 - 150, realh/2 - 15, progress*300, 30, 5) end
    love.graphics.setColor(1, 1, 1,1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle('line', realw/2 - 150, realh/2 - 15, 300, 30, 5)
    love.graphics.print("LOADING: ".._next, realw/2 - 150, realh/2 +40)
    love.graphics.pop()
    love.graphics.present()
  end