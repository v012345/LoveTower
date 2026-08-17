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
