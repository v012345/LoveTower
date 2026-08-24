---@class (partial) Controller : GameObject

function Controller:update(dt)
    self.locked = false
    self.locks.wipe = not not App.screenwipe
end
