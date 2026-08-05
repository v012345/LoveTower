---@class Window: Object
---@field TRANS Transform 窗口变换
---@field real_size Size 窗口实际大小
---@field orig_size Size 窗口原始大小
---@field orig_scale number 窗口原始缩放
---@field orig_ratio number 窗口原始宽高比例
local Window = Object:extend()

function Window:init()
    local tile_width = GameCfg:get_tile_width()
    local tile_height = GameCfg:get_tile_height()
    local tile_scale = GameCfg:get_tile_scale()
    local tile_size = GameCfg:get_tile_size()
    -- Initialize the window
    self.ROOM_PADDING_H = 0.7
    self.ROOM_PADDING_W = 1
    self.WINDOWTRANS = {
        x = 0,
        y = 0,
        w = tile_width + 2 * self.ROOM_PADDING_W,
        h = tile_height + 2 * self.ROOM_PADDING_H
    }
    self.window_prev = {
        orig_scale = tile_scale,
        w = self.WINDOWTRANS.w * tile_size * tile_scale,
        h = self.WINDOWTRANS.h * tile_size * tile_scale,
        orig_ratio = self.WINDOWTRANS.w * tile_size * tile_scale
            / (self.WINDOWTRANS.h * tile_size * tile_scale)
    }
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

return Window
