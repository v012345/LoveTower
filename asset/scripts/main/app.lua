-- 进到这里说明所有的资源都下载完了

---@class App: Object
---@field CANVAS Canvas
---@field ROOM   Node   房间, 就是游戏的主场景, 一切节点的根节点
---@field jiggle number 震动, 用于屏幕震动, 如果是 0 则不震动, 需要震动的时候加一个值, 震动过程会逐渐减小到 0
App = Object:extend()

function App:init()
    self.ID = 0 -- ID 生成器
    UIBox({
        T = Transform(0, 0, 0, 0),
        definition = {
            n = UIT.ROOT,
            config = { align = "cm", colour = Color.UI.TRANSPARENT_DARK },
            nodes = {
                { n = UIT.T, config = { text = "1.0.1", scale = 0.3, colour = Color.UI.TEXT_LIGHT } }
            }
        },
        config = { align = "tri", offset = { x = 0, y = 0 }, major = nil, bond = 'Weak' }
    })
end

---@param new_stage    number
---@param new_state    number
---@param new_game_obj boolean
function App:prep_stage(new_stage, new_state, new_game_obj)

end

---@return table
function App:init_game_object()

end

function App:update(dt)

end

function App:draw()

end

function App:start_up()

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
