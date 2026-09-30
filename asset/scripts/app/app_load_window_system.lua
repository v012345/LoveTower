---@class (partial) App
---@field window_manager WindowManager
function App:load_window_system(window_manager)
    ---@type WindowManager
    self.window_manager = window_manager
end

---@return WindowManager
function App:get_window_manager()
    return self.window_manager
end

function App:on_window_resize(w, h)
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
