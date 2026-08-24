---目前看来直接实例化 Node 的只有一个, 就是 App.ROOM
---@class (partial) Node: GameObject
---@overload fun(transform: Transform, container: Node): Node
Node = GameObject:extend()

---@param transform Transform
---@param container Node
function Node:init(transform, container)
    self.args = {}
    self.rets = {}
    self.config = {}
    self.children = {}
    self.transform = transform
    self.collision_transform = transform
    self.id = generate_id()
    self.click_offset = Vec2()
    self.hover_offset = Vec2()
    self.container = container
    self.states = create_node_states()
    self.frames = create_frame_counter()
    self.created_on_pause = App.settings:is_paused()

    if getmetatable(self) == Node then
        table.insert(App.I.NODE, self)
    end

    -- 这个地方我没有明白
    if not App.STAGE_OBJECT_INTERRUPT then
        table.insert(App.STAGE_OBJECTS[App.STAGE], self)
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

---@private
function Node:get_bounding_transform()
    return self.transform
end

---@private
function Node:is_calculating()
    return false
end

--Draw a bounding rectangle representing the transform of this node. Used in debugging.
function Node:draw_boundingrect()
    self.under_overlay = App.under_overlay
    if App.DEBUG then
        self:draw_self_boundingrect()
    end
end

function Node:draw_self_boundingrect()
    local T = self:get_bounding_transform()
    local s = App.window:get_tile_scale()
    local size = App.window:get_tile_size()
    local x, y, w, h, r = T.x * size, T.y * size, T.w * size, T.h * size, T.r

    love.graphics.push()
    love.graphics.scale(s)
    love.graphics.translate(x + w * 0.5, y + h * 0.5)
    love.graphics.rotate(r)
    love.graphics.translate(-w * 0.5, -h * 0.5)
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.print(tostring(self), w, h, nil, 1 / s)
    love.graphics.setLineWidth(1 + (self.states.focus.is and 1 or 0))
    if self.states.collide.is then
        love.graphics.setColor(0, 1, 0, 0.3)
    else
        love.graphics.setColor(1, 0, 0, 0.3)
    end
    if self.states.focus.can then
        love.graphics.setColor(App.C.GOLD)
        love.graphics.setLineWidth(1)
    end
    if self:is_calculating() then
        love.graphics.setColor({ 0, 0, 1, 1 })
        love.graphics.setLineWidth(3)
    end
    love.graphics.rectangle('line', 0, 0, w, h, 3)
    love.graphics.pop()
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

---目前不知道进来的时候原点在什么地方, 但是根据这个函数来看, 进来的时候原点应该在 container 的左上角
---进入之后, 先移动到 container 的中心, 然后旋转, 然后移动到 container 的左上角, 再移动到 x , y \
---Room 的 container 是自己, 所以不会进入这个条件
function Node:translate_container()
    if self.container and self.container ~= self then
        local unit_tile = App.window:get_pixels_per_tile()
        local t = self.container.transform
        local center_x, center_y = t.w * unit_tile * 0.5, t.h * unit_tile * 0.5
        love.graphics.translate(center_x, center_y)
        love.graphics.rotate(t.r)
        love.graphics.translate(-center_x, -center_y)
        local x, y = t.x * unit_tile, t.y * unit_tile
        love.graphics.translate(x, y)
    end
end

--When this Node needs to be deleted, removes self from any tables it may have been added to to destroy any weak references\
--Also calls the remove method of all children to have them do the same
function Node:remove()
    local I = App.I
    for k, v in pairs(I.POPUP) do
        if v == self then
            table.remove(I.POPUP, k)
            break;
        end
    end
    for k, v in pairs(I.NODE) do
        if v == self then
            table.remove(I.NODE, k)
            break;
        end
    end
    for k, v in pairs(App.STAGE_OBJECTS[App.STAGE]) do
        if v == self then
            table.remove(App.STAGE_OBJECTS[App.STAGE], k)
            break;
        end
    end
    if self.children then
        for k, v in pairs(self.children) do
            v:remove()
        end
    end
    local controller = App.controller
    if controller.clicked.target == self then
        controller.clicked.target = nil
    end
    if controller.focused.target == self then
        controller.focused.target = nil
    end
    if controller.cursor_down.target == self then
        controller.cursor_down.target = nil
    end
    if controller.cursor_up.target == self then
        controller.cursor_up.target = nil
    end
    if controller.cursor_hover.target == self then
        controller.cursor_hover.target = nil
    end

    self.REMOVED = true
end

function Node:remove_all(t)
    for i = #t, 1, -1 do
        local v = t[i]
        table.remove(t, i)
        if v and v.children then
            remove_all(v.children)
        end
        if v then v:remove() end
        v = nil
    end
    for _, v in pairs(t) do
        if v.children then remove_all(v.children) end
        v:remove()
        v = nil
    end
end

---返回两个节点中心点之间的距离的平方(快速计算)
---returns the squared(fast) distance in game units from the center of this node to the center of another node
---@param other_node Node to measure the distance from
---@return number
function Node:fast_mid_dist(other_node)
    local dx = (other_node.transform.x + 0.5 * other_node.transform.w) - (self.transform.x + 0.5 * self.transform.w)
    local dy = (other_node.transform.y + 0.5 * other_node.transform.h) - (self.transform.y + 0.5 * self.transform.h)
    return dx * dx + dy * dy
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
    return "N#" .. self.id
end

------------ todo ------------


---@param point Point
function Node:collides_with_point(point)
    --First reset the collision state to false
    if self.container then
        local T = self.CT or self.T
        self.ARGS.collides_with_point_point = self.ARGS.collides_with_point_point or {}
        self.ARGS.collides_with_point_translation = self.ARGS.collides_with_point_translation or {}
        self.ARGS.collides_with_point_rotation = self.ARGS.collides_with_point_rotation or {}
        local _p = self.ARGS.collides_with_point_point
        local _t = self.ARGS.collides_with_point_translation
        local _r = self.ARGS.collides_with_point_rotation

        local _b = self.states.hover.is and App.COLLISION_BUFFER or 0

        _p.x, _p.y = point.x, point.y

        if self.container ~= self then --if there is some valid container, we need to apply all translations and rotations for the container first
            if math.abs(self.container.T.r) < 0.1 then
                --Translate to normalize this Node to the center of the container
                _t.x, _t.y = -self.container.T.w / 2, -self.container.T.h / 2
                point_translate(_p, _t)

                --Rotate node about the center of the container
                point_rotate(_p, self.container.T.r)

                --Translate node to undo the container translation, essentially reframing it in 'container' space
                _t.x, _t.y = self.container.T.w / 2 - self.container.T.x, self.container.T.h / 2 - self.container.T.y
                point_translate(_p, _t)
            else
                --Translate node to undo the container translation, essentially reframing it in 'container' space
                _t.x, _t.y = -self.container.T.x, -self.container.T.y
                point_translate(_p, _t)
            end
        end
        if math.abs(T.r) < 0.1 then
            --If we can essentially disregard transform rotation, just treat it like a normal rectangle
            if _p.x >= T.x - _b and _p.y >= T.y - _b and _p.x <= T.x + T.w + _b and _p.y <= T.y + T.h + _b then
                return true
            end
        else
            --Otherwise we need to do some silly point rotation garbage to determine if the point intersects the rotated rectangle
            _r.cos, _r.sin = math.cos(T.r + math.pi / 2), math.sin(T.r + math.pi / 2)
            _p.x, _p.y = _p.x - (T.x + 0.5 * (T.w)), _p.y - (T.y + 0.5 * (T.h))
            _t.x, _t.y = _p.y * _r.cos - _p.x * _r.sin, _p.y * _r.sin + _p.x * _r.cos
            _p.x, _p.y = _t.x + (T.x + 0.5 * (T.w)), _t.y + (T.y + 0.5 * (T.h))

            if _p.x >= T.x - _b and _p.y >= T.y - _b
                and _p.x <= T.x + T.w + _b and _p.y <= T.y + T.h + _b then
                return true
            end
        end
    end
end

---Controller 调用这个函数来设置这个节点的偏移量
---Sets the offset of passed point in terms of this nodes T.x and T.y
---@param point {x: number, y: number}
---@param type string
--**x and y** The coordinates of the cursor transformed into game units
--**type** the type of offset to set for this Node, either 'Click' or 'Hover'
function Node:set_offset(point, type)
    self.ARGS.set_offset_point = self.ARGS.set_offset_point or {}
    self.ARGS.set_offset_translation = self.ARGS.set_offset_translation or {}
    local _p = self.ARGS.set_offset_point
    local _t = self.ARGS.set_offset_translation

    _p.x, _p.y = point.x, point.y

    --Translate to middle of the container
    _t.x = -self.container.T.w / 2
    _t.y = -self.container.T.h / 2
    point_translate(_p, _t)

    --Rotate about the container midpoint according to node rotation
    point_rotate(_p, self.container.T.r)

    --Translate node to undo the container translation, essentially reframing it in 'container' space
    _t.x = self.container.T.w / 2 - self.container.T.x
    _t.y = self.container.T.h / 2 - self.container.T.y
    point_translate(_p, _t)

    if type == 'Click' then
        self.click_offset.x = (_p.x - self.T.x)
        self.click_offset.y = (_p.y - self.T.y)
    elseif type == 'Hover' then
        self.hover_offset.x = (_p.x - self.T.x)
        self.hover_offset.y = (_p.y - self.T.y)
    end
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

---Called by the CONTROLLER when this node is no longer being hovered, removes any h_popups
---@return nil
function Node:stop_hover()
    if self.children.h_popup then
        self.children.h_popup:remove()
        self.children.h_popup = nil
    end
end

---得到这个节点的中心, 好把光标聚焦在这个节点上
---Called by the CONTROLLER to determine the position the cursor should be set to for this node
---@return number
---@return number
function Node:put_focused_cursor()
    local unit_tile = Tile.instance:get_pixels_per_tile()
    return (self.T.x + self.T.w / 2 + self.container.T.x) * unit_tile, (self.T.y + self.T.h / 2 + self.container.T.y) * unit_tile
end
