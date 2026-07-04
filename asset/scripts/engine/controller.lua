---@class Controller
Controller = Object:extend()


--The controller contains all engine logic for how human input interacts with any game objects.
function Controller:init()
    self.locks = {}
end
