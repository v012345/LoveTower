---玩家成就记录
---@class (partial) Metrics : GameObject
local Metrics = GameObject:extend()


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
