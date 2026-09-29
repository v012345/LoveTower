---玩家成就记录
---@class (partial) Metrics : Component
local Metrics = Component:extend()


function Metrics:init()
    self.cards = {
        used = {},
        bought = {},
        appeared = {},
    }
    self.decks = {
        chosen = {},
        win = {},
        lose = {}
    }
    self.bosses = {
        faced = {},
        win = {},
        lose = {},
    }
end

return Metrics
