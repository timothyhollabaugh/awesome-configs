#!/bin/bash

# gets enabled status for all xinput devices

for device in "$(xinput --list --name-only)"; do
    xinput --list-props "$device" | awk '$0 ~ /Device Enabled/ {print $NF}'
    echo $device $enabled
done
