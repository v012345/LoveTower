---@class Settings:Object
---@field paused boolean 是否暂停
---@field QUEUED_CHANGE table 待执行的更改
---@field WINDOW WINDOW 窗口变换和真实大小
Settings = Object:extend()

function Settings:init()
    self.paused = false
end

---@type Settings
Settings.instance = Settings()
