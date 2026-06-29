local Map = require("scripts/map")

---@class Game
local Game = {}

function Game:load()
    Map:load() -- 生成路
    self.path = Map:getPathPixels()

    -- 测试敌人：用来验证路径系统，第三步会替换成真正的敌人模块
    self.enemy = {
        x = self.path[1].x,
        y = self.path[1].y,
        speed = 140, -- 像素/秒
        nextNode = 2 -- 正在前往的路径点索引
    }
end

function Game:update(dt)
    local e = self.enemy
    local node = self.path[e.nextNode]
    if not node then return end

    local dx, dy = node.x - e.x, node.y - e.y
    local dist = math.sqrt(dx * dx + dy * dy)
    local step = e.speed * dt

    if step >= dist then
        -- 这帧能走到下一个点：吸附到点上，再瞄准后面那个点
        e.x, e.y = node.x, node.y
        e.nextNode = e.nextNode + 1
        if e.nextNode > #self.path then
            -- 走到终点，回到起点循环（方便观察）
            e.x, e.y = self.path[1].x, self.path[1].y
            e.nextNode = 2
        end
    else
        e.x = e.x + dx / dist * step -- dx / dist 算的是方向, 可能为 +/-1 或 0
        e.y = e.y + dy / dist * step -- dy / dist 算的是方向, 可能为 +/-1 或 0
    end
end

function Game:draw()
    Map:draw()
    Map:drawDebug()

    local e = self.enemy
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.circle("fill", e.x, e.y, 14)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        "FPS: " .. love.timer.getFPS() .. "   红球沿蓝线移动 = 路径系统OK | ESC 退出", 10, 10
    )
end

return Game
