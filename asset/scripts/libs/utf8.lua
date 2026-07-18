--UTF8 handler for special characters, from https://github.com/blitmap/lua-utf8-simple
utf8 = { pattern = '[%z\1-\127\194-\244][\128-\191]*' }
utf8.map = function(s, f, no_subs)
    local i = 0
    if no_subs then
        for b, e in s:gmatch('()' .. utf8.pattern .. '()') do
            i = i + 1
            local c = e - b
            f(i, c, b)
        end
    else
        for b, c in s:gmatch('()(' .. utf8.pattern .. ')') do
            i = i + 1
            f(i, c, b)
        end
    end
end

utf8.chars = function(s, no_subs)
    return coroutine.wrap(function() return utf8.map(s, coroutine.yield, no_subs) end)
end
