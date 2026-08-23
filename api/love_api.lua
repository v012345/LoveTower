---@meta

---The Variant type is not a real lua type, but instead indicates what lua values LÖVE can store internally. It is used in love.thread and love.event. Indeed, as it is a "virtual" type, it has no specific representation in lua, and no methods.\
---A Variant can be a table, a boolean, a string, a number or LÖVE Objects.
---@alias Variant any

---@class love
love = love or {}



---@class Drawable: love.object

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


---@class love.Text: Drawable
love.Text = love.Text or {}


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

---@class love.Image: Texture
love.Image = love.Image or {}

---返回 Image 的真实大小
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

--#region love.window
---@class love.window
love.window = love.window or {}

---Gets the width and height of the desktop.
---@param displayindex number The index of the display, if multiple monitors are available. First is 1.
---@return number width The width of the desktop.
---@return number height The height of the desktop.
function love.window.getDesktopDimensions(displayindex) end

---Gets a list of supported fullscreen modes.
---@param displayindex number (1) The index of the display, if multiple monitors are available.
---@return table modes A table of width/height pairs. (Note that this may not be in order.)
function love.window.getFullscreenModes(displayindex) end

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
