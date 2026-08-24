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

    self.room_padding_height = 0.7
    self.room_padding_width = 1
    self.window_transform = Transform(0, 0, self.width_in_tiles + 2 * self.room_padding_width, self.height_in_tiles + 2 * self.room_padding_height)
    self.pixels_per_tile = self.tile_size * self.tile_scale
    local orig_w = self.window_transform.w * self.pixels_per_tile
    local orig_h = self.window_transform.h * self.pixels_per_tile
    self.real_size = Size(0, 0)
    self.window_prev = {
        orig_scale = self.tile_scale,
        orig_size = Size(orig_w, orig_h),
        orig_ratio = orig_w / orig_h
    }
end

---@return Node ROOM
---@return Moveable ROOT_ATTACH
function Window:create_room()
    self.ROOM = Node(Transform(self.ROOM_PADDING_W, self.ROOM_PADDING_H, self.TILE_W, self.TILE_H))
    self.ROOM.jiggle = 0
    self.ROOM.states.drag.can = false
    self.ROOM:set_container(self.ROOM)
    self.ROOM_ATTACH = Moveable(Transform(0, 0, self.TILE_W, self.TILE_H))
    self.ROOM_ATTACH.states.drag.can = false
    self.ROOM_ATTACH:set_container(self.ROOM)
    return self.ROOM, self.ROOM_ATTACH
end

function Window:save_room_transform()
    self.ROOM_ORIG = {
        x = self.ROOM.T.x,
        y = self.ROOM.T.y,
        r = self.ROOM.T.r
    }
end

function Window:set_room_size(w, h)
    self.ROOM.T.w = w
    self.ROOM.T.h = h
    self.ROOM_ATTACH.T.w = w
    self.ROOM_ATTACH.T.h = h
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

function Window:set_tile_scale(scale)
    self.TILESCALE = scale
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

function Window:set_real_size(w, h)
    self.WINDOWTRANS.real_window_w = w
    self.WINDOWTRANS.real_window_h = h
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

function Window:update()
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
