---@class (partial) Timer : GameObject
---@field TOTAL number 累计时间, 受 SPEEDFACTOR 影响
---@field REAL number 和 UPTIME 一样, 但是会被手动修改
---@field REAL_SHADER number
---@field UPTIME number 就是游戏第一次 update 到现在的真实累计时间
---@field BACKGROUND number
---@field real_dt number 真实的每帧时间, 因为游戏循环可能会被暂停, 所以需要记录真实的每帧时间
---@field frames FrameCounter 帧数
---@field exp_times ExpTimes 指数时间, 用于计算动画的指数衰减
local Timer = GameObject:extend()
function Timer:init()
    self.TOTAL = 0
    self.REAL = 0
    self.REAL_SHADER = 0
    self.UPTIME = 0
    self.BACKGROUND = 0
    self.real_dt = 0
    self.frames = {
        draw = 0,
        move = 0
    }
    self.exp_times = {
        xy = 0,
        scale = 0,
        r = 0,
        max_vel = 0
    }
end

function Timer:update_background_time(dt)
    self.BACKGROUND = self.BACKGROUND + dt
end

function Timer:get_exp_times()
    return self.exp_times
end

---平滑过度用
function Timer:update_exp_times(dt)
    self.exp_times.xy = math.exp(-50 * dt)
    self.exp_times.scale = math.exp(-60 * dt)
    self.exp_times.r = math.exp(-190 * dt)
    local move_dt = math.min(1 / 20, dt)
    self.exp_times.max_vel = 70 * move_dt
end

function Timer:get_frames()
    return self.frames
end

function Timer:get_real_time()
    return self.REAL
end

function Timer:update_time(dt)
    self.UPTIME = self.UPTIME + dt
end

function Timer:update_real_time(dt)
    self.REAL = self.REAL + dt
end

function Timer:set_real_shader_time(time)
    self.REAL_SHADER = time
end

function Timer:update_game_time(dt)
    self.TOTAL = self.TOTAL + dt
end

---@return fun(): number
function Timer:get_total_timer()
    return function()
        return self.TOTAL
    end
end

---@return fun(): number
function Timer:get_real_timer()
    return function()
        return self.REAL
    end
end

---@return fun(): number
function Timer:get_real_shader_timer()
    return function()
        return self.REAL_SHADER
    end
end

---@return fun(): number
function Timer:get_update_timer()
    return function()
        return self.UPTIME
    end
end

--- NewX = a*OldX + (1-a)*NewX
--- a = exp(-50 * dt)
--- 就是 dy/dx = k(y-x), 其中 k 是常数, 的离散解
--- 多代入几次, 可以推导出, 现在就不写了, 有点麻烦
function Timer:approach_r(cur_r, des_r)
    return self.exp_times.r * cur_r + (1 - self.exp_times.r) * des_r
end

return Timer
