
local cairo = require("lgi").cairo

local gears = require("gears")
local beautiful = require("beautiful")
beautiful.init("/home/tim/.config/awesome/theme.lua")

local wallpaper = {}

function wallpaper.set_wallpaper(s)
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

return wallpaper
