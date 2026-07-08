---@class Timer:Object
---@field TOTAL number 累计时间, 受 SPEEDFACTOR 影响
---@field REAL number 和 UPTIME 一样, 但是会被手动修改
---@field REAL_SHADER number
---@field UPTIME number 就是游戏第一次 update 到现在的真实累计时间
---@field BACKGROUND number
Timer = Object:extend()
function Timer:init()
    self.TOTAL = 0
    self.REAL = 0
    self.REAL_SHADER = 0
    self.UPTIME = 0
    self.BACKGROUND = 0
    self.SPEEDFACTOR = 1
end

function Timer:update(dt)
    self.TOTAL = self.TOTAL + dt * self.SPEEDFACTOR
    self.REAL = self.REAL + dt
    self.REAL_SHADER = self.REAL_SHADER + dt
    self.UPTIME = self.UPTIME + dt
    self.BACKGROUND = self.BACKGROUND + dt
end

---@return function
function Timer:get_total_timer()
    return function()
        return self.TOTAL
    end
end

---@return function
function Timer:get_real_timer()
    return function()
        return self.REAL
    end
end

---@return function
function Timer:get_real_shader_timer()
    return function()
        return self.REAL_SHADER
    end
end

---@return function
function Timer:get_update_timer()
    return function()
        return self.UPTIME
    end
end

---@type Timer
Timer.instance = Timer()
