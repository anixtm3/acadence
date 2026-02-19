#!/bin/bash

echo "Starting Code Mode..."

pkill -f acadence_watchdog 2>/dev/null

echo "💻 CODE MODE" > /tmp/acadence_mode

gsettings set org.gnome.desktop.notifications show-banners false

pkill firefox
pkill discord
pkill telegram-desktop
pkill spotify

brave --profile-directory="Profile 2" &
code &
gnome-terminal &

bash -c '
acadence_watchdog() {
    while true
    do
        pkill firefox
        pkill discord
        pkill telegram-desktop
        pkill spotify
        sleep 3
    done
}
acadence_watchdog
' &
