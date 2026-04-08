from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import sqlite3
from pathlib import Path

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


@app.get("/")
def root():
    return {"status": "Acadence backend running"}


@app.get("/session")
def get_session():
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()

        cursor.execute("""
            SELECT mode, duration_seconds, face_warnings, forced_exit
            FROM sessions
            ORDER BY id DESC
            LIMIT 1
        """)

        row = cursor.fetchone()
        conn.close()

        if not row:
            return {
                "mode": "NONE",
                "duration": 0,
                "warnings": 0,
                "forced_exit": 0
            }

        return {
            "mode": row[0],
            "duration": row[1],
            "warnings": row[2],
            "forced_exit": row[3]
        }

    except Exception as e:
        return {"error": str(e)}