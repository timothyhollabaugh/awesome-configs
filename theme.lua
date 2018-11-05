---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local naughty = require("naughty")
local cairo = require( "lgi" ).cairo
local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()


-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"
--
-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

local theme = {}


-- Global defaults {{{

theme.font          = "Fira Sans Medium 10"
--theme.font          = "Zilla Slab Medium 11"

theme.bg_normal     = "#444444" -- "#444851"
theme.bg_focus      = "#1a80b6" -- "#1d90cd" -- "#cccc00" -- "#ffcf44" -- "#444851"
theme.bg_hover      = "#333333"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#ffffff"
theme.fg_focus      = "#ffffff"
theme.fg_hover      = "$ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#999999"

theme.useless_gap   = dpi(10)
theme.border_width  = 0 -- dpi(2)
theme.border_normal = theme.fg_minimize
theme.border_focus  = theme.bg_focus
theme.border_marked = "#91231c"

--theme.wallpaper = "/home/tim/Pictures/lnxpcs/linux-penguins-1920x1080.png"
--theme.wallpaper = "/home/tim/Pictures/lnxpcs/arch-anatomy-1920x1080.png"
--theme.wallpaper = "/home/tim/.config/awesome/wallpapers/3d/XJu51Ly-arch-linux-wallpaper.png"
--theme.wallpaper = "/home/tim/.config/awesome/wallpapers/flat/ArchNumixFlatDark1080p.png"
--theme.wallpaper = "/home/tim/.config/awesome/wallpapers/grey.png"
theme.wallpaper = "/home/tim/.config/awesome/wallpapers/circuits/cyclone_light.png"

--[[
theme.wallpaper = function(s)
    image = gears.surface.load("/home/tim/.config/awesome/wallpapers/3d/XJu51Ly-arch-linux-wallpaper.png")
    naughty.notify({
            title = gears.surface.get_size(image)
        })
    sx = s.geometry.x / gears.surface.get_size(image)
    sy = s.geometry.y / gears.surface.get_size(image)
    cr = cairo.Context()
    cr:scale(0.5, 0.5)
    cr:set_source_surface(image, 0, 0)
    cr.operator = cairo.Operator.SOURCE
    cr:paint()
    cr:set_source(gears.color("#dd3333"))
    cr:rectangle(0, 0, 100, 100)
    cr:fill()
    return image
end
--]]

theme.focus_bar_shape = gears.shape.transform(function(cr, width, height)
    return gears.shape.rounded_rect(cr, width, 2, 0)
end):translate(0, 0)

-- }}}

-- Tooltip {{{

theme.tooltip_bg_color = "#1a1a1a1a"

-- }}}


-- Notifications {{{

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

theme.notification_border_color = theme.bg_normal
theme.notification_shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 2)
end

-- }}}

-- Menu {{{

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(20)
theme.menu_width  = dpi(50)
theme.menu_bg_normal = theme.bg_normal -- "#ffffff88"
theme.menu_bg_focus = theme.bg_focus -- "#ffffff"
theme.menu_fg_normal = theme.fg_normal -- "#11111188"
theme.menu_fg_focus = theme.bg_normal -- "#111111"

-- }}}

-- Layout {{{

theme.layout_fairh = themes_path.."default/layouts/fairhw.png"
theme.layout_fairv = themes_path.."default/layouts/fairvw.png"
theme.layout_floating  = themes_path.."default/layouts/floatingw.png"
theme.layout_magnifier = themes_path.."default/layouts/magnifierw.png"
theme.layout_max = themes_path.."default/layouts/maxw.png"
theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path.."default/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path.."default/layouts/tileleftw.png"
theme.layout_tile = themes_path.."default/layouts/tilew.png"
theme.layout_tiletop = themes_path.."default/layouts/tiletopw.png"
theme.layout_spiral  = themes_path.."default/layouts/spiralw.png"
theme.layout_dwindle = themes_path.."default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path.."default/layouts/cornernww.png"
theme.layout_cornerne = themes_path.."default/layouts/cornernew.png"
theme.layout_cornersw = themes_path.."default/layouts/cornersww.png"
theme.layout_cornerse = themes_path.."default/layouts/cornersew.png"

-- }}}

-- Taglist {{{
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]

--theme.taglist_spacing = 10

theme.taglist_shape = theme.focus_bar_shape
theme.taglist_bg_occupied = "#666666"

-- }}}

-- Tasklist {{{

theme.tasklist_disable_icon = false
theme.tasklist_align = "center"
theme.tasklist_shape = theme.focus_bar_shape

-- }}}

-- Titlebar {{

-- Define the image to load

theme.titlebar_fg_normal = "#aaaaaa"

theme.titlebar_close_button_normal = "/home/tim/.config/awesome/icons/close.svg"
theme.titlebar_close_button_focus  = "/home/tim/.config/awesome/icons/close.svg"

theme.titlebar_minimize_button_normal = "/home/tim/.config/awesome/icons/minimize.svg"
theme.titlebar_minimize_button_focus  = "/home/tim/.config/awesome/icons/minimize.svg"

theme.titlebar_ontop_button_normal_inactive = "/home/tim/.config/awesome/icons/shade.svg"
theme.titlebar_ontop_button_focus_inactive  = "/home/tim/.config/awesome/icons/shade.svg"
theme.titlebar_ontop_button_normal_active = "/home/tim/.config/awesome/icons/unshade.svg"
theme.titlebar_ontop_button_focus_active  = "/home/tim/.config/awesome/icons/unshade.svg"

theme.titlebar_sticky_button_normal_inactive = "/home/tim/.config/awesome/icons/pin.svg"
theme.titlebar_sticky_button_focus_inactive  = "/home/tim/.config/awesome/icons/pin.svg"
theme.titlebar_sticky_button_normal_active = "/home/tim/.config/awesome/icons/unpin.svg"
theme.titlebar_sticky_button_focus_active  = "/home/tim/.config/awesome/icons/unpin.svg"

theme.titlebar_floating_button_normal_inactive = "/home/tim/.config/awesome/icons/windowed.svg"
theme.titlebar_floating_button_focus_inactive  = "/home/tim/.config/awesome/icons/windowed.svg"
theme.titlebar_floating_button_normal_active = "/home/tim/.config/awesome/icons/tiled.svg"
theme.titlebar_floating_button_focus_active  = "/home/tim/.config/awesome/icons/tiled.svg"

theme.titlebar_maximized_button_normal_inactive = "/home/tim/.config/awesome/icons/maximize.svg"
theme.titlebar_maximized_button_focus_inactive  = "/home/tim/.config/awesome/icons/maximize.svg"
theme.titlebar_maximized_button_normal_active = "/home/tim/.config/awesome/icons/unmaximize.svg"
theme.titlebar_maximized_button_focus_active  = "/home/tim/.config/awesome/icons/unmaximize.svg"

theme.titlebar_bg_focus = theme.bg_normal -- "#444851"

-- Width is 1920 so it always goes all the way across
-- There does not seem to be a way to get the width of the client
theme.titlebar_bgimage_focus = gears.surface.load_from_shape(1920, 30,
    gears.shape.transform(function(cr, width, height)
        return gears.shape.rounded_rect(cr, width, 2, 0)
    end):translate(0, 0), theme.bg_focus)

-- }}}

-- Awesome Icon {{{

-- Generate Awesome icon:
--theme.awesome_icon = theme_assets.awesome_icon(
    --theme.menu_height, theme.bg_focus, theme.fg_focus
--)

theme.awesome_icon = "/home/tim/.config/awesome/icons/archlogo.svg"

-- }}}


-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = "Paper"

function theme:find_icon(icon)
    return "/usr/share/icons/"..self.icon_theme.."/"..icon
end

-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
theme.hotkeys_modifiers_fg = theme.bg_focus

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
