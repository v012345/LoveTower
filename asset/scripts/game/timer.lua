---@class Timer:Object
---@field TOTAL number 累计时间, 受 SPEEDFACTOR 影响
---@field REAL number 和 UPTIME 一样, 但是会被手动修改
---@field REAL_SHADER number
---@field UPTIME number 就是游戏第一次 update 到现在的真实累计时间
---@field BACKGROUND number
---@field real_dt number 真实的每帧时间, 因为游戏循环可能会被暂停, 所以需要记录真实的每帧时间
---@field FRAMES {DRAW: number, MOVE: number} 帧数
---@field exp_times {xy: number, scale: number, r: number} 指数时间, 用于计算动画的指数衰减
local Timer = Object:extend()
function Timer:init()
    self.TOTAL = 0
    self.REAL = 0
    self.REAL_SHADER = 0
    self.UPTIME = 0
    self.BACKGROUND = 0
    self.SPEEDFACTOR = 1
    self.real_dt = 0
    self.FRAMES = {
        DRAW = 0,
        MOVE = 0
    }
    self.exp_times = { xy = 0, scale = 0, r = 0 }
end

function Timer:get_exp_times()
    return self.exp_times
end

function Timer:get_frames()
    return self.FRAMES
end

function Timer:get_real_time()
    return self.REAL
end

function Timer:update_real_time(dt)
    self.REAL = self.REAL + dt
end

function Timer:set_real_shader_time(time)
    self.REAL_SHADER = time
end

function Timer:update_game_time(dt)
    self.TOTAL = self.TOTAL + dt * self.SPEEDFACTOR
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

return Timer
