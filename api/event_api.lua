---@meta

---@class EventConfig
---@field trigger?     EventTrigger
---@field delay?       number
---@field blockable?   boolean
---@field func?        function
---@field blocking?    boolean
---@field no_delete?   boolean
---@field start_timer? boolean
---@field timer?       function
---@field ref_table?   table
---@field ref_value?   string
---@field ease_to?     any
---@field stop_val?    any
EventConfig = {}

---@class EventStatus
---@field blocking   boolean
---@field completed  boolean
---@field time_done  boolean
---@field pause_skip boolean
EventStatus = {}

---@class (partial) Event : Object
---@field trigger EventTrigger 触发器函数
---@field blocking boolean
---@field blockable boolean
---@field func function
---@field timer function 使用的定时器函数
---@field time number
---@field complete boolean 是否完成
---@field private start_timer boolean 是否开始计时
---@field delay number
---@field no_delete boolean
---@field created_on_pause boolean
