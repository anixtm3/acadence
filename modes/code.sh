#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VENV_PATH="$PROJECT_ROOT/venv"

SESSION_FILE="/tmp/acadence_session"
WARNING_FILE="/tmp/acadence_warnings"

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

# Start session (no face monitor, but still log sessions)
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

pkill -f firefox
pkill -f discord
pkill -f telegram-desktop
pkill -f spotify

ALLOWED_BRAVE_PROFILE="Profile 2"

nohup bash -c "
ALLOWED_BRAVE_PROFILE=\"$ALLOWED_BRAVE_PROFILE\"
while true; do
    pkill -f firefox
    pkill -f discord
    pkill -f telegram-desktop
    pkill -f spotify

    # Brave (Snap) often does NOT expose --profile-directory in process argv.
    # So we enforce profile by only allowing Brave instances launched via
    # `modes/open_brave.sh`, which injects a recognizable flag.
    if command -v pgrep >/dev/null 2>&1; then
        if pgrep -af \"brave|brave-browser\" >/dev/null 2>&1; then
            if ! pgrep -af \"brave|brave-browser\" | grep -qF -- \"--acadence-profile=\$ALLOWED_BRAVE_PROFILE\"; then
                pkill -f \"brave|brave-browser\" 2>/dev/null
            fi
        fi
    fi

    sleep 3
done
" >/dev/null 2>&1 &

echo $! > "$WATCHDOG_FILE"