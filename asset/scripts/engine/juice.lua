--- 有点像 tween 的感觉

---@class Juice
Juice = Object:extend()

function Juice:init(amount, rot_amt)
    self.scale = 0
    self.scale_amt = amount
    self.r = 0
    self.r_amt = rot_amt
    self.start_time = 0
    self.end_time = self.start_time + 0.4
end
