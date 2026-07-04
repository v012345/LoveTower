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

---@param r  number
---@param g  number
---@param b  number
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
