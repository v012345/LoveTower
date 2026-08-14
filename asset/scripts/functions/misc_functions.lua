local font = love.graphics.setNewFont("asset/resources/fonts/YQ_FH.ttf", 20)
function boot_timer(cur_step, next_step, progress)
    -- print("boot_timer", cur_step, next_step, progress)
    progress = progress or 0
    love.graphics.setFont(font)
    local realw, realh = love.window.getMode()
    love.graphics.setCanvas()
    love.graphics.push()
    love.graphics.setShader()
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setColor(0.6, 0.8, 0.9, 1)
    love.graphics.rectangle('fill', realw / 2 - 150, realh / 2 - 15, progress * 300, 30, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle('line', realw / 2 - 150, realh / 2 - 15, 300, 30, 5)
    love.graphics.print("LOADING: " .. cur_step .. " -> " .. next_step, realw / 2 - 150, realh / 2 + 40)
    love.graphics.pop()
    love.graphics.present()
end

function play_sound(sound_code, per, vol)
end

function darken(colour, percent, no_tab)
    if no_tab then
        return
            colour[1] * (1 - percent),
            colour[2] * (1 - percent),
            colour[3] * (1 - percent),
            colour[4]
    end
    return {
        colour[1] * (1 - percent),
        colour[2] * (1 - percent),
        colour[3] * (1 - percent),
        colour[4]
    }
end

function adjust_alpha(colour, new_alpha, no_tab)
    if no_tab then
        return
            colour[1],
            colour[2],
            colour[3],
            new_alpha
    end
    return {
        colour[1],
        colour[2],
        colour[3],
        new_alpha
    }
end

function HEX(hex)
    if #hex <= 6 then hex = hex .. "FF" end
    local _, _, r, g, b, a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
    local color = { tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255 or 255 }
    return color
end

function get_chosen_triangle_from_rect(x, y, w, h, vert)
    local scale = 2
    if vert then
        x = x + math.min(0.6 * math.sin(Timer.instance.REAL * 9) * scale + 0.2, 0)
        return {
            x - 3.5 * scale, y + h / 2 - 1.5 * scale,
            x - 0.5 * scale, y + h / 2 + 0,
            x - 3.5 * scale, y + h / 2 + 1.5 * scale
        }
    else
        y = y + math.min(0.6 * math.sin(Timer.instance.REAL * 9) * scale + 0.2, 0)
        return {
            x + w / 2 - 1.5 * scale, y - 4 * scale,
            x + w / 2 + 0, y - 1.1 * scale,
            x + w / 2 + 1.5 * scale, y - 4 * scale
        }
    end
end

function mix_colours(C1, C2, proportionC1)
    return {
        (C1[1] or 0.5) * proportionC1 + (C2[1] or 0.5) * (1 - proportionC1),
        (C1[2] or 0.5) * proportionC1 + (C2[2] or 0.5) * (1 - proportionC1),
        (C1[3] or 0.5) * proportionC1 + (C2[3] or 0.5) * (1 - proportionC1),
        (C1[4] or 1) * proportionC1 + (C2[4] or 1) * (1 - proportionC1),
    }
end

---随机返回一个元素
---@generic K, V
---@param _t table<K, V>
---@param seed? number
---@return V, K
function pseudorandom_element(_t, seed)
    if seed then math.randomseed(seed) end
    local keys = {}
    for k, v in pairs(_t) do
        keys[#keys + 1] = { k = k, v = v }
    end

    if keys[1] and keys[1].v and type(keys[1].v) == 'table' and keys[1].v.sort_id then
        table.sort(keys, function(a, b) return a.v.sort_id < b.v.sort_id end)
    else
        table.sort(keys, function(a, b) return a.k < b.k end)
    end

    local key = keys[math.random(#keys)].k
    return _t[key], key
end

---为什么没有 end_draw 函数?
function prep_draw(moveable, scale, rotate, offset)
    love.graphics.push()
    love.graphics.scale(moveable.VT.scale * scale)
end

---@param obj Moveable
function add_to_drawhash(obj)
    if obj then
        App.DRAW_HASH[#App.DRAW_HASH + 1] = obj
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

---平移一个点
--- @param _T Transform
--- @param delta {x: number, y: number}
function point_translate(_T, delta)
    _T.x = _T.x + delta.x
    _T.y = _T.y + delta.y
end

---旋转一个点
---@param _T Transform
---@param angle number
function point_rotate(_T, angle)
    local _cos, _sin, _ox, _oy = math.cos(angle), math.sin(angle), _T.x, _T.y
    _T.x = _ox * _cos - _oy * _sin
    _T.y = _ox * _sin + _oy * _cos
end
