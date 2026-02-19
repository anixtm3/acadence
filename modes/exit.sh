#!/bin/bash

echo "Exiting Acadence Mode..."

# Kill watchdog
pkill -f acadence_watchdog 2>/dev/null

# Remove indicator
rm -f /tmp/acadence_mode

# Re-enable notifications
gsettings set org.gnome.desktop.notifications show-banners true

echo "Mode exited."
