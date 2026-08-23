---@meta

---@class love.joystick
love.joystick = love.joystick or {}

---Gets a list of connected Joysticks.
---@return Joystick[] joysticks The list of currently connected Joysticks.
function love.joystick.getJoysticks() end

---@class Joystick
Joystick = Joystick or {}

---@return string mappingstring `(nil)` A string containing the Joystick's gamepad mappings, or nil if the Joystick is not recognized as a gamepad.
function Joystick:getGamepadMappingString() end
