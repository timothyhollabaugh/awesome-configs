local cairo = require("lgi").cairo

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local launcher = require("launcher")
--local battery_widget = require("awesome-wm-widgets.battery-widget.battery")
--local volumebar_widget = require("awesome-wm-widgets.volumebar-widget.volumebar")
local lain = require("lain")
local vicious = require("vicious")

local xrandr = require("xrandr")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
            title = "Oops, there were errors during startup!",
        text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                title = "Oops, an error happened!",
            text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.init("/home/tim/.config/awesome/theme.lua")

awful.spawn.with_shell("/home/tim/.config/awesome/autorun.sh")

terminal = "alacritty"
--terminal = "gnome-terminal"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.floating,
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end},
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
            { "open terminal", terminal }
        }
    })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
    menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
-- mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
    )

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
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
    end),
    awful.button({ }, 3, client_menu_toggle_fn()),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
        awful.client.focus.byidx(-1)
    end)
    )

local function set_wallpaper(s)
    local surf = gears.surface.load(beautiful.wallpaper)
    local geom, cr = gears.wallpaper.prepare_context(s)
    local original_surf = surf
    surf = gears.surface.load_uncached(surf)
    local w, h = gears.surface.get_size(surf)
    local aspect_w = geom.width / w
    local aspect_h = geom.height / h

    --[[
    aspect_h = math.max(aspect_w, aspect_h)
    aspect_w = math.max(aspect_w, aspect_h)
    --]]

    cr:scale(aspect_w, aspect_h)

    local scaled_width = geom.width / aspect_w
    local scaled_height = geom.height / aspect_h
    cr:translate((scaled_width - w) / 2, (scaled_height - h) / 2)

    cr:set_source_surface(surf, 0, 0)
    cr.operator = cairo.Operator.OVER
    cr:paint()
    if surf ~= original_surf then
        surf:finish()
    end
    if cr.status ~= "SUCCESS" then
        debug.print_warning("Cairo context entered error state: " .. cr.status)
    end

    cr:set_source_rgba(0, 0, 0, 0.52)
    cr:rectangle(0, 26/aspect_h + 0, scaled_width, 1)
    cr:fill()

    cr:set_source_rgba(0, 0, 0, 0.42)
    cr:rectangle(0, 26/aspect_h + 1, scaled_width, 1)
    cr:fill()

    cr:set_source_rgba(0, 0, 0, 0.3)
    cr:rectangle(0, 26/aspect_h + 2, scaled_width, 1)
    cr:fill()

    cr:set_source_rgba(0, 0, 0, 0.2)
    cr:rectangle(0, 26/aspect_h + 3, scaled_width, 1)
    cr:fill()

    cr:set_source_rgba(0, 0, 0, 0.11)
    cr:rectangle(0, 26/aspect_h + 4, scaled_width, 1)
    cr:fill()

    cr:set_source_rgba(0, 0, 0, 0.04)
    cr:rectangle(0, 26/aspect_h + 5, scaled_width, 1)
    cr:fill()

end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- Create a textclock widget
mytextclock = wibox.widget.textclock("%l:%M %P", 1)
mytextclock.forced_width = 55

-- Keyboard widget
keyboard_widget = wibox.widget {
    {
        id = "icon",
        widget = wibox.widget.imagebox,
        resize = false,
        image = "/home/tim/.config/awesome/icons/keyboard.svg"
    },
    layout = wibox.container.margin(_, 0, 0, 3);
}

keyboard_widget:connect_signal("button::press", function()
    awful.spawn.spawn("/home/tim/scripts/keyboard.sh")
end)

seperator = wibox.widget{
    markup = '   ',
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

function pass(w, d) return d end

battery = {
    set_markup = function (self, data)
        self.widget:get_children_by_id("icon")[1].level = data[2] / 100
        self.widget:get_children_by_id("text")[1]:set_markup('<span color="#444444">'..data[1]..'</span>')
    end,

    widget = wibox.widget {
        {

            id = "icon",
            level = 1.0,

            fit = function (self, context, width, height)
                return height, height
            end,

            draw = function(self, context, cr, width, height)

                local cx = width/2
                local cy = height/2

                cr:set_source_rgba(1.0, 1.0, 1.0, 0.5)
                cr:rectangle(cx-5, cy-6, 10, 14)
                cr:rectangle(cx-2, cy-8, 4, 2)
                cr:stroke()

                local pixels = self.level * 14

                cr:set_source_rgba(0.9412, 0.9412, 0.9412, 1.0)
                cr:rectangle(cx-5, cy-6+14-pixels, 10, pixels)
                if (self.level >= 1.0) then
                    cr:rectangle(cx-2, cy-8, 4, 2)
                end
                cr:fill()
            end,

            layout = wibox.widget.base.make_widget,
        },

        {
            {
                id = "text",
                widget = wibox.widget.textbox,
                markup = "?",
                align = "center",
            },

            widget = wibox.container.rotate,
            direction = "east",
        },

        layout = wibox.layout.stack,
        horizontal_offset = -1,
        forced_width = 14
    }
}

vicious.cache(vicious.widgets.bat)
vicious.register(battery, vicious.widgets.bat, pass, 2, "BAT0")

memory = {
    set_markup = function (self, data)
        self.widget:get_children_by_id("text")[1]:set_markup(string.format("%.1fGB", data[2]/1000))
    end,

    widget = wibox.widget {
        {
            id = "text",
            widget = wibox.widget.textbox,
            forced_width = 38,
            align = "right",
        },

        layout = wibox.layout.fixed.horizontal,
    }
}

vicious.cache(vicious.widgets.mem)
vicious.register(memory, vicious.widgets.mem, pass, 2)

cpu = {
    set_markup = function(self, data)
        self.widget:get_children_by_id("text")[1]:set_markup(string.format("%d%%", data[1]))
    end,

    widget = wibox.widget {
        --{
        --    id = "icon",
        --    widget = wibox.widget.imagebox,
        --    image = "/home/tim/.config/awesome/icons/cpu-frequency-indicator.svg",
        --},
        {
            id = "text",
            widget = wibox.widget.textbox,
            forced_width = 38,
            align = "right",
        },

        layout = wibox.layout.fixed.horizontal,
    }
}

vicious.cache(vicious.widgets.cpu)
vicious.register(cpu, vicious.widgets.cpu, pass, 2)

mpd = {
    set_markup = function(self, data)
        self.widget:get_children_by_id("text")[1]:set_markup(data['{Title}'])

        local state = data['{state}']

        if (state == "Play") then
            self.widget:get_children_by_id("icon")[1].image = "/home/tim/.config/awesome/icons/media/pause.svg"
        else
            self.widget:get_children_by_id("icon")[1].image = "/home/tim/.config/awesome/icons/media/play.svg"
        end
    end,

    widget = wibox.widget {
        {
            id = "icon",
            widget = wibox.widget.imagebox,
            image = "/home/tim/.config/awesome/icons/media/play.svg",
        },
        {
            id = "text",
            widget = wibox.widget.textbox,
            markup = "Unknown",
        },

        layout = wibox.layout.fixed.horizontal,
    }
}

mpd.widget:connect_signal("button::press", function ()
    awful.spawn.spawn("mpc toggle")
    vicious.force({mpd})
end)

vicious.cache(vicious.widgets.mpd)
vicious.register(mpd, vicious.widgets.mpd, pass, 2)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "main", "notes", "hw", "projects", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc( 1) end),
            awful.button({ }, 5, function () awful.layout.inc(-1) end)
        ))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --mylauncher,
            launcher.widget,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- mykeyboardlayout,
            wibox.widget.systray(),
            seperator,
            mpd.widget,
            seperator,
            cpu.widget,
            seperator,
            memory.widget,
            seperator,
            mytextclock,
            seperator,
            battery.widget,
            seperator,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
        awful.button({ }, 3, function () mymainmenu:toggle() end),
        awful.button({ }, 4, awful.tag.viewnext),
        awful.button({ }, 5, awful.tag.viewprev)
    ))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
        {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
        {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
        {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
        {description = "go back", group = "tag"}),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
        {description = "show main menu", group = "awesome"}),

    -- Focus moving
    awful.key({ modkey,           }, "h", function () awful.client.focus.bydirection("left") end,
        {description = "focus window to the left", group = "client"}),
    awful.key({ modkey,           }, "j", function () awful.client.focus.bydirection("down") end,
        {description = "focus window to the down", group = "client"}),
    awful.key({ modkey,           }, "k", function () awful.client.focus.bydirection("up") end,
        {description = "focus window to the up", group = "client"}),
    awful.key({ modkey,           }, "l", function () awful.client.focus.bydirection("right") end,
        {description = "focus window to the right", group = "client"}),

    -- Window moving
    awful.key({ modkey, "Shift"   }, "h", function () awful.client.swap.bydirection("left") end,
        {description = "move window to the left", group = "client"}),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.bydirection("down") end,
        {description = "move window to the down", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.bydirection("up") end,
        {description = "move window to the up", group = "client"}),
    awful.key({ modkey, "Shift"   }, "l", function () awful.client.swap.bydirection("right") end,
        {description = "move window to the right", group = "client"}),

    -- Tag moving
    awful.key({ modkey,           }, ".", function () awful.tag.viewnext(awful.screen.focused()) end,
        {description = "move to next tag", group = "tags"}),
    awful.key({ modkey,           }, ",", function () awful.tag.viewprev(awful.screen.focused()) end,
        {description = "move to previous tag", group = "tags"}),

    -- Layout manipulation
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
        {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
        {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
        {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"}),

    --[[
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    --]]
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
        {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
        {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
        {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
        {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end,
        {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
        {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
        function ()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        {description = "lua execute prompt", group = "awesome"}),

    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
        {description = "show the menubar", group = "launcher"}),

    -- Montor switching
    awful.key({ modkey }, "`", function() xrandr.xrandr() end),

    -- Volume up
    awful.key({ }, "XF86AudioRaiseVolume", function() awful.spawn.spawn("amixer -D pulse sset Master 5%+") end,
        {description = "Raise the volume", group = "volume"}),
    -- Volume down
    awful.key({ }, "XF86AudioLowerVolume", function() awful.spawn.spawn("amixer -D pulse sset Master 5%-") end,
        {description = "Lower the volume", group = "volume"}),

    -- xlunch
    awful.key({ modkey }, "z", function() launcher:show() end,
        {description = "Show xlunch", group = "launcher"}),

    -- Volatile tags
    awful.key({ modkey }, "0", function ()
        awful.tag.add("tmp", {
                screen = client.focus.screen,
                Volatile = true,
                clients  = {
                    client.focus,
                    awful.client.focus.history.get(client.focus.screen, 1)
                }
            }
            )
    end,
    {description = "Make temp tag", group = "awesome"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
        {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
        {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
        {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
        {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
        {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
    )

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            {description = "toggle focused client on tag #" .. i, group = "tag"})
        )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
        properties = { border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    { rule_any = {
            instance = {
                "DTA",  -- Firefox addon DownThemAll.
                "copyq",  -- Includes session name in class.
            },
            class = {
                "Arandr",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Wpa_gui",
                "pinentry",
                "veromix",
            "xtightvncviewer"},

            name = {
                "Event Tester",  -- xev.
            },
            role = {
                "AlarmWindow",  -- Thunderbird's calendar.
                "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
            }
    }, properties = { floating = true }},

    { rule = { floating = true},
        properties = { ontop = true}
    },

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
        }, properties = { titlebars_enabled = true }
    },

    { rule = { class = "xlunch" },
        properties = {
            titlebars_enabled = false,
            floating = true,
            sticky = true,
            ontop = true,
            skip_taskbar = true,
            type = dock,
            width = 500,
            height = 500,
            x = 1920/2 - 250,
            y = 1080/2 - 250
        }
    }

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
        not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
        )

    local bar_color = "#444851"

    if c.maximized then
        bar_color = "#ffcf44"
    end

    awful.titlebar(c) : setup {
        { -- Left
            --awful.titlebar.widget.iconwidget(c),
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.stickybutton   (c),
            layout  = wibox.layout.fixed.horizontal
        },
        {
            { -- Middle
                { -- Title
                    id = "title",
                    align  = "center",
                    widget = awful.titlebar.widget.titlewidget(c)
                },
                buttons = buttons,
                layout  = wibox.layout.flex.horizontal
            },
            id = "bar",

            shape = beautiful.focus_bar_shape,

            --shape = gears.shape.rounded_rect,
            --bg = bar_color,
            widget = wibox.container.background,
        },
        { -- Right
            awful.titlebar.widget.minimizebutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c)
    if (awful.titlebar(c) ~= nil) then
        --awful.titlebar(c):get_children_by_id("bar")[1].bg = beautiful.bg_focus
    end
    c:raise()
    c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
    if (awful.titlebar(c) ~= nil) then
        --awful.titlebar(c):get_children_by_id("bar")[1].bg = beautiful.bg_normal
    end
    c.border_color = beautiful.border_normal
end)

-- }}}

-- Rounded corners
--client.connect_signal("manage", function (c)
--    c.shape = function(cr,w,h)
--        gears.shape.rounded_rect(cr,w,h,0)
--    end
--end)

