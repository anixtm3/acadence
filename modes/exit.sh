#!/bin/bash

EXIT_PASSWORD="hakunamatata"

PROJECT_ROOT="$HOME/Documents/GitHub/acadence"
VENV_PATH="$PROJECT_ROOT/venv"
SESSION_FILE="/tmp/acadence_session"
WARNING_FILE="/tmp/acadence_warnings"

# Ask for password using zenity
USER_INPUT=$(zenity --password \
    --title="Exit Acadence" \
    --text="Enter exit password:")

# If user cancelled
if [ $? -ne 0 ]; then
    exit 0
fi

# If wrong password
if [ "$USER_INPUT" != "$EXIT_PASSWORD" ]; then
    zenity --error \
        --title="Access Denied" \
        --text="Incorrect password. Exit denied."
    exit 1
fi

# ===== END SESSION LOGGING =====
if [ -f "$SESSION_FILE" ]; then
    SESSION_ID=$(cat "$SESSION_FILE")

    # Default warnings to 0
    WARNINGS=0
    if [ -f "$WARNING_FILE" ]; then
        WARNINGS=$(cat "$WARNING_FILE")
    fi

    "$VENV_PATH/bin/python" - <<EOF
import sys
sys.path.append("$PROJECT_ROOT")
from db.session_logger import end_session
end_session($SESSION_ID, face_warnings=$WARNINGS)
EOF

    rm -f "$SESSION_FILE"
    rm -f "$WARNING_FILE"
fi
# =================================

# Kill watchdog
pkill -f acadence_watchdog 2>/dev/null

# Kill face monitor
pkill -f face_monitor.py 2>/dev/null

# Remove mode indicator
rm -f /tmp/acadence_mode

# Small delay for clean restore
sleep 0.2

# Re-enable GNOME notification banners
gsettings set org.gnome.desktop.notifications show-banners true

# Success popup
zenity --info \
    --title="Acadence" \
    --text="Acadence exited successfully."

exit 0