-- 进到这里说明所有的资源都下载完了
require "asset.scripts.main.app_init"

---@param new_stage    STAGES
---@param new_state    STATES
---@param new_game_obj boolean
function App:prep_stage(new_stage, new_state, new_game_obj)
    self.STAGE = new_stage
    self.STATE = new_state
    self.STATE_COMPLETE = false
    self.SETTINGS.paused = false
    -- 窗口大小是 self.TILE_W + 2 * self.ROOM_PADDING_W 和 self.TILE_H + 2 * self.ROOM_PADDING_H
    -- ROOM 大小是 self.TILE_W 和 self.TILE_H, 正好嵌入 Padding 矩形里

    local transform = Room.instance:get_transform()
    local root_node = Node(transform)
    Room.instance:set_root_node(root_node)
    love.resize(love.graphics.getWidth(), love.graphics.getHeight())
    -- Particles(Transform(1, 1, 0, 0), nil, { timer = 0.003 })
end

function App:init_game_object()

end

function App:update(dt)
    self.FRAMES.MOVE = self.FRAMES.MOVE + 1
    Timer.instance:update_real_time(dt)
    if not self.fbf or self.new_frame then
        self.new_frame = false
        Timer.instance:update_game_time(dt)
        EventManager.instance:update(Timer.instance.real_dt)
        local move_dt = math.min(1 / 20, Timer.instance.real_dt)
        for k, v in pairs(self.I.MOVEABLE) do
            if v.FRAME.MOVE < self.FRAMES.MOVE then
                v:move(move_dt)
            end
        end
        for k, v in pairs(self.MOVEABLES) do
            v:update(dt * Timer.instance.SPEEDFACTOR)
            v.states.collide.is = false
        end
    end
    Controller.instance:update(Timer.instance.real_dt)
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

---在 init 之后被调用, 调用位置是 main.lua 中的 love.run -> love.load 函数
function App:start_up()
    boot_timer("start", "settings", 0.1)
    self:init_window()
    boot_timer('settings', 'window init', 0.2)

    boot_timer('window init', 'savemanager', 0.3)

    boot_timer('savemanager', 'shaders', 0.4)

    boot_timer('shaders', 'controllers', 0.7)

    boot_timer('controllers', 'localization', 0.8)

    boot_timer('protos', 'shared sprites', 0.9)

    boot_timer('shared sprites', 'prep stage', 0.95)

    boot_timer('prep stage', 'splash prep', 1)

    boot_timer('splash prep', 'end', 1)
    self:splash_screen()

    -- love.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

function App:set_language()

end

--- 目前默认是Windowed模式，1000x650分辨率, 使用第一个显示器, 之后要读用户设置文件中的设置
function App:init_window()
    local room_size = Room.instance:get_real_size()
    local tile_size = Tile.instance:get_pixels_per_tile()

    Window.instance:init_size(room_size.w * tile_size, room_size.h * tile_size)
    Window.instance:set_transform_wh(room_size.w, room_size.h)
    local real_size = Window.instance:get_real_size()
    --- 设置窗口大小, 会影响 love.graphics.getWidth(), love.graphics.getHeight()
    love.window.updateMode(real_size.w, real_size.h, { fullscreen = false, fullscreentype = nil, vsync = 1, resizable = true, display = 1, highdpi = false })
end

function App:apply_window_changes()

end

function App:save_settings()
end

function App:splash_screen()
    -- 直接跳转到主菜单
    self:main_menu()
end

function App:main_menu()
    self:prep_stage(STAGES.MAIN_MENU, STATES.MENU, true)

    --- 创建主菜单场景
    --- 创建主菜单场景
end

---@return number
function App:generate_id()
    self.ID = self.ID + 1
    return self.ID
end

---@class App
App.instance = App()

return App
