---@meta

---@param love_conf_table LoveConfTable 配置表
function love.conf(love_conf_table) end

---@class LoveConfTable
---@field window WindowConfig 窗口配置

---@class WindowConfig
---@field width number Sets the window's dimensions. If these flags are set to 0 LÖVE automatically uses the user's desktop dimensions. In mobile, the aspect ratio will be used to determine if the game runs in landscape or portrait.
---@field height number Sets the window's dimensions. If these flags are set to 0 LÖVE automatically uses the user's desktop dimensions. In mobile, the aspect ratio will be used to determine if the game runs in landscape or portrait.
