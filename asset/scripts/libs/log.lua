assert(Log == nil, "log is already defined")
Log = {}

---@private
function Log:format_messages(...)
    local messages = {}
    for i, v in ipairs({ ... }) do
        messages[i] = tostring(v)
    end
    return table.concat(messages, " ")
end

function Log:info(...)
    print("\27[36m[INFO]\27[0m", string.format("\27[36m%s\27[0m", self:format_messages(...)))
end

function Log:error(...)
    print("\27[31m[ERROR]\27[0m", string.format("\27[31m%s\27[0m", self:format_messages(...)))
end

function Log:warn(...)
    print("\27[33m[WARN]\27[0m", string.format("\27[33m%s\27[0m", self:format_messages(...)))
end

function Log:ok(...)
    print("\27[32m[OK]\27[0m", string.format("\27[32m%s\27[0m", self:format_messages(...)))
end

function Log:print(...)
    print(self:format_messages(...))
end
