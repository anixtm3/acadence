#!/bin/bash

# ===== PATH SETUP =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

WATCHDOG_FILE="/tmp/acadence_watchdog"

# ===== CLEAN PREVIOUS STATE =====
if [ -f "$WATCHDOG_FILE" ]; then
    kill $(cat "$WATCHDOG_FILE") 2>/dev/null
    rm -f "$WATCHDOG_FILE"
fi
sleep 0.2
# =================================

notify-send "Acadence" "💻 Code Mode Activated"

echo "💻 CODE MODE" > /tmp/acadence_mode

gsettings set org.gnome.desktop.notifications show-banners false

pkill firefox
pkill discord
pkill telegram-desktop
pkill spotify

brave --profile-directory="Profile 2" &
code &
gnome-terminal &

# ===== START DETACHED WATCHDOG =====
nohup bash -c '
while true; do
    pkill firefox
    pkill discord
    pkill telegram-desktop
    pkill spotify
    sleep 3
done
' >/dev/null 2>&1 &

echo $! > "$WATCHDOG_FILE"
