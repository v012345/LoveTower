-- Copy from Balatro
-- This GameObject implementation was taken from SNKRX (MIT license)

---@class GameObject
GameObject = {}
GameObject.__index = GameObject
function GameObject:init(...) end

function GameObject:extend()
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

function GameObject:implement(...)
    for _, cls in pairs({ ... }) do
        for k, v in pairs(cls) do
            if self[k] == nil and type(v) == "function" then
                self[k] = v
            end
        end
    end
end

function GameObject:is(T)
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
function GameObject:__call(...)
    local obj = setmetatable({}, self)
    obj:init(...)
    return obj
end

function GameObject:__tostring()
    return "GameObject"
end
