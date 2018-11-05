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

local lain = require("lain")
local vicious = require("vicious")
local radical = require("radical")
local xrandr = require("xrandr")

local config = require("config")
local keys = require("keys")
local launcher = require("launcher")
local input = require("input")
local wallpaper = require("wallpaper")
local active_button = require("widgets.active_button")

local topbar = require("topbar")

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

awful.layout.layouts = config.layouts


-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end},
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
            { "open terminal", config.terminal }
        }
    })

-- Menubar configuration
menubar.utils.terminal = config.terminal -- Set the terminal for applications that require it
-- }}}

-- Set keys
root.keys(keys.global_keys)
root.buttons(keys.desktop_buttons)

-- {{{ Wibar

-- Create a wibox for each screen and add it

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
        properties = { border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = keys.client_keys,
            buttons = keys.client_buttons,
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
            active_button(awful.titlebar.widget.floatingbutton (c)),
            active_button(awful.titlebar.widget.ontopbutton    (c)),
            active_button(awful.titlebar.widget.stickybutton   (c)),
            layout  = wibox.layout.fixed.horizontal
        },
        {
            { -- Middle
                active_button(wibox.widget { -- Title
                    --id = "title",
                    align  = "center",

                    widget = awful.titlebar.widget.titlewidget(c)
                }),
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
            active_button(awful.titlebar.widget.minimizebutton (c)),
            active_button(awful.titlebar.widget.maximizedbutton(c)),
            active_button(awful.titlebar.widget.closebutton    (c)),
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
