---@class Smooth: Object
Smooth = Object:extend()


function Smooth:init()
    self.xy = 0
    self.scale = 0
    self.r = 0
    self.max_vel = 0
    self.move_dt = 0
end

function Smooth:update(dt)
    self.xy = math.exp(-50 * dt)
    self.scale = math.exp(-60 * dt)
    self.r = math.exp(-190 * dt)
    self.move_dt = math.min(1 / 20, dt)
    self.max_vel = 70 * self.move_dt
end

---@type Smooth
Smooth.instance = Smooth()
