#!/bin/bash

EXIT_PASSWORD="hakunamatata"

# Ask password using popup
input_password=$(zenity --password --title="Acadence Lock" --text="Enter password to exit Acadence Mode")

# If user pressed Cancel
if [[ $? -ne 0 ]]; then
    exit 1
fi

# Check password
if [[ "$input_password" != "$EXIT_PASSWORD" ]]; then
    zenity --error --title="Acadence" --text="❌ Wrong Password. Exit Denied."
    exit 1
fi

# Kill watchdog
pkill -f acadence_watchdog 2>/dev/null
sleep 0.1

# Remove mode indicator
rm -f /tmp/acadence_mode

# Re-enable notifications
gsettings set org.gnome.desktop.notifications show-banners true
sleep 0.2

# Success message
zenity --info --title="Acadence" --text="🔓 Acadence Mode Exited"
