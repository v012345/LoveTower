function boot_timer(_label, _next, progress)
    progress = progress or 0
    local realw, realh = love.window.getMode()
    love.graphics.setCanvas()
    love.graphics.push()
    love.graphics.setShader()
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setColor(0.6, 0.8, 0.9, 1)
    if progress > 0 then love.graphics.rectangle('fill', realw / 2 - 150, realh / 2 - 15, progress * 300, 30, 5) end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle('line', realw / 2 - 150, realh / 2 - 15, 300, 30, 5)
    love.graphics.print("LOADING: " .. _next, realw / 2 - 150, realh / 2 + 40)
    love.graphics.pop()
    love.graphics.present()
end

function HEX(hex)
    if #hex <= 6 then hex = hex .. "FF" end
    local _, _, r, g, b, a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
    local color = { tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255 or 255 }
    return color
end

function add_to_drawhash(obj)
    if obj then
        App.instance.DRAW_HASH[#App.instance.DRAW_HASH + 1] = obj
    end
end

function copy_table(O)
    local O_type = type(O)
    local copy
    if O_type == 'table' then
        copy = {}
        for k, v in next, O, nil do
            copy[copy_table(k)] = copy_table(v)
        end
        setmetatable(copy, copy_table(getmetatable(O)))
    else
        copy = O
    end
    return copy
end

function EMPTY(t)
    if not t then return {} end
    for k, v in pairs(t) do
        t[k] = nil
    end
    return t
end

function is_UI_containter(node)
end

--- 我怀疑这里是错的, 应该是
--- _T.x = _T.x + delta.x or 0
--- _T.y = _T.y + delta.y or 0
--- @param _T Transform
--- @param delta {x: number, y: number}
function point_translate(_T, delta)
    _T.x = (_T.x + delta.x) or 0
    _T.y = (_T.y + delta.y) or 0
end

--- 旋转一个点
---@param _T Transform
---@param angle number
function point_rotate(_T, angle)
    local _cos, _sin, _ox, _oy = math.cos(angle + math.pi / 2), math.sin(angle + math.pi / 2), _T.x, _T.y
    _T.x = -_oy * _cos + _ox * _sin
    _T.y = _oy * _sin + _ox * _cos
end
