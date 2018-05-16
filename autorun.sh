#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

killall compton
run compton --config /home/tim/.config/compton.conf

run /home/tim/scripts/wacomsetup.sh

run nm-applet

run xautolock -locker /home/tim/.config/awesome/lock.sh -time 10

