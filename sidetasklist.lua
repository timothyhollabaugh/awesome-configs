local awful = require("awful")
local type = type
local ipairs = ipairs
local capi = { button = button }
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local naughty = require("naughty")

local active_button = require("widgets.active_button")
local keys = require("keys")

local radical = require("radical")

--- Common method to create buttons.
-- @tab buttons
-- @param object
-- @treturn table
function create_buttons(buttons, object)
    if buttons then
        local btns = {}
        for _, b in ipairs(buttons) do
            -- Create a proxy button object: it will receive the real
            -- press and release events, and will propagate them to the
            -- button object the user provided, but with the object as
            -- argument.
            local btn = capi.button { modifiers = b.modifiers, button = b.button }
            btn:connect_signal("press", function () b:emit_signal("press", object) end)
            btn:connect_signal("release", function () b:emit_signal("release", object) end)
            btns[#btns + 1] = btn
        end

        return btns
    end
end

--- Common update method.
-- @param w The widget.
-- @tab buttons
-- @func label Function to generate label parameters from an object.
--   The function gets passed an object from `objects`, and
--   has to return `text`, `bg`, `bg_image`, `icon`.
-- @tab data Current data/cache, indexed by objects.
-- @tab objects Objects to be displayed / updated.

-- objects are clients in this case
local function side_list_update(w, buttons, label, data, objects)
    -- update the widgets, creating them if needed
    w:reset()

    local client_groups = {}

    local dummy_textbox = wibox.widget.textbox()

    for i, o in ipairs(objects) do

        if not client_groups[o.class] then
            client_groups[o.class] = {o}
        else
            table.insert(client_groups[o.class], o)
        end
    end

    for class, clients in pairs(client_groups) do

        imagebox = wibox.widget.imagebox()

        local text, bg, bg_image, icon, args = label(clients[1], dummy_textbox)
        args = args or {}

        if icon then
            imagebox:set_image(icon)
        end

        client_menu = radical.context {
            style = radical.style.classic
        }

        for j, c in ipairs(clients) do
            client_menu:add_item {
                text=c.name,
                button1=function(menu, item, mods)
                    client_menu:hide()
                    if c == client.focus then
                        c.minimized = true
                    else
                        -- Without this, the following
                        -- :isvisible() makes no sense
                        c.minimized = false
                        if not c:isvisible() and c.first_tag then
                            c.first_tag:view_only()
                        end
                        -- This will also un-minimize
                        -- the client, if needed
                        client.focus = c
                        c:raise()
                    end
                end
            }
        end

        imagebox:set_menu(client_menu, "button::pressed", 1)

        w:add(active_button(imagebox))
    end
--[[
        local cache = data[o]
        local ib, tb, bgb, tbm, ibm, l
        if cache then
            ib = cache.ib
            tb = cache.tb
            bgb = cache.bgb
            tbm = cache.tbm
            ibm = cache.ibm
        else
            ib = wibox.widget.imagebox()
            tb = wibox.widget.textbox()
            bgb = wibox.container.background()
            tbm = wibox.container.margin(tb, dpi(4), dpi(4))
            ibm = wibox.container.margin(ib, dpi(4))
            l = wibox.layout.fixed.horizontal()

            -- All of this is added in a fixed widget
            l:fill_space(true)
            l:add(ibm)
            l:add(tbm)

            -- And all of this gets a background
            bgb:set_widget(l)
            bgb.min_width = 100

            bgb:buttons(create_buttons(buttons, o))

            data[o] = {
                ib  = ib,
                tb  = tb,
                bgb = bgb,
                tbm = tbm,
                ibm = ibm,
            }
        end

        --for k, v in pairs(o) do
            --naughty.notify({text=k})
        --end

        --naughty.notify({text=o.icon_name})

        local text, bg, bg_image, icon, args = label(o, tb)
        args = args or {}

        -- The text might be invalid, so use pcall.
        if text == nil or text == "" then
            tbm:set_margins(0)
        else
            if not tb:set_markup_silently("hello") then
                tb:set_markup("<i>&lt;Invalid text&gt;</i>")
            end
        end
        bgb:set_bg(bg)
        if type(bg_image) == "function" then
            -- TODO: Why does this pass nil as an argument?
            bg_image = bg_image(tb,o,nil,objects,i)
        end
        bgb:set_bgimage(bg_image)
        if icon then
            ib:set_image(icon)
        else
            ibm:set_margins(0)
        end

        bgb.shape              = args.shape
        bgb.shape_border_width = args.shape_border_width
        bgb.shape_border_color = args.shape_border_color

        w:add(active_button(bgb))
   end
   --]]
end

local sidetasklist = function(s)

    return awful.widget.tasklist(
        s,
        awful.widget.tasklist.filter.currenttags,
        keys.tasklist_buttons,
        {},
        side_list_update,
        wibox.layout.fixed.vertical()
    )
end

return sidetasklist
