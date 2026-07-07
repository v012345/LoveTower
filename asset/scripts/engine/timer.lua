---@class Timer:Object
Timer = Object:extend()
function Timer:init()
    self.TOTAL = 0
    self.REAL = 0
    self.REAL_SHADER = 0
    self.UPTIME = 0
    self.BACKGROUND = 0
end

function Timer:update(dt)
    self.TOTAL = self.TOTAL + dt
    self.REAL = self.REAL + dt
    self.REAL_SHADER = self.REAL_SHADER + dt
    self.UPTIME = self.UPTIME + dt
    self.BACKGROUND = self.BACKGROUND + dt
end

---@type Timer
Timer.instance = Timer()
