#!/bin/bash

scrot /tmp/screenshot.png
convert /tmp/screenshot.png -blur 0x3 /tmp/screenshotblur.png
i3lock -i /tmp/screenshotblur.png
#i3lock -i /home/tim/.config/awesome/wallpapers/3d/XJu51Ly-arch-linux-wallpaper.png

