local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local vicious = require("vicious")
local radical = require("radical")

local config = require("config")
local wallpaper = require("wallpaper")
local keys = require("keys")
local input = require("input")
local launcher = require("launcher")

local tasklist = require("tasklist")
local sidetasklist = require("sidetasklist")
local taglist = require("taglist")

local battery = require("widgets.vicious.battery")
local memory = require("widgets.vicious.memory")
local cpu = require("widgets.vicious.cpu")
local mpd = require("widgets.vicious.mpd")
local active_button = require("widgets.active_button")

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", wallpaper.set_wallpaper)

-- Create a textclock widget
mytextclock = wibox.widget.textclock("%l:%M %P", 1)
mytextclock.forced_width = 55

-- Time menu
time_button = wibox.widget.textclock("%l:%M:%P", 1)
time_button.forced_width = 55


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

function on_enter(self, w) self:set_bg(beautiful.bg_focus) end
function on_leave(self, w) self:set_bg(beautiful.bg_normal) end

battery_button = active_button(wibox.widget {
        battery.widget,
        widget = wibox.container.margin,
        left = 5,
        right = 5,
    })

local battery_menu = radical.context {
    style = radical.style.classic
}

battery_menu:add_widget(battery.power)
battery_menu:add_widget(battery.time)

battery_button:set_menu(battery_menu, "button::pressed", 1)

vicious.cache(vicious.widgets.bat)
vicious.register(battery, vicious.widgets.bat, pass, 2, "BAT0")

vicious.cache(vicious.widgets.mem)
vicious.register(memory, vicious.widgets.mem, pass, 2)

vicious.cache(vicious.widgets.cpu)
vicious.register(cpu, vicious.widgets.cpu, pass, 2)

mpd_box = wibox.widget {
    active_button(mpd.button),
    mpd.widget,
    layout = wibox.layout.fixed.horizontal()
}

vicious.cache(vicious.widgets.mpd)
vicious.register(mpd, vicious.widgets.mpd, pass, 2)

mpd.button:connect_signal("button::press", function ()
    awful.spawn.spawn("mpc toggle")
    vicious.force({mpd})
end)

local trackpad = input.widget(
    "/home/tim/.config/awesome/icons/input-touchpad-symbolic.svg",
    "ETPS/2 Elantech Touchpad",
    2
)

local trackpoint = input.widget(
    "/home/tim/.config/awesome/icons/radio-checked-symbolic.svg",
    "ETPS/2 Elantech TrackPoint",
    2
)

local stylus = input.widget(
    "/home/tim/.config/awesome/icons/input-tablet-symbolic.svg",
    "Wacom Pen and multitouch sensor Pen stylus",
    2
)

local touch = input.widget(
    "/home/tim/.config/awesome/icons/tablet-symbolic.svg",
    "Wacom Pen and multitouch sensor Finger touch",
    2
)

local input_button = active_button(wibox.widget {
    {
       widget = wibox.widget.imagebox,
        image = "/home/tim/.config/awesome/icons/input-tablet-symbolic.svg",
        resize = false
    },

    widget = wibox.container.margin,
    left = 5,
    top = 5,
    right = 5,

})

local input_menu = radical.context {
    style = radical.style.classic
}

input_menu:add_widget(trackpad.widget)
input_menu:add_widget(trackpoint.widget)
input_menu:add_widget(stylus.widget)
input_menu:add_widget(touch.widget)

input_button:set_menu(input_menu, "button::pressed", 1)

local resources = active_button(wibox.widget {
    {
        id = "icon",
        widget = wibox.widget.imagebox,
        image = "/home/tim/.config/awesome/icons/cpu-frequency-indicator.svg",
    },

    widget = wibox.container.margin,
    left = 5,
    top = 2,
    right = 5,
})

local resources_menu = radical.context {
    style = radical.style.classic
}
resources_menu:add_widget(cpu.widget)
resources_menu:add_widget(memory.widget)

resources:set_menu(resources_menu, "button::pressed", 1)

local rotate_button = active_button(wibox.widget {
    {
        widget = wibox.widget.imagebox,
        image = "/home/tim/.config/awesome/icons/media-playlist-repeat-symbolic.svg",
        resize = false
    },

    widget = wibox.container.margin,
    left = 5,
    top = 5,
    right = 5,
})

local rotate_menu = radical.context {
    style = radical.style.classic
}

rotate_menu:add_item {
    text="Normal",
    button1=function(menu, item, mods)
        awful.spawn.spawn("/home/tim/scripts/rotate-screen.sh normal")
        menu.visible = false
    end
}

rotate_menu:add_item {
    text="Left",
    button1=function(menu, item, mods)
        awful.spawn.spawn("/home/tim/scripts/rotate-screen.sh left")
        menu.visible = false
    end
}

rotate_menu:add_item {
    text="Right",
    button1=function(menu, item, mods)
        awful.spawn.spawn("/home/tim/scripts/rotate-screen.sh right")
        menu.visible = false
    end
}

rotate_menu:add_item {
    text="Inverted",
    button1=function(menu, item, mods)
        awful.spawn.spawn("/home/tim/scripts/rotate-screen.sh inverted")
        menu.visible = false
    end
}

rotate_button:set_menu(rotate_menu, "button::pressed", 1);

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    wallpaper.set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "main", "notes", "hw", "projects", "5", "6", "7", "8", "9" }, s, config.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = active_button(awful.widget.layoutbox(s))
    s.mylayoutbox:buttons(gears.table.join(
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc( 1) end),
            awful.button({ }, 5, function () awful.layout.inc(-1) end)
        ))
    -- Create a taglist widget
    --s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, keys.taglist_buttons)
    s.mytaglist = taglist(s)

    -- Create a tasklist widget
    --s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, keys.tasklist_buttons)
    s.mytasklist = tasklist(s)

    s.mywibox = awful.wibar({ position = "top", screen = s, })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            active_button(launcher.widget),
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            seperator,
            mpd_box,
            seperator,
            rotate_button,
            input_button,
            resources,
            mytextclock,
            battery_button,
            seperator,
            s.mylayoutbox,
        },
    }

    s.sidetasklist = sidetasklist(s)

    s.sidebar = awful.wibar({
        position = "left",
        screen = s,
        stretch = false,
        ontop = true,
        width = 24,
        height = 1000,
    })

    s.sidebar:struts({ left = 0, right = 0, bottom = 0, top = 0 })

    s.sidebar:setup {
        s.sidetasklist,
        rotate_button,
        layout = wibox.layout.align.vertical,
    }

    s.sidebar_timer = gears.timer {
        timeout = 1,
        autostart = true,
        callback = function()
            s.sidebar.opacity = 0
            s.sidebar.width = 9
            s.sidebar:struts({ left = 0, right = 0, bottom = 0, top = 0 })
        end,
        single_shot = true
    }

    s.sidebar:connect_signal("mouse::enter", function()
        s.sidebar.width = 24
        s.sidebar.opacity = 1
        s.sidebar:struts({ left = 0, right = 0, bottom = 0, top = 0 })
    end)

    s.sidebar:connect_signal("mouse::leave", function()
        s.sidebar_timer:start()
    end)

end)
