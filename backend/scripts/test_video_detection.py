from ultralytics import YOLO
import cv2

# Load model
model = YOLO('yolov8n.pt')

# Open video
video_path = 'D:/projects/cattle-geofence-project/backend/tests/sample_videos/cattle_test.mp4'  # Change to your video path
cap = cv2.VideoCapture(video_path)

print("Processing video... Press 'q' to quit")

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break
    
    # Run detection
    results = model(frame, verbose=False)
    
    # Draw results on frame
    annotated_frame = results[0].plot()
    
    # Display
    cv2.imshow('Cattle Detection', annotated_frame)
    
    # Press 'q' to quit
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()

print("Done!")