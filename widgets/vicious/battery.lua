local wibox = require("wibox")
local beautiful = require("beautiful")
beautiful.init("/home/tim/.config/awesome/theme.lua")

battery = {
    set_markup = function (self, data)
        self.widget:get_children_by_id("icon")[1].level = data[2] / 100
        --self.widget:get_children_by_id("icon")[1]:refresh()
        self.widget:get_children_by_id("text")[1]:set_markup('<span color="#444444">'..data[1]..'</span>')
        self.time:set_markup(data[3])
        self.power:set_markup(data[5].."W")
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
            direction = "south",
        },

        layout = wibox.layout.stack,
        --horizontal_offset = -1,
        forced_width = 14
    },
    power = wibox.widget {
        id = "power",
        widget = wibox.widget.textbox,
        markup = "-- W",
        align = "right",
        forced_width = 45
    },
    time = wibox.widget {
        id = "time",
        widget = wibox.widget.textbox,
        markup = "--",
        align = "right",
        forced_width = 45
    },
}

return battery
