---@class UIBox: Moveable
---@field UIRoot UIElement
UIBox = Moveable:extend()
---@param args {T: table, definition: table, config: table}
function UIBox:init(args)
    Moveable.init(self, args)
    if getmetatable(self) == UIBox then
        table.insert(App.instance.I.UIBOX, self)
    end
end

function UIBox:get_UIE_by_ID(id, node)
end

function UIBox:calculate_xywh(node, _T, recalculate, _scale)
end

function UIBox:remove_group(node, group)
end

function UIBox:get_group(node, group, ingroup)
end

function UIBox:set_parent_child(node, parent)
end

function UIBox:remove()
end

function UIBox:draw()
    print('UIBox:draw')
    local realw, realh = love.window.getMode()
    -- love.graphics.setCanvas()
    -- love.graphics.push()
    -- love.graphics.setShader()
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setColor(0.6, 0.8, 0.9, 1)
    -- if progress > 0 then love.graphics.rectangle('fill', realw / 2 - 150, realh / 2 - 15, progress * 300, 30, 5) end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle('line', realw / 2 - 150, realh / 2 - 15, 300, 30, 5)
    love.graphics.print("LOADING: ", realw / 2 - 150, realh / 2 + 40)
    -- love.graphics.pop()
    -- love.graphics.present()
end

function UIBox:recalculate()
end

function UIBox:move(dt)
end

function UIBox:drag(offset)
end

function UIBox:add_child(node, parent)
end

function UIBox:set_container(container)
end

function UIBox:print_topology(indent)
end
