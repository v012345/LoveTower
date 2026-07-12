---@class Window: Object
---@field TRANS Transform 窗口变换
---@field real_size Size 窗口实际大小
---@field orig_size Size 窗口原始大小
---@field orig_scale number 窗口原始缩放
---@field orig_ratio number 窗口原始宽高比例
Window = Object:extend()

function Window:init()
    -- x 和 y 就是 0
    self.TRANS = Transform(0, 0, 1, 1)
    self.real_size = Size(1, 1)
    self.size_by_tile = Size(1, 1)

    self.orig_size = Size(1, 1)
    self.orig_ratio = 1
end

---@param w number 窗口宽度以像素为单位
---@param h number 窗口高度以像素为单位
function Window:init_size(w, h)
    self.real_size:set(w, h)
    self.orig_size:set(w, h)
    self.orig_ratio = w / h
end

---comment
---@return Size
function Window:get_real_size()
    return self.real_size
end

---@param w number 窗口宽度
---@param h number 窗口高度
function Window:set_transform_wh(w, h)
    self.TRANS.w = w
    self.TRANS.h = h
end

function Window:update()
end

---@type Window
Window.instance = Window()
