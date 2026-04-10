#!/bin/bash
# Acadence watchdog — runs as a background process, kills blocked apps every 3s
# Usage: watchdog.sh "firefox|discord|telegram|spotify"
# PID stored in /tmp/acadence_watchdog by the caller

BLOCKED_PATTERN="${1:-firefox|discord|telegram|spotify}"
HEARTBEAT_FILE="/tmp/acadence_watchdog_heartbeat"

while true; do
    echo "$(date +%s)" > "$HEARTBEAT_FILE"

    IFS='|' read -ra APPS <<< "$BLOCKED_PATTERN"
    for app in "${APPS[@]}"; do
        pkill -9 -f "$app" 2>/dev/null
    done

    sleep 3
done
