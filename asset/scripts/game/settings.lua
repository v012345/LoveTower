---@class (partial) Settings:Object
local Settings = Object:extend()

function Settings:init()
    self.data = {
        settings = {
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
            rumble = PlatformCfg:get_cfg().F_RUMBLE,
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
                texture_scaling = 2,
                shadows = 'On',
                crt = 70,
                bloom = 1
            },
            QUEUED_CHANGE = {
                screenres = {}
            }
        }
    }
end

function Settings:load_settings()
    local settings = get_compressed('settings.jkr')
    local settings_ver = nil
    --- 加载保存的设置
    if settings then
        local settings_file = STR_UNPACK(settings)
    end

    -- ,paused = false
end

function Settings:reset_queued_change()
    local queued_change = self.data.settings.QUEUED_CHANGE
    queued_change.screenmode = nil
    queued_change.selected_display = nil
    queued_change.screenres.w = nil
    queued_change.screenres.h = nil
    queued_change.vsync = nil
end

return Settings
