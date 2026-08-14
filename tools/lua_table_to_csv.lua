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

function LuaTableToCSV.to_csv(t, file_path)
    local file = io.open(file_path, "w")
    if not file then
        error("LuaTableToCSV.to_csv: failed to open file: " .. file_path)
    end

    file:write(lua_array_to_string(t))
    file:close()
end
