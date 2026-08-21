---@class Particles: Moveable 粒子发射器
---@field particles Particle[] 粒子
---@field private scale number 粒子的参数缩放, 不是 Transform 的缩放
---@field private lifespan number 产生的粒子的寿命
---@overload fun(T: Transform, config?: ParticlesConfig, container: Node): Particles
Particles = Moveable:extend()

---@param T Transform
---@param config? ParticlesConfig
---@param container Node
function Particles:init(T, config, container)
    config = config or {}
    Moveable.init(self, T, container)

    self.fill = config.fill
    self.padding = config.padding or 0

    if config.attach then
        self:set_alignment({ major = config.attach, type = AlignmentType.cm, bond = BondType.Strong })
        local major = self.role:get_major()
        table.insert(major.children, self)
        self.parent = major
        self.T.x = major.T.x + self.padding
        self.T.y = major.T.y + self.padding
        if self.fill then
            self.T.w = major.T.w - self.padding
            self.T.h = major.T.h - self.padding
        end
    end

    self.states.hover.can = false
    self.states.click.can = false
    self.states.collide.can = false
    self.states.drag.can = false
    self.states.release_on.can = false

    self.timer = config.timer or 0.5
    self.timer_type = (self.created_on_pause and App.TIMERS:get_real_timer()) or config.timer_type or App.TIMERS:get_real_timer()
    self.last_real_time = self.timer_type() - self.timer
    self.last_drawn = 0
    self.lifespan = config.lifespan or 1
    self.fade_alpha = 0
    self.speed = config.speed or 1
    self.max = config.max or 1000000000000000
    self.pulse_max = math.min(20, config.pulse_max or 0)
    self.pulsed = 0
    self.vel_variation = config.vel_variation or 1
    self.particles = {}
    self.scale = config.scale or 1
    self.colours = config.colours or { App.C.BACKGROUND.D }

    if config.initialize then
        for i = 1, 60 do
            self.last_real_time = self.last_real_time - 15 / 60
            self:update(15 / 60)
            self:move(15 / 60)
        end
    end

    if getmetatable(self) == Particles then
        table.insert(App.I.MOVEABLE, self)
    end
end

function Particles:update(dt)
    if App.SETTINGS:is_paused() and not self.created_on_pause then
        self.last_real_time = self.timer_type()
    else
        -- 每帧最多添加 20 个粒子
        local added_this_frame = 0
        while self.timer_type() > self.last_real_time + self.timer and (#self.particles < self.max or self.pulsed < self.pulse_max) and added_this_frame < 20 do
            self.last_real_time = self.last_real_time + self.timer
            local new_offset = {
                x = self.fill and (0.5 - math.random()) * self.T.w or 0,
                y = self.fill and (0.5 - math.random()) * self.T.h or 0
            }
            if self.fill and self.T.r < 0.1 and self.T.r > -0.1 then
                local newer_offset = {
                    x = math.sin(self.T.r) * new_offset.y + math.cos(self.T.r) * new_offset.x,
                    y = math.sin(self.T.r) * new_offset.x + math.cos(self.T.r) * new_offset.y,
                }
                new_offset = newer_offset
            end
            table.insert(self.particles, {
                draw = false,
                facing = math.random() * 2 * math.pi,
                age = 0,
                r_vel = 0.2 * (0.5 - math.random()),
                scale = 0,
                dir = math.random() * 2 * math.pi,
                colour = pseudorandom_element(self.colours),
                velocity = self.speed * (self.vel_variation * math.random() + (1 - self.vel_variation)) * 0.7,
                offset = new_offset
            })
            added_this_frame = added_this_frame + 1
            if self.pulsed <= self.pulse_max then self.pulsed = self.pulsed + 1 end
        end
    end
end

---对于 Moveable 实例来说, 游戏的主循环会先调用 move(dt) 方法, 然后调用 update(dt) 方法
function Particles:move(dt)
    if App.SETTINGS:is_paused() and not self.created_on_pause then return end

    Moveable.move(self, dt)
    -- if self.timer_type ~= Timer.real_timer then dt = dt * App.SETTINGS.speed_factor end
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        p.draw = true
        p.age = p.age + dt
        p.scale = 2 * math.min(p.age, self.lifespan - p.age) / self.lifespan * self.scale
        if p.scale < 0 then
            table.remove(self.particles, i)
        else
            p.offset.x = p.offset.x + p.velocity * math.sin(p.dir) * dt
            p.offset.y = p.offset.y + p.velocity * math.cos(p.dir) * dt
            p.facing = p.facing + p.r_vel * dt
            p.velocity = math.max(0, p.velocity - p.velocity * 0.07 * dt)
        end
    end
end

function Particles:fade(delay, to)
    App.E_MANAGER:add_event(Event({
        trigger = EventTrigger.ease,
        timer = self.timer_type,
        blockable = false,
        blocking = false,
        ref_value = 'fade_alpha',
        ref_table = self,
        ease_to = to or 1,
        delay = delay
    }))
end

function Particles:draw(alpha)
    alpha = alpha or 1
    love.graphics.push()
    do
        self:prep_draw(1)
        love.graphics.translate(self.T.w / 2, self.T.h / 2)
        for k, v in pairs(self.particles) do
            if v.draw then
                love.graphics.push()
                do
                    love.graphics.setColor(v.colour[1], v.colour[2], v.colour[3], v.colour[4] * alpha * (1 - self.fade_alpha))
                    love.graphics.translate(v.offset.x, v.offset.y)
                    love.graphics.rotate(v.facing)
                    local s = v.scale
                    love.graphics.rectangle('fill', -s / 2, -s / 2, s, s) -- origin in the middle
                end
                love.graphics.pop()
            end
        end
    end
    love.graphics.pop()
    add_to_drawhash(self)
    self:draw_boundingrect()
end

---从附着的节点中移除自己
function Particles:remove()
    local major = self.role:get_major()
    if major then
        for k, v in pairs(major.children) do
            if v == self and type(k) == 'number' then
                table.remove(major.children, k)
            end
        end
    end

    self:remove_all(self.children)

    Moveable.remove(self)
end

function Particles:__tostring()
    return "Particles" .. self.ID
end
