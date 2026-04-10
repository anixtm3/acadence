#!/bin/bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

HASH_FILE="$ACADENCE_ROOT/config/.exit_hash"

FORCE_EXIT=0
[ "$1" == "--force" ] && FORCE_EXIT=1

# ── Authentication ────────────────────────────────────────────────────────────

if [ "$FORCE_EXIT" -eq 0 ]; then
    if [ ! -f "$HASH_FILE" ]; then
        zenity --error --title="Acadence" \
            --text="Exit password not configured.\nRun: bash modes/setup_password.sh"
        exit 1
    fi

    USER_INPUT=$(zenity --password --title="Exit Acadence" --text="Enter exit password:")
    [ $? -ne 0 ] && exit 0

    STORED_HASH=$(cat "$HASH_FILE")
    INPUT_HASH=$(echo -n "$USER_INPUT" | sha256sum | cut -d' ' -f1)

    if [ "$INPUT_HASH" != "$STORED_HASH" ]; then
        zenity --error --title="Access Denied" --text="Incorrect password."
        exit 1
    fi
fi

# ── Teardown order (race-condition safe) ──────────────────────────────────────

# 1. Kill face_monitor FIRST — prevents it from triggering a second exit
acadence_stop_face_monitor

# 2. Kill watchdog — stops enforcement loop
acadence_stop_watchdog

# 2.5 Restore PATH for any child processes started during this exit flow
acadence_disable_path_blockers

# 3. Log session end — /tmp files still exist here so we can read them
if [ -f "$SESSION_FILE" ]; then
    SESSION_ID=$(cat "$SESSION_FILE")
    [[ "$SESSION_ID" =~ ^[0-9]+$ ]] || SESSION_ID=0

    WARNINGS=0
    [ -f "$WARNING_FILE" ] && WARNINGS=$(cat "$WARNING_FILE")

    "$VENV_PYTHON" - <<EOF
import sys
sys.path.append("$ACADENCE_ROOT")
from db.session_logger import end_session
end_session($SESSION_ID, face_warnings=$WARNINGS, forced_exit=$FORCE_EXIT)
EOF

    if [ $? -ne 0 ]; then
        notify-send -u critical "Acadence Error" "Session logging failed — check DB"
    fi
fi

# 4. Clean all state files — last step before UI
acadence_cleanup_state

# 5. Restore notifications
gsettings set org.gnome.desktop.notifications show-banners true

# ── Exit feedback ─────────────────────────────────────────────────────────────

if [ "$FORCE_EXIT" -eq 0 ]; then
    zenity --info --title="Acadence" --text="Session ended. Good work."
else
    notify-send -u critical "Acadence" "Session terminated: face not detected."
fi
