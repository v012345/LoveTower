---@class (partial) LanguageConfig:GameObject
local LanguageConfig = GameObject:extend()

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
    return love.filesystem.getInfo('asset/localization/' .. id .. '.lua') ~= nil
end

function LanguageConfig:load_localization(language)
    assert(self:is_have_language(language), "Language " .. language .. " not found")
    local localization = assert(loadstring(love.filesystem.read('asset/localization/' .. language .. '.lua')))()
    localization.misc.v_dictionary_parsed = {}
    for k, v in pairs(localization.misc.v_dictionary) do
        if type(v) == 'table' then
            localization.misc.v_dictionary_parsed[k] = { multi_line = true }
            for kk, vv in ipairs(v) do
                localization.misc.v_dictionary_parsed[k][kk] = self:loc_parse_string(vv)
            end
        else
            localization.misc.v_dictionary_parsed[k] = self:loc_parse_string(v)
        end
    end
    localization.misc.v_text_parsed = {}
    for k, v in pairs(localization.misc.v_text) do
        localization.misc.v_text_parsed[k] = {}
        for kk, vv in ipairs(v) do
            localization.misc.v_text_parsed[k][kk] = self:loc_parse_string(vv)
        end
    end
    localization.tutorial_parsed = {}
    for k, v in pairs(localization.misc.tutorial) do
        localization.tutorial_parsed[k] = { multi_line = true }
        for kk, vv in ipairs(v) do
            localization.tutorial_parsed[k][kk] = self:loc_parse_string(vv)
        end
    end
    localization.quips_parsed = {}
    for k, v in pairs(localization.misc.quips or {}) do
        localization.quips_parsed[k] = { multi_line = true }
        for kk, vv in ipairs(v) do
            localization.quips_parsed[k][kk] = self:loc_parse_string(vv)
        end
    end
    for g_k, group in pairs(localization) do
        if g_k == 'descriptions' then
            for _, set in pairs(group) do
                for _, center in pairs(set) do
                    center.text_parsed = {}
                    if not center.text then else
                        for _, line in ipairs(center.text) do
                            center.text_parsed[#center.text_parsed + 1] = self:loc_parse_string(line)
                        end
                        center.name_parsed = {}
                        for _, line in ipairs(type(center.name) == 'table' and center.name or { center.name }) do
                            center.name_parsed[#center.name_parsed + 1] = self:loc_parse_string(line)
                        end
                        if center.unlock then
                            center.unlock_parsed = {}
                            for _, line in ipairs(center.unlock) do
                                center.unlock_parsed[#center.unlock_parsed + 1] = self:loc_parse_string(line)
                            end
                        end
                    end
                end
            end
        end
    end
    return localization
end

---@private
function LanguageConfig:loc_parse_string(line)
    local parsed_line = {}
    local control = {}
    local _c, _c_name, _c_val, _c_gather = nil, nil, nil, nil
    local _s_gather, _s_ref = nil, nil
    local str_parts, str_it = {}, 1
    for i = 1, #line do
        local char = line:sub(i, i)
        if char == '{' then --Start of a control section, extract all controls
            if str_parts[1] then parsed_line[#parsed_line + 1] = { strings = str_parts, control = control or {} } end
            str_parts, str_it = {}, 1
            control, _c, _c_name, _c_val, _c_gather = {}, nil, nil, nil, nil
            _s_gather, _s_ref = nil, nil
            _c = true
        elseif _c and not (char == ':' or char == '}') and not _c_gather then
            _c_name = (_c_name or '') .. char
        elseif _c and char == ':' then
            _c_gather = true
        elseif _c and not (char == ',' or char == '}') and _c_gather then
            _c_val = (_c_val or '') .. char
        elseif _c and (char == ',' or char == '}') then
            _c_gather = nil; if _c_name then control[_c_name] = _c_val end; _c_name = nil; _c_val = nil; if char == '}' then _c = nil end
        elseif not _c and char ~= '#' and not _s_gather then
            str_parts[str_it] = (str_parts[str_it] or '') .. (control['X'] and char:gsub("%s+", "") or char)
        elseif not _c and char == '#' and not _s_gather then
            _s_gather = true; if str_parts[str_it] then str_it = str_it + 1 end
        elseif not _c and char == '#' and _s_gather then
            _s_gather = nil; if _s_ref then
                str_parts[str_it] = { _s_ref }; str_it = str_it + 1; _s_ref = nil
            end
        elseif not _c and _s_gather then
            _s_ref = (_s_ref or '') .. char
        end
        if i == #line then
            if str_parts[1] then parsed_line[#parsed_line + 1] = { strings = str_parts, control = control or {} } end
            return parsed_line
        end
    end
end

---@type LanguageConfig
LanguageCfg = LanguageConfig()
