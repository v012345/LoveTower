---@meta

---@class (partial) Particles: Moveable 粒子发射器
---@field particles Particle[] 粒子
---@field private scale number 粒子的参数缩放, 不是 Transform 的缩放
---@field private lifespan number 产生的粒子的寿命
---@field private timer number 产生一个粒子需要的时间
---@field private last_real_time number 产生上一个粒子的时间
---@field private timer_type fun(): number 时间函数, 调用返回一个时间
---@field fill boolean 在粒子发射器的大小范围内产生粒子, 或在 (0, 0) 点产生粒子


---@class Particle
---@field draw     boolean    是否绘制
---@field age      number     已存活时间
---@field scale    number     缩放
---@field facing   number     朝向
---@field r_vel    number     旋转速度
---@field velocity number     速度
---@field dir      number     方向
---@field offset   Vec2       偏移
---@field colour   table      颜色


---@class ParticlesConfig
---@field fill? boolean 在粒子发射器的大小范围内产生粒子, 或在 (0, 0) 点产生粒子
---@field padding? number
---@field attach? Moveable 要附着到哪个 Moveable 上
---@field timer? number
---@field timer_type? fun(): number
---@field lifespan? number
---@field speed? number
---@field max? number
---@field pulse_max? number
---@field vel_variation? number
---@field scale? number
---@field colours? Color[]
---@field initialize? boolean
