---@class (partial) LockConfig : Object
local LockConfig = Object:extend()

function LockConfig:init()
    self.locks = TableParser.instance:parse("lock")
end

function LockConfig:get_locks()
    return self.locks
end

function LockConfig:get_cfg_by_id(id)
    return self.locks[id]
end

---@type LockConfig
LockCfg = LockConfig()
