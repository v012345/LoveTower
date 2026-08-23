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
---@param _gamepad love.joystick
function Controller:set_gamepad(_gamepad)
    if self.GAMEPAD.object ~= _gamepad then
        self.GAMEPAD.object = _gamepad
        self.GAMEPAD.mapping = _gamepad:getGamepadMappingString() or ''
        self.GAMEPAD.name = self.GAMEPAD.mapping:match("^%x*,(.-),") or ''
        self.GAMEPAD.temp_console = self:get_console_from_gamepad(self.GAMEPAD.name)
        if self.GAMEPAD_CONSOLE ~= self.GAMEPAD.temp_console then
            self.GAMEPAD_CONSOLE = self.GAMEPAD.temp_console
            for k, v in pairs(G.I.SPRITE) do
                if v.atlas == G.ASSET_ATLAS["gamepad_ui"] then
                    v.sprite_pos.y = G.CONTROLLER.GAMEPAD_CONSOLE == 'Nintendo' and 2 or G.CONTROLLER.GAMEPAD_CONSOLE == 'Playstation' and (G.F_PS4_PLAYSTATION_GLYPHS and 3 or 1) or 0
                    v:set_sprite_pos(v.sprite_pos)
                end
            end
        end
        self.GAMEPAD.temp_console = nil
    end
end

return Controller
