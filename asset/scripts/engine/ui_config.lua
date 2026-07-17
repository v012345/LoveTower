---@class UIConfig
UIConfig = Object:extend()

function UIConfig:init()
    self.object = nil
    self.text = nil
    self.scale = nil
    self.colour = nil
    self.align = nil
    self.offset = nil
    self.major = nil
    self.bond = nil
    self.force_focus = false
    self.button = false
    self.force_collision = false
    self.shadow = false
    self.lang = {
        font = {
            FONTSCALE = 1
        }
    }
    self.text_drawable = nil
end
