-- 这里可以做点好玩的东西

function love.conf(t)
    t.window.title = "LoveTower"
    t.window.width = 1200
    t.window.height = 800 -- 地图 720 + 底部工具栏 80
    t.window.vsync = 1
    t.console = false

    t.modules.joystick = false
    t.modules.physics = false
end
