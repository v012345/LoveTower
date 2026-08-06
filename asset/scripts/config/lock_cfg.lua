---@class (partial) LockConfig : Object
local LockConfig = Object:extend()

function LockConfig:init()
    self.locks = TableParser.instance:parse("lock")
end

function LockConfig:get_locks()
    return self.locks
end

---@type LockConfig
LockCfg = LockConfig()
