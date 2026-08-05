---@class (partial) Settings:Object
---@field WINDOW WindowSetting 窗口设置
---@field QUEUED_CHANGE QueuedChange 队列改变



---@class WindowSetting
---@field screenmode "Windowed" | "Fullscreen" | "Borderless" 窗口模式
---@field selected_display number 选择的显示器
---@field vsync number VSync值
---@field DISPLAYS DisplaySetting[] 显示器设置


---@class QueuedChange
---@field screenmode? "Windowed" | "Fullscreen" | "Borderless" 窗口模式
---@field selected_display? number 选择的显示器


---@class DisplaySetting
---@field name string 显示器名称
---@field screen_res Size 屏幕分辨率
