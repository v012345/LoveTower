require "love.filesystem"

print(love.filesystem.getSaveDirectory())

local function lua_table_to_string(t)
end


---@param t table
---@return string[]
local function extract_table_keys(t)
    local keys = {}
    for k, _ in pairs(t) do
        keys[#keys + 1] = k
    end

    for _, key in ipairs(keys) do
        assert(type(key) == "string", "extract_table_keys: key is not a string, " .. type(key) .. " - " .. tostring(key))
    end

    table.sort(keys)
    return keys
end


---@param s string
---@return string
local function lua_string_to_csv_string(s)
    local need_quote = false

    -- 1. 转义 "
    if s:find('"', 1, true) then
        s = s:gsub('"', '""')
        need_quote = true
    end

    -- 2. 检查其它需要引用的字符
    if not need_quote then
        if s:find(",", 1, true) or s:find("\n", 1, true) or s:find("\r", 1, true) then
            need_quote = true
        end
    end

    -- 3. 包裹
    if need_quote then
        s = '"' .. s .. '"'
    end
    return s
end


---有一个要求, 就是 t 里的元素是同一个类型, 且不能是表
---@generic T
---@param t T[]
---@return string
local function lua_array_to_string(t)
    -- 先 check 一下
    local len = #t
    local index = 1
    for i, _ in ipairs(t) do
        index = i
    end

    assert(index == len, "lua_array_to_string: table is not a array")

    local elements = {}
    for i, v in ipairs(t) do
        if type(v) == "string" then
            elements[i] = "'" .. tostring(v) .. "'"
        else
            elements[i] = tostring(v)
        end
    end

    return ("{" .. table.concat(elements, ",") .. "}")
end



---@param t string[][]
---@param file_path string
local function write_to_csv(t, file_path)
    local rows = {}
    for i, row in ipairs(t) do
        local line = {}
        for j, cell in ipairs(row) do
            line[#line + 1] = lua_string_to_csv_string(cell)
            line[#line + 1] = ","
        end
        line[#line] = nil
        rows[#rows + 1] = table.concat(line)
    end
    local data = table.concat(rows, "\n")
    love.filesystem.write(file_path, "\239\187\191" .. data)
end


local function collabs_cfg_to_csv()
    local t = {
        Spades = {
            'default',
            'collab_TW',
            'collab_CYP',
            'collab_SK',
            'collab_DS',
            'collab_AC',
            'collab_STP',
        },
        Hearts = {
            'default',
            'collab_AU',
            'collab_TBoI',
            'collab_CL',
            'collab_D2',
            'collab_CR',
            'collab_BUG',
        },
        Clubs = {
            'default',
            'collab_VS',
            'collab_STS',
            'collab_PC',
            'collab_WF',
            'collab_FO',
            'collab_DBD'
        },
        Diamonds = {
            'default',
            'collab_DTD',
            'collab_SV',
            'collab_EG',
            'collab_XR',
            'collab_C7',
            'collab_R'
        }
    }
    local comment = { "注释行" }
    local header = { "Id" }
    local data_type = { "string" }
    local keys = extract_table_keys(t)
    for _, key in ipairs(keys) do
        header[#header + 1] = key
        data_type[#data_type + 1] = "string[]"
    end
    local data = {}
    data[#data + 1] = comment
    data[#data + 1] = header
    data[#data + 1] = data_type
    data[#data + 1] = { "unique" }
    local line = { "1" }
    for _, key in ipairs(header) do
        if t[key] then
            line[#line + 1] = lua_array_to_string(t[key])
        end
    end
    data[#data + 1] = line
    write_to_csv(data, "collabs_temp.csv")
end
-- collabs_cfg_to_csv()


local function atli_cfg_to_csv()
    local SETTINGS = {
        GRAPHICS = {
            texture_scaling = 1
        }
    }
    local animation_atli = {
        { name = "blind_chips", path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/BlindChips.png",        px = 34,  py = 34, frames = 21 },
        { name = "shop_sign",   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/ShopSignAnimation.png", px = 113, py = 57, frames = 4 }
    }
    local asset_atli = {
        { name = "cards_1",       path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/8BitDeck.png",              px = 71,  py = 95 },
        { name = "cards_2",       path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/8BitDeck_opt2.png",         px = 71,  py = 95 },
        { name = "centers",       path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/Enhancers.png",             px = 71,  py = 95 },
        { name = "Joker",         path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/Jokers.png",                px = 71,  py = 95 },
        { name = "Tarot",         path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/Tarots.png",                px = 71,  py = 95 },
        { name = "Voucher",       path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/Vouchers.png",              px = 71,  py = 95 },
        { name = "Booster",       path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/boosters.png",              px = 71,  py = 95 },
        { name = "ui_1",          path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/ui_assets.png",             px = 18,  py = 18 },
        { name = "ui_2",          path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/ui_assets_opt2.png",        px = 18,  py = 18 },
        { name = "balatro",       path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/balatro.png",               px = 333, py = 216 },
        { name = 'gamepad_ui',    path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/gamepad_ui.png",            px = 32,  py = 32 },
        { name = 'icons',         path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/icons.png",                 px = 66,  py = 66 },
        { name = 'tags',          path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/tags.png",                  px = 34,  py = 34 },
        { name = 'stickers',      path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/stickers.png",              px = 71,  py = 95 },
        { name = 'chips',         path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/chips.png",                 px = 29,  py = 29 },

        { name = 'collab_AU_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_AU_1.png",   px = 71,  py = 95 },
        { name = 'collab_AU_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_AU_2.png",   px = 71,  py = 95 },
        { name = 'collab_TW_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_TW_1.png",   px = 71,  py = 95 },
        { name = 'collab_TW_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_TW_2.png",   px = 71,  py = 95 },
        { name = 'collab_VS_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_VS_1.png",   px = 71,  py = 95 },
        { name = 'collab_VS_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_VS_2.png",   px = 71,  py = 95 },
        { name = 'collab_DTD_1',  path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_DTD_1.png",  px = 71,  py = 95 },
        { name = 'collab_DTD_2',  path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_DTD_2.png",  px = 71,  py = 95 },

        { name = 'collab_CYP_1',  path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_CYP_1.png",  px = 71,  py = 95 },
        { name = 'collab_CYP_2',  path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_CYP_2.png",  px = 71,  py = 95 },
        { name = 'collab_STS_1',  path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_STS_1.png",  px = 71,  py = 95 },
        { name = 'collab_STS_2',  path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_STS_2.png",  px = 71,  py = 95 },
        { name = 'collab_TBoI_1', path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_TBoI_1.png", px = 71,  py = 95 },
        { name = 'collab_TBoI_2', path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_TBoI_2.png", px = 71,  py = 95 },
        { name = 'collab_SV_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_SV_1.png",   px = 71,  py = 95 },
        { name = 'collab_SV_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_SV_2.png",   px = 71,  py = 95 },

        { name = 'collab_SK_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_SK_1.png",   px = 71,  py = 95 },
        { name = 'collab_SK_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_SK_2.png",   px = 71,  py = 95 },
        { name = 'collab_DS_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_DS_1.png",   px = 71,  py = 95 },
        { name = 'collab_DS_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_DS_2.png",   px = 71,  py = 95 },
        { name = 'collab_CL_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_CL_1.png",   px = 71,  py = 95 },
        { name = 'collab_CL_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_CL_2.png",   px = 71,  py = 95 },
        { name = 'collab_D2_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_D2_1.png",   px = 71,  py = 95 },
        { name = 'collab_D2_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_D2_2.png",   px = 71,  py = 95 },
        { name = 'collab_PC_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_PC_1.png",   px = 71,  py = 95 },
        { name = 'collab_PC_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_PC_2.png",   px = 71,  py = 95 },
        { name = 'collab_WF_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_WF_1.png",   px = 71,  py = 95 },
        { name = 'collab_WF_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_WF_2.png",   px = 71,  py = 95 },
        { name = 'collab_EG_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_EG_1.png",   px = 71,  py = 95 },
        { name = 'collab_EG_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_EG_2.png",   px = 71,  py = 95 },
        { name = 'collab_XR_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_XR_1.png",   px = 71,  py = 95 },
        { name = 'collab_XR_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_XR_2.png",   px = 71,  py = 95 },

        { name = 'collab_CR_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_CR_1.png",   px = 71,  py = 95 },
        { name = 'collab_CR_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_CR_2.png",   px = 71,  py = 95 },
        { name = 'collab_BUG_1',  path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_BUG_1.png",  px = 71,  py = 95 },
        { name = 'collab_BUG_2',  path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_BUG_2.png",  px = 71,  py = 95 },
        { name = 'collab_FO_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_FO_1.png",   px = 71,  py = 95 },
        { name = 'collab_FO_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_FO_2.png",   px = 71,  py = 95 },
        { name = 'collab_DBD_1',  path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_DBD_1.png",  px = 71,  py = 95 },
        { name = 'collab_DBD_2',  path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_DBD_2.png",  px = 71,  py = 95 },
        { name = 'collab_C7_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_C7_1.png",   px = 71,  py = 95 },
        { name = 'collab_C7_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_C7_2.png",   px = 71,  py = 95 },
        { name = 'collab_R_1',    path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_R_1.png",    px = 71,  py = 95 },
        { name = 'collab_R_2',    path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_R_2.png",    px = 71,  py = 95 },
        { name = 'collab_AC_1',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_AC_1.png",   px = 71,  py = 95 },
        { name = 'collab_AC_2',   path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_AC_2.png",   px = 71,  py = 95 },
        { name = 'collab_STP_1',  path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_STP_1.png",  px = 71,  py = 95 },
        { name = 'collab_STP_2',  path = "resources/textures/" .. SETTINGS.GRAPHICS.texture_scaling .. "x/collabs/collab_STP_2.png",  px = 71,  py = 95 },
    }
    local asset_images = {
        { name = "playstack_logo",  path = "resources/textures/1x/playstack-logo.png",  px = 1417, py = 1417 },
        { name = "localthunk_logo", path = "resources/textures/1x/localthunk-logo.png", px = 1390, py = 560 }
    }
    local keys = {}
    for _, value in ipairs(animation_atli) do
        for _, key in ipairs(extract_table_keys(value)) do
            keys[#keys + 1] = key
        end
    end
    for _, value in ipairs(asset_images) do
        for _, key in ipairs(extract_table_keys(value)) do
            keys[#keys + 1] = key
        end
    end
    for _, value in ipairs(asset_atli) do
        for _, key in ipairs(extract_table_keys(value)) do
            keys[#keys + 1] = key
        end
    end

    local key_delete_duplicated = {}
    for _, key in ipairs(keys) do
        key_delete_duplicated[key] = true
    end
    keys = {}
    for key, _ in pairs(key_delete_duplicated) do
        keys[#keys + 1] = key
    end
    table.sort(keys)
    for _, key in ipairs(keys) do
        print(key)
    end
    local comment = { "注释行" }
    local header = { "Id" }
    local data_type = { "string" }


    local data = {}
    data[#data + 1] = comment
    data[#data + 1] = header
    data[#data + 1] = data_type
    data[#data + 1] = { "unique" }
end

atli_cfg_to_csv()
