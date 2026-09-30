---目前看来直接实例化 Node 的只有一个, 就是 App.ROOM
---@class (partial) Node: BaseClass
---@field name string 节点名称
---@field children Node[] 子节点
---@field parent Node 父节点
---@field components table<string, Component> 组件
---@overload fun(name: string): Node
Node = BaseClass:extend()

---@private
function Node:init(name)
    self.name = name
    self.children = {}
    self.parent = nil
    self.active = true
    self.components = {}
end

--Draws self, then adds self the the draw hash, then draws all children
function Node:draw()
    if self.active then
        self:draw_self()
        for i, v in ipairs(self.children) do
            v:draw()
        end
    end
end

---@private
function Node:draw_self()
    for _, c in pairs(self.components) do
        c:draw()
    end
end

function Node:update(dt)
    if self.active then
        self:update_self(dt)
        for i, v in ipairs(self.children) do
            v:update(dt)
        end
    end
end

---@private
function Node:update_self(dt)
        for _, c in pairs(self.components) do
            c:update(dt)
        end
end

function Node:add_child(child)
    table.insert(self.children, child)
    child.parent = self
end

function Node:remove_child(child)
    for i, v in ipairs(self.children) do
        if v == child then
            table.remove(self.children, i)
            break
        end
    end
end

function Node:set_parent(parent)
    if self.parent then
        self.parent:remove_child(self)
    end
    self.parent = parent
    parent:add_child(self)
end

function Node:remove_from_parent()
    if self.parent then
        self.parent:remove_child(self)
    end
    self.parent = nil
end

function Node:add_component(component)
    self.components[component.name] = component
end

function Node:set_active(active)
    self.active = active
end
