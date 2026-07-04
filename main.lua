local https = require("https")
function love.load()
    -- print("love.load")
    print(https)
    code, body = https.request( "https://raw.githubusercontent.com/v012345/NightOwlToolsV2/refs/heads/main/README.md" )
    print(code, body)
    -- local url = ""

    -- local body, statusCode, headers, statusText = http.request(url)

    -- if statusCode == 200 then
    --     love.filesystem.write("file.txt", body)
    --     print("File downloaded successfully.")
    -- else
    --     print("Failed to download: " .. tostring(statusCode))
    -- end
end

-- function love.update(dt)
--     Game:update(dt)
-- end

-- function love.draw()
--     Game:draw()
-- end

-- function love.keypressed(key)
--     InputManager:keypressed(key)
-- end

-- function love.mousepressed(x, y, button)
--     InputManager:mousepressed(x, y, button)
-- end
