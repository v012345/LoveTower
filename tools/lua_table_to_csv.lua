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
        assert(type(key) == "string", "extract_table_keys: key is not a string")
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
collabs_cfg_to_csv()
