#!/bin/bash

# Kill previous watchdog first
pkill -f acadence_watchdog 2>/dev/null
sleep 0.1

# Send notification
notify-send "Acadence" "🔴 Focus Mode Activated"

# Set top bar indicator
echo "🔴 FOCUS MODE" > /tmp/acadence_mode

# Disable notifications for focus session
gsettings set org.gnome.desktop.notifications show-banners false

# Initial cleanup
pkill firefox
pkill discord
pkill telegram-desktop
pkill spotify

# Launch allowed apps
brave --profile-directory="Default" &
obsidian &
evince &

# Start watchdog
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