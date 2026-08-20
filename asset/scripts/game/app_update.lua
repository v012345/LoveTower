function App:update(dt)
    nuGC(nil, nil, true)
    self.FRAMES.MOVE = self.FRAMES.MOVE + 1
    self.Performance:timer_checkpoint('start->discovery', 'update')
    if not self.SETTINGS:is_tutorial_complete() then self.FUNCS.tutorial_controller() end
    self.Performance:timer_checkpoint('tallies', 'update')
    self:modulate_sound(dt)
    self.Performance:timer_checkpoint('sounds', 'update')
    self.window:update_canvas_juice(dt)
    self.Performance:timer_checkpoint('canvas and juice', 'update')

    --Smooth out the dts to avoid any big jumps

    self.TIMERS:update_real_time(dt)
    self.TIMERS:set_real_shader_time(self.SETTINGS:is_reduced_motion() and 300 or self.TIMERS:get_real_time())
    self.TIMERS:update_time(dt)
    self.SETTINGS:update_demo_total_time(dt)
    self.TIMERS:update_background_time(dt * (self.ARGS.spin and self.ARGS.spin.amount or 0))
    self.real_dt = dt
    if self.real_dt > 0.05 then Log:warn('LONG DT @ ' .. math.floor(self.TIMERS.REAL) .. ': ' .. self.real_dt) end


    if not self.fbf or self.new_frame then
        self.new_frame = false
        self:set_alerts()
        self.Performance:timer_checkpoint('alerts', 'update')
        local http_resp = self.HTTP_MANAGER.in_channel:pop()
        if http_resp then
            self.ARGS.HIGH_SCORE_RESPONSE = http_resp
        end

        --暂停游戏时, dt 为 0
        if self.SETTINGS:is_paused() then dt = 0 end


        self.TIMERS:update_game_time(dt)
        self.E_MANAGER:update(self.real_dt)
        -- Smooth.instance:update(Timer.instance.real_dt)
        for k, v in pairs(self.MOVEABLES) do
            if v.FRAME.MOVE < self.FRAMES.MOVE then
                v:move(Smooth.instance.move_dt)
            end
        end
        for k, v in pairs(self.MOVEABLES) do
            -- v:update(dt * Timer.instance.SPEEDFACTOR)
            v.states.collide.is = false
        end
        self.Performance:timer_checkpoint('update', 'update')
    end

    self.CONTROLLER:update(self.real_dt)
    if self.FILE_HANDLER:is_need_save() then
        self.FILE_HANDLER:save()
        self.FILE_HANDLER:reset_status()
    end
end

function App:update_state(dt)
    if self.STATE == self.STATES.SELECTING_HAND then
        if (not self.hand.cards[1]) and self.deck.cards[1] then
            self.STATE = self.STATES.DRAW_TO_HAND
            self.STATE_COMPLETE = false
        else
            self:update_selecting_hand(dt)
        end
    end

    if self.STATE == self.STATES.SHOP then
        self:update_shop(dt)
    end

    if self.STATE == self.STATES.PLAY_TAROT then
        self:update_play_tarot(dt)
    end

    if self.STATE == self.STATES.HAND_PLAYED then
        self:update_hand_played(dt)
    end

    if self.STATE == self.STATES.DRAW_TO_HAND then
        self:update_draw_to_hand(dt)
    end

    if self.STATE == self.STATES.NEW_ROUND then
        self:update_new_round(dt)
    end

    if self.STATE == self.STATES.BLIND_SELECT then
        self:update_blind_select(dt)
    end

    if self.STATE == self.STATES.ROUND_EVAL then
        self:update_round_eval(dt)
    end

    if self.STATE == self.STATES.TAROT_PACK then
        self:update_arcana_pack(dt)
    end

    if self.STATE == self.STATES.SPECTRAL_PACK then
        self:update_spectral_pack(dt)
    end

    if self.STATE == self.STATES.STANDARD_PACK then
        self:update_standard_pack(dt)
    end

    if self.STATE == self.STATES.BUFFOON_PACK then
        self:update_buffoon_pack(dt)
    end

    if self.STATE == self.STATES.PLANET_PACK then
        self:update_celestial_pack(dt)
    end

    if self.STATE == self.STATES.GAME_OVER then
        self:update_game_over(dt)
    end

    if self.STATE == self.STATES.MENU then
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
