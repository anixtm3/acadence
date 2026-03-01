# Acadence

Acadence is a behavior-driven productivity operating layer built on Linux. It enforces deep work through controlled execution modes, distraction blocking, face-based presence monitoring, and persistent session tracking.

This is not a productivity app.
It is an execution environment for disciplined academic work.

---

## Core Philosophy

Acadence is designed around one principle:

> Environment controls behavior.

Instead of relying on willpower, Acadence restructures the operating system environment to eliminate distractions and enforce intentional work sessions.

---

## Features

### 1. Productivity Modes

Acadence provides dedicated execution modes:

* **Focus Mode** – Deep work with face monitoring and session tracking
* **Study Mode** – Structured academic reading environment
* **Code Mode** – Development-focused environment

Each mode:

* Kills distracting applications (Firefox, Discord, Telegram, Spotify)
* Disables GNOME notification banners
* Launches only allowed applications
* Activates a background watchdog to continuously block distractions

---

### 2. Watchdog Enforcement

A background `acadence_watchdog` process runs every 3 seconds and terminates blocked applications if launched.

This ensures environment integrity during active sessions.

---

### 3. Face-Based Discipline System (Focus Mode)

Focus Mode activates a real-time OpenCV face detection monitor.

* If your face is not detected consistently, a warning is issued.
* Warnings are counted.
* If absence exceeds a threshold (30 seconds), forced exit is triggered.

This enforces physical presence and prevents passive distraction.

---

### 4. Persistent Session Tracking

Acadence logs every Focus session to SQLite:

Database: `db/acadence.db`

Session fields:

* id
* mode
* start_time
* end_time
* duration_seconds
* face_warnings
* forced_exit

This enables long-term analytics, accountability, and performance review.

---

## Architecture Overview

```
Mode Script (focus/study/code)
        ↓
Environment Lock (notifications + pkill + watchdog)
        ↓
Optional Face Monitor (Focus Mode)
        ↓
Session Logger (SQLite)
        ↓
Forced Exit Pipeline (if discipline breaks)
```

---

## Project Structure

```
acadence/
├── modes/
│   ├── focus.sh
│   ├── study.sh
│   ├── code.sh
│   └── exit.sh
│
├── tracking/
│   └── face_monitor.py
│
├── db/
│   ├── init_db.py
│   └── session_logger.py
│
├── venv/
└── db/acadence.db
```

---

## Requirements

* Linux (GNOME-based environment recommended)
* Python 3
* OpenCV
* SQLite3
* notify-send
* Brave Browser
* Obsidian
* VS Code
* Evince

---

## Setup

1. Clone the repository
2. Create a Python virtual environment
3. Install dependencies
4. Run `init_db.py` to initialize the database
5. Execute any mode script

Example:

```
bash modes/focus.sh
```

---

## Current Status

Acadence includes:

* Enforced execution modes
* Distraction blocking
* Face-based discipline trigger
* Persistent session logging
* Forced exit control

Planned expansions:

* CLI analytics dashboard
* Weekly performance reports
* Streak system
* Anti-tamper protection
* Remote supervisory architecture

---

## License

MIT License (recommended)

---

## Author

Aniket Dixit
BTech Data Science (2024–2028)

---

Acadence is an experiment in environmental discipline engineering.
