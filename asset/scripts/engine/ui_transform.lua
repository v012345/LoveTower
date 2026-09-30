---@class UITransform : Component
UITransform = BaseClass:extend()
function UITransform:init()
    self.name = UITransform
    self.size = { w = 100, h = 100 }
    self.anchor = { x = 0.5, y = 0.5 }
end

function UITransform:set_size(w, h)
    if w then self.size.w = w end
    if h then self.size.h = h end
end

function UITransform:get_size()
    return self.size
end

function UITransform:set_anchor(x, y)
    if x then self.anchor.x = x end
    if y then self.anchor.y = y end
end

function UITransform:get_anchor()
    return self.anchor
end