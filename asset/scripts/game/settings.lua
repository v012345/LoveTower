---@class (partial) Settings:Object
local Settings = Object:extend()

function Settings:init()
    local version = GameCfg:get_version()

    self.version = version
    self.paused = false
    self.COMP = {
        name = '',
        prev_name = '',
        submission_name = nil,
        score = 0,
    }
    self.DEMO = {
        total_uptime = 0,
        timed_CTA_shown = false,
        win_CTA_shown = false,
        quit_CTA_shown = false
    }
    self.ACHIEVEMENTS_EARNED = {}
    self.crashreports = false
    self.colourblind_option = false
    self.language = 'en-us'
    self.screenshake = true
    self.run_stake_stickers = false
    self.rumble = PlatformCfg:get_cfg().F_RUMBLE
    self.play_button_pos = 2
    self.GAMESPEED = 1
    self.paused = false
    self.SOUND = {
        volume = 50,
        music_volume = 100,
        game_sounds_volume = 100,
    }
    self.WINDOW = {
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
    }
    self.CUSTOM_DECK = {
        Collabs = {
            Spades = 'default',
            Hearts = 'default',
            Clubs = 'default',
            Diamonds = 'default',
        }
    }
    self.GRAPHICS = {
        texture_scaling = 2,
        shadows = 'On',
        crt = 70,
        bloom = 1
    }
    self.QUEUED_CHANGE = {
        screenres = {}
    }
end

function Settings:load_settings()
    local settings = get_compressed('settings.jkr')
    local settings_ver = nil
    if settings then
        local settings_file = STR_UNPACK(settings)
    end
end

function Settings:reset_queued_change()
    self.QUEUED_CHANGE.screenmode = nil
    self.QUEUED_CHANGE.selected_display = nil
    self.QUEUED_CHANGE.screenres.w = nil
    self.QUEUED_CHANGE.screenres.h = nil
    self.QUEUED_CHANGE.vsync = nil
end

return Settings
