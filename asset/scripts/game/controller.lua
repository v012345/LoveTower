---@class (partial) Controller : GameObject
local Controller = GameObject:extend()


--The controller contains all engine logic for how human input interacts with any game objects.
function Controller:init()
    --Each of these are calculated per frame to pass along to the corresponding nodes for input handling
    self.clicked = { target = nil, handled = true, prev_target = nil }     --The node that was clicked this frame
    self.focused = { target = nil, handled = true, prev_target = nil }     --The node that is being focused on this frame, only applies when using controller
    self.dragging = { target = nil, handled = true, prev_target = nil }    --The node being dragged this frame
    self.hovering = { target = nil, handled = true, prev_target = nil }    --The node being hovered this frame
    self.released_on = { target = nil, handled = true, prev_target = nil } --The node that the cursor 'Released' on, like letting go of LMB

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

    self.cursor_down = { target = nil }
    self.cursor_up = { target = nil }
    self.cursor_hover = { target = nil }
    self.is_cursor_down = false
    --NOT IN GAME UNITS
    self.cursor_position = { x = 0, y = 0 }
    self.gamepad_patterns = {
        Playstation = { "%f[%w]PS%d%f[%D]", "Sony%f[%W]", "Play[Ss]tation" },
        Nintendo = { "Wii%f[%L]", "%f[%u]S?NES%f[%U]", "%f[%l]s?nes%f[%L]", "%f[%u]Switch%f[%L]", "Joy[- ]Cons?%f[%L]", },
        --Keyboard = {'balatro_kbm'}
    }
end

function Controller:reset_locks()
    for k, _ in pairs(self.locks) do
        self.locks[k] = nil
    end
end

function Controller:update(dt)
end

--Sets the gamepad to be the updated gamepad, searches for the console type and sets the art button pips accordingly
--Some code here is from github.com/idbrii/love-gamepadguesser (MIT License)
---@param _gamepad Joystick
function Controller:set_gamepad(_gamepad)

end

--Some code here is from github.com/idbrii/love-gamepadguesser (MIT License)
---@param _gamepad string
---@return string console
function Controller:get_console_from_gamepad(_gamepad)
    for k, v in pairs(self.gamepad_patterns) do
        for kk, vv in ipairs(v) do
            if _gamepad:match(vv) then
                return k
            end
        end
    end
    return 'Xbox'
end

return Controller
