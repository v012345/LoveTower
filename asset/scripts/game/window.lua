---@class Window: Object
---@field app App
---@field TRANS Transform 窗口变换
---@field real_size Size 窗口实际大小
---@field orig_size Size 窗口原始大小
---@field orig_scale number 窗口原始缩放
---@field orig_ratio number 窗口原始宽高比例
---@field ROOM_PADDING_W number 房间左右边距, 以地图单元格为单位
---@field ROOM_PADDING_H number 房间上下边距, 以地图单元格为单位
---@field TILE_W number 地图单元格宽度, 以像素为单位
---@field TILE_H number 地图单元格高度, 以像素为单位
---@field ROOM Node 房间
local Window = Object:extend()

---@param app App
function Window:init(app)
    self.app = app
    self.TILE_W = GameCfg:get_tile_width()
    self.TILE_H = GameCfg:get_tile_height()
    local tile_scale = GameCfg:get_tile_scale()
    local tile_size = GameCfg:get_tile_size()
    -- Initialize the window
    --- 设计大小
    --- 窗口大小为 1606*941, 设计大小为 1460*840
    --- 宽高比为 1.74
    self.ROOM_PADDING_H = 0.7
    self.ROOM_PADDING_W = 1
    self.WINDOWTRANS = {
        x = 0,
        y = 0,
        w = self.TILE_W + 2 * self.ROOM_PADDING_W,
        h = self.TILE_H + 2 * self.ROOM_PADDING_H
    }
    self.window_prev = {
        orig_scale = tile_scale,
        w = self.WINDOWTRANS.w * tile_size * tile_scale,
        h = self.WINDOWTRANS.h * tile_size * tile_scale,
        orig_ratio = self.WINDOWTRANS.w * tile_size * tile_scale / (self.WINDOWTRANS.h * tile_size * tile_scale)
    }
end

---@return Node
function Window:create_room()
    self.ROOM = Node(Transform(self.ROOM_PADDING_W, self.ROOM_PADDING_H, self.TILE_W, self.TILE_H))
    self.ROOM.jiggle = 0
    self.ROOM.states.drag.can = false
    self.ROOM:set_container(self.ROOM)
    return self.ROOM
end

---@param w number 窗口宽度以像素为单位
---@param h number 窗口高度以像素为单位
function Window:init_size(w, h)

end

---初始宽高比例
---@return number
function Window:get_orig_ratio()

end

---初始大小
---@return Size
function Window:get_orig_size()

end

---comment
---@return Size
function Window:get_real_size()

end

function Window:set_real_size(w, h)

end

---@param w number 窗口宽度
---@param h number 窗口高度
function Window:set_transform_wh(w, h)

end

function Window:update()
end

---Applies all window changes, including updates to the screenmode, selected display, resolution and vsync.\
---These changes are all defined in the G.SETTINGS.QUEUED_CHANGE table. Any unchanged settings use the previous value
---@param _initial boolean 是否是初始化
function Window:apply_window_changes(_initial)
    -- print("apply_window_changes")
    local settings = self.app.SETTINGS.data
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
    self.app.SETTINGS:reset_queued_change()
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


-- ---@class Room: Object
-- ---@field TILE_W number 宽度为多少个 Tile
-- ---@field TILE_H number 高度为多少个 Tile
-- ---@field root_node Node 根节点
-- ---@field root_attach Moveable 根节点附件
-- Room = Object:extend()
-- function Room:init()
--     self.TILE_W = 20
--     self.TILE_H = 11.5
--     self.ROOM_PADDING_H = 0.7
--     self.ROOM_PADDING_W = 1
--     self.root_node = nil
--     self.root_attach = nil
-- end

-- function Room:get_transform()
--     return Transform(self.ROOM_PADDING_W, self.ROOM_PADDING_H, self.TILE_W, self.TILE_H)
-- end

-- ---包含 padding 的实际大小, 以 Tile 为单位
-- ---@return Size
-- function Room:get_real_size()
--     return Size(self.TILE_W + 2 * self.ROOM_PADDING_W, self.TILE_H + 2 * self.ROOM_PADDING_H)
-- end

-- ---@param node Node 根节点
-- function Room:set_root_node(node)
--     self.root_node = node
--     self.root_node:set_container(node)
--     self.root_attach = Moveable(Transform(0, 0, node.T.w, node.T.h), node)
-- end

-- ---@return Node
-- function Room:get_root_node()
--     return self.root_node
-- end

-- ---@type Room
-- Room.instance = Room()
