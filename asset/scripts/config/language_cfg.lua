---@class (partial) LanguageConfig:Object
local LanguageConfig = Object:extend()

function LanguageConfig:init()
    self.ids = {}
    self.cfg_items = {}
    ---@type LanguageConfigItem[]
    local language_table = TableParser.instance:parse("language")

    for _, language_item in pairs(language_table) do
        self.ids[#self.ids + 1] = language_item.Id

        local cfg_item = {}
        for key, value in pairs(language_item) do
            cfg_item[key] = value
        end
        cfg_item.font = FontCfg:get_cfg_item(language_item.font_id)
        self.cfg_items[language_item.Id] = cfg_item
    end
end

---@return string[]
function LanguageConfig:get_ids()
    return self.ids
end

---@param id string
---@return LanguageConfigItem
function LanguageConfig:get_cfg_item(id)
    return self.cfg_items[id]
end

function LanguageConfig:get_default_cfg_item()
    return self.cfg_items['en-us']
end

---@param id string
---@return boolean
function LanguageConfig:is_have_language(id)
    return self.cfg_items[id] ~= nil
end

---@type LanguageConfig
LanguageCfg = LanguageConfig()
