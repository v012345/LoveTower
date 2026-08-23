---@meta

---@class Shader: Object
Shader = {}

---Sends one or more values to a special (uniform) variable inside the shader. Uniform variables have to be marked using the uniform or extern keyword, e.g
---@param name string Name of the number to send to the shader.
---@param number number Number to send to store in the uniform variable.
---@param ... unknown Additional numbers to send if the uniform variable is an array.
function Shader:send(name, number, ...) end

---@param name string Name of the vector to send to the shader.
---@param vector table Numbers to send to the uniform variable as a vector. The number of elements in the table determines the type of the vector (e.g. two numbers -> vec2). At least two and at most four numbers can be used.
---@param ... table Additional vectors to send if the uniform variable is an array. All vectors need to be of the same size (e.g. only vec3's).
function Shader:send(name, vector, ...) end
