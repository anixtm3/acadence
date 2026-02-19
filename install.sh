#!/bin/bash

echo "======================================"
echo "        Acadence Installer"
echo "======================================"
echo ""

# --- Check GNOME ---
if ! command -v gnome-shell &> /dev/null
then
    echo "❌ GNOME not detected. Acadence requires GNOME."
    exit 1
else
    echo "✅ GNOME detected."
fi

# --- Check Brave ---
if ! command -v brave &> /dev/null
then
    echo "⚠ Brave browser not found."
    echo "Install Brave before using Acadence."
else
    echo "✅ Brave detected."
fi

echo ""

# --- Make scripts executable ---
chmod +x modes/*.sh
echo "✅ Mode scripts made executable."

echo ""

# --- Create launcher directory ---
mkdir -p ~/.local/share/applications

# --- Create .desktop launchers ---

create_launcher () {
    NAME=$1
    SCRIPT=$2

    cat > ~/.local/share/applications/acadence-$NAME.desktop <<EOF
[Desktop Entry]
Version=1.0
Name=Acadence $NAME
Exec=$(pwd)/modes/$SCRIPT
Type=Application
Terminal=false
Categories=Utility;
EOF

    chmod +x ~/.local/share/applications/acadence-$NAME.desktop
}

create_launcher "Focus" "focus.sh"
create_launcher "Study" "study.sh"
create_launcher "Code" "code.sh"
create_launcher "Exit" "exit.sh"

echo "✅ Desktop launchers created."

echo ""
echo "======================================"
echo "Next Steps:"
echo "1. Install GNOME extension: Executor"
echo "2. Configure it with command:"
echo "   cat /tmp/acadence_mode"
echo "3. Set refresh interval to 1 second"
echo ""
echo "Then launch Acadence from your app menu."
echo "======================================" 
