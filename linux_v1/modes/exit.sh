#!/bin/bash

# ===== PATH SETUP =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VENV_PATH="$PROJECT_ROOT/venv"

SESSION_FILE="/tmp/acadence_session"
WARNING_FILE="/tmp/acadence_warnings"
WATCHDOG_FILE="/tmp/acadence_watchdog"

EXIT_PASSWORD="hakunamatata"

# ===== FORCE MODE CHECK =====
FORCE_EXIT=0
if [ "$1" == "--force" ]; then
    FORCE_EXIT=1
fi
# ============================

# ===== PASSWORD (ONLY IF NOT FORCED) =====
if [ "$FORCE_EXIT" -eq 0 ]; then
    USER_INPUT=$(zenity --password \
        --title="Exit Acadence" \
        --text="Enter exit password:")

    # Cancelled
    if [ $? -ne 0 ]; then
        exit 0
    fi

    # Wrong password
    if [ "$USER_INPUT" != "$EXIT_PASSWORD" ]; then
        zenity --error \
            --title="Access Denied" \
            --text="Incorrect password. Exit denied."
        exit 1
    fi
fi
# =========================================

# ===== END SESSION LOGGING =====
if [ -f "$SESSION_FILE" ]; then
    SESSION_ID=$(cat "$SESSION_FILE")

    WARNINGS=0
    if [ -f "$WARNING_FILE" ]; then
        WARNINGS=$(cat "$WARNING_FILE")
    fi

    "$VENV_PATH/bin/python" - <<EOF
import sys
sys.path.append("$PROJECT_ROOT")
from db.session_logger import end_session
end_session($SESSION_ID, face_warnings=$WARNINGS, forced_exit=$FORCE_EXIT)
EOF

    rm -f "$SESSION_FILE"
    rm -f "$WARNING_FILE"
fi
# =================================

# ===== KILL WATCHDOG =====
if [ -f "$WATCHDOG_FILE" ]; then
    WATCHDOG_PID=$(cat "$WATCHDOG_FILE")
    kill "$WATCHDOG_PID" 2>/dev/null
    rm -f "$WATCHDOG_FILE"
fi

# Kill face monitor
pkill -f face_monitor.py 2>/dev/null

# Remove mode indicator
rm -f /tmp/acadence_mode

sleep 0.2

# Re-enable GNOME notifications
gsettings set org.gnome.desktop.notifications show-banners true

# ===== EXIT NOTIFICATION =====
if [ "$FORCE_EXIT" -eq 0 ]; then
    zenity --info \
        --title="Acadence" \
        --text="Acadence exited successfully."
else
    notify-send \
        -u critical \
        "Acadence" \
        "Focus session terminated due to inactivity."
fi
# =============================

exit 0
