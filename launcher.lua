
local wibox = require("wibox")
local awful = require("awful")

local launcher = {}

launcher.widget = wibox.widget {
    {
        id = "icon",
        widget = wibox.widget.imagebox,
        resize = false,
        image = "/home/tim/.config/awesome/icons/archlogo.svg"
    },
    layout = wibox.container.margin(_, 0, 0, 3);
}

launcher.widget:connect_signal("button::press", function()
    launcher:show()
end)

function launcher:show()

    local function callback(stdout, stderr, exitreason, exitcode)

        local launch_type = stdout:sub(1, 1)
        local selection = stdout:sub(2)

        if launch_type == "a" then
            awful.spawn.spawn(selection)
        end

    end

    awful.spawn.easy_async("/home/tim/.config/awesome/launcher.sh a", callback)
end

return launcher

