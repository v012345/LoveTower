-- Copy from Balatro
-- This Component implementation was taken from SNKRX (MIT license)
-- 叫 Component 是因为 love2d 里有 object 类 , 重名了

---@class Component
Component = {}
Component.__index = Component
function Component:init(...) end

function Component:extend()
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
end

function Component:implement(...)
    for _, cls in pairs({ ... }) do
        for k, v in pairs(cls) do
            if self[k] == nil and type(v) == "function" then
                self[k] = v
            end
        end
    end
end

function Component:is(T)
    local mt = getmetatable(self)
    while mt do
        if mt == T then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end

---@generic T
---@return T
function Component:__call(...)
    local obj = setmetatable({}, self)
    obj:init(...)
    return obj
end

function Component:__tostring()
    return "Component"
end
