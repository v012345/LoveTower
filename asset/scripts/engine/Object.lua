-- Copy from Balatro
-- This Object implementation was taken from SNKRX (MIT license)

---@class Object
Object = {}
Object.__index = Object
function Object:init(...) end

function Object:extend()
    local cls = {}
    -- 复制当前类的 __字段
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    -- 重写当前类的 __index 字段
    cls.__index = cls
    -- 设置当前类的父类
    cls.super = self
    setmetatable(cls, self)
    return cls
end

function Object:implement(...)
    for _, cls in pairs({ ... }) do
        for k, v in pairs(cls) do
            if self[k] == nil and type(v) == "function" then
                self[k] = v
            end
        end
    end
end

function Object:is(T)
    local mt = getmetatable(self)
    while mt do
        if mt == T then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end

function Object:__call(...)
    local obj = setmetatable({}, self)
    obj:init(...)
    return obj
end

function Object:__tostring()
    return "Object"
end
