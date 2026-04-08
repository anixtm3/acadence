#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

WATCHDOG_FILE="/tmp/acadence_watchdog"

# Clean previous watchdog
if [ -f "$WATCHDOG_FILE" ]; then
    PID=$(cat "$WATCHDOG_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
    fi
    rm -f "$WATCHDOG_FILE"
fi

notify-send "Acadence" "💻 Code Mode Activated"

echo "💻 CODE MODE" > /tmp/acadence_mode

gsettings set org.gnome.desktop.notifications show-banners false

pkill -f firefox
pkill -f discord
pkill -f telegram-desktop
pkill -f spotify

brave --profile-directory="Profile 2" &
code &
gnome-terminal &

nohup bash -c '
while true; do
    pkill -f firefox
    pkill -f discord
    pkill -f telegram-desktop
    pkill -f spotify
    sleep 3
done
' >/dev/null 2>&1 &

echo $! > "$WATCHDOG_FILE"