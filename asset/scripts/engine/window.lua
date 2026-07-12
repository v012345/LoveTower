---@class Window: Object
Window = Object:extend()

function Window:init()
    self.TRANS = Transform(0, 0, 0, 0)
    self.real_size = Size(0, 0)
    self.orig_size = Size(0, 0)
    self.orig_scale = 0
end

function Window:update()
end

Window.instance = Window()
