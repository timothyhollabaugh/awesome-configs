local wibox = require("wibox")
local beautiful = require("beautiful")
beautiful.init("/home/tim/.config/awesome/theme.lua")

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


return memory
