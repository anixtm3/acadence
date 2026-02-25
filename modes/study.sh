#!/bin/bash

pkill -f acadence_watchdog 2>/dev/null
sleep 0.1

notify-send "Acadence" "📚 Study Mode Activated"

echo "📚 STUDY MODE" > /tmp/acadence_mode

gsettings set org.gnome.desktop.notifications show-banners false

pkill firefox
pkill discord
pkill telegram-desktop
pkill spotify

brave --profile-directory="Profile 1" &
obsidian &
evince &

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
