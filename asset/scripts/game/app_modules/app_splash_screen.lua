function App:splash_screen()
    --If the skip splash screen option is set, immediately go to the main menu here
    if self.settings:is_skip_splash() then
        -- 直接跳转到主菜单
        self:main_menu()
    else
        Log:info("splash screen")
        --准备好场景了
        self:prep_stage(STAGES.MAIN_MENU, STATES.SPLASH, true)


        self.E_MANAGER:add_event(Event({
            func = function()
                self.TIMERS.TOTAL = 0
                self.TIMERS.REAL = 0
                --Prep the splash screen shaders for both the background(colour swirl) and the foreground(white flash), starting at black
                self.SPLASH_BACK = Sprite(Transform(-30, -13, self.room.transform.w + 60, self.room.transform.h + 22), self.ASSET_ATLAS["ui_1"], { x = 2, y = 0 }, self.room)
                self.SPLASH_BACK:define_draw_steps({ {
                    shader = 'splash',
                    send = {
                        { name = 'time', ref_table = self.TIMERS, ref_value = 'REAL' },
                        { name = 'vort_speed', val = 1 },
                        { name = 'colour_1', ref_table = self.C, ref_value = 'BLUE' },
                        { name = 'colour_2', ref_table = self.C, ref_value = 'WHITE' },
                        { name = 'mid_flash', val = 0 },
                        { name = 'vort_offset', val = (2 * 90.15315131 * os.time()) % 100000 },
                    }
                } })
                self.SPLASH_BACK:set_alignment({
                    major = self.ROOM_ATTACH,
                    type = AlignmentType.cm,
                    offset = Vec2(0, 0)
                })
                self.SPLASH_FRONT = Sprite(Transform(0, -20, self.ROOM.T.w * 2, self.ROOM.T.h * 4), self.ASSET_ATLAS["ui_1"], { x = 2, y = 0 }, self.ROOM)
                self.SPLASH_FRONT:define_draw_steps({ {
                    shader = 'flash',
                    send = {
                        { name = 'time', ref_table = self.TIMERS, ref_value = 'REAL' },
                        { name = 'mid_flash', val = 1 }
                    }
                } })
                self.SPLASH_FRONT:set_alignment({
                    major = self.ROOM_ATTACH,
                    type = AlignmentType.cm,
                    offset = Vec2(0, 0)
                })


                --spawn in splash card
                local SC = nil --[[@type Card]]
                self.E_MANAGER:add_event(Event({
                    trigger = EventTrigger.after,
                    delay = 0.2,
                    func = (function()
                        local SC_scale = 1.2
                        local CARD_W, CARD_H = GameCfg:get_card_size()
                        local SC_T = Transform(self.ROOM.T.w / 2 - SC_scale * CARD_W / 2, 10. + self.ROOM.T.h / 2 - SC_scale * CARD_H / 2, SC_scale * CARD_W, SC_scale * CARD_H)
                        SC = Card(SC_T, nil, CardCfg:get_joker_by_id('j_joker'), nil, self.ROOM)
                        SC.T.y = self.ROOM.T.h / 2 - SC_scale * CARD_H / 2
                        SC.ambient_tilt = 1
                        SC.states.drag.can = false
                        SC.states.hover.can = false
                        SC.no_ui = true
                        self.VIBRATION = self.VIBRATION + 2
                        play_sound('whoosh1', 0.7, 0.2)
                        play_sound('introPad1', 0.704, 0.6)
                        return true;
                    end)
                }))
                --dissolve fool card and start to fade in the vortex
                self.E_MANAGER:add_event(Event({
                    trigger = EventTrigger.after,
                    delay = 1.8,
                    func = (function() --|||||||||||
                        SC:start_dissolve({ self.C.WHITE, self.C.WHITE }, true, 12, true)
                        play_sound('magic_crumple', 1, 0.5)
                        play_sound('splash_buildup', 1, 0.7)
                        return true;
                    end)
                }))


                self.vortex_time = self.TIMERS.REAL
                local temp_del = nil

                for i = 1, 200 do
                    temp_del = temp_del or 3
                    self.E_MANAGER:add_event(Event({
                        trigger = EventTrigger.after,
                        blockable = false,
                        delay = temp_del,
                        func = (function()
                            local card, card_pos = self:make_splash_card({ scale = 2 - i / 300 })
                            local speed = math.max(2. - i * 0.005, 0.001)
                            ease_value(card.T, 'scale', -card.T.scale, nil, nil, nil, 1. * speed, 'elastic')
                            ease_value(card.T, 'x', -card_pos.x, nil, nil, nil, 0.9 * speed)
                            ease_value(card.T, 'y', -card_pos.y, nil, nil, nil, 0.9 * speed)
                            local temp_pitch = i * 0.007 + 0.6
                            local temp_i = i
                            App.E_MANAGER:add_event(Event({
                                blockable = false,
                                func = (function()
                                    if card.T.scale <= 0 then
                                        if temp_i < 30 then
                                            play_sound('whoosh1', temp_pitch + math.random() * 0.05, 0.25 * (1 - temp_i / 50))
                                        end

                                        if temp_i == 15 then
                                            play_sound('whoosh_long', 0.9, 0.7)
                                        end
                                        App.VIBRATION = App.VIBRATION + 0.1
                                        card:remove()
                                        return true
                                    end
                                end)
                            }))
                            return true
                        end)
                    }))
                    temp_del = temp_del + math.max(1 / (i), math.max(0.2 * (170 - i) / 500, 0.016))
                end

                --when faded to white, spit out the 'Fool's' cards and slowly have them settle in to place
                self.E_MANAGER:add_event(Event({
                    trigger = EventTrigger.after,
                    delay = 2.,
                    func = (function()
                        self.SPLASH_BACK:remove()
                        self.SPLASH_BACK = self.SPLASH_FRONT
                        self.SPLASH_FRONT = nil
                        self:main_menu('splash')
                        return true;
                    end)
                }))
                return true
            end
        }))
    end
end

---@private create all the cards and suck them in
function App:make_splash_card(args)
    args = args or {}
    local angle = math.random() * 2 * 3.14
    local card_size = (args.scale or 1.5) * (math.random() + 1)
    local card_pos = args.card_pos or {
        x = (18 + card_size) * math.sin(angle),
        y = (18 + card_size) * math.cos(angle)
    }
    local CARD_W, CARD_H = GameCfg:get_card_size()
    local T = Transform(card_pos.x + App.ROOM.T.w / 2 - CARD_W * card_size / 2,
        card_pos.y + App.ROOM.T.h / 2 - CARD_H * card_size / 2,
        card_size * CARD_W, card_size * CARD_H)
    local card = Card(T, pseudorandom_element(App.P_CARDS), CardCfg:get_card_base(), nil, App.ROOM)
    if math.random() > 0.8 then
        card.sprite_facing = 'back'; card.facing = 'back'
    end
    card.no_shadow = true
    card.states.hover.can = false
    card.states.drag.can = false
    card.vortex = true and not args.no_vortex
    card.T.r = angle
    return card, card_pos
end
