from ultralytics import YOLO
import cv2
from firebase_handler import FirebaseHandler
import time

model = YOLO('yolov8n.pt')
cap = cv2.VideoCapture(0)

BOUNDARY_Y = 300
COW_CLASS_ID = 0

# Store previous positions
previous_positions = {}
last_alert_time={}
ALERT_COOLDOWN = 5

print("Live Camera Detection Started")
print("Press 'q' to quit")

firebase = FirebaseHandler()

while True:
    ret, frame = cap.read()
    if not ret:
        break

    results = model.track(frame, conf=0.3, persist=True, verbose=False)

    cv2.line(frame, (0, BOUNDARY_Y),
             (frame.shape[1], BOUNDARY_Y),
             (0, 0, 255), 3)

    for box in results[0].boxes:

        if box.id is None:
            continue

        track_id = int(box.id[0])
        cls_id = int(box.cls[0])

        if cls_id != COW_CLASS_ID:
            continue

        x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
        center_y = (y1 + y2) / 2

        color = (0, 255, 0) if center_y < BOUNDARY_Y else (0, 0, 255)

        cv2.rectangle(frame,
                      (int(x1), int(y1)),
                      (int(x2), int(y2)),
                      color, 2)

        cv2.putText(frame,
                    f"CATTLE ID {track_id}",
                    (int(x1), int(y1) - 10),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.8,
                    color, 2)

        # Crossing detection
        if track_id in previous_positions:
            prev_y = previous_positions[track_id]

            if prev_y < BOUNDARY_Y and center_y > BOUNDARY_Y:
                print(f" Cattle {track_id} crossed boundary!")

                current_time = time.time()

                if track_id not in last_alert_time or \
       current_time - last_alert_time[track_id] > ALERT_COOLDOWN:
                    
                    print(f"cattle {track_id} has crossed the boundary")
                    
                    firebase.save_alert(
                    cattle_count=1,
                    crossed=True,
                    cattle_id=track_id
                    )
                    last_alert_time[track_id]=current_time

                cv2.putText(frame,
                            "ALERT: CATTLE CROSSED",
                            (50, 100),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            1.5,
                            (0, 0, 255),
                            3)

        previous_positions[track_id] = center_y

    cv2.imshow("Live Detection", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()