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
    print(#chars)
end

TableParser.instance = TableParser()
