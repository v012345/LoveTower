function App:update(dt)
    nuGC(nil, nil, true)
    self.FRAMES.MOVE = self.FRAMES.MOVE + 1
    self.Performance:timer_checkpoint('start->discovery', 'update')

    if not self.settings:is_tutorial_complete() then self.FUNCS.tutorial_controller() end

    self.Performance:timer_checkpoint('tallies', 'update')
    self:modulate_sound(dt)
    self.Performance:timer_checkpoint('sounds', 'update')
    self.window:update_canvas_juice(dt)
    self.Performance:timer_checkpoint('canvas and juice', 'update')

    --Smooth out the dts to avoid any big jumps

    self.TIMERS:update_real_time(dt)
    self.TIMERS:set_real_shader_time(self.settings:is_reduced_motion() and 300 or self.TIMERS:get_real_time())
    self.TIMERS:update_time(dt)
    self.settings:update_demo_total_time(dt)
    self.TIMERS:update_background_time(dt * (self.ARGS.spin and self.ARGS.spin.amount or 0))
    self.real_dt = dt
    if self.real_dt > 0.05 then Log:warn('LONG DT @ ' .. math.floor(self.TIMERS.REAL) .. ': ' .. self.real_dt) end


    if not self.fbf or self.new_frame then
        self.new_frame = false
        self:set_alerts()
        self.Performance:timer_checkpoint('alerts', 'update')
        local http_resp = self.http_manager.in_channel:pop()
        if http_resp then
            self.ARGS.HIGH_SCORE_RESPONSE = http_resp
        end

        --暂停游戏时, dt 为 0
        if self.settings:is_paused() then dt = 0 end

        self:update_speed_factor(dt)
        self.TIMERS:update_game_time(dt * self.SPEEDFACTOR)
        self:update_color(dt)
        self.event_manager:update(self.real_dt)
        self.Performance:timer_checkpoint('e_manager', 'update')


        self:update_state(dt)

        self.Performance:timer_checkpoint('states', 'update')

        for k, v in pairs(self.ANIMATIONS) do
            v:animate(self.real_dt * self.SPEEDFACTOR)
        end
        self.Performance:timer_checkpoint('animate', 'update')

        --move and update all other moveables
        self.TIMERS:update_exp_times(self.real_dt)
        local move_dt = math.min(1 / 20, self.real_dt)


        for k, v in pairs(self.MOVEABLES) do
            if v.frames.move < self.frames.move then
                v:move(move_dt)
            end
        end
        for k, v in pairs(self.MOVEABLES) do
            v:update(dt * self.SPEEDFACTOR)
            v.states.collide.is = false
        end
        self.Performance:timer_checkpoint('update', 'update')
    end

    self.controller:update(self.real_dt)
    if self.FILE_HANDLER:is_need_save() then
        self.FILE_HANDLER:save()
        self.FILE_HANDLER:reset_status()
    end
end

function App:update_state(dt)
    if self.state == self.STATES.SELECTING_HAND then
        if (not self.hand.cards[1]) and self.deck.cards[1] then
            self.state = self.STATES.DRAW_TO_HAND
            self.state_complete = false
        else
            self:update_selecting_hand(dt)
        end
    end

    if self.state == self.STATES.SHOP then
        self:update_shop(dt)
    end

    if self.state == self.STATES.PLAY_TAROT then
        self:update_play_tarot(dt)
    end

    if self.state == self.STATES.HAND_PLAYED then
        self:update_hand_played(dt)
    end

    if self.state == self.STATES.DRAW_TO_HAND then
        self:update_draw_to_hand(dt)
    end

    if self.state == self.STATES.NEW_ROUND then
        self:update_new_round(dt)
    end

    if self.state == self.STATES.BLIND_SELECT then
        self:update_blind_select(dt)
    end

    if self.state == self.STATES.ROUND_EVAL then
        self:update_round_eval(dt)
    end

    if self.state == self.STATES.TAROT_PACK then
        self:update_arcana_pack(dt)
    end

    if self.state == self.STATES.SPECTRAL_PACK then
        self:update_spectral_pack(dt)
    end

    if self.state == self.STATES.STANDARD_PACK then
        self:update_standard_pack(dt)
    end

    if self.state == self.STATES.BUFFOON_PACK then
        self:update_buffoon_pack(dt)
    end

    if self.state == self.STATES.PLANET_PACK then
        self:update_celestial_pack(dt)
    end

    if self.state == self.STATES.GAME_OVER then
        self:update_game_over(dt)
    end

    if self.state == self.STATES.MENU then
        self:update_menu(dt)
    end
end

function App:update_menu(dt) end

function App:update_game_over(dt) end

function App:update_celestial_pack(dt) end

function App:update_buffoon_pack(dt) end

function App:update_standard_pack(dt) end

function App:update_spectral_pack(dt) end

function App:update_arcana_pack(dt) end

function App:update_round_eval(dt) end

function App:update_blind_select(dt) end

function App:update_new_round(dt) end

function App:update_draw_to_hand(dt) end

function App:update_hand_played(dt) end

function App:update_play_tarot(dt) end

function App:update_shop(dt) end

function App:update_selecting_hand(dt) end

---是什么东西在变色?
function App:update_color(dt)
    self.C.DARK_EDITION[1] = 0.6 + 0.2 * math.sin(self.TIMERS.REAL * 1.3)
    self.C.DARK_EDITION[3] = 0.6 + 0.2 * (1 - math.sin(self.TIMERS.REAL * 1.3))
    self.C.DARK_EDITION[2] = math.min(self.C.DARK_EDITION[3], self.C.DARK_EDITION[1])

    self.C.EDITION[1] = 0.7 + 0.2 * (1 + math.sin(self.TIMERS.REAL * 1.5 + 0))
    self.C.EDITION[3] = 0.7 + 0.2 * (1 + math.sin(self.TIMERS.REAL * 1.5 + 3))
    self.C.EDITION[2] = 0.7 + 0.2 * (1 + math.sin(self.TIMERS.REAL * 1.5 + 6))
end

---出牌后, 比如算分的时间长, 需要加速一下
function App:update_speed_factor(dt)
    if self.state ~= self.ACC_state then self.ACC = 0 end
    self.ACC_state = self.state

    if self.state == self.STATES.HAND_PLAYED or self.state == self.STATES.NEW_ROUND then
        self.ACC = math.min(self.ACC + dt * 0.2 * self.settings.data.GAMESPEED, 16)
    else
        self.ACC = 0
    end

    local can_speed_up = self.stage == self.STAGES.RUN and not self.settings:is_paused() and not self.screenwipe
    self.SPEEDFACTOR = can_speed_up and self.settings.data.GAMESPEED or 1
    self.SPEEDFACTOR = self.SPEEDFACTOR + math.max(0, math.abs(self.ACC) - 2)
end
