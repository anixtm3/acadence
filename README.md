# Acadence

Acadence is a Linux productivity enforcement system. It locks you into focus modes, kills distracting applications, optionally monitors your presence via webcam, and logs every session to a local SQLite database. A FastAPI + Electron dashboard provides a UI for starting modes and reviewing session history.

Built for GNOME-based Linux environments.

## Requirements

- Linux with GNOME
- Python 3.10+
- Node.js + npm (for the Electron dashboard)
- Webcam (required only for Focus mode face monitoring)
- `zenity` — for the password dialog on exit
- `notify-send` (libnotify-bin) — installed automatically by `install.sh` if missing
- Brave browser (optional, but listed as an allowed app in all modes)

## Repository Structure

```
acadence/
├── config/
│   └── .exit_hash                # SHA256 hash of exit password (created by setup_password.sh)
├── dashboard/
│   ├── backend/
│   │   └── main.py               # FastAPI server: API + static file hosting
│   └── frontend/
│       ├── index.html            # dashboard UI (Tailwind dark theme)
│       ├── script.js             # polling logic, mode controls, session history
│       └── style.css             # component styles layered on Tailwind
├── db/
│   ├── init_db.py                # creates acadence.db and sessions table
│   └── session_logger.py         # start_session / end_session writes
├── electron/
│   ├── main.js                   # spawns Python backend, opens BrowserWindow
│   └── preload.js                # (empty)
├── modes/
│   ├── focus.sh                  # Focus mode entry point (face monitor enabled)
│   ├── study.sh                  # Study mode entry point
│   ├── code.sh                   # Code mode entry point
│   ├── exit.sh                   # Authenticated exit + session teardown
│   ├── setup_password.sh         # One-time password setup
│   ├── watchdog.sh               # Whitelist enforcement loop
│   └── lib/
│       └── common.sh             # All shared mode logic (session, watchdog, face monitor, PATH blocking)
├── tracking/
│   └── face_monitor.py           # OpenCV webcam loop — warns and force-exits on absence
├── install.sh                    # Bootstrap installer
├── package.json                  # Electron scripts (npm start / npm run dev)
├── requirements.txt              # Python dependencies
├── LICENSE
└── README.md
```

## Installation

```bash
git clone https://github.com/anixtm3/acadence.git
cd acadence
bash install.sh
```

`install.sh` does the following:

1. Checks for GNOME, Python 3, and Brave (optional)
2. Installs `libnotify-bin` if `notify-send` is missing
3. Creates a Python virtual environment at `venv/` and installs `requirements.txt`
4. Initializes the SQLite database (`db/acadence.db`)
5. Makes all mode scripts and tracking scripts executable
6. Creates `.desktop` launchers in `~/.local/share/applications/` for Focus, Study, Code, and Exit

Then set your exit password (required before you can exit any mode):

```bash
bash modes/setup_password.sh
```

This stores a SHA256 hash of your password in `config/.exit_hash`. The plaintext is never saved.

To install Node dependencies for the Electron dashboard:

```bash
npm install
```

## Usage

### Starting a mode

**From the terminal:**

```bash
bash modes/focus.sh
bash modes/study.sh
bash modes/code.sh
```

**From the GNOME application launcher:** search for "Acadence Focus", "Acadence Study", or "Acadence Code" after installation.

**From the dashboard UI:** click Focus, Study, or Code in the sidebar.

### Exiting a mode

```bash
bash modes/exit.sh
```

A Zenity password dialog will appear. Enter the password you set with `setup_password.sh`. On success, the session is finalized and all enforcement stops.

Alternatively, use the "Exit current mode" button in the dashboard — it triggers the same `exit.sh` script and shows the Zenity prompt.

### Running the Electron dashboard

```bash
npm start
```

Or in headless/debug mode:

```bash
npm run dev
```

This spawns the FastAPI backend and opens a `BrowserWindow` at `http://127.0.0.1:8000`.

The dashboard can also be accessed directly in a browser at `http://127.0.0.1:8000` if you start the backend manually:

```bash
venv/bin/python dashboard/backend/main.py
```

## Modes

| Mode | Face Monitor | Allowed Apps |
|------|-------------|--------------|
| Focus | Yes | Brave, Obsidian, Evince, VSCode/Cursor |
| Study | No | Brave, Obsidian, Evince, VSCode/Cursor |
| Code | No | Brave, Obsidian, GNOME Terminal, VSCode/Cursor |

All modes block everything not in the allowlist. The watchdog loop kills disallowed processes continuously while a mode is active.

### PATH Blocking

On mode start, a directory `~/.acadence_block/` is prepended to `PATH`. It contains symlink stubs for:

- `firefox`
- `discord`
- `telegram-desktop`
- `spotify`

These stubs print `Blocked by Acadence` and exit with code 1. The original `PATH` is saved and restored when the mode exits.

### GNOME Notifications

GNOME notification banners are disabled (`gsettings set org.gnome.desktop.notifications show-banners false`) on mode start and restored on exit.

## Face Monitor (Focus mode only)

`tracking/face_monitor.py` runs as a background process during Focus mode. It uses OpenCV's Haar cascade (`haarcascade_frontalface_default.xml`) to detect your face via the default webcam.

| Parameter | Value | Description |
|-----------|-------|-------------|
| `MISS_FRAME_LIMIT` | 10 frames | Consecutive missed frames before triggering a warning |
| `NOTIFY_COOLDOWN` | 10 seconds | Minimum time between warning notifications |
| `ABSENCE_LIMIT` | 30 seconds | Continuous absence before forced exit |

- Each warning increments the face warning counter saved in `/tmp/acadence_warnings` and logged to the session.
- After 30 seconds of no face detected, `exit.sh --force` is called — no password prompt, session is logged with `forced_exit = 1`.

## Watchdog

`modes/watchdog.sh` runs as a background loop while any mode is active. It scans all processes owned by the current user and kills any that are not in the mode's allowlist.

Protected processes that are never killed regardless of mode:

- Shell interpreters: `bash`, `sh`, `zsh`, `dash`, `fish`
- System utilities: `sleep`, `ps`, `pgrep`, `pkill`, `kill`, `cat`, `sed`, `nohup`
- Desktop session: `systemd`, `dbus-daemon`, `dbus-broker`, `gnome-shell`, `Xorg`, `Xwayland`, `wayland`, `notify-send`, `zenity`, `gsettings`
- Any process with `ACADENCE_ROOT` in its arguments (Acadence's own Python/Electron processes)
- Any full desktop session process matched by args (gnome-session, gsd-*, pipewire, ibus, polkit, etc.)

The watchdog writes a heartbeat file at `/tmp/acadence_watchdog_heartbeat` once running. Mode startup aborts if the heartbeat is not confirmed within 1 second.

## Session Tracking

All sessions are recorded in `db/acadence.db` (SQLite).

**Table: `sessions`**

| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER | Auto-increment primary key |
| `mode` | TEXT | `FOCUS`, `STUDY`, or `CODE` |
| `start_time` | TEXT | ISO 8601 timestamp |
| `end_time` | TEXT | ISO 8601 timestamp (null while active) |
| `duration_seconds` | INTEGER | Computed on session end |
| `face_warnings` | INTEGER | Number of face-absent notifications |
| `forced_exit` | INTEGER | `1` if exited by face monitor, `0` otherwise |

An index on `start_time` is created for query performance.

## Dashboard API

The FastAPI backend runs at `http://127.0.0.1:8000` and is started automatically by Electron or manually via `venv/bin/python dashboard/backend/main.py`.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | Serves `index.html` |
| `GET` | `/status` | Returns current mode, session ID, duration, warnings |
| `GET` | `/sessions?limit=25` | Returns last N sessions (max 200) |
| `POST` | `/mode/{focus\|study\|code}` | Starts a mode (409 if one is already active) |
| `POST` | `/exit` | Launches `exit.sh` — triggers Zenity password prompt |

Static files (JS, CSS) are served from `dashboard/frontend/` at `/static/`.

### `GET /status` response shape

```json
{
  "mode": "FOCUS",
  "session_id": 12,
  "start_time": "2026-04-10T09:00:00",
  "duration_seconds": 432,
  "warnings": 2,
  "forced_exit": 0,
  "active": true
}
```

## Runtime State Files

While a mode is active, Acadence writes state to `/tmp/`:

| File | Contents |
|------|----------|
| `/tmp/acadence_mode` | Active mode label (e.g. `🔴 Focus Mode`) |
| `/tmp/acadence_session` | Current session ID (integer) |
| `/tmp/acadence_warnings` | Face warning count (integer) |
| `/tmp/acadence_watchdog` | Watchdog process PID |
| `/tmp/acadence_watchdog_heartbeat` | Created by watchdog once running |
| `/tmp/acadence_face_monitor` | Face monitor process PID |
| `/tmp/acadence_path_backup` | Original `PATH` value before blocking |

All files are removed on clean exit by `acadence_cleanup_state` in `common.sh`.

## Runtime Flow

### Starting a mode

1. Source `modes/lib/common.sh`
2. Verify Python venv exists at `venv/bin/python`
3. Stop any leftover face monitor and watchdog from a previous run
4. Insert a new row in `sessions` and write the session ID to `/tmp/acadence_session`
5. Write mode label to `/tmp/acadence_mode`, initialize warning counter to `0`
6. Prepend `~/.acadence_block` to `PATH` (PATH blocker)
7. Disable GNOME notification banners
8. Start watchdog; abort if heartbeat not confirmed
9. Start face monitor (Focus mode only)

### Exiting a mode

1. Prompt for password via Zenity (skipped if `--force` flag is passed by face monitor)
2. Kill face monitor first (prevents a race condition triggering a second exit)
3. Kill watchdog
4. Restore original `PATH`
5. Read session ID and warning count from `/tmp/` files; call `end_session()` to finalize DB row
6. Delete all `/tmp/acadence_*` state files
7. Restore GNOME notification banners
8. Show Zenity confirmation dialog (normal exit) or `notify-send` (forced exit)
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
