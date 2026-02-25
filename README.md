# Acadence
![GNOME](https://img.shields.io/badge/GNOME-46-blue?logo=gnome)
![Ubuntu](https://img.shields.io/badge/Ubuntu-Tested-orange?logo=ubuntu)
![Python](https://img.shields.io/badge/Python-3.x-blue?logo=python)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Active-success)

A state-aware productivity engine for GNOME.

Acadence transforms your Linux desktop into a structured academic
environment with enforceable modes, live UI feedback, and AI-based
focus monitoring.

Built and tested on Ubuntu GNOME 46.

## Highlights
- Strict Focus Mode
- Face Presence Monitoring (OpenCV)
- Critical Focus Alerts (bypass DND)
- Watchdog-Based Distraction Blocking
- Password-Protected Exit
- Live Top-Bar Mode Indicator
- Isolated Python Virtual Environment

## How Acadence Works
Acadence is built around deterministic lifecycle control.

### Focus Mode
- Disables GNOME notification banners
- Launches Brave (Default profile)
- Starts watchdog (kills distractions every 3 seconds)
- Starts silent face monitor
- Shows state in GNOME top bar
- Sends activation notification

If no face is detected:

- Sends critical notification  
  Message: "You aren't focusing"
- After 30 seconds → forces Exit Mode

### Study Mode
- Moderate enforcement
- Displays study indicator in top bar

### Code Mode
- Launches development environment
- Displays code indicator in top bar

### Exit Mode
- Requires password
- Stops watchdog
- Stops face monitor
- Restores GNOME notifications
- Removes top-bar indicator

## Architecture
```
acadence/
├── modes/
├── tracking/
├── requirements.txt
├── .gitignore
├── LICENSE
├── README.md
├── install.sh
└── launcher.sh
```

## Requirements
- Ubuntu / GNOME 46
- Brave browser
- GNOME Shell Extension: Executor
- Python 3
- libnotify-bin

Install notification support if needed:
```
sudo apt install libnotify-bin
```

## Installation
```
chmod +x install.sh
./install.sh
```

The installer will:

- Create Python virtual environment
- Install Python dependencies from requirements.txt
- Make scripts executable
- Create desktop launchers

## Dependency Management
Acadence uses a Python virtual environment and installs all required
packages from `requirements.txt`.

To generate `requirements.txt` after installing dependencies:
```
source venv/bin/activate
pip freeze > requirements.txt
```

The installer automatically:

- Creates a virtual environment (`venv/`)
- Upgrades pip
- Installs all dependencies from `requirements.txt`

This ensures reproducible installations across systems.

If you add new Python dependencies:
```
pip install <package-name>
pip freeze > requirements.txt
```

Commit the updated `requirements.txt` to the repository.

## Executor Setup
Install the GNOME extension **Executor**.

Command:
```
cat /tmp/acadence_mode
```

Refresh interval: 1 second

## Keyboard Shortcuts (Optional)
GNOME → Settings → Keyboard → Custom Shortcuts

Use absolute paths like:
```
/home/youruser/path/to/acadence/modes/focus.sh
```
Do not use `~`.

## Design Philosophy
- Deterministic lifecycle control
- No extension stacking
- No race-condition switching
- No fragile dconf manipulation
- Modular enforcement architecture

Acadence behaves like a lightweight academic OS layer on top of GNOME.

## Roadmap
- Session analytics
- Break mode instead of hard exit
- Strict exam mode
- Workspace auto-switching
- Systemd integration

## License
MIT