# Acadence

Acadence is a behavior-driven productivity operating layer built for Linux (GNOME). It enforces deep work through controlled execution modes, distraction blocking, face-based presence monitoring, and persistent session tracking.

Acadence is not a productivity app.
It is an execution environment designed to reduce reliance on willpower and instead engineer discipline through system control.

---

## Philosophy

Acadence operates on a simple principle:

Environment shapes behavior.

Rather than trusting motivation, Acadence modifies the operating environment to remove distractions, enforce intentional sessions, and track behavioral integrity.

---

## Core Features

### Productivity Modes

Acadence provides dedicated execution modes:

* Focus Mode — Deep work with face monitoring and session tracking
* Study Mode — Structured academic reading environment
* Code Mode — Development-focused environment

Each mode:

* Terminates distracting applications (Firefox, Discord, Telegram, Spotify)
* Disables GNOME notification banners
* Launches only approved applications
* Activates a background watchdog that continuously enforces restrictions

### Watchdog Enforcement

A background `acadence_watchdog` process runs every 3 seconds and terminates blocked applications if launched during an active session.

This ensures environmental integrity throughout the session.

### Face-Based Discipline System (Focus Mode)

Focus Mode activates a real-time OpenCV face detection monitor.

* If your face is not detected consistently, a warning notification is issued.
* Warnings are counted during the session.
* If absence exceeds the configured threshold (30 seconds), a forced exit is triggered.

This enforces physical presence and prevents passive disengagement.

### Persistent Session Tracking

All Focus sessions are logged to a local SQLite database.

Database location:

`db/acadence.db`

Each session stores:

* id
* mode
* start_time
* end_time
* duration_seconds
* face_warnings
* forced_exit

This enables long-term accountability, analytics, and performance evaluation.

---

## Architecture Overview

```
Mode Script (focus / study / code)
        ↓
Environment Lock (notifications disabled + pkill + watchdog)
        ↓
Optional Face Monitor (Focus Mode only)
        ↓
Session Logger (SQLite)
        ↓
Forced Exit Pipeline (if discipline conditions fail)
```

---

## Project Structure

```
acadence/
├── db/
│   ├── init_db.py
│   ├── session_logger.py
│   └── acadence.db        # generated at runtime (ignored by git)
│
├── modes/
│   ├── focus.sh
│   ├── study.sh
│   ├── code.sh
│   └── exit.sh
│
├── tracking/
│   └── face_monitor.py
│
├── install.sh
├── requirements.txt
├── .gitignore
├── LICENSE
└── README.md
```

Note: `acadence.db` is generated locally and should not be committed to version control.

---

## Requirements

* Linux (GNOME recommended)
* Python 3
* OpenCV
* SQLite3
* notify-send (libnotify-bin)
* Brave Browser
* Obsidian
* Visual Studio Code
* Evince

---

## Installation

1. Clone the repository
2. Run the installer:

```
bash install.sh
```

The installer will:

* Create a Python virtual environment
* Install dependencies from `requirements.txt`
* Initialize the SQLite database
* Make scripts executable
* Create desktop launchers

---

## Running Modes

Modes can be launched via desktop entries or directly:

```
bash modes/focus.sh
bash modes/study.sh
bash modes/code.sh
bash modes/exit.sh
```

---

## Data Reset

To reset session history:

```
rm db/acadence.db
python db/init_db.py
```

---

## Roadmap

Planned expansions:

* CLI analytics dashboard
* Weekly performance reports
* Streak system
* Anti-tamper protection
* Remote supervisory architecture

---

## License

MIT License

---

## Author

Aniket Dixit
BTech Data Science (2024–2028)

---

Acadence is an experiment in environmental discipline engineering.
