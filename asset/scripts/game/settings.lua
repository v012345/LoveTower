---@class (partial) Settings:Object
local Settings = Object:extend()

function Settings:init()
    self.data = {
        version = GameCfg:get_version(),
        COMP = {
            name = '',
            prev_name = '',
            submission_name = nil,
            score = 0,
        },
        DEMO = {
            total_uptime = 0,
            timed_CTA_shown = false,
            win_CTA_shown = false,
            quit_CTA_shown = false
        },
        ACHIEVEMENTS_EARNED = {},
        crashreports = false,
        colourblind_option = false,
        language = 'en-us',
        screenshake = true,
        run_stake_stickers = false,
        rumble = FeatureCfg:get_cfg().F_RUMBLE,
        play_button_pos = 2,
        GAMESPEED = 1,
        paused = false,
        SOUND = {
            volume = 50,
            music_volume = 100,
            game_sounds_volume = 100,
        },
        WINDOW = {
            screenmode = 'Windowed',
            selected_display = 1,
            vsync = 1,
            display_names = { '[NONE]' },
            DISPLAYS = {
                {
                    name = '[NONE]',
                    screen_res = Size(1000, 650),
                }
            }
        },
        CUSTOM_DECK = {
            Collabs = {
                Spades = 'default',
                Hearts = 'default',
                Clubs = 'default',
                Diamonds = 'default',
            }
        },
        GRAPHICS = {
            texture_scaling = 2, -- 只有 1 和 2 两个选项
            shadows = 'On',
            crt = 70,
            bloom = 1
        },
        QUEUED_CHANGE = {
            screenres = {}
        },
        skip_splash = false,
        profile = 1,
    }
end

---@return integer texture_scaling
function Settings:get_texture_scaling()
    return self.data.GRAPHICS.texture_scaling
end

function Settings:get_language()
    return self.data.language
end

---切换到演示模式
function Settings:switch_to_demo()
    local demo = self.data.DEMO
    demo.total_uptime = 0
    demo.timed_CTA_shown = true
    demo.win_CTA_shown = true
    demo.quit_CTA_shown = true
end

function Settings:is_skip_splash()
    return self.data.skip_splash
end

---返回当前使用的玩家存档编号
---@return number No. The profile number, 1, 2 or 3.
function Settings:get_profile_no()
    return self.data.profile
end

function Settings:set_profile_no(no)
    self.data.profile = no
end

function Settings:load_settings()
    local settings = get_compressed('settings.jkr')
    --- 加载保存的设置
    if settings then
        local settings_file = STR_UNPACK(settings)
        for k, v in pairs(settings_file) do
            self.data[k] = v
        end
    end
    self.data.paused = false
end

function Settings:reset_queued_change()
    local queued_change = self.data.QUEUED_CHANGE
    queued_change.screenmode = nil
    queued_change.selected_display = nil
    queued_change.screenres.w = nil
    queued_change.screenres.h = nil
    queued_change.vsync = nil
end

function Settings:is_paused()
    return self.data.paused
end

---先不实现, 默认教程已经完成
---@return boolean
function Settings:is_tutorial_complete()
    return true
end

---设置暂停状态
---@param paused boolean 是否暂停
function Settings:set_paused(paused)
    self.data.paused = paused
end

return Settings
