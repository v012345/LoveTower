---@class Moveable
Moveable = Node:extend()

Moveable.exp_times = {
    xy = 0,
    scale = 0,
    r = 0,
    max_vel = 0
}

--Moveable represents any game object that has the ability to move about the gamespace.\
--All Moveables have a T (transform) that describes their desired transform in game units, as\
--well as a VT (Visible Transform) that eases to T over time. This allows for simplified movement where\
--we only need to set T.x, T.y, etc. to their final position and the engine will ensure the Moveable\
--VT eases to that final location, regargless of any events or timing.
--
--**T** The transform ititializer, with keys of x|1, y|2, w|3, h|4, r|5\
--**container** optional container for this Node, defaults to G.ROOM


---@param T Transform
---@param container Node
function Moveable:init(T, container)
    Node.init(self, T, container)
    self.layered_parallax = Coordinate(0, 0)
    --The Visible transform is initally set to the same values as the transform T.
    --Note that the VT has an extra 'scale' factor, this is used to manipulate the center-adjusted
    --scale of any objects that need to be drawn larger or smaller
    self.VT = self.T:clone()

    --To determine location of VT, we need to keep track of the velocity of VT as it approaches T for the next frame
    self.velocity = Velocity()

    --For more robust drawing, attaching, movement and fewer redundant movement calculations, Moveables each have a 'role'
    --that describes a heirarchy of move() calls. Any Moveables with 'Major' role type behave normally, essentially recalculating their
    --VT every frame to ensure smooth movement. Moveables can be set to 'Minor' role and attached to some 'Major' moveable
    --to weld the Minor moveable to the Major moveable. This makes the dependent moveable set their T and VT to be equal to
    --the corresponding 'Major' T and VT, plus some defined offset.
    --For finer control over what parts of T and VT are inherited, xy_bond, wh_bond, and r_bond can be set to one of
    --'Strong' or 'Weak'. Strong simply copies the values, Weak allows the 'Minor' moveable to calculate their own.
    self.role = MoveableRole(nil, RoleType.Major, self, Vec2(), BondType.Strong, BondType.Strong, BondType.Strong, BondType.Strong)
    self.alignment = Alignment(AlignmentType.a, Vec2(), AlignmentType.none, Vec2(), false)


    --the pinch table is used to modify the VT.w and VT.h compared to T.w and T.h. If either x or y pinch is
    --set to true, the VT width and or height will ease to 0. If pinch is false, they ease to T.w or T.h
    self.pinch = { x = false, y = false }

    --Keep track of the last time this Moveable was moved via :move(dt). When it is successfully moved, set to equal
    --the current G.TIMERS.REAL, and if it is called again this frame, doesn't recalculate move(dt)
    self.last_moved = -1
    self.last_aligned = -1

    self.static_rotation = false

    self.offset = Coordinate(0, 0)
    self.Mid = self -- 对齐参考点默认是自己

    self.shadow_parrallax = Coordinate(0, -1.5)
    self.shadow_height = 0.2

    self:calculate_parrallax()

    table.insert(App.MOVEABLES, self)
    if getmetatable(self) == Moveable then
        table.insert(App.I.MOVEABLE, self)
    end
end

---@private
function Moveable:get_bounding_transform()
    return self.VT
end

function Moveable:draw()
    Node.draw(self)
    self:draw_boundingrect()
end

--Sets the alignment of moveable using roles
--
---@param args {major: Moveable, bond: string, offset: table, type: AlignmentType}
--**major** The moveable this moveable will attach to\
--**bond** The bond type, either 'Strong' or 'Weak'. Strong instantly adjusts VT, Weak manually calculates VT changes\
--**offset** {x , y} offset from the alignment\
--**type** the alignment type. Vertical options: c - center, t - top, b - bottom. Horizontal options: l - left, m - middle, r - right. i for inner
function Moveable:set_alignment(args)
    args = args or {}
    if args.major then
        self:set_role({
            role_type = RoleType.Minor,
            major = args.major,
            xy_bond = args.bond or args.xy_bond or BondType.Weak,
            wh_bond = args.wh_bond or self.role:get_wh_bond(),
            r_bond = args.r_bond or self.role:get_r_bond(),
            scale_bond = args.scale_bond or self.role:get_scale_bond(),
        })
    end
    self.alignment:update_type(args.type)
    if args.offset and (type(args.offset) == 'table' and not (args.offset.y and args.offset.x)) or type(args.offset) ~= 'table' then
        args.offset = nil
    end
    self.alignment:update_offset(args.offset)
    self.alignment:set_lr_clamp(args.lr_clamp)
end

function Moveable:align_to_major()
    if not self.alignment:is_changed() then
        return
    end

    self.alignment:refresh()

    self.NEW_ALIGNMENT = true

    if self.alignment:is_a() or self.role:is_major_nil() then return end

    --- 左 和 上 都是 0
    local major_center_x = self.role:get_major().T.w / 2
    local major_center_y = self.role:get_major().T.h / 2
    local major_bottom_y = self.role:get_major().T.h
    local major_right_x = self.role:get_major().T.w
    --- 首先我们要知道当前 Node 的中心点相对于当前 Node 的左上角的偏移量
    --- 这里 center_offset_x 和 center_offset_y 就是当前 Node 的中心点指向当前 Node 的左上角的向量
    local center_offset_x = self.T.x - (self.Mid.T.x + self.Mid.T.w / 2)
    local center_offset_y = self.T.y - (self.Mid.T.y + self.Mid.T.h / 2)

    local offset_x = self.alignment:get_offset().x
    local offset_y = self.alignment:get_offset().y

    --- 水平居中对齐
    if self.alignment:is_m() then
        self.role:set_offset_x(major_center_x + center_offset_x + offset_x)
    end

    --- 垂直居中对齐
    if self.alignment:is_c() then
        self.role:set_offset_y(major_center_y + center_offset_y + offset_y)
    end

    --- 底部对齐
    if self.alignment:is_b() then
        if self.alignment:is_i() then
            self.role:set_offset_y(major_bottom_y + offset_y - self.T.h)
        else
            self.role:set_offset_y(major_bottom_y + offset_y)
        end
    end

    if self.alignment:is_r() then
        if self.alignment:is_i() then
            self.role:set_offset_x(major_right_x + offset_x - self.T.w)
        else
            self.role:set_offset_x(major_right_x + offset_x)
        end
    end

    if self.alignment:is_t() then
        if self.alignment:is_i() then
            self.role:set_offset_y(offset_y)
        else
            self.role:set_offset_y(offset_y - self.T.h)
        end
    end

    if self.alignment:is_l() then
        if self.alignment:is_i() then
            self.role:set_offset_x(offset_x)
        else
            self.role:set_offset_x(offset_x - self.T.w)
        end
    end


    self.T.x = self.role:get_final_x()
    self.T.y = self.role:get_final_y()

    self.alignment:set_prev_offset(self.alignment:get_offset())
end

function Moveable:hard_set_T(X, Y, W, H)
    self.T.x = X
    self.T.y = Y
    self.T.w = W
    self.T.h = H

    self.velocity.x = 0
    self.velocity.y = 0
    self.velocity.r = 0
    self.velocity.scale = 0

    self.VT.x = X
    self.VT.y = Y
    self.VT.w = W
    self.VT.h = H
    self.VT.r = self.T.r
    self.VT.scale = self.T.scale
    self:calculate_parrallax()
end

function Moveable:hard_set_VT()
    self.VT.x = self.T.x
    self.VT.y = self.T.y
    self.VT.w = self.T.w
    self.VT.h = self.T.h
end

function Moveable:drag(offset)
    if self.states.drag.can or offset then
        self.ARGS.drag_cursor_trans = self.ARGS.drag_cursor_trans or {}
        self.ARGS.drag_translation = self.ARGS.drag_translation or {}
        local _p = self.ARGS.drag_cursor_trans
        local _t = self.ARGS.drag_translation
        _p.x = G.CONTROLLER.cursor_position.x / (G.TILESCALE * G.TILESIZE)
        _p.y = G.CONTROLLER.cursor_position.y / (G.TILESCALE * G.TILESIZE)

        _t.x, _t.y = -self.container.T.w / 2, -self.container.T.h / 2
        point_translate(_p, _t)

        point_rotate(_p, self.container.T.r)

        _t.x, _t.y = self.container.T.w / 2 - self.container.T.x, self.container.T.h / 2 - self.container.T.y
        point_translate(_p, _t)

        if not offset then
            offset = self.click_offset
        end

        self.T.x = _p.x - offset.x
        self.T.y = _p.y - offset.y
        self.NEW_ALIGNMENT = true
        for k, v in pairs(self.children) do
            v:drag(offset)
        end
    end
    if self.states.drag.can then
        Node.drag(self)
    end
end

function Moveable:juice_up(amount, rot_amt)
    if App.SETTINGS.reduced_motion then return end
    amount = amount or 0.4
    local timer = Timer.instance:get_real_timer()
    local start_time = timer()
    local end_time = start_time + 0.4
    rot_amt = rot_amt or pseudorandom_element({ 0.6 * amount, -0.6 * amount }) or 0
    self.juice = Juice(0, amount, 0, rot_amt, start_time, end_time)
    self.VT.scale = 1 - 0.6 * amount
end

function Moveable:move_juice(dt)
    if self.juice and not self.juice.handled_elsewhere then
        local timer = Timer.instance:get_real_timer()
        local end_time = self.juice.end_time
        if end_time < timer() then
            self.juice = nil
        else
            local start_time = self.juice.start_time
            local life_time = end_time - start_time
            self.juice.scale = self.juice.scale_amt *
                math.sin(50.8 * (timer() - start_time)) *
                math.max(0, ((end_time - timer()) / life_time) ^ 3)
            self.juice.r = self.juice.r_amt *
                math.sin(40.8 * (timer() - start_time)) *
                math.max(0, ((end_time - timer()) / life_time) ^ 2)
        end
    end
end

function Moveable:move(dt)
    if self.FRAME.MOVE >= App.FRAMES.MOVE then return end
    self.FRAME.MAJOR = nil
    self.FRAME.MOVE = App.FRAMES.MOVE
    if not self.created_on_pause and App.SETTINGS.paused then return end

    --WHY ON EARTH DOES THIS LINE MAKE IT RUN 2X AS FAST???
    -------------------------------------------------------
    --local timestart = love.timer.getTime()
    -------------------------------------------------------

    self:align_to_major()

    self.CALCING = false
    local major = self.role:get_major()
    if self.role:is_glued() then
        if major then self:glue_to_major(major) end
    elseif self.role:is_minor() and major then
        if major.FRAME.MOVE < App.FRAMES.MOVE then
            major:move(dt)
        end
        self.STATIONARY = major.STATIONARY
        if (not self.STATIONARY) or
            self.NEW_ALIGNMENT or
            self.config.refresh_movement or
            self.juice or
            self.role:get_xy_bond() == BondType.Weak or
            self.role:get_r_bond() == BondType.Weak then
            self.CALCING = true
            self:move_with_major(dt)
        end
    elseif self.role:is_major() then
        self.STATIONARY = true
        self:move_juice(dt)
        self:move_xy(dt)
        self:move_r(dt, self.velocity)
        self:move_scale(dt)
        self:move_wh(dt)
        self:calculate_parrallax()
    end
    if self.alignment:get_lr_clamp() then
        self:lr_clamp()
    end

    self.NEW_ALIGNMENT = false
end

function Moveable:lr_clamp()
    if self.T.x < 0 then self.T.x = 0 end
    if self.VT.x < 0 then self.VT.x = 0 end
    if (self.T.x + self.T.w) > G.ROOM.T.w then self.T.x = G.ROOM.T.w - self.T.w end
    if (self.VT.x + self.VT.w) > G.ROOM.T.w then self.VT.x = G.ROOM.T.w - self.VT.w end
end

---感觉没有必要, 真的有效果吗?
---@param major_tab Moveable
function Moveable:glue_to_major(major_tab)
    self.T = major_tab.T --[[@as Transform]]

    self.VT.x = major_tab.VT.x + ((1 - major_tab.VT.w / major_tab.T.w) * (self.T.w / 2))
    self.VT.y = major_tab.VT.y
    self.VT.w = major_tab.VT.w
    self.VT.h = major_tab.VT.h
    self.VT.r = major_tab.VT.r
    self.VT.scale = major_tab.VT.scale

    self.pinch = major_tab.pinch
    self.shadow_parrallax = major_tab.shadow_parrallax
end

MWM = {
    rotated_offset = {},
    angles = {},
    WH = {},
    offs = {},
}

function Moveable:move_with_major(dt)
    if not self.role:is_minor() then return end
    local major_tab = self.role:get_major():get_major()

    self:move_juice(dt)

    --- 如果当前节点的旋转约束为弱，则计算旋转偏移
    if self.role:get_r_bond() == BondType.Weak then
        MWM.rotated_offset.x = self.role.offset.x + major_tab.offset.x
        MWM.rotated_offset.y = self.role.offset.y + major_tab.offset.y
    else
        if major_tab.major.VT.r < 0.0001 and major_tab.major.VT.r > -0.0001 then
            MWM.rotated_offset.x = self.role.offset.x + major_tab.offset.x
            MWM.rotated_offset.y = self.role.offset.y + major_tab.offset.y
        else
            MWM.angles.cos = math.cos(major_tab.major.VT.r)
            MWM.angles.sin = math.sin(major_tab.major.VT.r)
            MWM.WH.w = -self.T.w / 2 + major_tab.major.T.w / 2
            MWM.WH.h = -self.T.h / 2 + major_tab.major.T.h / 2

            MWM.offs.x = self.role.offset.x + major_tab.offset.x - MWM.WH.w
            MWM.offs.y = self.role.offset.y + major_tab.offset.y - MWM.WH.h

            MWM.rotated_offset.x = MWM.offs.x * MWM.angles.cos - MWM.offs.y * MWM.angles.sin + MWM.WH.w
            MWM.rotated_offset.y = MWM.offs.x * MWM.angles.sin + MWM.offs.y * MWM.angles.cos + MWM.WH.h
        end
    end

    self.T.x = major_tab.major.T.x + MWM.rotated_offset.x
    self.T.y = major_tab.major.T.y + MWM.rotated_offset.y

    if self.role:get_xy_bond() == BondType.Strong then
        self.VT.x = major_tab.major.VT.x + MWM.rotated_offset.x
        self.VT.y = major_tab.major.VT.y + MWM.rotated_offset.y
    elseif self.role:get_xy_bond() == BondType.Weak then
        self:move_xy(dt)
    end

    if self.role:get_r_bond() == BondType.Strong then
        self.VT.r = self.T.r + major_tab.major.VT.r + (self.juice and self.juice.r or 0)
    elseif self.role:get_r_bond() == BondType.Weak then
        self:move_r(dt, self.velocity)
    end

    if self.role:get_scale_bond() == BondType.Strong then
        self.VT.scale = self.T.scale * (major_tab.major.VT.scale / major_tab.major.T.scale) +
            (self.juice and self.juice.scale or 0)
    elseif self.role:get_scale_bond() == BondType.Weak then
        self:move_scale(dt)
    end

    if self.role:get_wh_bond() == BondType.Strong then
        self.VT.x = self.VT.x + (0.5 * (1 - major_tab.major.VT.w / (major_tab.major.T.w)) * self.T.w)
        self.VT.w = (self.T.w) * (major_tab.major.VT.w / major_tab.major.T.w)
        self.VT.h = (self.T.h) * (major_tab.major.VT.h / major_tab.major.T.h)
    elseif self.role:get_wh_bond() == BondType.Weak then
        self:move_wh(dt)
    end

    self:calculate_parrallax()
end

function Moveable:move_xy(dt)
    if (self.T.x ~= self.VT.x or math.abs(self.velocity.x) > 0.01) or (self.T.y ~= self.VT.y or math.abs(self.velocity.y) > 0.01) then
        self.velocity.x = App.exp_times.xy * self.velocity.x + (1 - App.exp_times.xy) * (self.T.x - self.VT.x) * 35 * dt
        self.velocity.y = App.exp_times.xy * self.velocity.y + (1 - App.exp_times.xy) * (self.T.y - self.VT.y) * 35 * dt
        if self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.y > App.exp_times.max_vel * App.exp_times.max_vel then
            local actual_vel = math.sqrt(self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.y)
            self.velocity.x = App.exp_times.max_vel * self.velocity.x / actual_vel
            self.velocity.y = App.exp_times.max_vel * self.velocity.y / actual_vel
        end
        self.STATIONARY = false
        self.VT.x = self.VT.x + self.velocity.x
        self.VT.y = self.VT.y + self.velocity.y
        if math.abs(self.VT.x - self.T.x) < 0.01 and math.abs(self.velocity.x) < 0.01 then
            self.VT.x = self.T.x; self.velocity.x = 0
        end
        if math.abs(self.VT.y - self.T.y) < 0.01 and math.abs(self.velocity.y) < 0.01 then
            self.VT.y = self.T.y; self.velocity.y = 0
        end
    end
end

function Moveable:move_scale(dt)
    local des_scale = self.T.scale +
        (self.zoom and ((self.states.drag.is and 0.1 or 0) + (self.states.hover.is and 0.05 or 0)) or 0) +
        (self.juice and self.juice.scale or 0)

    if des_scale ~= self.VT.scale or
        math.abs(self.velocity.scale) > 0.001 then
        self.STATIONARY = false
        self.velocity.scale = G.exp_times.scale * self.velocity.scale + (1 - G.exp_times.scale) *
            (des_scale - self.VT.scale)
        self.VT.scale = self.VT.scale + self.velocity.scale
    end
end

function Moveable:move_wh(dt)
    if (self.T.w ~= self.VT.w and not self.pinch.x) or
        (self.T.h ~= self.VT.h and not self.pinch.y) or
        (self.VT.w > 0 and self.pinch.x) or
        (self.VT.h > 0 and self.pinch.y) then
        self.STATIONARY = false
        self.VT.w = self.VT.w + (8 * dt) * (self.pinch.x and -1 or 1) * self.T.w
        self.VT.h = self.VT.h + (8 * dt) * (self.pinch.y and -1 or 1) * self.T.h
        self.VT.w = math.max(math.min(self.VT.w, self.T.w), 0)
        self.VT.h = math.max(math.min(self.VT.h, self.T.h), 0)
    end
end

---是不是旋转呀?
---@param dt number
---@param vel Velocity
function Moveable:move_r(dt, vel)
    local des_r = self.T.r + 0.015 * vel.x / dt + (self.juice and self.juice.r * 2 or 0)

    if des_r ~= self.VT.r or math.abs(self.velocity:get_r()) > 0.001 then
        self.STATIONARY = false
        self.velocity:set_r(App.TIMERS:approach_r(self.velocity:get_r(), des_r - self.VT.r))
        self.VT.r = self.VT.r + self.velocity.r
    end
    if math.abs(self.VT.r - self.T.r) < 0.001 and math.abs(self.velocity.r) < 0.001 then
        self.VT.r = self.T.r
        self.velocity.r = 0
    end
end

--- 离房间中心越远，阴影偏移越大
function Moveable:calculate_parrallax()
    local room = App.ROOM
    if room then
        self.shadow_parrallax.x = (self.T.x + self.T.w / 2 - room.T.w / 2) / (room.T.w / 2) * 1.5
    end
end

function Moveable:set_role(args)
    if args.major and not args.major.set_role then return end
    if args.offset and (type(args.offset) == 'table' and not (args.offset.y and args.offset.x)) or type(args.offset) ~= 'table' then
        args.offset = nil
    end
    self.role:update_role_type(args.role_type)
    self.role:update_offset(args.offset)
    self.role:update_major(args.major)
    self.role:update_xy_bond(args.xy_bond)
    self.role:update_wh_bond(args.wh_bond)
    self.role:update_r_bond(args.r_bond)
    self.role:update_scale_bond(args.scale_bond)
    self.role:update_draw_major(args.draw_major)

    if self.role:is_major() then self.role:set_major(nil) end
end

---@param scale number
---@param rotate? number
---@param offset? table
function Moveable:prep_draw(scale, rotate, offset)
    -- love.graphics.scale(App.TILESCALE * App.TILESIZE)
    offset = offset or Coordinate(0, 0)
    love.graphics.setColor(Color.RED)
    love.graphics.rectangle('fill', 0, 0, 20, 20)
    local VT = self.VT
    local layered_parallax = self.layered_parallax
    love.graphics.translate(
        VT.x + VT.w / 2 + offset.x + layered_parallax.x,
        VT.y + VT.h / 2 + offset.y + layered_parallax.y
    )
    if VT.r ~= 0 or self.juice or rotate then love.graphics.rotate(VT.r + (rotate or 0)) end
    love.graphics.translate(-scale * VT.w * (VT.scale) / 2, -scale * VT.h * (VT.scale) / 2)
    love.graphics.scale(self.VT.scale * scale)
end

---@return MoveableRole
function Moveable:get_major()
    local condition_1 = not self.role:is_major() and self.role:get_major() ~= self
    local condition_2 = self.role:get_xy_bond() ~= BondType.Weak and self.role:get_r_bond() ~= BondType.Weak
    if condition_1 and condition_2 then
        --First, does the major already have their offset precalculated for this frame?
        if not self.FRAME.MAJOR or App.REFRESH_FRAME_MAJOR_CACHE > 0 then
            local major = self.role:get_major():get_major()
            self.FRAME.MAJOR = MoveableRole(major:get_major(), nil, nil, Vec2(major.offset.x + self.role.offset.x + self.layered_parallax.x, major.offset.y + self.role.offset.y + self.layered_parallax.y))
        end
        return self.FRAME.MAJOR
    else
        self.ARGS.get_major = self.ARGS.get_major or MoveableRole(self)
        return self.ARGS.get_major
    end
end

---从App.instance.MOVEABLES和App.instance.I.MOVEABLE中移除self
--然后调用Node的remove方法
function Moveable:remove()
    for k, v in pairs(App.MOVEABLES) do
        if v == self then
            table.remove(App.MOVEABLES, k)
            break;
        end
    end
    for k, v in pairs(App.I.MOVEABLE) do
        if v == self then
            table.remove(App.I.MOVEABLE, k)
            break;
        end
    end
    Node.remove(self)
end

function Moveable:__tostring()
    return "Moveable" .. (self.ID)
end
