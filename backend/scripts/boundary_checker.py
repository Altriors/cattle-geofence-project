from ultralytics import YOLO
import cv2
import numpy as np
from datetime import datetime

class BoundaryChecker:
    """
    Check if cattle cross predefined boundary lines
    """
    
    def __init__(self, model_path='../models/best.pt', boundary_y=400):
        """
        Initialize boundary checker
        
        Args:
            model_path: Path to trained model
            boundary_y: Y-coordinate of boundary line (pixels from top)
        """
        self.model = YOLO(model_path) if model_path else YOLO('yolov8n.pt')
        self.boundary_y = boundary_y
        self.previous_positions = {}
        self.alerts = []
        
        print(f"✓ Boundary set at y={boundary_y}")
    
    def check_crossing(self, video_path, alert_callback=None):
        """
        Monitor video for boundary crossings
        
        Args:
            video_path: Path to video
            alert_callback: Function to call when crossing detected
        """
        cap = cv2.VideoCapture(video_path)
        
        print(f"\nMonitoring boundary crossings...")
        print(f"Boundary position: y={self.boundary_y}")
        print("Press 'q' to quit\n")
        
        frame_count = 0
        
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            
            frame_count += 1
            
            # Detect cattle
            results = self.model(frame, conf=0.5, verbose=False)
            
            # Draw boundary line (RED)
            cv2.line(frame, (0, self.boundary_y), 
                    (frame.shape[1], self.boundary_y), 
                    (0, 0, 255), 4)
            
            # Add boundary label
            cv2.putText(frame, 'RESTRICTED AREA', 
                       (20, self.boundary_y + 40),
                       cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
            
            # Check each detected cattle
            for i, box in enumerate(results[0].boxes):
                x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
                center_y = (y1 + y2) / 2
                center_x = (x1 + x2) / 2
                
                # Draw detection box
                color = (0, 255, 0) if center_y < self.boundary_y else (0, 0, 255)
                cv2.rectangle(frame, (int(x1), int(y1)), 
                            (int(x2), int(y2)), color, 3)
                
                # Check crossing
                if i in self.previous_positions:
                    prev_y = self.previous_positions[i]
                    
                    # Crossed into restricted area
                    if prev_y < self.boundary_y and center_y > self.boundary_y:
                        alert_msg = f"🚨 ALERT! Cattle {i} entered RESTRICTED AREA"
                        print(f"\n{datetime.now().strftime('%H:%M:%S')} - {alert_msg}")
                        
                        self.alerts.append({
                            'time': datetime.now(),
                            'cattle_id': i,
                            'direction': 'entered',
                            'position': (int(center_x), int(center_y))
                        })
                        
                        # Call callback
                        if alert_callback:
                            alert_callback(alert_msg)
                        
                        # Visual alert on frame
                        cv2.putText(frame, 'BOUNDARY CROSSED!', 
                                   (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 
                                   2, (0, 0, 255), 4)
                    
                    # Crossed back to safe area
                    elif prev_y > self.boundary_y and center_y < self.boundary_y:
                        print(f"{datetime.now().strftime('%H:%M:%S')} - Cattle {i} returned to safe area")
                
                # Update position
                self.previous_positions[i] = center_y
            
            # Display cattle count
            num_cattle = len(results[0].boxes)
            cv2.putText(frame, f'Cattle Count: {num_cattle}', 
                       (20, 50), cv2.FONT_HERSHEY_SIMPLEX, 
                       1.2, (255, 255, 255), 3)
            
            # Display alert count
            cv2.putText(frame, f'Alerts: {len(self.alerts)}', 
                       (20, 90), cv2.FONT_HERSHEY_SIMPLEX, 
                       1.2, (0, 255, 255), 3)
            
            # Show frame
            cv2.imshow('Boundary Monitoring', frame)
            
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
        
        cap.release()
        cv2.destroyAllWindows()
        
        # Summary
        print("\n" + "="*50)
        print("MONITORING SUMMARY")
        print("="*50)
        print(f"Total frames: {frame_count}")
        print(f"Total alerts: {len(self.alerts)}")
        print("\nAlert details:")
        for alert in self.alerts:
            print(f"  {alert['time'].strftime('%H:%M:%S')} - Cattle {alert['cattle_id']} {alert['direction']}")

def test_boundary():
    """Test boundary checker"""
    checker = BoundaryChecker(boundary_y=300)
    checker.check_crossing('../tests/sample_videos/cattle_test5.mp4')

if __name__ == "__main__":
    test_boundary()
