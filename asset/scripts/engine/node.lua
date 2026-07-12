---目前看来直接实例化 Node 的只有一个, 就是 App.instance.ROOM

---@class Node: Object
---@field T Transform The transform of the node | Transform: 位置/大小/旋转 {x, y, w, h, r, scale}  (逻辑坐标)
---@field VT Transform 缓动变换成使用, 引擎会自动计算到 T
---@field CT Transform 碰撞检测的transform, 与 T 相同
---@field ID number 唯一ID
---@field states NodeStates 节点状态
---@field FRAME { DRAW: number, MOVE: number } 帧计数器, 用于记录绘制和移动的帧数
---@field children Children 子节点
---@field container Node 就是父节点, 子节点会被父节点影响
---@field config table 当前节点的元数据
---@field under_overlay boolean 是否在覆盖层?
---@field click_offset Coordinate Create the offset tables, used to determine things like drag offset and 3d shader effects
---@field hover_offset Coordinate Create the offset tables, used to determine things like drag offset and 3d shader effects
---@field created_on_pause boolean To keep track of all nodes created on pause. If true, this node moves normally even when the G.TIMERS.TOTAL doesn't increment
---@field ARGS table Store all argument tables here for reuse, because Lua likes to generate garbage
---@field RETS table Store all return tables here for reuse, because Lua likes to generate garbage
---@field CALCING boolean 是否正在计算, Moveable 的 move 方法会设置这个为 true
---@field parent Node 父节点
---@field layered_parallax Coordinate 分层偏移????
Node = Object:extend()


---Node represent any game object that needs to have some transform available in the game itself.\
---Everything that you see in the game is a Node, and some invisible things like the G.ROOM are also\
---represented here.
---**T** The transform ititializer, with keys of x|1, y|2, w|3, h|4, r|5
---**container** optional container for this Node, defaults to G.ROOM
---@param T? Transform,
---@param container Node
function Node:init(T, container)
    --From args, set the values of self transform
    self.ID = generate_id()
    self.T = T and T:clone() or Transform()
    self.CT = self.T
    self.parent = nil
    self.layered_parallax = Coordinate(0, 0)
    --The Visible transform is initally set to the same values as the transform T.
    --Note that the VT has an extra 'scale' factor, this is used to manipulate the center-adjusted
    --scale of any objects that need to be drawn larger or smaller
    self.VT = self.T:clone()
    self.click_offset = Coordinate()
    self.hover_offset = Coordinate()
    self.created_on_pause = App.instance.SETTINGS.paused
    self.FRAME = {
        DRAW = -1,
        MOVE = -1
    }
    self.ARGS = self.ARGS or {}
    self.RETS = {}
    self.config = self.config or {}
    self.container = container
    if not self.children then
        self.children = {}
    end

    --The states for this Node and all derived nodes. This is how we control the visibility and interactibility of any object
    --All nodes do not collide by default. This reduces the size of n for the O(n^2) collision detection
    self.states = {
        visible = true,
        collide = { can = false, is = false },
        focus = { can = false, is = false },
        hover = { can = true, is = false },
        click = { can = true, is = false },
        drag = { can = true, is = false },
        release_on = { can = true, is = false }
    }
    self.CALCING = false

    --Add this object to the appropriate instance table only if the metatable matches with NODE
    if getmetatable(self) == Node then
        table.insert(App.instance.I.NODE, self)
    end

    --Unless node was created during a stage transition (when G.STAGE_OBJECT_INTERRUPT is true), add all nodes to their appropriate
    --stage object table so they can be easily deleted on stage transition
    if not App.instance.STAGE_OBJECT_INTERRUPT then
        table.insert(App.instance.STAGE_OBJECTS[App.instance.STAGE], self)
    end
end

--Draws self, then adds self the the draw hash, then draws all children
function Node:draw()
    self:draw_boundingrect()
    if self.states.visible then
        add_to_drawhash(self)
        for _, v in pairs(self.children) do
            v:draw()
        end
    end
end

--Draw a bounding rectangle representing the transform of this node. Used in debugging.
function Node:draw_boundingrect()
    self.under_overlay = App.instance.under_overlay

    if App.instance.DEBUG then
        love.graphics.push()
        do
            local s = App.instance.TILESCALE
            local x, y, w, h, r = self.VT.x * s, self.VT.y * s, self.VT.w * s, self.VT.h * s, self.VT.r
            love.graphics.scale(s)
            love.graphics.translate(x + w * 0.5, y + h * 0.5)
            love.graphics.rotate(r)
            love.graphics.translate(-w * 0.5, -h * 0.5)
            love.graphics.setColor(1, 1, 0, 1)
            love.graphics.print(tostring(self), w, h, nil, 1 / App.instance.TILESCALE)
            love.graphics.setLineWidth(1 + (self.states.focus.is and 1 or 0))
            if self.states.collide.is then
                love.graphics.setColor(0, 1, 0, 0.3)
            else
                love.graphics.setColor(1, 0, 0, 0.3)
            end
            if self.states.focus.can then
                love.graphics.setColor(Color.GOLD)
                love.graphics.setLineWidth(1)
            end
            if self.CALCING then
                love.graphics.setColor({ 0, 0, 1, 1 })
                love.graphics.setLineWidth(3)
            end
            love.graphics.rectangle('line', 0, 0, w, h, 3)
        end
        love.graphics.pop()
    end
end

---Determines if this node collides with some point. Applies any container translations and rotations, then\
---applies translations and rotations specific to this node. This means the collision detection effectively\
---determines if some point intersects this node regargless of rotation.
---**x and y** The coordinates of the cursor transformed into game units
---@param point {x: number, y: number}
function Node:collides_with_point(point)
    --First reset the collision state to false
end

--Sets the offset of passed point in terms of this nodes T.x and T.y
--
---@param point {x: number, y: number}
---@param type string
--**x and y** The coordinates of the cursor transformed into game units
--**type** the type of offset to set for this Node, either 'Click' or 'Hover'
function Node:set_offset(point, type)

end

--If the current container is being 'Dragged', usually by a cursor, determine if any drag popups need to be generated and do so
function Node:drag()

end

--Determines if this Node can be dragged. This is a simple function but more complex objects may redefine this to return a parent\
--if the parent needs to drag other children with it
function Node:can_drag()
    return self.states.drag.can and self or nil
end

--Called by the CONTROLLER when this node is no longer being dragged, removes any d_popups
function Node:stop_drag()

end

--If the current container is being 'Hovered', usually by a cursor, determine if any hover popups need to be generated and do so
function Node:hover()

end

--- Called by the CONTROLLER when this node is no longer being hovered, removes any h_popups
---@return nil
function Node:stop_hover()

end

--Called by the CONTROLLER to determine the position the cursor should be set to for this node
function Node:put_focused_cursor()

end

---Sets the container of this node and all child nodes to be a new container node
---不理解为什么 children 也要一同重新设置 container
---@param container Node The new node that will behave as this nodes container
function Node:set_container(container)
    if self.children then
        for _, v in pairs(self.children) do
            v:set_container(container)
        end
    end
    self.container = container
end

--Translation function used before any draw calls, translates this node according to the transform of the container node
function Node:translate_container()

end

--When this Node needs to be deleted, removes self from any tables it may have been added to to destroy any weak references\
--Also calls the remove method of all children to have them do the same
function Node:remove()

end

---returns the squared(fast) distance in game units from the center of this node to the center of another node
---@param other_node Node to measure the distance from
function Node:fast_mid_dist(other_node)
end

--Prototype for a click release function, when the cursor is released on this node
function Node:release(dragged) end

--Prototype for a click function
function Node:click() end

--Prototype animation function for any frame manipulation needed
function Node:animate() end

--Prototype update function for any object specific logic that needs to occur every frame
function Node:update(dt) end

function Node:__tostring()
    return "Node" .. self.ID
end
