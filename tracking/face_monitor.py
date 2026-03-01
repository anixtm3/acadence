import cv2
import time
import subprocess
from pathlib import Path

# ===== CONFIG =====
ABSENCE_LIMIT = 30          # Seconds before triggering exit
MISS_FRAME_LIMIT = 10       # Frame smoothing
NOTIFY_COOLDOWN = 10        # Seconds between notifications
EXIT_SCRIPT = "modes/exit.sh"
WARNING_FILE = Path("/tmp/acadence_warnings")
# ==================

face_cascade = cv2.CascadeClassifier(
    cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
)

cap = cv2.VideoCapture(0)

if not cap.isOpened():
    exit()

last_seen = time.time()
missed_frames = 0
last_notification = 0


def increment_warning():
    if WARNING_FILE.exists():
        try:
            count = int(WARNING_FILE.read_text().strip())
        except:
            count = 0
    else:
        count = 0

    count += 1
    WARNING_FILE.write_text(str(count))


while True:
    ret, frame = cap.read()
    if not ret:
        break

    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    faces = face_cascade.detectMultiScale(
        gray,
        scaleFactor=1.3,
        minNeighbors=5,
        minSize=(60, 60)
    )

    if len(faces) > 0:
        last_seen = time.time()
        missed_frames = 0
    else:
        missed_frames += 1

        if missed_frames > MISS_FRAME_LIMIT:
            current_time = time.time()

            # Send notification (with cooldown)
            if current_time - last_notification > NOTIFY_COOLDOWN:
                subprocess.run([
                    "notify-send",
                    "-u", "critical",
                    "Acadence",
                    "You aren't focusing"
                ])

                increment_warning()
                last_notification = current_time

    # Trigger exit if absent too long
    if time.time() - last_seen > ABSENCE_LIMIT:
        subprocess.run(["bash", EXIT_SCRIPT])
        break

cap.release()