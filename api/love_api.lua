---@meta

---The Variant type is not a real lua type, but instead indicates what lua values LÖVE can store internally. It is used in love.thread and love.event. Indeed, as it is a "virtual" type, it has no specific representation in lua, and no methods.\
---A Variant can be a table, a boolean, a string, a number or LÖVE Objects.
---@alias Variant any

---@class love
love = love or {}


---@enum SourceType
SourceType = {
    static = "static",
    stream = "stream",
}

--#region love.joystick
---@class love.joystick
love.joystick = love.joystick or {}

---Loads a gamepad mappings string from a file.
---@param filename string The filename to load the mappings string from.
---@return nil
function love.joystick.loadGamepadMappings(filename) end

--#endregion

--#region love.thread

---A Thread is a chunk of code that can run in parallel with other threads. Data can be sent between different threads with Channel objects.
---@class Thread
Thread = {}

---Starts a Thread.
---@param arg1 Variant A string, number, boolean, LÖVE object, or simple table.
---@param arg2 Variant A string, number, boolean, LÖVE object, or simple table.
---@param ... Variant You can continue passing values to the thread.
---@return nil
function Thread:start(arg1, arg2, ...) end

---An object which can be used to send and receive data between different threads.
---@class Channel
Channel = {}

---Retrieves the value of a Channel message and removes it from the message queue.
---It returns nil if there are no messages in the queue.
---@return Variant value The contents of the message.
function Channel:pop() end

---Send a message to the thread Channel.
---@param value Variant
---@return number Id Identifier which can be supplied to Channel:hasRead
function Channel:push(value) end

---Retrieves the value of a Channel message and removes it from the message queue.
---It waits until a message is in the queue then returns the message value.
---@return Variant value The contents of the message.
function Channel:demand() end

---@class love.thread
love.thread = love.thread or {}

---Creates or retrieves a named thread channel.
---@param name string
---@return Channel
function love.thread.getChannel(name) end

---Creates a new Thread from a filename, string or FileData object containing Lua code.
---@param filename string The name of the Lua file to use as the source.
---@return Thread thread A new Thread that has yet to be started.
function love.thread.newThread(filename) end

--#endregion

--#region love.audio

---@class Source
Source = {}

---Sets the current volume of the Source.
---@param volume number
---@return nil
function Source:setVolume(volume) end

---Stops a Source.
---@return nil
function Source:stop() end

---@class love.audio
love.audio = love.audio or {}

---Creates a new Source from a filepath, File, Decoder or SoundData. Sources created from SoundData are always static
---@param filename string
---@param type SourceType
---@return Source source
function love.audio.newSource(filename, type) end

---comment
---@param source Source The first Source to play.
---@param ... Source Additional Sources to play.
---@return boolean success Whether the Sources were able to successfully start playing.
function love.audio.play(source, ...) end

--#endregion


---@class love.Text:love.Drawable
love.Text = love.Text or {}

--#region love.graphics

---@class love.graphics
love.graphics = love.graphics or {}

---@class Shader
Shader = {}

---@class Quad
Quad = {}

---@param x number  The top-left position in the Texture along the x-axis.
---@param y number  The top-left position in the Texture along the y-axis.
---@param width number  The width of the Quad in the Texture. (Must be greater than 0.)
---@param height number  The height of the Quad in the Texture. (Must be greater than 0.)
---@param sw number  The reference width, the width of the Texture. (Must be greater than 0.)
---@param sh number  The reference height, the height of the Texture. (Must be greater than 0.)
---@return Quad quad
function love.graphics.newQuad(x, y, width, height, sw, sh) end

---@param code string The pixel shader or vertex shader code, or a filename pointing to a file with the code.
---@return Shader shader
function love.graphics.newShader(code) end

---@param min "linear"| "nearest"  Filter mode used when scaling the image down.
---@param mag "linear"| "nearest"  Filter mode used when scaling the image up.
---@param anisotropy number  (1) Maximum amount of Anisotropic Filtering used.
function love.graphics.setDefaultFilter(min, mag, anisotropy) end

---@param pixelcode string  The pixel shader code, or a filename pointing to a file with the code.
---@param vertexcode string The vertex shader code, or a filename pointing to a file with the code.
---@return Shader shader
function love.graphics.newShader(pixelcode, vertexcode) end

--- Copies and pushes the current coordinate transformation to the transformation stack.
--- This function is always used to prepare for a corresponding pop operation later. It stores the current coordinate transformation state into the transformation stack and keeps it active. Later changes to the transformation can be undone by using the pop operation, which returns the coordinate transform to the state it was in before calling push.
---@return nil
function love.graphics.push() end

--- Pops the current coordinate transformation from the transformation stack.
--- This function is always used to reverse a previous push operation. It returns the current transformation state to what it was before the last preceding push.--@return nil
---@return nil
function love.graphics.pop() end

---@return nil
function love.graphics.setShader() end

--- Clears the screen or active Canvas to the specified color.
---@param r  number
---@param g  number
---@param b  number
---@param a? number
function love.graphics.clear(r, g, b, a) end

---@param color table {r: number, g: number, b: number, a: number}
function love.graphics.clear(color) end

---@param font love.Font
---@param text string
---@return love.Text
function love.graphics.newText(font, text) end

---@param filename string
---@param settings? { mipmaps: boolean, dpiscale: number }
---@return love.Image
function love.graphics.newImage(filename, settings) end

---@param style "smooth" | "rough"
function love.graphics.setLineStyle(style) end

--- Displays the results of drawing operations on the screen.
--- This function is used when writing your own love.run function. It presents all the results of your drawing operations on the screen. See the example in love.run for a typical use of this function.
---@return nil
function love.graphics.present() end

---@param filename string
---@param size     number
---@return love.Font
function love.graphics.newFont(filename, size) end

---@param font love.Font
function love.graphics.setFont(font)
end

---@param r  number | table
---@param g? number
---@param b? number
---@param a? number
function love.graphics.setColor(r, g, b, a)
end

---@param drawable  love.Drawable
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

--- Gets the width in pixels of the window.
---@return number width
function love.graphics.getWidth() end

--- Gets the height in pixels of the window.
---@return number height
function love.graphics.getHeight() end

---@param r  number
---@param g  number
---@param b  number
---@param a? number
function love.graphics.setBackgroundColor(r, g, b, a) end

---@return number width
---@return number height
function love.graphics.getDimensions() end

--- You can continue passing point positions to draw a polyline.
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
function love.graphics.line(x1, y1, x2, y2, ...) end

---@param mode   string "fill" | "line"
---@param x      number
---@param y      number
---@param radius number
function love.graphics.circle(mode, x, y, radius) end

---@param mode      string "fill" | "line"
---@param x         number
---@param y         number
---@param width     number
---@param height    number
---@param rx?       number The x-axis radius of each round corner. Cannot be greater than half the rectangle's width.
---@param ry?       number The y-axis radius of each round corner. Cannot be greater than half the rectangle's height.
---@param segments? number The number of segments used for drawing the round corners. A default amount will be chosen if no number is given.
function love.graphics.rectangle(mode, x, y, width, height, rx, ry, segments) end

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

---@param width   number
---@param height  number
---@param options table | nil
---@return Canvas
function love.graphics.newCanvas(width, height, options) end

---@param canvas Canvas | table | nil
---@return nil
function love.graphics.setCanvas(canvas) end

--- 移动当前坐标系
---@param dx number
---@param dy number
---@return nil
function love.graphics.translate(dx, dy) end

---@param angle number
---@return nil
function love.graphics.rotate(angle) end

---@param sx  number The scaling in the direction of the x-axis
---@param sy? number The scaling in the direction of the y-axis. If omitted, it defaults to same as parameter sx.
---@return nil
function love.graphics.scale(sx, sy) end

---Draws a polygon.
---Following the mode argument, this function can accept multiple numeric arguments or a single table of numeric arguments. In either case the arguments are interpreted as alternating x and y coordinates of the polygon's vertices.
---@param mode "fill"|"line"
---@param ... number|table
---@return nil
function love.graphics.polygon(mode, ...) end

--- Creates and sets a new LoveFont.
---@param filename string
---@param size     number
---@return love.Font
function love.graphics.setNewFont(filename, size) end

--- Sets the width of lines.
---@param width number
---@return nil
function love.graphics.setLineWidth(width) end

--#endregion


love.handlers = love.handlers or {}

function love.quit() end

--#region love.filesystem

---@class love.filesystem
love.filesystem = love.filesystem or {}

---@param dir string
---@return string[] files
function love.filesystem.getDirectoryItems(dir) end

---@param path string
---@param size? number
---@return string data
function love.filesystem.read(path, size) end

---@param path string
---@return boolean success
function love.filesystem.remove(path) end

---@param path  string
---@param type? "file" | "directory"
---@return table | nil info
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

--#endregion

--#region love.image

---@class love.Image:love.Drawable
love.Image = love.Image or {}

---@return number width
---@return number height
function love.Image:getDimensions() end

---@return number width
function love.Image:getWidth() end

---@return number height
function love.Image:getHeight() end

--#endregion


---@class love.Font
love.Font = {}

---@return number
function love.Font:getHeight()
end

---@param text string
---@return number
function love.Font:getWidth(text)
end

---@class love.arg
love.arg = love.arg or {}
function love.arg.parseGameArguments(arg) end

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

---@param container string
---@param format string
---@param rawstring string
---@param level number
---@return string compressed_string
function love.data.compress(container, format, rawstring, level) end

---@param container string
---@param format string
---@param data string
---@return string decompressed_string
function love.data.decompress(container, format, data) end

---@class love.system
love.system = love.system or {}

---@return string os
function love.system.getOS() end

---@class Canvas
Canvas = {}
---@param filter "nearest" | "linear"
---@param filtermag "nearest" | "linear"
---@return nil
function Canvas:setFilter(filter, filtermag) end

---@class UIDdefinition
---@field n      UIT
---@field config UIConfig
---@field nodes? UIDdefinition[]
UIDdefinition = {}


--#region love.window
---@class love.window
love.window = love.window or {}

---Gets the width and height of the desktop.
---@param displayindex number The index of the display, if multiple monitors are available. First is 1.
---@return number width The width of the desktop.
---@return number height The height of the desktop.
function love.window.getDesktopDimensions(displayindex) end

--- Gets the display mode and properties of the window.
---@return number width
---@return number height
---@return table flags
function love.window.getMode() end

--#endregion





--- Sets the display mode and properties of the window, without modifying unspecified properties.
--- If width or height is 0, updateMode will use the width and height of the desktop.
--- Changing the display mode may have side effects: for example, canvases will be cleared. Make sure to save the contents of canvases beforehand or re-draw to them afterward if you need to.
--- [api reference](https://love2d.org/wiki/love.window.updateMode)
---@param width    number
---@param height   number
---@param settings table
---@return boolean success
function love.window.updateMode(width, height, settings) end

---@class WINDOW
---@field TRANS      Transform 窗口变换
---@field real_size  Size      窗口真实大小
---@field orig_size  Size      窗口原始大小
---@field orig_scale number    窗口原始缩放

---@class Particle
---@field draw     boolean    是否绘制
---@field age      number     已存活时间
---@field scale    number     缩放
---@field facing   number     朝向
---@field r_vel    number     旋转速度
---@field velocity number     速度
---@field dir      number     方向
---@field offset   Coordinate 偏移
---@field colour   table      颜色




---@class love.Drawable
