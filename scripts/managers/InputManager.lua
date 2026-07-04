InputManager = {}

InputManager._event = {}
function InputManager:keypressed(pressedKey)
    if pressedKey == "escape" then love.event.quit() end
    for context, eventType in pairs(self._event) do
        for _key, callback in pairs(eventType.keypressed) do
            if _key == pressedKey then callback(context, pressedKey) end
        end
    end
end

---@generic T
---@param context T
---@param eventType string
---@param key string
---@param callback function
function InputManager:on(context, eventType, key, callback)
    if not self._event[context] then self._event[context] = {} end
    if not self._event[context][eventType] then self._event[context][eventType] = {} end
    self._event[context][eventType][key] = callback
end

function InputManager:off(context, eventType, key)
    if not self._event[context] then return end
    if not self._event[context][eventType] then return end
    self._event[context][eventType][key] = nil
end

return InputManager
