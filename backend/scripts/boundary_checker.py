from ultralytics import YOLO
import cv2
from datetime import datetime
from firebase_handler import FirebaseHandler

class BoundaryChecker:
    """Check if cattle cross predefined boundary lines"""
    
    def __init__(self, model_path='yolov8n.pt', boundary_y=400, use_firebase=True):
        """Initialize boundary checker"""
        self.model = YOLO(model_path)
        self.boundary_y = boundary_y
        self.previous_positions = {}
        self.alerts = []
        
        # Firebase integration
        self.use_firebase = use_firebase
        if use_firebase:
            try:
                self.firebase = FirebaseHandler()
            except Exception as e:
                print(f"⚠️  Firebase disabled: {e}")
                self.use_firebase = False
        
        print(f"✓ Boundary set at y={boundary_y}")
        print(f"✓ Model: {model_path}")
        print(f"✓ Firebase: {'Enabled' if self.use_firebase else 'Disabled'}")
    
    def check_crossing(self, video_path):
        """Monitor video for boundary crossings"""
        cap = cv2.VideoCapture(video_path)
        
        print("\n🎥 Monitoring started...")
        print("Press 'q' to quit\n")
        
        frame_count = 0
        
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            
            frame_count += 1
            
            # YOLO detection
            results = self.model(frame, conf=0.2, verbose=False)
            
            # Draw boundary line
            cv2.line(frame, (0, self.boundary_y), 
                    (frame.shape[1], self.boundary_y), 
                    (0, 0, 255), 4)
            
            cv2.putText(frame, 'RESTRICTED AREA', 
                       (20, self.boundary_y + 40),
                       cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
            
            # Process detections
            num_cattle = len(results[0].boxes)
            
            for i, box in enumerate(results[0].boxes):
                x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
                center_y = (y1 + y2) / 2
                center_x = (x1 + x2) / 2
                
                # Draw box
                color = (0, 255, 0) if center_y < self.boundary_y else (0, 0, 255)
                cv2.rectangle(frame, (int(x1), int(y1)), 
                            (int(x2), int(y2)), color, 3)
                
                # Check crossing
                if i in self.previous_positions:
                    prev_y = self.previous_positions[i]
                    
                    # Crossed into restricted zone
                    if prev_y < self.boundary_y and center_y > self.boundary_y:
                        alert_msg = f"🚨 CATTLE {i} ENTERED RESTRICTED AREA"
                        print(f"{datetime.now().strftime('%H:%M:%S')} - {alert_msg}")
                        
                        self.alerts.append({
                            'time': datetime.now(),
                            'cattle_id': i,
                            'position': (int(center_x), int(center_y))
                        })
                        
                        # Save to Firebase
                        if self.use_firebase:
                            self.firebase.save_alert(
                                cattle_count=num_cattle,
                                crossed=True
                            )
                        
                        # Visual alert
                        cv2.putText(frame, 'BOUNDARY CROSSED!', 
                                   (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 
                                   2, (0, 0, 255), 4)
                    
                    # Returned to safe zone
                    elif prev_y > self.boundary_y and center_y < self.boundary_y:
                        print(f"{datetime.now().strftime('%H:%M:%S')} - Cattle {i} returned to safe area")
                
                self.previous_positions[i] = center_y
            
            # Display info
            cv2.putText(frame, f'Cattle: {num_cattle}', 
                       (20, 50), cv2.FONT_HERSHEY_SIMPLEX, 
                       1.2, (255, 255, 255), 3)
            
            cv2.putText(frame, f'Alerts: {len(self.alerts)}', 
                       (20, 90), cv2.FONT_HERSHEY_SIMPLEX, 
                       1.2, (0, 255, 255), 3)
            
            cv2.imshow('Boundary Monitoring', frame)
            
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
        
        cap.release()
        cv2.destroyAllWindows()
        
        # Summary
        print("\n" + "="*50)
        print("MONITORING SUMMARY")
        print("="*50)
        print(f"Frames processed: {frame_count}")
        print(f"Total alerts: {len(self.alerts)}")
        
        for alert in self.alerts:
            print(f"{alert['time'].strftime('%H:%M:%S')} - Cattle {alert['cattle_id']}")

def test_boundary():
    checker = BoundaryChecker(boundary_y=300, use_firebase=True)
    checker.check_crossing('../../tests/sample_videos/cattle_test5.mp4')

if __name__ == "__main__":
    test_boundary()