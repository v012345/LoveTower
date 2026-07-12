---@class Window: Object
---@field TRANS Transform 窗口变换
---@field real_size Size 窗口实际大小
---@field orig_size Size 窗口原始大小
---@field orig_scale number 窗口原始缩放
Window = Object:extend()

function Window:init()
    self.TRANS = Transform(0, 0, 1, 1)
    self.real_size = Size(1, 1)
    self.orig_size = Size(1, 1)
    self.orig_scale = 1
end

function Window:update()
end

---@type Window
Window.instance = Window()
