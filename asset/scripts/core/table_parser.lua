---@class (partial) TableParser: Object
---@field instance TableParser
TableParser = Object:extend()

---@param table_name string 表名, 不是路径, 而是文件名
function TableParser:parse(table_name)
    local path = "asset/csv/" .. table_name .. ".csv"
    if love.filesystem.getInfo(path, "file") then
        self:parse_csv(love.filesystem.read(path))
    else
        error("Table " .. table_name .. " not found")
    end
end

---@private
---@param csv_data string 原始csv数据
function TableParser:parse_csv(csv_data)
    local chars = {}
    for char in utf8.chars(csv_data) do
        chars[#chars + 1] = char
    end

    local csv_table = {}
    -- 使用语法解析来解析 csv 数据
    for i = 1, #chars do
        print(chars[i])
    end

    --- 上面处理完成之后, csv_table 中存储了所有的 csv 数据, 第一行是注解行, 第四行是校验行(现在不处理)
    local attir_row = csv_table[2]
    local type_row = csv_table[3]

    --- 配置表, 就是返回的表
    local cfg_table = {}
    local cfg_table_meta_table = {
        __index = function(self, key)

        end,
    }
    local row_meta_table = {
        __index = function(self, key)

        end,
    }


    for i = 5, #csv_table do
        local row = csv_table[i]
        local row_table = setmetatable({}, row_meta_table)
        for j = 1, #row do
            local value_type = string.lower(type_row[j])
            if value_type == "string" then
                row_table[attir_row[j]] = row[j]
            elseif value_type == "number" then
                row_table[attir_row[j]] = tonumber(row[j])
            elseif value_type == "bool" or value_type == "boolean" then
                row_table[attir_row[j]] = string.lower(row[j])
            elseif value_type == "table" then
                -- 不处理
            elseif value_type == "vec2" then
            else
                error("Unknown value type: " .. value_type)
            end
        end
    end
end

---@private
function TableParser:parse_value()
end

TableParser.instance = TableParser()
