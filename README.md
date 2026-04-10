# Acadence

Acadence is a Linux productivity enforcement system with three main layers:

1. Shell-based mode control (focus, study, code, exit)
2. Python services (session logging, face monitoring, FastAPI dashboard backend)
3. Electron desktop wrapper for the dashboard UI

It is currently implemented for GNOME-based Linux environments.

## Current Repository Structure

```
acadence/
├── config/
│   └── .exit_hash                # created after password setup
├── dashboard/
│   ├── backend/
│   │   └── main.py               # FastAPI API + static hosting
│   └── frontend/
│       ├── index.html            # dashboard UI
│       ├── script.js             # dashboard logic + polling
│       └── style.css             # UI component styles
├── db/
│   ├── init_db.py                # creates SQLite schema
│   └── session_logger.py         # start/end session writes
├── electron/
│   ├── main.js                   # launches backend + BrowserWindow
│   └── preload.js                # currently empty
├── modes/
│   ├── code.sh
│   ├── exit.sh
│   ├── focus.sh
│   ├── setup_password.sh
│   ├── study.sh
│   ├── watchdog.sh
│   └── lib/
│       └── common.sh             # shared mode runtime logic
├── tracking/
│   └── face_monitor.py           # OpenCV face absence enforcement
├── install.sh                    # Linux installer/bootstrap
├── package.json                  # Electron scripts
├── requirements.txt              # Python dependencies
├── LICENSE
└── README.md
```

## What Acadence Does Today

### Mode Engine (Bash)
- Focus mode starts session, blocks configured apps, starts watchdog, starts face monitor
- Study mode starts session, blocks configured apps, starts watchdog
- Code mode starts session, blocks configured apps, starts watchdog
- Exit mode authenticates user via password (Zenity), ends session, restores state

### Enforcement
- Watchdog loop runs every 3 seconds and kills blocked processes using pattern matching
- Focus mode face monitor warns on prolonged missed detections and force-exits after threshold
- GNOME notification banners are disabled while a mode is active and restored on exit

### Session Tracking
- SQLite database at db/acadence.db
- Table: sessions
- Stored fields:
	- mode
	- start_time
	- end_time
	- duration_seconds
	- face_warnings
	- forced_exit

### Dashboard
- FastAPI backend serves both API and frontend
- Frontend polls status and session history every 2 seconds
- Controls exposed in UI:
	- Start Focus / Study / Code
	- Exit active mode
	- Refresh history

### Electron App
- Electron starts Python backend (dashboard/backend/main.py)
- Then opens BrowserWindow at http://127.0.0.1:8000

## Runtime Flow

### Starting a mode
1. Source shared logic from modes/lib/common.sh
2. Validate Python venv path exists (venv/bin/python)
3. Stop leftover face monitor/watchdog from previous run
4. Create DB session row and write tmp state files
5. Disable GNOME notification banners
6. Kill distractions immediately
7. Start watchdog loop
8. Start face monitor only in focus mode

### Exiting a mode
1. Optional password check against config/.exit_hash
2. Stop face monitor
3. Stop watchdog
4. Finalize DB session with warnings/forced_exit
5. Clean tmp state files
6. Re-enable GNOME notification banners

## Temporary Runtime Files

Acadence uses these files in /tmp:

- /tmp/acadence_mode
- /tmp/acadence_session
- /tmp/acadence_warnings
- /tmp/acadence_watchdog
- /tmp/acadence_watchdog_heartbeat
- /tmp/acadence_face_monitor

## API Endpoints

Provided by dashboard/backend/main.py:

- GET /
	- serves frontend index.html if present
- GET /status
	- current mode/session state
- GET /sessions?limit=25
	- recent session history
- POST /mode/{focus|study|code}
	- starts the selected mode
- POST /exit
	- launches exit.sh (Zenity password flow)

## Installation

From repository root:

```bash
bash install.sh
```

Installer currently performs:

- GNOME check
- Python3 check
- notify-send install/check
- virtual environment creation
- Python package install from requirements.txt
- DB initialization
- script executable permissions
- desktop launcher creation for Focus/Study/Code/Exit

## Running the Project

### Option A: Electron desktop app
```bash
npm install
npm start
```

### Option B: Backend directly (browser)
```bash
source venv/bin/activate
python dashboard/backend/main.py
```
Then open http://127.0.0.1:8000

### Password setup (required for manual exit auth)
```bash
bash modes/setup_password.sh
```

## Dependencies

### System-level
- Linux with GNOME
- gsettings
- notify-send
- zenity
- pkill
- Python 3

### Python
- numpy==2.4.2
- opencv-python==4.13.0.92
- fastapi
- uvicorn[standard]

### Node/Electron
- electron ^41.2.0

## Known Scope and Limitations

- Linux GNOME focused implementation (not cross-platform yet in code)
- Blocked app list is currently hardcoded in modes/lib/common.sh
- electron/preload.js is present but currently unused
- Face monitor exits silently if camera/cascade initialization fails

## License

This repository includes GNU GPL v3 license text in LICENSE.
