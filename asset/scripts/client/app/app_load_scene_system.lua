---@class (partial) App

---@param SceneManager SceneManager
function App:install_scene_manager(SceneManager)
    self.scene_manager = SceneManager
end


function App:get_scene_manager()
    return self.scene_manager
end