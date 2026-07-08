---@meta

---@class love
love = love or {}



---@class love.graphics
love.graphics = love.graphics or {}

---Copies and pushes the current coordinate transformation to the transformation stack.
---This function is always used to prepare for a corresponding pop operation later. It stores the current coordinate transformation state into the transformation stack and keeps it active. Later changes to the transformation can be undone by using the pop operation, which returns the coordinate transform to the state it was in before calling push.
---@return nil
function love.graphics.push() end

--- Pops the current coordinate transformation from the transformation stack.
--- This function is always used to reverse a previous push operation. It returns the current transformation state to what it was before the last preceding push.--@return nil
---@return nil
function love.graphics.pop() end

---@return nil
function love.graphics.setShader() end

--- Clears the screen or active Canvas to the specified color.
---@param r number
---@param g number
---@param b number
---@param a? number
function love.graphics.clear(r, g, b, a) end

love.handlers = love.handlers or {}

function love.quit() end

---@class love.filesystem
love.filesystem = love.filesystem or {}

---@param path string
---@return boolean success
function love.filesystem.remove(path) end

---@param path string
---@param type? "file" | "directory"
---@return table|nil info
function love.filesystem.getInfo(path, type) end

---@param path string
---@param data string
---@return boolean success
function love.filesystem.write(path, data) end

---@param path string
---@return boolean isDirectory
function love.filesystem.isDirectory(path) end

---@param path string
---@return boolean success
function love.filesystem.createDirectory(path) end

---@return string path
function love.filesystem.getSaveDirectory() end

---@class Image
Image = {}

---@return number width
---@return number height
function Image:getDimensions() end

---@return number width
function Image:getWidth()
end

---@return number height
function Image:getHeight()
end

---@class Font
Font = {}

---@return number
function Font:getHeight()
end

---@param filename string
---@return Image
function love.graphics.newImage(filename)
end

--- Displays the results of drawing operations on the screen.
--- This function is used when writing your own love.run function. It presents all the results of your drawing operations on the screen. See the example in love.run for a typical use of this function.
---@return nil
function love.graphics.present() end

---@param filename string
---@param size     number
---@return Font
function love.graphics.newFont(filename, size) end

---@param font Font
function love.graphics.setFont(font)
end

---@param r  number|table
---@param g?  number
---@param b?  number
---@param a? number
function love.graphics.setColor(r, g, b, a)
end

---@param drawable  Image
---@param x         number
---@param y         number
---@param rotation? number
---@param scaleX?   number
---@param scaleY?   number
---@param offsetX?  number
---@param offsetY?  number
---@param shearX?   number
---@param shearY?   number
function love.graphics.draw(drawable, x, y, rotation, scaleX, scaleY, offsetX, offsetY, shearX, shearY)
end

---@param text      string
---@param x         number
---@param y         number
---@param rotation? number
---@param scaleX?   number
---@param scaleY?   number
---@param offsetX?  number
---@param offsetY?  number
---@param shearX?   number
---@param shearY?   number
function love.graphics.print(text, x, y, rotation, scaleX, scaleY, offsetX, offsetY, shearX, shearY)
end

---@param r  number
---@param g  number
---@param b  number
---@param a? number
function love.graphics.setBackgroundColor(r, g, b, a)
end

---@class love.arg
love.arg = love.arg or {}
function love.arg.parseGameArguments(arg) end

---@return number width
---@return number height
function love.graphics.getDimensions()
end

---@return number FPS
function love.timer.getFPS() end

--- Pauses the current thread for the specified amount of time.
---@param time number
---@return nil
function love.timer.sleep(time) end

---@class love.mouse
love.mouse = love.mouse or {}

---@return number x
---@return number y
function love.mouse.getPosition() end

--- You can continue passing point positions to draw a polyline.
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
function love.graphics.line(x1, y1, x2, y2, ...) end

---@param mode    string "fill" | "line"
---@param x       number
---@param y       number
---@param radius  number
function love.graphics.circle(mode, x, y, radius) end

---@param mode   string "fill" | "line"
---@param x      number
---@param y      number
---@param width  number
---@param height number
function love.graphics.rectangle(mode, x, y, width, height) end

---@param text   string
---@param x      number
---@param y      number
---@param limit  number 换行宽度
---@param align? string "left" | "center" | "right"
function love.graphics.printf(text, x, y, limit, align) end

--- Gets whether the graphics module is able to be used. If it is not active, love.graphics function and method calls will not work correctly and may cause the program to crash.
--- The graphics module is inactive if a window is not open, or if the app is in the background on iOS. Typically the app's execution will be automatically paused by the system, in the latter case.
---@return boolean isActive
function love.graphics.isActive() end

---@class love.event
love.event = love.event or {}

--- Returns an iterator for messages in the event queue.
---@return function iterator
function love.event.poll() end

function love.event.quit() end

---@class love.timer
love.timer = love.timer or {}

--- Measures the time between two frames.
---@return number dt
function love.timer.step() end

--- Returns the precise amount of time since some time in the past.
---@return number time
function love.timer.getTime() end

---@class love.event
love.event = {}

--- Pump events into the event queue.
--- This is a low-level function, and is usually not called by the user, but by `love.run`.
--- Note that this does need to be called for any OS to think your program is still running, and if you want to handle OS-generated events at all (think callbacks).
---@return nil
function love.event.pump() end

---@class love.data
love.data = love.data or {}

function love.data.compress(container, format, rawstring, level) end

function love.data.decompress(container, format, data) end

---@class love.system
love.system = love.system or {}

---@return string os
function love.system.getOS() end

function love.graphics.newCanvas(width, height, options) end

---@param canvas Canvas|table|nil
---@return nil
function love.graphics.setCanvas(canvas) end

---@class Canvas
Canvas = {}
---@param filter string "nearest" | "linear"
---@param filtermag string "nearest" | "linear"
---@return nil
function Canvas:setFilter(filter, filtermag) end

---@class NodeStates
---@field visible boolean 节点是否可见
---@field collide { can: boolean, is: boolean }
---@field focus { can: boolean, is: boolean }
---@field hover { can: boolean, is: boolean }
---@field click { can: boolean, is: boolean }
---@field drag { can: boolean, is: boolean }
---@field release_on { can: boolean, is: boolean }
NodeStates = {}


---@param dx number
---@param dy number
---@return nil
function love.graphics.translate(dx, dy) end

---@param angle number
---@return nil
function love.graphics.rotate(angle) end

---@param scale number
---@return nil
function love.graphics.scale(scale) end

--- 包括 `悬浮弹窗` `拖拽弹窗` `警告弹窗`
---@class Children
---@field h_popup UIBox 悬浮弹窗
---@field d_popup UIBox 拖拽弹窗
---@field alert UIBox 警告弹窗
Children = {}


---@class UIConfig
---@field object any
---@field text? string
---@field scale? number
---@field colour? table
---@field align? string
---@field offset? { x: number, y: number }
---@field major? Node
---@field bond? string
UIConfig = {}

---@class Size
---@field w number
---@field h number
Size = {}



---@class UIDdefinition
---@field n UIT
---@field config UIConfig
---@field nodes? UIDdefinition[]
UIDdefinition = {}


---@class EventConfig
---@field trigger function
---@field delay number
---@field blockable boolean
---@field func function
---@field blocking boolean
---@field no_delete boolean
---@field start_timer boolean
---@field timer function
---@field ref_table table
---@field ref_value string
---@field ease_to any
---@field stop_val any
EventConfig = {}


---@class EventStatus
---@field blocking boolean
---@field completed boolean
---@field time_done boolean
---@field pause_skip boolean
EventStatus = {}

---comment
---@param config EventConfig
---@return Event
function Event(config) end
