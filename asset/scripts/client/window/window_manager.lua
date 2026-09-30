---@class (partial) WindowManager : BaseClass
---@overload fun(): WindowManager
local WindowManager = BaseClass:extend()

function WindowManager:init()
    self.width = -1
    self.height = -1
    ---也可以手动调用 love.resize(w, h) 来调整窗口大小\
    ---Called when the window is resized, for example if the user resizes the window, or if love.window.setMode is called with an unsupported width or height in fullscreen and the window chooses the closest appropriate size.
    ---[api reference](https://love2d.org/wiki/love.resize)
    love.resize = function(w, h)
        if self.width ~= w or self.height ~= h then
            self.width = w
            self.height = h
            self:on_window_resize(w, h)
        end
    end
end

---Applies all window changes, including updates to the screenmode, selected display, resolution and vsync.\
---These changes are all defined in the G.SETTINGS.QUEUED_CHANGE table. Any unchanged settings use the previous value
---@param config table 是否是初始化
function WindowManager:apply_window_changes(config)
    --Set the vsync value, 0 is off 1 is on
    local vsync = config.vsync
    local screenmode = config.screenmode             -- "Windowed" "Fullscreen" "Borderless"
    local selected_display = config.selected_display -- 哪个显示器

    local window_width = screenmode == 'Windowed' and love.graphics.getWidth() * 0.8 or love.graphics.getWidth()
    local window_height = screenmode == 'Windowed' and love.graphics.getHeight() * 0.8 or love.graphics.getHeight()
    love.window.updateMode(window_width, window_height, {
        fullscreen = screenmode ~= 'Windowed',
        fullscreentype = (screenmode == 'Borderless' and 'desktop') or (screenmode == 'Fullscreen' and 'exclusive') or nil,
        vsync = vsync,
        resizable = true,
        display = selected_display,
        highdpi = (love.system.getOS() == 'OS X')
    })
end


function WindowManager:on_window_resize(w, h)
    print("on_window_resize", w, h)
    do return end
    -- print("love.resize", w, h)
    assert(h > 0 and w > 0, "Window size must be greater than 0, but got " .. w .. "x" .. h)
    -- 不允许窗口变成竖屏, 因为会上下溢出
    --Dont allow the screen to be too square, since pop in occurs above and below screen
    if w < h then h = w end

    -- 宽高比
    local curr_ratio = w / h
    local is_narrower = curr_ratio < App.window:get_orig_ratio()

    if is_narrower then
        -- 相对变窄了
        App.window:set_tile_scale(w / App.window:get_orig_width() * App.window:get_orig_tile_scale())
    else
        -- 相对变宽了
        App.window:set_tile_scale(h / App.window:get_orig_height() * App.window:get_orig_tile_scale())
    end


    local room = App.window.room
    if room then
        local pixels_per_tile = App.window:get_pixels_per_tile()
        local room_transform = App.room.transform
        if is_narrower then
            room.transform.x = App.window:get_room_padding_width()
            room.transform.y = (h / pixels_per_tile - room_transform.h) / 2
        else
            room.transform.y = App.window:get_room_padding_height()
            room.transform.x = (w / pixels_per_tile - room_transform.w) / 2
        end
        App.window:take_room_transform_snapshot()
    end

    App.window:save_real_size(w, h)
    App.canvas_scale = 1

    if love.system.getOS() == 'Windows' and false then --implement later if needed
        local render_w, render_h = love.window.getDesktopDimensions(App.settings.WINDOW.selected_display)
        local unscaled_dims = love.window.getFullscreenModes(App.settings.WINDOW.selected_display)[1]

        local DPI_scale = math.floor((0.5 * unscaled_dims.width / render_w + 0.5 * unscaled_dims.height / render_h) * 500 + 0.5) / 500

        if DPI_scale > 1.1 then
            App.canvas_scale = 1.5
            App.AA_CANVAS = love.graphics.newCanvas(App.window.WINDOWTRANS.real_window_w * App.canvas_scale, App.window.WINDOWTRANS.real_window_h * App.canvas_scale, { type = '2d', readable = true })
            App.AA_CANVAS:setFilter('linear', 'linear')
        else
            App.AA_CANVAS = nil
        end
    end


    App.canvas = love.graphics.newCanvas(w * App.canvas_scale, h * App.canvas_scale, { type = '2d', readable = true })
    App.canvas:setFilter("linear", "linear")
end


return WindowManager
