import sqlite3
from datetime import datetime
from pathlib import Path

# Same DB location as init_db.py
DB_PATH = Path("/home/anixtm3/Documents/GitHub/acadence/db/acadence.db")


def start_session(mode):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    start_time = datetime.now().isoformat()

    cursor.execute("""
        INSERT INTO sessions (mode, start_time)
        VALUES (?, ?)
    """, (mode, start_time))

    session_id = cursor.lastrowid

    conn.commit()
    conn.close()

    return session_id


def end_session(session_id, face_warnings=0, forced_exit=0):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    end_time = datetime.now()

    cursor.execute("""
        SELECT start_time FROM sessions WHERE id=?
    """, (session_id,))
    result = cursor.fetchone()

    if result is None:
        conn.close()
        return

    start_time = datetime.fromisoformat(result[0])
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
        face_warnings,
        forced_exit,
        session_id
    ))

    conn.commit()
    conn.close()