local wibox = require("wibox")
local naughty = require("naughty")
local spawn = require("awful.spawn")
local gears = require("gears")

local input = {}

function input.widget(icon, device_name, interval)
    local widget = {

        update = function(self)
            spawn.easy_async_with_shell(
                "xinput --list-props \""..self.widget.device.."\" | awk '$0 ~ /Device Enabled/ {print $NF}'",
                function (stdout, stderr)
                    if (string.match(stdout, "1")) then
                        self.widget.enabled = true;
                        self.widget:get_children_by_id("text")[1]:set_markup("✓")
                    else
                        self.widget.enabled = false;
                        self.widget:get_children_by_id("text")[1]:set_markup("✗")
                    end
                end
            )
        end,

        widget = wibox.widget {

            enabled = false,
            device = device_name,

            {
                {
                    id = "icon",
                    widget = wibox.widget.imagebox,
                    image = icon,
                    resize = false,
                },

                widget = wibox.container.margin,
                left = 6,
                top = 5,
            },

            {
                id = "text",
                widget = wibox.widget.textbox,
                markup = "?",
                align = "right"
            },

            layout = wibox.layout.fixed.horizontal,
        },
    }

    widget.widget:connect_signal("button::press", function (self)

        local command = "xinput enable \""..self.device.."\""

        if self.enabled then
            command = "xinput disable \""..self.device.."\""
        end

        spawn.spawn(command)

        widget:update()
    end)

    gears.timer {
        timeout = 2,
        autostart = true,
        callback = function () widget:update() end
    }

    return widget
end

function input.async(format, warg, callback)
end

function input.worker(format, warg)

    local enabled = nil

    input.async(format, warg,
        function (stdout)
            enabled = 2
            naughty.notify({
                    title = "callback",
                    text = stdout
                })
        end
        )

    local starttime = os.time();
    while enabled == nil and os.time()-starttime < 1 do end

    naughty.notify({
            title = warg,
            text = enabled
        })

    return enabled
end

return input
