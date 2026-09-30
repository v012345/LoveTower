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
            self.on_window_resize(w, h)
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

function WindowManager.on_window_resize(w, h) end

return WindowManager
