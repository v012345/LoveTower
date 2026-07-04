
-- 这里可以做点好玩的东西
local cfg = require("asset.scripts.hotfix.Love2dConfig")

function love.conf(t)
    t.window.title = cfg.window.title
    t.window.width = cfg.window.width
    t.window.height = cfg.window.height
    t.window.vsync = cfg.window.vsync
    t.console = cfg.console

    t.modules.joystick = cfg.modules.joystick
    t.modules.physics = cfg.modules.physics
end
