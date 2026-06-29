---@class love
love = love or {}

---@class love.graphics
love.graphics = love.graphics or {}

---@class Image
Image = {}

---@return number, number
function Image:getDimensions()
end

---@return number
function Image:getWidth()
end

---@return number
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

---@param filename string
---@param size     number
---@return Font
function love.graphics.newFont(filename, size)
end

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

---@return number
function love.timer.getFPS()
end

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

---@class love.event
love.event = love.event or {}

function love.event.quit() end

---@class love.timer
love.timer = love.timer or {}
