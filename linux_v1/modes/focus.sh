#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VENV_PATH="$PROJECT_ROOT/venv"
FACE_MONITOR="$PROJECT_ROOT/tracking/face_monitor.py"

SESSION_FILE="/tmp/acadence_session"
WARNING_FILE="/tmp/acadence_warnings"
WATCHDOG_FILE="/tmp/acadence_watchdog"

# Clean previous state
if [ -f "$WATCHDOG_FILE" ]; then
    PID=$(cat "$WATCHDOG_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
    fi
    rm -f "$WATCHDOG_FILE"
fi

pkill -f "tracking/face_monitor.py" 2>/dev/null

echo "🔴 FOCUS MODE" > /tmp/acadence_mode

# Start session
SESSION_ID=$("$VENV_PATH/bin/python" - <<EOF
import sys
sys.path.append("$PROJECT_ROOT")
from db.session_logger import start_session
print(start_session("FOCUS"))
EOF
)

[[ "$SESSION_ID" =~ ^[0-9]+$ ]] || SESSION_ID=0

echo "$SESSION_ID" > "$SESSION_FILE"
echo 0 > "$WARNING_FILE"

notify-send "Acadence" "🔴 Focus Mode Activated"

gsettings set org.gnome.desktop.notifications show-banners false

pkill -f firefox
pkill -f discord
pkill -f telegram-desktop
pkill -f spotify

brave --profile-directory="Default" &
obsidian &
evince &

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

"$VENV_PATH/bin/python" "$FACE_MONITOR" &