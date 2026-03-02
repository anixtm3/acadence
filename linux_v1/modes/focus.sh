#!/bin/bash

# ===== PATH SETUP =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VENV_PATH="$PROJECT_ROOT/venv"
FACE_MONITOR="$PROJECT_ROOT/tracking/face_monitor.py"

SESSION_FILE="/tmp/acadence_session"
WARNING_FILE="/tmp/acadence_warnings"
WATCHDOG_FILE="/tmp/acadence_watchdog"

# ======================

# ===== CLEAN PREVIOUS STATE =====
if [ -f "$WATCHDOG_FILE" ]; then
    kill $(cat "$WATCHDOG_FILE") 2>/dev/null
    rm -f "$WATCHDOG_FILE"
fi

pkill -f face_monitor.py 2>/dev/null
sleep 0.2
# =================================

# Mode indicator
echo "🔴 FOCUS MODE" > /tmp/acadence_mode

# ===== START SESSION LOGGING =====
SESSION_ID=$("$VENV_PATH/bin/python" - <<EOF
import sys
sys.path.append("$PROJECT_ROOT")
from db.session_logger import start_session
print(start_session("FOCUS"))
EOF
)

echo "$SESSION_ID" > "$SESSION_FILE"

# Initialize face warning counter
echo 0 > "$WARNING_FILE"
# ==================================

# Notification
notify-send "Acadence" "🔴 Focus Mode Activated"

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
# ===================================

# Start face monitor (background)
"$VENV_PATH/bin/python" "$FACE_MONITOR" &

exit 0
