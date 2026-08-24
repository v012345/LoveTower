---@class (partial) Window : GameObject
---@overload fun(app: App): Window
local Window = GameObject:extend()

---@param app App
function Window:init(app)
    self.app = app
    self.width_in_tiles = GameCfg:get_tile_width()
    self.height_in_tiles = GameCfg:get_tile_height()
    self.tile_scale = GameCfg:get_tile_scale()
    self.tile_size = GameCfg:get_tile_size()
    self.pixels_per_tile = self.tile_size * self.tile_scale

    self.room_padding_height = 0.7
    self.room_padding_width = 1
    self.window_transform = Transform(0, 0, self.width_in_tiles + 2 * self.room_padding_width, self.height_in_tiles + 2 * self.room_padding_height)
    self.real_size = Size(love.graphics.getWidth(), love.graphics.getHeight())
    self:take_a_snapshot_of_window()
end

function Window:save_real_size(w, h)
    self.real_size.w = w
    self.real_size.h = h
end

---保存窗口的原始大小和比例
function Window:take_a_snapshot_of_window()
    local orig_w = self.window_transform.w * self.pixels_per_tile
    local orig_h = self.window_transform.h * self.pixels_per_tile
    self.window_prev = {
        orig_scale = self.tile_scale,
        orig_size = Size(orig_w, orig_h),
        orig_ratio = orig_w / orig_h
    }
end

---@return Node ROOM
---@return Moveable ROOT_ATTACH
function Window:create_room()
    self.room = Node(Transform(self.ROOM_PADDING_W, self.ROOM_PADDING_H, self.TILE_W, self.TILE_H))
    self.room.jiggle = 0
    self.room.states.drag.can = false
    self.room:set_container(self.room)
    self.room_attach = Moveable(Transform(0, 0, self.TILE_W, self.TILE_H))
    self.room_attach.states.drag.can = false
    self.room_attach:set_container(self.room)
    return self.room, self.room_attach
end

function Window:save_room_transform()
    self.ROOM_ORIG = {
        x = self.room.transform.x,
        y = self.room.transform.y,
        r = self.room.transform.r
    }
end

function Window:set_room_size(w, h)
    self.room.transform.w = w
    self.room.transform.h = h
    self.room_attach.transform.w = w
    self.room_attach.transform.h = h
end

---@param w number 窗口宽度以像素为单位
---@param h number 窗口高度以像素为单位
function Window:init_size(w, h)

end

---初始宽高比例
---@return number
function Window:get_orig_ratio()
    return self.window_prev.orig_ratio
end

---初始大小
---@return Size
function Window:get_orig_size()
    return self.window_prev.orig_size
end

---@return number
function Window:get_orig_scale()
    return self.window_prev.orig_scale
end

function Window:get_tile_scale()
    return self.TILESCALE
end

---@return number
function Window:get_tile_size()
    return self.TILESIZE
end

---更新画布抖动
---@param dt number
function Window:update_canvas_juice(dt)
    -- 先不实现, 默认不更新画布抖动
end

---comment
---@return Size
function Window:get_real_size()

end

---@param w number 窗口宽度
---@param h number 窗口高度
function Window:set_transform_wh(w, h)

end

---每个 Tile 以像素为单位的大小, Tile 就是方形的!
---@return number
function Window:get_pixels_per_tile()
    return self.pixels_per_tile
end

function Window:set_tile_scale(scale)
    self.tile_scale = scale
    self.pixels_per_tile = self.tile_size * self.tile_scale
end

---Applies all window changes, including updates to the screenmode, selected display, resolution and vsync.\
---These changes are all defined in the G.SETTINGS.QUEUED_CHANGE table. Any unchanged settings use the previous value
---@param _initial boolean 是否是初始化
function Window:apply_window_changes(_initial)
    local settings = self.app.settings.data
    --Set the screenmode setting from Windowed, Fullscreen or Borderless
    settings.WINDOW.screenmode = settings.QUEUED_CHANGE.screenmode or settings.WINDOW.screenmode

    --Set the monitor the window should be rendered to
    settings.WINDOW.selected_display = settings.QUEUED_CHANGE.selected_display or settings.WINDOW.selected_display

    --Set the screen resolution
    settings.WINDOW.DISPLAYS[settings.WINDOW.selected_display].screen_res = {
        w = settings.QUEUED_CHANGE.screenres.w or love.graphics.getWidth(),
        h = settings.QUEUED_CHANGE.screenres.h or love.graphics.getHeight()
    }

    --Set the vsync value, 0 is off 1 is on
    settings.WINDOW.vsync = settings.QUEUED_CHANGE.vsync or settings.WINDOW.vsync
    local screenmode = settings.WINDOW.screenmode
    local display = settings.WINDOW.DISPLAYS[settings.WINDOW.selected_display]
    local window_width = screenmode == 'Windowed' and love.graphics.getWidth() * 0.8 or display.screen_res.w
    local window_height = screenmode == 'Windowed' and love.graphics.getHeight() * 0.8 or display.screen_res.h
    love.window.updateMode(window_width, window_height, {
        fullscreen = screenmode ~= 'Windowed',
        fullscreentype = (screenmode == 'Borderless' and 'desktop') or (screenmode == 'Fullscreen' and 'exclusive') or nil,
        vsync = settings.WINDOW.vsync,
        resizable = true,
        display = settings.WINDOW.selected_display,
        highdpi = (love.system.getOS() == 'OS X')
    })
    self.app.settings:reset_queued_change()


    ---- 下面这部分代码要再研究一下 ----

    if not _initial then
        love.resize(love.graphics.getWidth(), love.graphics.getHeight())
        -- G:save_settings()
    end
    do return end
    -- 这里还用不上, 之后再说
    if self.app.OVERLAY_MENU then
        local tab_but = self.app.OVERLAY_MENU:get_UIE_by_ID('tab_but_Video')
        self.app.FUNCS.change_tab(tab_but)
    end
end

return Window
