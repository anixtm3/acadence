import sqlite3
from pathlib import Path

# Absolute project path
PROJECT_ROOT = Path("/home/anixtm3/Documents/GitHub/acadence")
DB_DIR = PROJECT_ROOT / "db"
DB_PATH = DB_DIR / "acadence.db"

DB_DIR.mkdir(parents=True, exist_ok=True)

conn = sqlite3.connect(DB_PATH)
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

conn.commit()
conn.close()

print(f"Database initialized at {DB_PATH}")