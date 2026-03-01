#!/bin/bash

PROJECT_ROOT="$(pwd)"
VENV_PATH="$PROJECT_ROOT/venv"
REQ_FILE="$PROJECT_ROOT/requirements.txt"
DB_INIT_SCRIPT="$PROJECT_ROOT/db/init_db.py"

 echo "======================================"
 echo "        Acadence Installer"
 echo "======================================"
 echo ""

# --- Check GNOME ---
if ! command -v gnome-shell &> /dev/null
then
    echo "GNOME not detected. Acadence requires GNOME."
    exit 1
else
    echo "GNOME detected."
fi

# --- Check Brave ---
if ! command -v brave &> /dev/null
then
    echo "Brave browser not found. Install Brave before using Acadence."
else
    echo "Brave detected."
fi

# --- Check notify-send ---
if ! command -v notify-send &> /dev/null
then
    echo "Installing libnotify-bin..."
    sudo apt update
    sudo apt install -y libnotify-bin
else
    echo "notify-send detected."
fi

# --- Check Python ---
if ! command -v python3 &> /dev/null
then
    echo "Python3 not found."
    exit 1
else
    echo "Python3 detected."
fi

echo ""

# --- Create virtual environment if missing ---
if [ ! -d "$VENV_PATH" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_PATH"
fi

# --- Activate venv ---
source "$VENV_PATH/bin/activate"

# --- Upgrade pip ---
pip install --upgrade pip >/dev/null

# --- Install dependencies ---
if [ -f "$REQ_FILE" ]; then
    echo "Installing Python dependencies..."
    pip install -r "$REQ_FILE"
else
    echo "requirements.txt not found."
    deactivate
    exit 1
fi

# --- Initialize database ---
if [ -f "$DB_INIT_SCRIPT" ]; then
    echo "Initializing database..."
    python "$DB_INIT_SCRIPT"
else
    echo "init_db.py not found."
    deactivate
    exit 1
fi

deactivate

echo "Python environment ready."
echo ""

# --- Make scripts executable ---
chmod +x modes/*.sh 2>/dev/null
chmod +x tracking/*.py 2>/dev/null

 echo "Scripts made executable."
 echo ""

# --- Create launcher directory ---
mkdir -p ~/.local/share/applications

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

 echo "Desktop launchers created."
 echo ""
 echo "======================================"
 echo "Installation complete."
 echo "======================================"