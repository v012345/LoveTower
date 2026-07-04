UIManager = UIManager or {}
---@type IView[]
UIManager.ViewStack = {}

---@param view IView
function UIManager:openView(view)
    local viewInstance = view.new()
    table.insert(UIManager.ViewStack, viewInstance)
    viewInstance:load()
end

function UIManager:closeView()
    local view = table.remove(UIManager.ViewStack)
    view:destroy()
end

function UIManager:load()

end

function UIManager:draw()
    for _, view in ipairs(UIManager.ViewStack) do
        view:draw()
    end
end

function UIManager:update(dt)
    for _, view in ipairs(UIManager.ViewStack) do
        view:update(dt)
    end
end
