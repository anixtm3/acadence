#!/bin/bash

# Kill watchdog first
pkill -f acadence_watchdog 2>/dev/null
sleep 0.1

# Remove top bar indicator
rm -f /tmp/acadence_mode

# Re-enable notifications
gsettings set org.gnome.desktop.notifications show-banners true
sleep 0.2

# Send exit notification
notify-send "Acadence" "🔓 Acadence Mode Exited"