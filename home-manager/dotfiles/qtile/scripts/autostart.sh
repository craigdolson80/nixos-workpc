#! /bin/sh

#xrandr --output eDP-1 --off
xrandr -s 1920x1080
picom &
nm-applet &
#lxsession &
nitrogen --restore &
volumeicon &
udiskie -t &
flameshot &

