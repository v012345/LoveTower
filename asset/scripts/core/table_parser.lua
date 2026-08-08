---@class (partial) TableParser: Object
---@field instance TableParser
---@field private cache table<string, table> 已解析的配置表缓存, 表名 -> 配置表
TableParser = Object:extend()

-- LÖVE 自带的 LuaJIT 没有开启 Lua 5.2 兼容, 原生 pairs() 不识别 __pairs 元方法,
-- 这里包装一层: 元表里有 __pairs 就用它, 否则回退到原生 pairs
local raw_pairs = pairs
function pairs(t)
    local mt = getmetatable(t)
    if type(mt) == "table" and mt.__pairs then
        return mt.__pairs(t)
    end
    return raw_pairs(t)
end

---把真实数据藏在 data 里, 返回一个只读代理表
---@param data table 真实数据
---@param desc string 出错时的提示信息
---@return table
local function make_readonly(data, desc)
    return setmetatable({}, {
        __index = data,
        __newindex = function(_, key)
            error(desc .. " 是只读的, 不允许写入字段 '" .. tostring(key) .. "'", 2)
        end,
        __pairs = function()
            return raw_pairs(data)
        end,
        __tostring = function()
            return dump(data)
        end
    })
end

function TableParser:init()
    self.cache = {}
end

---解析(或从缓存中取出)一张配置表
---@param table_name string 表名, 不是路径, 而是文件名(不含扩展名)
---@return table cfg_table 只读配置表, 以主键(校验行标 unique 的列, 默认第一列)索引每一行
function TableParser:parse(table_name)
    if self.cache[table_name] then
        return self.cache[table_name]
    end

    local path = "asset/csv/" .. table_name .. ".csv"
    if not love.filesystem.getInfo(path, "file") then
        error("Table " .. table_name .. " not found: " .. path)
    end

    local cfg_table = self:parse_csv(love.filesystem.read(path), table_name)
    self.cache[table_name] = cfg_table
    return cfg_table
end

---把原始 csv 文本切成二维表 records[行][列] = string
---按字节扫描即可: CSV 的控制字符(逗号/引号/换行)都是 ASCII,
---UTF-8 多字节序列中不会出现 ASCII 字节, 所以不需要按 utf8 字符迭代
---@private
---@param csv_data string 原始csv数据
---@return string[][]
function TableParser:split_records(csv_data)
    local records = {}
    local row = {}
    local field = {}
    local in_quotes = false

    local i = 1
    -- 跳过 UTF-8 BOM
    if csv_data:sub(1, 3) == "\239\187\191" then i = 4 end

    local function end_field()
        row[#row + 1] = table.concat(field)
        field = {}
    end
    local function end_row()
        end_field()
        records[#records + 1] = row
        row = {}
    end

    local len = #csv_data
    while i <= len do
        local c = csv_data:sub(i, i)
        if in_quotes then
            if c == '"' then
                if csv_data:sub(i + 1, i + 1) == '"' then
                    -- "" 转义为一个引号
                    field[#field + 1] = '"'
                    i = i + 1
                else
                    in_quotes = false
                end
            else
                field[#field + 1] = c
            end
        elseif c == '"' then
            in_quotes = true
        elseif c == ',' then
            end_field()
        elseif c == '\n' then
            end_row()
        elseif c ~= '\r' then -- \r 直接丢弃, 兼容 CRLF
            field[#field + 1] = c
        end
        i = i + 1
    end
    -- 文件末尾没有换行符时, 收尾最后一行
    if #field > 0 or #row > 0 then
        end_row()
    end

    if in_quotes then
        error("CSV 引号未闭合")
    end
    return records
end

---@private
---@param csv_data string 原始csv数据
---@param table_name string 表名, 用于报错提示
---@return table
function TableParser:parse_csv(csv_data, table_name)
    local records = self:split_records(csv_data)
    -- 第 1 行是注解行, 第 2 行是属性名行, 第 3 行是类型行, 第 4 行是校验行, 第 5 行起是数据
    assert(#records >= 4, "Table " .. table_name .. " 至少需要 4 行(注解/属性/类型/校验)")
    local attr_row = records[2]
    local type_row = records[3]
    local check_row = records[4]

    -- 主键列: 校验行中标了 unique 的列, 默认第一列
    local key_col = 1
    for j = 1, #check_row do
        if string.lower(check_row[j] or "") == "unique" then
            key_col = j
            break
        end
    end

    local rows = {} -- 主键 -> 只读行

    for i = 5, #records do
        local record = records[i]
        -- 跳过完全空白的行
        local is_empty = true
        for j = 1, #record do
            if record[j] ~= "" then
                is_empty = false
                break
            end
        end

        if not is_empty then
            local row_data = {}
            for j = 1, #attr_row do
                local attr = attr_row[j]
                if attr and attr ~= "" then
                    row_data[attr] = self:parse_value(record[j], type_row[j],
                        table_name .. " 第 " .. i .. " 行 [" .. attr .. "]")
                end
            end

            local key = row_data[attr_row[key_col]]
            if key == nil then
                error("Table " .. table_name .. " 第 " .. i .. " 行主键为空")
            end
            if rows[key] ~= nil then
                error("Table " .. table_name .. " 主键重复: " .. tostring(key))
            end
            rows[key] = make_readonly(row_data, "Table " .. table_name .. " 行 [" .. tostring(key) .. "]")
        end
    end

    return make_readonly(rows, "Table " .. table_name)
end

---按类型行声明的类型解析单元格
---@private
---@param raw string|nil 单元格原始字符串
---@param value_type string 类型行声明的类型
---@param where string 出错时的位置提示
---@return any
function TableParser:parse_value(raw, value_type, where)
    if raw == nil or raw == "" then
        return nil
    end
    value_type = string.lower(value_type or "")

    if value_type == "string" then
        return raw
    elseif value_type == "number" then
        local num = tonumber(raw)
        if num == nil then
            error(where .. " 不是合法数字: " .. raw)
        end
        return num
    elseif value_type == "bool" or value_type == "boolean" then
        local s = string.lower(raw)
        if s == "true" or s == "1" then
            return true
        elseif s == "false" or s == "0" then
            return false
        end
        error(where .. " 不是合法布尔值: " .. raw)
    elseif value_type == "table" or value_type == "string[]" or value_type == "code" then
        return self:exec_lua_string(raw)
    elseif value_type == "vec2" then
        local lua_table = self:exec_lua_string(raw)
        return Vec2(lua_table[1], lua_table[2])
    end
    error(where .. " 未知类型: " .. value_type)
end

---@private
---@param lua_string string
---@return any
function TableParser:exec_lua_string(lua_string)
    local func, err = load("return " .. lua_string)
    if not func then
        error(err)
    end
    return func()
end

TableParser.instance = TableParser()
