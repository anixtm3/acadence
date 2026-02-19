# Acadence (v0.1)

A state-aware productivity mode engine for GNOME.

Acadence transforms your Linux desktop into a structured academic
environment with enforceable modes, live UI feedback, and browser
profile isolation.

Built and tested on **Ubuntu GNOME 46**.

## Features

-   🔴 Focus Mode (strict enforcement)
-   📚 Study Mode
-   💻 Code Mode
-   🔓 Clean Exit Mode

### Core Capabilities

-   App enforcement watchdog
-   Brave browser profile isolation
-   GNOME top-bar live mode indicator (via Executor)
-   Notification suppression during active modes
-   Clean mode switching (no stacking, no stale state)

## How It Works

Acadence uses:

-   Background watchdog process to suppress distractions
-   Separate Brave profiles per mode
-   GNOME Executor extension for live state display
-   `/tmp/acadence_mode` file for mode state management

The top-bar indicator is powered by:

    cat /tmp/acadence_mode

If the file exists → mode name appears\
If removed → indicator disappears

## Project Structure

    acadence/
    ├── launcher.sh
    ├── install.sh
    └── modes/
        ├── focus.sh
        ├── study.sh
        ├── code.sh
        └── exit.sh

## Requirements

-   Ubuntu / GNOME 46
-   Brave browser
-   GNOME Shell Extension: Executor
-   Git (optional)

## Setup

### Step1: Install Executor Extension

Install from GNOME Extension Manager and create one command:

Name: Acadence Mode

Command: cat /tmp/acadence_mode

Interval: 1

Position: Left (recommended)

### Step 2: Make Scripts Executable

    chmod +x modes/*.sh

### Step 3: Launch Modes

Example:

    ./modes/focus.sh

## Future Improvements

-   Workspace auto-switching
-   Timer-based sessions
-   Session logging
-   Passphrase unlock
-   Installation automation

## License

MIT
