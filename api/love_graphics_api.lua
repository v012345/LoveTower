--#region love.graphics
---@meta

---@class Quad
Quad = {}

---@class love.graphics
love.graphics = {}


---Sets or resets a Shader as the current pixel effect or vertex shaders. All drawing operations until the next love.graphics.setShader will be drawn using the Shader object specified.
---@param shader? Shader
---@return nil
function love.graphics.setShader(shader) end

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

---@param drawable  Drawable
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
