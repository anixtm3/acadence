import sqlite3
from datetime import datetime
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DB_PATH = PROJECT_ROOT / "db" / "acadence.db"


def start_session(mode):
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()

        start_time = datetime.now().isoformat()

        cursor.execute("""
            INSERT INTO sessions (mode, start_time)
            VALUES (?, ?)
        """, (mode, start_time))

        return cursor.lastrowid


def end_session(session_id, face_warnings=0, forced_exit=0):
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()

        cursor.execute("SELECT start_time, end_time FROM sessions WHERE id=?", (session_id,))
        row = cursor.fetchone()

        if row is None or row[1] is not None:
            return

        start_time = datetime.fromisoformat(row[0])
        end_time = datetime.now()

        duration = int((end_time - start_time).total_seconds())

        cursor.execute("""
            UPDATE sessions
            SET end_time=?,
                duration_seconds=?,
                face_warnings=?,
                forced_exit=?
            WHERE id=?
        """, (
            end_time.isoformat(),
            duration,
            int(face_warnings or 0),
            forced_exit,
            session_id
        ))