---@meta

---Object 是 LÖVE 的基类，所有 LÖVE 对象都继承自 Object。
---@class Object
Object = Object or {}

---`image = love.graphics.newImage("test.png")`\
---`print(image:typeOf("Object")) -- outputs: true`\
---`print(image:typeOf("Drawable")) -- outputs: true`\
---`print(image:typeOf("Image")) -- outputs: true`\
---`print(image:typeOf("MouseJoint")) -- outputs: false`\
---Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
---@param name string The name of the type to check for.
---@return boolean b True if the object is of the specified type, false otherwise.
function Object:typeOf(name) end
