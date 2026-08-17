---@class (partial) Controller: Object
local Controller = Object:extend()


--The controller contains all engine logic for how human input interacts with any game objects.
function Controller:init()
    self.locks = {}

    --Human Interface device flags, these are set per frame to ensure that correct controller updates are taking place
    self.HID = {
        last_type = '',
        dpad = false,
        pointer = true,
        touch = false,
        controller = false,
        mouse = true,
        axis_cursor = false,
    }
    self.clicked = { target = nil }
    self.focused = { target = nil }
    self.dragging = { target = nil }
    self.cursor_down = { target = nil }
    self.cursor_up = { target = nil }
    self.cursor_hover = { target = nil }
    self.is_cursor_down = false
end

function Controller:reset_locks()
    for k, _ in pairs(self.locks) do
        self.locks[k] = nil
    end
end

function Controller:update(dt)
end

return Controller
