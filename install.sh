#!/bin/bash

PROJECT_ROOT="$(pwd)"
VENV_PATH="$PROJECT_ROOT/venv"

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

# --- Check notify-send ---
if ! command -v notify-send &> /dev/null
then
    echo "⚠ notify-send not found. Installing libnotify-bin..."
    sudo apt install -y libnotify-bin
else
    echo "✅ notify-send detected."
fi

# --- Check Python ---
if ! command -v python3 &> /dev/null
then
    echo "❌ Python3 not found."
    exit 1
else
    echo "✅ Python3 detected."
fi

# --- Create venv if missing ---
if [ ! -d "$VENV_PATH" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# --- Install dependencies ---
source "$VENV_PATH/bin/activate"
pip install --upgrade pip >/dev/null
pip install opencv-python >/dev/null
deactivate

echo "✅ Python environment ready."

echo ""

# --- Make scripts executable ---
chmod +x modes/*.sh
chmod +x tracking/*.py
echo "✅ Mode and tracking scripts made executable."

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
Exec=$PROJECT_ROOT/modes/$SCRIPT
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