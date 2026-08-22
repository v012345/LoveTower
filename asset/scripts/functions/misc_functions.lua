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

function get_front_spriteinfo(_front)
    if _front and _front.suit and (_front.value == 'Jack' or _front.value == 'Queen' or _front.value == 'King') then
        if App.SETTINGS.data.CUSTOM_DECK and App.SETTINGS.data.CUSTOM_DECK.Collabs[_front.suit] then
            local _collab = App.SETTINGS.data.CUSTOM_DECK.Collabs[_front.suit]
            if (_collab == 'default') or (not App.ASSET_ATLAS[_collab .. '_' .. (App.SETTINGS.data.colourblind_option and 2 or 1)]) then
            else
                return App.ASSET_ATLAS[_collab .. '_' .. (App.SETTINGS.data.colourblind_option and 2 or 1)], App.COLLABS.pos[_front.value]
            end
        end
    end
    return App.ASSET_ATLAS[_front.atlas] or App.ASSET_ATLAS["cards_" .. (App.SETTINGS.data.colourblind_option and 2 or 1)], _front.pos
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
---@param m Moveable
---@param scale number
function prep_draw(m, scale)
    assert(m:is(Moveable), "moveable must be a Moveable")
    love.graphics.push()
    love.graphics.scale(App.window:get_pixels_per_tile())
    local x = m.VT.x + m.VT.w / 2 + m.layered_parallax.x
    local y = m.VT.y + m.VT.h / 2 + m.layered_parallax.y
    love.graphics.translate(x, y)
    if m.VT.r ~= 0 or m.juice then love.graphics.rotate(m.VT.r) end
    x = -scale * m.VT.w * (m.VT.scale) / 2
    y = -scale * m.VT.h * (m.VT.scale) / 2
    love.graphics.translate(x, y)
    love.graphics.scale(m.VT.scale * scale)
end

--create all the cards and suck them in
function make_splash_card(args)
    args = args or {}
    local angle = math.random() * 2 * 3.14
    local card_size = (args.scale or 1.5) * (math.random() + 1)
    local card_pos = args.card_pos or {
        x = (18 + card_size) * math.sin(angle),
        y = (18 + card_size) * math.cos(angle)
    }
    local CARD_W, CARD_H = GameCfg:get_card_size()
    local T = Transform(card_pos.x + App.ROOM.T.w / 2 - CARD_W * card_size / 2,
        card_pos.y + App.ROOM.T.h / 2 - CARD_H * card_size / 2,
        card_size * CARD_W, card_size * CARD_H)
    local card = Card(T, pseudorandom_element(App.P_CARDS), CardCfg:get_card_base(), nil, App.ROOM)
    if math.random() > 0.8 then
        card.sprite_facing = 'back'; card.facing = 'back'
    end
    card.no_shadow = true
    card.states.hover.can = false
    card.states.drag.can = false
    card.vortex = true and not args.no_vortex
    card.T.r = angle
    return card, card_pos
end

---@param obj Node
function add_to_drawhash(obj)
    if obj then
        App.DRAW_HASH[#App.DRAW_HASH + 1] = obj
    end
end

function ease_value(ref_table, ref_value, mod, floored, timer_type, not_blockable, delay, ease_type)
    mod = mod or 0

    --Ease from current chips to the new number of chips
    App.E_MANAGER:add_event(Event({
        trigger = EventTrigger.ease,
        blockable = (not_blockable == false),
        blocking = false,
        ref_table = ref_table,
        ref_value = ref_value,
        ease_to = ref_table[ref_value] + mod,
        timer = timer_type,
        delay = delay or 0.3,
        type = ease_type or nil,
        func = (function(t) if floored then return math.floor(t) else return t end end)
    }))
end

function reset_drawhash()
    for k in ipairs(App.DRAW_HASH) do
        App.DRAW_HASH[k] = nil
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
