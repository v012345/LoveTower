local Hotfix = {}



local progress = 0

-- ===== Shader：动态背景 =====
local bgShader = love.graphics.newShader([[
extern number time;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 screen_uv)
{
    float y = uv.y;
    float wave = sin(uv.x * 10.0 + time) * 0.1;

    vec3 col1 = vec3(0.10, 0.12, 0.18);
    vec3 col2 = vec3(0.20, 0.25, 0.35);

    vec3 col = mix(col1, col2, y + wave);

    return vec4(col, 1.0);
}
]])

local time = 0


-- 更新进度
function Hotfix:setProgress(p)
    progress = math.max(0, math.min(1, p))
end

function Hotfix:load()
    print("hotfix load")
end

function Hotfix:update(dt)
    -- print("hotfix update")
    time = time + dt
    bgShader:send("time", time)
end

function Hotfix:draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    -- ===== 背景 Shader =====
    love.graphics.setShader(bgShader)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setShader()

    -- ===== 进度条背景 =====
    local barW = w * 0.6
    local barH = 20
    local x = (w - barW) / 2
    local y = h * 0.7

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", x, y, barW, barH)

    -- ===== 进度条 =====
    love.graphics.setColor(0.2, 0.8, 0.3, 1)
    love.graphics.rectangle("fill", x, y, barW * progress, barH)

    -- ===== 外框 =====
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.rectangle("line", x, y, barW, barH)

    -- ===== 文字（默认字体，不加载资源）=====
    love.graphics.setColor(1, 1, 1, 1)
    local text = string.format("Downloading... %d%%", math.floor(progress * 100))

    local font = love.graphics.getFont() -- 默认字体
    local tw = font:getWidth(text)

    love.graphics.print(text, (w - tw) / 2, y - 30)
end

return Hotfix
