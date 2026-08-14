require "love.filesystem"

print(love.filesystem.getSaveDirectory())

local LuaTableToCSV = {}

local function lua_table_to_string(t)
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
        elements[i] = tostring(v)
    end

    return table.concat(elements, ",")
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

function LuaTableToCSV.to_csv(t, file_path)

end

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

LuaTableToCSV.to_csv(t, "test.csv")
