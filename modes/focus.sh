#!/bin/bash

# ===== CONFIG =====
PROJECT_ROOT="$HOME/Documents/GitHub/acadence"
VENV_PATH="$PROJECT_ROOT/venv"
FACE_MONITOR="$PROJECT_ROOT/tracking/face_monitor.py"
# ==================

# Kill previous watchdog and face monitor
pkill -f acadence_watchdog 2>/dev/null
pkill -f face_monitor.py 2>/dev/null
sleep 0.2

# Notification
notify-send "Acadence" "🔴 Focus Mode Activated"

# Mode indicator
echo "🔴 FOCUS MODE" > /tmp/acadence_mode

# Disable GNOME notifications
gsettings set org.gnome.desktop.notifications show-banners false

# Kill distractions immediately
pkill firefox
pkill discord
pkill telegram-desktop
pkill spotify

# Launch allowed apps
brave --profile-directory="Default" &
obsidian &
evince &

# Start watchdog (background)
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

# Start face monitor (silent background)
source "$VENV_PATH/bin/activate"
python "$FACE_MONITOR" &

exit 0