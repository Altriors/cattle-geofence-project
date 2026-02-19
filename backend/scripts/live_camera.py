from ultralytics import YOLO
import cv2

# Load YOLOv8 model
model = YOLO('yolov8n.pt')

# Open webcam
cap = cv2.VideoCapture(0)

BOUNDARY_Y = 300

# COCO class index for cow
COW_CLASS_ID = 19   # cow in COCO dataset

print("Live Camera Detection Started")
print("Press 'q' to quit")

while True:
    ret, frame = cap.read()
    if not ret:
        break

    results = model(frame, conf=0.3, verbose=False)

    # Draw boundary line
    cv2.line(
        frame,
        (0, BOUNDARY_Y),
        (frame.shape[1], BOUNDARY_Y),
        (0, 0, 255),
        3
    )

    alert_triggered = False

    for box in results[0].boxes:
        cls_id = int(box.cls[0])

        # Filter only cows
        if cls_id != COW_CLASS_ID:
            continue

        x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
        center_y = (y1 + y2) / 2

        # Box color based on position
        color = (0, 255, 0) if center_y < BOUNDARY_Y else (0, 0, 255)

        cv2.rectangle(
            frame,
            (int(x1), int(y1)),
            (int(x2), int(y2)),
            color,
            2
        )

        cv2.putText(
            frame,
            "CATTLE",
            (int(x1), int(y1) - 10),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.8,
            color,
            2
        )

        # Boundary check
        if center_y > BOUNDARY_Y:
            alert_triggered = True

    if alert_triggered:
        cv2.putText(
            frame,
            "ALERT: CATTLE CROSSED",
            (50, 100),
            cv2.FONT_HERSHEY_SIMPLEX,
            1.5,
            (0, 0, 255),
            3
        )
        print("ALERT: Cattle crossed boundary")

    cv2.imshow("Live Detection", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
