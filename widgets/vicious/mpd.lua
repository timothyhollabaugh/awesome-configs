local wibox = require("wibox")
local beautiful = require("beautiful")
beautiful.init("/home/tim/.config/awesome/theme.lua")

local active_button = require("widgets.active_button")

mpd = {
    set_markup = function(self, data)
        self.widget:get_children_by_id("text")[1]:set_markup(data['{Title}'])

        local state = data['{state}']

        if (state == "Play") then
            self.button:get_children_by_id("icon")[1].image = "/home/tim/.config/awesome/icons/media/pause.svg"
        else
            self.button:get_children_by_id("icon")[1].image = "/home/tim/.config/awesome/icons/media/play.svg"
        end
    end,

    button = wibox.widget {
        {
            id = "icon",
            widget = wibox.widget.imagebox,
            image = "/home/tim/.config/awesome/icons/media/play.svg",
        },

        widget = wibox.container.margin,
        top = 1,
        bottom = 1,
    },

    widget = wibox.widget {
        id = "text",
        widget = wibox.widget.textbox,
        markup = "Unknown",
    }
}

return mpd
