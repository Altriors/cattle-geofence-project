from ultralytics import YOLO
import cv2

# Load pre-trained YOLO model
print("Loading YOLO model...")
model = YOLO('yolov8n.pt')  # Downloads automatically first time
print("Model loaded successfully!")

# Test on a sample image (will download from internet)
print("\nTesting detection on sample image...")
results = model('https://ultralytics.com/images/bus.jpg')

# Display results
print(f"\nDetected {len(results[0].boxes)} objects")

# Show results
results[0].show()  # Opens window with detections

print("\nYOLO is working perfectly!")