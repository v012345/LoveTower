---@class (partial) Controller : BaseClass

function Controller:update(dt)
    self.locks.wipe = not not App.screenwipe
    self.locked = false
    for k, v in pairs(self.locks) do
        if v then
            self.locked = true
            break
        end
    end
end
