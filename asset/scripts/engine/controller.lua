---@class Controller
Controller = Object:extend()


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
end

Controller.instance = Controller()
return Controller
