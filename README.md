# Acadence

Acadence is a cross-platform productivity enforcement layer designed to run on top of existing operating systems.

It does not replace your OS.
It controls behavioral state inside it.

---

## What Acadence Is

Acadence is a discipline engine that enforces structured productivity modes such as:

* Focus Mode
* Study Mode
* Code Mode

It blocks distracting applications, monitors presence using computer vision, logs session data, and enforces controlled exits.

The goal is behavioral consistency — not convenience.

---

## Architecture

Current structure:

```
acadence/
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
├── db/
│   ├── init_db.py
│   └── session_logger.py
│
├── dashboard/
│   ├── backend/
│   │   └── main.py
│   └── frontend/
│       ├── index.html
│       ├── script.js
│       └── style.css
│
├── requirements.txt
└── install.sh
```

### Core Components

**Mode Engine (Bash)**
Controls system state, blocks apps, manages watchdog process.

**Face Monitor (Python + OpenCV)**
Detects absence and triggers forced exit.

**Session Logger (SQLite)**
Tracks:

* Mode
* Start time
* End time
* Duration
* Face warnings
* Forced exit flag

**Watchdog System**
Detached PID-based background process that continuously blocks restricted applications.

---

## How Modes Work

When a mode starts:

1. Previous watchdog is killed.
2. Distraction apps are terminated.
3. GNOME notifications are disabled.
4. Allowed apps are launched.
5. A detached watchdog loop begins.
6. (Focus Mode only) Face monitor activates.

If no face is detected for 30 seconds:

* `exit.sh --force` is triggered.
* Session is logged with `forced_exit = 1`.
* Watchdog is terminated.
* System state is restored.

Manual exit requires password authentication.

---

## Installation (Linux - GNOME Required)

From project root:

```
bash install.sh
```

Installer will:

* Verify GNOME
* Check required system tools
* Create Python virtual environment
* Install dependencies
* Initialize SQLite database
* Create desktop launchers

---

## Requirements

* Ubuntu / GNOME-based environment
* Python 3
* Brave browser
* OpenCV (installed via requirements.txt)
* notify-send

---

## Design Philosophy

Acadence is not a productivity assistant.

It is a behavioral enforcement layer.

It reduces system freedom during structured work sessions to eliminate distraction paths.

Discipline is enforced at the environment level.

---

## Roadmap

* Refactor into Core + OS Adapter architecture
* Windows adapter implementation
* Behavioral analytics engine
* Adaptive enforcement model
* Local AI integration for pattern analysis

---

## License

(To be defined)

---

Acadence is an evolving systems project focused on disciplined computing environments.
