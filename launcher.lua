
local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

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
        awful.spawn.spawn(stdout)
    end

    awful.spawn.easy_async("/home/tim/.config/awesome/launcher.sh a", callback)
end

function launcher:tags()

    local tags = awful.screen.focused().tags

    local function callback(stdout, stderr, exitreason, exitcode)

        stdout = stdout:sub(1, -2)

        local found = false

        for i, tag in pairs(tags) do
            if (tag.name == stdout) then
                tag:view_only()
                found = true
            end
        end


        if (found == false and stdout:len() > 0) then
            awful.tag.add(stdout, { screen = awful.screen.focused() }):view_only()
        end
    end

    local show_tags = ""

    for i, tag in pairs(tags) do
        show_tags = show_tags.."\n"..tag.name..";;"..tag.name
    end
end

return launcher

