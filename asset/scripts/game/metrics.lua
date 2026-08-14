---玩家成就记录
---@class (partial) Metrics: Object
local Metrics = Object:extend()


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
