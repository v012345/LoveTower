-- 进到这里说明所有的资源都下载完了

---@class App: Object
---@field CANVAS Canvas
---@field ROOM   Node   房间, 就是游戏的主场景, 一切节点的根节点
---@field jiggle number 震动, 用于屏幕震动, 如果是 0 则不震动, 需要震动的时候加一个值, 震动过程会逐渐减小到 0
---@field I NodeList
App = Object:extend()

function App:init()
    self.ID = 0 -- ID 生成器
    self.CANVAS = love.graphics.newCanvas(500, 500, { type = '2d', readable = true })
    self.CANVAS:setFilter('linear', 'linear')
    self.ROOM = Node(Transform())
    self.I = {
        NODE = {},
        MOVEABLE = {},
        UIBOX = {},
        SPRITE = {},
        CARD = {},
        CARDAREA = {},
    }
end

---@param new_stage    number
---@param new_state    number
---@param new_game_obj boolean
function App:prep_stage(new_stage, new_state, new_game_obj)

end

function App:init_game_object()

end

function App:update(dt)
    Timer.instance:update(dt)
end

function App:draw()
    love.graphics.setCanvas({ self.CANVAS })
    love.graphics.push()
    love.graphics.scale(1)

    love.graphics.setShader()
    love.graphics.clear(0, 0, 0, 1)


    do -- Draw the room
        for k, v in pairs(self.I.NODE) do
            if not v.parent then
                love.graphics.push()
                v:translate_container()
                v:draw()
                love.graphics.pop()
            end
        end
        for k, v in pairs(self.I.MOVEABLE) do
            if not v.parent then
                love.graphics.push()
                v:translate_container()
                v:draw()
                love.graphics.pop()
            end
        end
        for k, v in pairs(self.I.UIBOX) do
            if not v.parent then
                love.graphics.push()
                v:translate_container()
                v:draw()
                love.graphics.pop()
            end
        end
    end





    love.graphics.pop()

    love.graphics.setCanvas(self.AA_CANVAS)
    love.graphics.push()
    love.graphics.setColor(Color.WHITE)
    love.graphics.draw(self.CANVAS, 0, 0)
    love.graphics.pop()

    love.graphics.setCanvas()
    love.graphics.setShader()
end

function App:start_up()
    boot_timer("start", "settings", 0.1)

    boot_timer('settings', 'window init', 0.2)

    boot_timer('window init', 'savemanager', 0.3)

    boot_timer('savemanager', 'shaders', 0.4)

    boot_timer('shaders', 'controllers', 0.7)

    boot_timer('controllers', 'localization', 0.8)

    boot_timer('protos', 'shared sprites', 0.9)

    boot_timer('shared sprites', 'prep stage', 0.95)

    boot_timer('prep stage', 'splash prep', 1)

    boot_timer('splash prep', 'end', 1)
end

function App:set_language()

end

function App:init_window()

end

function App:apply_window_changes()

end

function App:save_settings()
end

function App:splash_screen()

end

function App:main_menu()

end

---@return number
function App:generate_id()
    self.ID = self.ID + 1
    return self.ID
end

---@class App
App.instance = App()

return App
