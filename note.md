conf.lua  LÖVE 第一个读取的文件


love.load() —— 启动时跑一次，初始化用
love.update(dt) —— 每帧跑，dt 是距上一帧的秒数，所有运动逻辑放这
love.draw() —— 每帧跑，只负责画画

例子
``` lua
local player = {
    x = 640,
    y = 360,
    speed = 300, -- 像素/秒
}

local target = { x = 640, y = 360 }

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.12)
    font = love.graphics.newFont(18)
    love.graphics.setFont(font)
end

function love.update(dt)
    -- 鼠标位置就是方块要追的目标
    target.x, target.y = love.mouse.getPosition()

    -- 朝目标移动，dt 保证不同帧率下速度一致
    local dx = target.x - player.x
    local dy = target.y - player.y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > 1 then
        local step = math.min(player.speed * dt, dist)
        player.x = player.x + (dx / dist) * step
        player.y = player.y + (dy / dist) * step
    end
end

function love.draw()
    -- 目标点（鼠标）
    love.graphics.setColor(0.3, 0.7, 1.0)
    love.graphics.circle("line", target.x, target.y, 12)

    -- 会"追"鼠标的方块
    love.graphics.setColor(1.0, 0.6, 0.2)
    love.graphics.rectangle("fill", player.x - 20, player.y - 20, 40, 40)

    -- HUD：证明 update/draw 每帧都在跑
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("移动鼠标，看方块追上来 | 按 ESC 退出", 10, 34)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

```

先 load Game 
再 load Map