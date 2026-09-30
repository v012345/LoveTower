---@param game_scene Node
function App:load_game_scene(game_scene)
    self.game_scene = game_scene
end

---@return Node
function App:get_game_scene()
    return self.game_scene
end
