---@class (partial) Controller: Object
---@field clicked InteractNode
---@field focused InteractNode
---@field dragging InteractNode
---@field hovering InteractNode
---@field released_on InteractNode
---@field game_pad GamePad


---@class GamePad
---@field object Joystick
---@field mapping string
---@field name string
---@field temp_console string


---@alias InteractNode {
---target?: Node,
---handled: boolean,
---prev_target?: Node,
---}
