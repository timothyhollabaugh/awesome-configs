local wibox = require('wibox')
local naughty = require('naughty')
local debug = require('gears.debug')
local awful = require('awful')
local beautiful = require("beautiful")

function build(widget)
    local container = wibox.container.background(widget)
    --container.bg = beautiful.bg_normal

    container:connect_signal(
        'mouse::enter',
        function()
            container.bg = beautiful.bg_hover
        end
    )

    container:connect_signal(
        'mouse::leave',
        function()
            --container.bg = beautiful.bg_normal
            container.bg = "#00000000"
        end
    )

    container:connect_signal(
        'button::press',
        function()
            container.bg = beautiful.bg_focus
        end
    )

    container:connect_signal(
        'button::release',
        function()
            --container.bg = beautiful.bg_normal
            container.bg = "#00000000"
        end
    )

    return container
end

return build
