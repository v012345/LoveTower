---@class (partial) SceneManager : BaseClass
---@overload fun(): SceneManager
local SceneManager = BaseClass:extend()

function SceneManager:init()
    self.root_node = Node("root")
    self.game_node = Node("game")
    self.ui_node = Node("ui")
    self.root_node:add_child(self.game_node)
    self.root_node:add_child(self.ui_node)
end

function SceneManager:update(dt)
    self.root_node:update(dt)
end

function SceneManager:draw()
    self.root_node:draw()
end

return SceneManager
