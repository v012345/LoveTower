function App:draw()
    self.FRAMES.DRAW = self.FRAMES.DRAW + 1
    --draw the room
    reset_drawhash()
    if self.OVERLAY_TUTORIAL and not self.OVERLAY_MENU then self.under_overlay = true end
    self.Performance:timer_checkpoint('start->canvas', 'draw')
    love.graphics.setCanvas({ self.CANVAS })
    love.graphics.push()
    do
        love.graphics.scale(self.CANV_SCALE)

        love.graphics.setShader()
        love.graphics.clear(0, 0, 0, 1)

        if self.SPLASH_BACK then
            if self.debug_background_toggle then
                love.graphics.clear({ 0, 1, 0, 1 })
            else
                love.graphics.push()
                self.SPLASH_BACK:translate_container()
                self.SPLASH_BACK:draw()
                love.graphics.pop()
            end
        end
        if not self.debug_UI_toggle then
            for k, v in pairs(self.I.NODE) do
                if not v.parent then
                    love.graphics.push()
                    v:translate_container()
                    v:draw()
                    love.graphics.pop()
                end
            end
            for k, v in pairs(self.I.MOVEABLE) do
                if not v.parent then
                    love.graphics.push()
                    v:translate_container()
                    v:draw()
                    love.graphics.pop()
                end
            end
            if self.SPLASH_LOGO then
                love.graphics.push()
                self.SPLASH_LOGO:translate_container()
                self.SPLASH_LOGO:draw()
                love.graphics.pop()
            end
            if self.debug_splash_size_toggle then
                for k, v in pairs(self.I.CARDAREA) do
                    if not v.parent then
                        love.graphics.push()
                        v:translate_container()
                        v:draw()
                        love.graphics.pop()
                    end
                end
            else
                if not self.OVERLAY_MENU or not self.Features:is_hide_bg() then
                    self.Performance:timer_checkpoint('primatives', 'draw')
                    for k, v in pairs(self.I.UIBOX) do
                        if not v.attention_text and not v.parent and v ~= self.OVERLAY_MENU and v ~= self.screenwipe and v ~= self.OVERLAY_TUTORIAL and v ~= self.debug_tools and v ~= self.online_leaderboard and v ~= self.achievement_notification then
                            love.graphics.push()
                            v:translate_container()
                            v:draw()
                            love.graphics.pop()
                        end
                    end
                    self.Performance:timer_checkpoint('uiboxes', 'draw')
                    for k, v in pairs(self.I.CARDAREA) do
                        if not v.parent then
                            love.graphics.push()
                            v:translate_container()
                            v:draw()
                            love.graphics.pop()
                        end
                    end
                    for k, v in pairs(self.I.CARD) do
                        if not v.parent and v ~= self.CONTROLLER.dragging.target and v ~= self.CONTROLLER.focused.target then
                            love.graphics.push()
                            v:translate_container()
                            v:draw()
                            love.graphics.pop()
                        end
                    end
                    for k, v in pairs(self.I.UIBOX) do
                        if v.attention_text and v ~= self.debug_tools and v ~= self.online_leaderboard and v ~= self.achievement_notification then
                            love.graphics.push()
                            v:translate_container()
                            v:draw()
                            love.graphics.pop()
                        end
                    end

                    if self.SPLASH_FRONT then
                        love.graphics.push()
                        self.SPLASH_FRONT:translate_container()
                        self.SPLASH_FRONT:draw()
                        love.graphics.pop()
                    end
                    self.under_overlay = false
                    if self.OVERLAY_TUTORIAL then
                        love.graphics.push()
                        self.OVERLAY_TUTORIAL:translate_container()
                        self.OVERLAY_TUTORIAL:draw()
                        love.graphics.pop()

                        if self.OVERLAY_TUTORIAL.highlights then
                            for k, v in ipairs(self.OVERLAY_TUTORIAL.highlights) do
                                love.graphics.push()
                                v:translate_container()
                                v:draw()
                                --- 这里我需要再看一下, 这个 draw_children 是什么意思
                                if v.draw_children then
                                    v:draw_self()
                                    v:draw_children()
                                end
                                love.graphics.pop()
                            end
                        end
                    end
                end

                if self.OVERLAY_MENU or not self.Features:is_hide_bg() then
                    if self.OVERLAY_MENU and self.OVERLAY_MENU ~= self.CONTROLLER.dragging.target then
                        love.graphics.push()
                        self.OVERLAY_MENU:translate_container()
                        self.OVERLAY_MENU:draw()
                        love.graphics.pop()
                    end
                end

                if self.debug_tools then
                    if self.debug_tools ~= self.CONTROLLER.dragging.target then
                        love.graphics.push()
                        self.debug_tools:translate_container()
                        self.debug_tools:draw()
                        love.graphics.pop()
                    end
                end

                self.ALERT_ON_SCREEN = false
                for k, v in pairs(self.I.ALERT) do
                    love.graphics.push()
                    v:translate_container()
                    v:draw()
                    self.ALERT_ON_SCREEN = true
                    love.graphics.pop()
                end

                if self.CONTROLLER.dragging.target and self.CONTROLLER.dragging.target ~= self.CONTROLLER.focused.target then
                    love.graphics.push()
                    self.CONTROLLER.dragging.target:translate_container()
                    self.CONTROLLER.dragging.target:draw()
                    love.graphics.pop()
                end

                if self.CONTROLLER.focused.target and getmetatable(self.CONTROLLER.focused.target) == Card and (self.CONTROLLER.focused.target.area ~= self.hand or self.CONTROLLER.focused.target == self.CONTROLLER.dragging.target) then
                    love.graphics.push()
                    self.CONTROLLER.focused.target:translate_container()
                    self.CONTROLLER.focused.target:draw()
                    love.graphics.pop()
                end

                for k, v in pairs(self.I.POPUP) do
                    love.graphics.push()
                    v:translate_container()
                    v:draw()
                    love.graphics.pop()
                end

                if self.achievement_notification then
                    love.graphics.push()
                    self.achievement_notification:translate_container()
                    self.achievement_notification:draw()
                    love.graphics.pop()
                end

                if self.screenwipe then
                    love.graphics.push()
                    self.screenwipe:translate_container()
                    self.screenwipe:draw()
                    love.graphics.pop()
                end
                love.graphics.push()
                local pixels_per_tile = self.window:get_pixels_per_tile()
                love.graphics.translate(-self.CURSOR.T.w * pixels_per_tile / 2, -self.CURSOR.T.h * pixels_per_tile / 2)
                self.CURSOR:draw()
                love.graphics.pop()
                self.Performance:timer_checkpoint('rest', 'draw')
            end
        end
    end
    love.graphics.pop()

    love.graphics.setCanvas(self.AA_CANVAS)
    love.graphics.push()
    love.graphics.setColor(self.C.WHITE)
    if (not self.recording_mode or self.video_control) and true then
        self.ARGS.eased_cursor_pos = self.ARGS.eased_cursor_pos or { x = self.CURSOR.T.x, y = self.CURSOR.T.y, sx = self.CONTROLLER.cursor_position.x, sy = self.CONTROLLER.cursor_position.y }
        self.screenwipe_amt = self.screenwipe_amt and (0.95 * self.screenwipe_amt + 0.05 * ((self.screenwipe and 0.4 or self.screenglitch and 0.4) or 0)) or 1
        local crt = self.SETTINGS.data.GRAPHICS.crt * 0.3
        self.SHADERS['CRT']:send('distortion_fac', { 1.0 + 0.07 * crt / 100, 1.0 + 0.1 * crt / 100 })
        self.SHADERS['CRT']:send('scale_fac', { 1.0 - 0.008 * crt / 100, 1.0 - 0.008 * crt / 100 })
        self.SHADERS['CRT']:send('feather_fac', 0.01)
        self.SHADERS['CRT']:send('bloom_fac', self.SETTINGS.data.GRAPHICS.bloom - 1)
        self.SHADERS['CRT']:send('time', 400 + self.TIMERS.REAL)
        self.SHADERS['CRT']:send('noise_fac', 0.001 * crt / 100)
        self.SHADERS['CRT']:send('crt_intensity', 0.16 * crt / 100)
        self.SHADERS['CRT']:send('glitch_intensity', 0) --0.1*crt/100 + (G.screenwipe_amt) + 1)
        self.SHADERS['CRT']:send('scanlines', self.CANVAS:getPixelHeight() * 0.75 / self.CANV_SCALE)
        self.SHADERS['CRT']:send('mouse_screen_pos', self.video_control and { love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 } or { self.ARGS.eased_cursor_pos.sx, self.ARGS.eased_cursor_pos.sy })
        self.SHADERS['CRT']:send('screen_scale', self.window:get_pixels_per_tile())
        self.SHADERS['CRT']:send('hovering', 1)
        love.graphics.setShader(self.SHADERS['CRT'])
    end

    love.graphics.draw(self.CANVAS, 0, 0)
    love.graphics.pop()

    love.graphics.setCanvas()
    love.graphics.setShader()
    if self.AA_CANVAS then
        love.graphics.push()
        love.graphics.scale(1 / self.CANV_SCALE)
        love.graphics.draw(self.AA_CANVAS, 0, 0)
        love.graphics.pop()
    end
    self.Performance:timer_checkpoint('canvas', 'draw')
    if not _RELEASE_MODE and self.DEBUG and not self.video_control and self.Features:is_verbose_enabled() then
        love.graphics.push()
        love.graphics.setColor(0, 1, 1, 1)
        local fps = love.timer.getFPS()
        love.graphics.print("Current FPS: " .. fps, 10, 10)

        if self.SETTINGS.data.perf_mode then
            self.Performance:draw()
        end

        love.graphics.pop()
    end
    self.Performance:timer_checkpoint('debug', 'draw')
    self.ROOM:draw_self_boundingrect()
end
