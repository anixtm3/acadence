import sqlite3
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DB_DIR = PROJECT_ROOT / "db"
DB_PATH = DB_DIR / "acadence.db"

DB_DIR.mkdir(parents=True, exist_ok=True)

with sqlite3.connect(DB_PATH) as conn:
    cursor = conn.cursor()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mode TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        duration_seconds INTEGER,
        face_warnings INTEGER DEFAULT 0,
        forced_exit INTEGER DEFAULT 0
    );
    """)

    cursor.execute("""
    CREATE INDEX IF NOT EXISTS idx_sessions_start_time
    ON sessions(start_time);
    """)

print(f"Database initialized at {DB_PATH}")