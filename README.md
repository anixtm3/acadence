# Acadence

A state-aware productivity mode engine for GNOME.

Acadence transforms your Linux desktop into a structured academic
environment with enforceable modes, live UI feedback, and instant
keyboard switching.

Built and tested on **Ubuntu GNOME 46**.

## ✨ Features

-   🔴 Focus Mode (strict enforcement)
-   📚 Study Mode
-   💻 Code Mode
-   🔓 Exit Mode
-   ⌨ Global keyboard shortcuts
-   🧠 Live top-bar state indicator
-   🛡 Active distraction suppression (watchdog)
-   🔄 Clean mode switching (no stacking / no ghost states)

## 🧠 How It Works

Acadence is built on three core components:

### 1️⃣ Watchdog Enforcement

Each mode starts a background watchdog that:

-   Kills distracting applications
-   Runs continuously
-   Stops cleanly when switching modes

The watchdog is safely terminated before any new mode starts.

### 2️⃣ Live Top-Bar Indicator (Executor)

Acadence uses the GNOME **Executor** extension with this command:
```
cat /tmp/acadence_mode
```

Behavior:

-   If `/tmp/acadence_mode` exists → its contents are shown in the top
    bar
-   If removed → indicator disappears
-   Switching modes simply rewrites that file

This avoids fragile dconf manipulation and ensures stable state
switching.

### 3️⃣ Keyboard Shortcuts

Default shortcuts:

|      Shortcut       |   Mode   |
|---------------------|----------|
| **Shift + Alt + F** | 🔴 Focus |
| **Shift + Alt + S** | 📚 Study |
| **Shift + Alt + C** | 💻 Code  |
| **Shift + Alt + E** | 🔓 Exit  |
Shortcuts run the corresponding scripts directly.

## 📦 Project Structure
```
acadence/
├── launcher.sh
├── install.sh
└── modes/
    ├── focus.sh
    ├── study.sh
    ├── code.sh
    └── exit.sh
```

## ⚙ Requirements

-   Ubuntu / GNOME 46
-   Brave browser
-   GNOME Shell Extension: Executor
-   libnotify-bin (for notifications)

Install notifications support if needed:
```
sudo apt install libnotify-bin
```

## 🔧 Setup

### 1️⃣ Install Executor Extension

Install via GNOME Extension Manager.

Create one command:

Name: `Acadence Mode`

Command: `cat /tmp/acadence_mode`

Interval: `1`

Position: `Left` (recommended)

### 2️⃣ Run Installer
```
chmod +x install.sh
./install.sh
```

This will:
-   Make scripts executable
-   Create desktop launchers
-   Guide Executor setup

### 3️⃣ Optional: Add Keyboard Shortcuts

In GNOME:

Settings → Keyboard → Custom Shortcuts

Use absolute paths like:
```
/home/youruser/path/to/acadence/modes/focus.sh
```

Do not use `~`.

## 🔴 Focus Mode

-   Disables notifications
-   Launches Brave (Focus profile)
-   Starts watchdog
-   Shows 🔴 in top bar
-   Sends activation notification

## 📚 Study Mode

-   Moderate enforcement
-   Uses Study Brave profile
-   Shows 📚 in top bar

## 💻 Code Mode

-   Launches VS Code + Terminal
-   Uses Code Brave profile
-   Shows 💻 in top bar

## 🔓 Exit Mode

-   Stops watchdog
-   Restores notifications
-   Removes top-bar indicator
-   Sends exit confirmation notification

## 🛠 Design Principles

-   No fragile dconf rewriting
-   No extension state stacking
-   No race-condition switching
-   Deterministic lifecycle control
-   Minimal GNOME intrusion

Acadence behaves like a lightweight OS layer on top of GNOME.

## 🚀 Future Improvements

-   Workspace auto-switch per mode
-   Timer-based Focus sessions
-   Session logging
-   Passphrase unlock for Focus
-   Installation automation for Brave profiles
-   Systemd integration

## 📜 License

MIT
