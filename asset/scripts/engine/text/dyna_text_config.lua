---@class (partial) DynaTextConfig: GameObject
DynaTextConfig = GameObject:extend()

---@param data? DynaTextConfigData
function DynaTextConfig:init(data)
    data = data or {}
    self.data = data
    data.shadow = data.shadow or false
    data.scale = data.scale or 1
    data.pop_in_rate = data.pop_in_rate or 3
    data.bump_rate = data.bump_rate or 2.666
    data.bump_amount = data.bump_amount or 1
    data.font_config = data.font_config or LanguageCfg:get_default_cfg_item()
    data.x_offset = data.x_offset or 0
    data.y_offset = data.y_offset or 0
    data.spacing = data.spacing or 0
    data.string_config_datas = data.string_config_datas or { {
        font_config = LanguageCfg:get_default_cfg_item(),
        prefix = "",
        suffix = "",
        ref_table = { [""] = "HELLO WORLD" },
        ref_value = "",
        scale = 1,
        colour = Color.RED,
        spacing = data.spacing,
        pop_in = data.pop_in
    } }
    self.text_offset = Vec2(
        data.font_config.TEXT_OFFSET.x * data.scale + data.x_offset,
        data.font_config.TEXT_OFFSET.y * data.scale + data.y_offset
    )

    self.string_configs = {}
    for k, v in ipairs(data.string_config_datas) do
        self.string_configs[k] = StringConfig(v)
    end
    return self
end

function DynaTextConfig:get_spacing()
    return self.data.spacing
end

function DynaTextConfig:has_shadow()
    return self.data.shadow
end

function DynaTextConfig:get_text_offset()
    return self.text_offset
end

function DynaTextConfig:get_font_config()
    return self.data.font_config
end

function DynaTextConfig:get_scale()
    return self.data.scale
end
