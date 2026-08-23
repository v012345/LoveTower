---@class (partial) Performance : GameObject
---@field app App
---@overload fun(app: App):Performance
local Performance = GameObject:extend()

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

function Performance:state_col(_state)
    return (_state * 15251252.2 / 5.132) % 1, (_state * 1422.5641311 / 5.42) % 1, (_state * 1522.1523122 / 5.132) % 1, 1
end

function Performance:draw()
    love.graphics.push()
    local section_h = 30
    local resolution = 60 * section_h
    local poll_w = 1
    local v_off = 100
    for a, b in ipairs({ self.check.update, self.check.draw }) do
        for k, v in ipairs(b.checkpoint_list) do
            love.graphics.setColor(0, 0, 0, 0.2)
            love.graphics.rectangle('fill', 12, 20 + v_off, poll_w + poll_w * #v.trend, -section_h + 5)
            for kk, vv in ipairs(v.trend) do
                if a == 2 then
                    love.graphics.setColor(0.3, 0.7, 0.7, 1)
                else
                    love.graphics.setColor(self:state_col(v.states[kk] or 123))
                end
                love.graphics.rectangle('fill', 10 + poll_w * kk, 20 + v_off, 5 * poll_w, -(vv) * resolution)
            end
            love.graphics.setColor(a == 2 and 0.5 or 1, a == 2 and 1 or 0.5, 1, 1)
            love.graphics.print(v.label .. ': ' .. (string.format("%.2f", 1000 * (v.average or 0))) .. '\n', 10, -section_h + 30 + v_off)
            v_off = v_off + section_h
        end
    end
    love.graphics.pop()
end

return Performance
