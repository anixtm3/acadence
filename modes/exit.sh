#!/bin/bash

EXIT_PASSWORD="hakunamatata"

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

# ✅ Correct password — proceed with exit

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