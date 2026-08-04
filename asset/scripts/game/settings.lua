---@class Settings:Object
Settings = Object:extend()

function Settings:init()
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
    self.rumble = self.F_RUMBLE
    self.play_button_pos = 2
    self.GAMESPEED = 1
    self.paused = false
    self.SOUND = {
        volume = 50,
        music_volume = 100,
        game_sounds_volume = 100,
    }
    self.WINDOW = {
        screenmode = 'Borderless',
        vsync = 1,
        selected_display = 1,
        display_names = { '[NONE]' },
        DISPLAYS = {
            {
                name = '[NONE]',
                screen_res = { w = 1000, h = 650 },
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
end

---@type Settings
Settings.instance = Settings()
