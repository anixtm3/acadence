from __future__ import annotations

import os
import signal
import sqlite3
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Literal

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

app = FastAPI()

# ✅ Allow frontend (fixes "Failed to fetch")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # later you can restrict this
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ Dynamic DB path (safe + clean)
PROJECT_ROOT = Path(__file__).resolve().parents[2]
DB_PATH = PROJECT_ROOT / "db" / "acadence.db"
FRONTEND_DIR = PROJECT_ROOT / "dashboard" / "frontend"
MODES_DIR = PROJECT_ROOT / "modes"

TMP_MODE = Path("/tmp/acadence_mode")
TMP_SESSION = Path("/tmp/acadence_session")
TMP_WARNINGS = Path("/tmp/acadence_warnings")
TMP_WATCHDOG = Path("/tmp/acadence_watchdog")

ModeName = Literal["focus", "study", "code"]


def _read_text(path: Path) -> str | None:
    try:
        return path.read_text(encoding="utf-8").strip()
    except FileNotFoundError:
        return None


def _read_int(path: Path, default: int = 0) -> int:
    raw = _read_text(path)
    if raw is None:
        return default
    try:
        return int(str(raw).strip())
    except Exception:
        return default


def _normalize_mode(raw: str | None) -> str:
    if not raw:
        return "NONE"
    upper = raw.upper()
    if "FOCUS" in upper:
        return "FOCUS"
    if "STUDY" in upper:
        return "STUDY"
    if "CODE" in upper:
        return "CODE"
    return raw.strip()


def _utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _db_connect() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def _get_session_start_time(session_id: int) -> str | None:
    with _db_connect() as conn:
        row = conn.execute(
            "SELECT start_time FROM sessions WHERE id = ? LIMIT 1",
            (session_id,),
        ).fetchone()
        return str(row["start_time"]) if row else None


def _duration_seconds_from_start(start_time_iso: str | None) -> int:
    if not start_time_iso:
        return 0
    try:
        start = datetime.fromisoformat(start_time_iso)
        end = datetime.now(start.tzinfo) if start.tzinfo else datetime.now()
        return max(0, int((end - start).total_seconds()))
    except Exception:
        return 0


def _kill_pid_file(pid_file: Path) -> None:
    pid = _read_int(pid_file, default=0)
    if pid <= 0:
        try:
            pid_file.unlink(missing_ok=True)
        except Exception:
            pass
        return
    try:
        os.kill(pid, signal.SIGTERM)
    except ProcessLookupError:
        pass
    except PermissionError:
        pass
    finally:
        try:
            pid_file.unlink(missing_ok=True)
        except Exception:
            pass


def _pkill_contains(pattern: str) -> None:
    # Best-effort; don't crash if pkill isn't available.
    try:
        subprocess.run(["pkill", "-f", pattern], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        return


def _is_mode_active() -> bool:
    raw = _read_text(TMP_MODE)
    return bool(raw and raw.strip())


def _script_for_mode(mode_name: ModeName) -> Path:
    script = MODES_DIR / f"{mode_name}.sh"
    if not script.exists():
        raise HTTPException(status_code=404, detail=f"Mode script not found: {script.name}")
    return script


@app.get("/")
def root():
    index = FRONTEND_DIR / "index.html"
    if index.exists():
        return FileResponse(index)
    return {"status": "Acadence backend running", "time": _utc_now_iso()}


app.mount("/static", StaticFiles(directory=FRONTEND_DIR), name="static")

@app.get("/status")
def status() -> dict[str, Any]:
    raw_mode = _read_text(TMP_MODE)
    mode = _normalize_mode(raw_mode)

    session_id = _read_int(TMP_SESSION, default=0) or None
    start_time = _get_session_start_time(session_id) if session_id else None
    duration_seconds = _duration_seconds_from_start(start_time)

    warnings = _read_int(TMP_WARNINGS, default=0)
    forced_exit = 0

    return {
        "mode": mode,
        "session_id": session_id,
        "start_time": start_time,
        "duration_seconds": duration_seconds,
        "warnings": warnings,
        "forced_exit": forced_exit,
        "active": mode != "NONE",
    }


@app.get("/sessions")
def sessions(limit: int = 25) -> dict[str, Any]:
    limit = max(1, min(int(limit), 200))
    with _db_connect() as conn:
        rows = conn.execute(
            """
            SELECT id, mode, start_time, end_time, duration_seconds, face_warnings, forced_exit
            FROM sessions
            ORDER BY id DESC
            LIMIT ?
            """,
            (limit,),
        ).fetchall()

    items: list[dict[str, Any]] = []
    for r in rows:
        items.append(
            {
                "id": int(r["id"]),
                "mode": str(r["mode"]),
                "start_time": r["start_time"],
                "end_time": r["end_time"],
                "duration_seconds": int(r["duration_seconds"] or 0),
                "warnings": int(r["face_warnings"] or 0),
                "forced_exit": int(r["forced_exit"] or 0),
            }
        )
    return {"items": items}


@app.post("/mode/{mode_name}")
def start_mode(mode_name: ModeName) -> dict[str, Any]:
    if _is_mode_active():
        raise HTTPException(status_code=409, detail="A mode is already active. Exit first.")

    script = _script_for_mode(mode_name)
    try:
        subprocess.Popen(
            ["bash", str(script)],
            cwd=str(PROJECT_ROOT),
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to start mode: {e}")

    return {"ok": True, "started": mode_name}


@app.post("/exit")
def exit_mode() -> dict[str, Any]:
    """
    Exit via the canonical script so the Zenity password prompt appears.

    Note: this endpoint starts the script and returns immediately (does not wait).
    """
    script = MODES_DIR / "exit.sh"
    if not script.exists():
        raise HTTPException(status_code=404, detail="exit.sh not found")

    try:
        subprocess.Popen(
            ["bash", str(script)],
            cwd=str(PROJECT_ROOT),
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to run exit.sh: {e}")

    return {"ok": True, "prompted": True}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="127.0.0.1", port=8000)