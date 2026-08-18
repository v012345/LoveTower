---@class (partial) Performance: Object
---@field app App
---@overload fun(app: App):Performance
local Performance = Object:extend()

function Performance:init(app)
    self.app = app
    self.PREV_GARB = 0
    self.check = {
        draw = {
            checkpoint_list = {},
            checkpoints = 0,
            last_time = 0,
        },
        update = {
            checkpoint_list = {},
            checkpoints = 0,
            last_time = 0,
        }
    }
end

---@param label? string
---@param type string
---@param reset? boolean
function Performance:timer_checkpoint(label, type, reset)
    if FeatureCfg:is_perf_overlay_enabled() then
        local cp = self.check[type]
        if reset then
            cp.last_time = love.timer.getTime()
            cp.checkpoints = 0
            return
        end

        cp.checkpoint_list[cp.checkpoints + 1] = cp.checkpoint_list[cp.checkpoints + 1] or {}
        cp.checkpoints = cp.checkpoints + 1
        cp.checkpoint_list[cp.checkpoints].label = label .. ': ' .. (collectgarbage("count") - self.PREV_GARB)
        cp.checkpoint_list[cp.checkpoints].time = love.timer.getTime()
        cp.checkpoint_list[cp.checkpoints].TTC = cp.checkpoint_list[cp.checkpoints].time - cp.last_time
        cp.checkpoint_list[cp.checkpoints].trend = cp.checkpoint_list[cp.checkpoints].trend or {}
        cp.checkpoint_list[cp.checkpoints].states = cp.checkpoint_list[cp.checkpoints].states or {}
        table.insert(cp.checkpoint_list[cp.checkpoints].trend, 1, cp.checkpoint_list[cp.checkpoints].TTC)
        table.insert(cp.checkpoint_list[cp.checkpoints].states, 1, self.app.STATE)
        cp.checkpoint_list[cp.checkpoints].trend[401] = nil
        cp.checkpoint_list[cp.checkpoints].states[401] = nil
        cp.last_time = cp.checkpoint_list[cp.checkpoints].time
        self.PREV_GARB = collectgarbage("count")
        local av = 0
        for k, v in ipairs(cp.checkpoint_list[cp.checkpoints].trend) do
            av = av + v / #cp.checkpoint_list[cp.checkpoints].trend
        end
        cp.checkpoint_list[cp.checkpoints].average = av
    end
end

return Performance
