#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VENV_PATH="$PROJECT_ROOT/venv"

SESSION_FILE="/tmp/acadence_session"
WARNING_FILE="/tmp/acadence_warnings"
WATCHDOG_FILE="/tmp/acadence_watchdog"

EXIT_PASSWORD="hakunamatata"

FORCE_EXIT=0
[ "$1" == "--force" ] && FORCE_EXIT=1

if [ "$FORCE_EXIT" -eq 0 ]; then
    USER_INPUT=$(zenity --password --title="Exit Acadence" --text="Enter exit password:")

    [ $? -ne 0 ] && exit 0

    if [ "$USER_INPUT" != "$EXIT_PASSWORD" ]; then
        zenity --error --title="Access Denied" --text="Incorrect password."
        exit 1
    fi
fi

if [ -f "$SESSION_FILE" ]; then
    SESSION_ID=$(cat "$SESSION_FILE")
    [[ "$SESSION_ID" =~ ^[0-9]+$ ]] || SESSION_ID=0

    WARNINGS=0
    [ -f "$WARNING_FILE" ] && WARNINGS=$(cat "$WARNING_FILE")

    if [ -x "$VENV_PATH/bin/python" ]; then
        "$VENV_PATH/bin/python" - <<EOF
import sys
sys.path.append("$PROJECT_ROOT")
from db.session_logger import end_session
end_session($SESSION_ID, face_warnings=$WARNINGS, forced_exit=$FORCE_EXIT)
EOF
    fi

    rm -f "$SESSION_FILE" "$WARNING_FILE"
fi

if [ -f "$WATCHDOG_FILE" ]; then
    PID=$(cat "$WATCHDOG_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
    fi
    rm -f "$WATCHDOG_FILE"
fi

pkill -f "tracking/face_monitor.py" 2>/dev/null
rm -f /tmp/acadence_mode

gsettings set org.gnome.desktop.notifications show-banners true

if [ "$FORCE_EXIT" -eq 0 ]; then
    zenity --info --title="Acadence" --text="Exited successfully."
else
    notify-send -u critical "Acadence" "Session terminated due to inactivity."
fi