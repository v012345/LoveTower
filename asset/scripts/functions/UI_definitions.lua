function UIBox_button(args)
    args = args or {}
    args.button = args.button or "exit_overlay_menu"
    args.func = args.func or nil
    args.colour = args.colour or App.instance.C.RED
    args.choice = args.choice or nil
    args.chosen = args.chosen or nil
    args.label = args.label or { 'LABEL' }
    args.minw = args.minw or 2.7
    args.maxw = args.maxw or (args.minw - 0.2)
    if args.minw < args.maxw then args.maxw = args.minw - 0.2 end
    args.minh = args.minh or 0.9
    args.scale = args.scale or 0.5
    args.focus_args = args.focus_args or nil
    args.text_colour = args.text_colour or G.C.UI.TEXT_LIGHT
    local but_UIT = args.col == true and G.UIT.C or G.UIT.R

    local but_UI_label = {}

    local button_pip = nil
    for k, v in ipairs(args.label) do
        if k == #args.label and args.focus_args and args.focus_args.set_button_pip then
            button_pip = 'set_button_pip'
        end
        table.insert(but_UI_label,
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0, minw = args.minw, maxw = args.maxw },
                nodes = {
                    { n = G.UIT.T, config = { text = v, scale = args.scale, colour = args.text_colour, shadow = args.shadow, focus_args = button_pip and args.focus_args or nil, func = button_pip, ref_table = args.ref_table } }
                }
            })
    end

    if args.count then
        table.insert(but_UI_label,
            {
                n = G.UIT.R,
                config = { align = "cm", minh = 0.4 },
                nodes = {
                    { n = G.UIT.T, config = { scale = 0.35, text = args.count.tally .. ' / ' .. args.count.of, colour = { 1, 1, 1, 0.9 } } }
                }
            }
        )
    end

    return
    {
        n = but_UIT,
        config = { align = 'cm' },
        nodes = {
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = args.padding or 0,
                    r = 0.1,
                    hover = true,
                    colour = args.colour,
                    one_press = args.one_press,
                    button = (args.button ~= 'nil') and args.button or nil,
                    choice = args.choice,
                    chosen = args.chosen,
                    focus_args = args.focus_args,
                    minh = args.minh - 0.3 * (args.count and 1 or 0),
                    shadow = true,
                    func = args.func,
                    id = args.id,
                    back_func = args.back_func,
                    ref_table = args.ref_table,
                    mid = args.mid
                },
                nodes =
                    but_UI_label
            } }
    }
end
