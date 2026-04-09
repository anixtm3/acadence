#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VENV_PATH="$PROJECT_ROOT/venv"

SESSION_FILE="/tmp/acadence_session"
WARNING_FILE="/tmp/acadence_warnings"
WATCHDOG_FILE="/tmp/acadence_watchdog"

# Clean previous watchdog
if [ -f "$WATCHDOG_FILE" ]; then
    OLD_PID=$(cat "$WATCHDOG_FILE")
    kill -9 "$OLD_PID" 2>/dev/null
    pkill -P "$OLD_PID" 2>/dev/null
    rm -f "$WATCHDOG_FILE"
fi

notify-send "Acadence" "💻 Code Mode Activated"
echo "💻 CODE MODE" > /tmp/acadence_mode

# Start session
SESSION_ID=$("$VENV_PATH/bin/python" - <<EOF
import sys
sys.path.append("$PROJECT_ROOT")
from db.session_logger import start_session
print(start_session("CODE"))
EOF
)

[[ "$SESSION_ID" =~ ^[0-9]+$ ]] || SESSION_ID=0

echo "$SESSION_ID" > "$SESSION_FILE"
echo 0 > "$WARNING_FILE"

gsettings set org.gnome.desktop.notifications show-banners false

# Initial kill
pkill -9 -f firefox
pkill -9 -f discord
pkill -9 -f telegram
pkill -9 -f spotify

# Watchdog
nohup bash -c '
while true; do
    pkill -9 -f firefox
    pkill -9 -f discord
    pkill -9 -f telegram
    pkill -9 -f spotify
    sleep 3
done
' >/dev/null 2>&1 &

WATCHDOG_PID=$!
echo $WATCHDOG_PID > "$WATCHDOG_FILE"

sleep 0.5
kill -0 $WATCHDOG_PID 2>/dev/null || notify-send "Acadence Error" "Watchdog failed!"