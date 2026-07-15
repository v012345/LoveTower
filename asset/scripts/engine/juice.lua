--- 有点像 tween 的感觉

---@class Juice
Juice = Object:extend()

function Juice:init(scale, scale_amt, rotation, rotation_amt, start_time, end_time, handled_elsewhere)
    self.scale = scale
    self.scale_amt = scale_amt
    self.r = rotation
    self.r_amt = rotation_amt
    self.start_time = start_time
    self.end_time = end_time
    self.handled_elsewhere = handled_elsewhere
end
