import cv2
import time
import subprocess
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
EXIT_SCRIPT = PROJECT_ROOT / "modes" / "exit.sh"
WARNING_FILE = Path("/tmp/acadence_warnings")

ABSENCE_LIMIT = 30
MISS_FRAME_LIMIT = 10
NOTIFY_COOLDOWN = 10

face_cascade = cv2.CascadeClassifier(
    cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
)

if face_cascade.empty():
    subprocess.run(
        ["notify-send", "-u", "critical", "Acadence Error", "Face cascade failed to load — face monitor inactive"],
        check=False
    )
    exit()

cap = cv2.VideoCapture(0)
if not cap.isOpened():
    subprocess.run(
        ["notify-send", "-u", "critical", "Acadence Error", "Camera not accessible — face monitor inactive"],
        check=False
    )
    exit()

last_seen = time.time()
missed_frames = 0
last_notification = 0
exit_triggered = False


def increment_warning():
    try:
        count = int(WARNING_FILE.read_text().strip())
    except:
        count = 0
    WARNING_FILE.write_text(str(count + 1))


while True:
    ret, frame = cap.read()

    if not ret:
        time.sleep(1)
        continue

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

            if current_time - last_notification > NOTIFY_COOLDOWN:
                subprocess.Popen([
                    "notify-send",
                    "-u", "critical",
                    "Acadence",
                    "You aren't focusing"
                ])
                increment_warning()
                last_notification = current_time

    if not exit_triggered and time.time() - last_seen > ABSENCE_LIMIT:
        exit_triggered = True
        subprocess.Popen(["bash", str(EXIT_SCRIPT), "--force"])
        break

    time.sleep(0.05)

cap.release()