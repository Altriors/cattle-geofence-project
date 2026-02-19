from ultralytics import YOLO
import cv2
import os


class CattleDetector:
    """
    Cattle detection using YOLOv8 model
    """

    def __init__(self, model_path='yolov8n.pt'):
        """
        Initialize detector

        Args:
            model_path: Path to YOLOv8 model (default: yolov8n.pt)
        """

        if not os.path.exists(model_path) and model_path != 'yolov8n.pt':
            print(f"Model not found at {model_path}")
            print("Falling back to yolov8n.pt")
            model_path = 'yolov8n.pt'

        self.model = YOLO(model_path)
        print(f"Model loaded: {model_path}")

    def detect_image(self, image_path, conf_threshold=0.3):
        if not os.path.exists(image_path):
            print(f"Image not found: {image_path}")
            return None

        results = self.model.predict(
            source=image_path,
            conf=conf_threshold,
            save=True,
            verbose=False
        )

        num_cattle = 0
        if results and results[0].boxes is not None:
            num_cattle = results[0].boxes.xyxy.shape[0]

        print(f"Detected {num_cattle} cattle")

        if results and results[0].boxes is not None:
            for box in results[0].boxes:
                confidence = float(box.conf[0])
                print(f"  confidence: {confidence:.2f}")

        return results

    def detect_video(self, video_path, conf_threshold=0.3, save_output=False):
        if not os.path.exists(video_path):
            print(f"Video not found: {video_path}")
            return

        cap = cv2.VideoCapture(video_path)

        fps = int(cap.get(cv2.CAP_PROP_FPS))
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

        if save_output:
            output_path = 'detected_output.mp4'
            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
            out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))

        frame_count = 0
        print("Press 'q' to quit")

        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            frame_count += 1

            results = self.model(frame, conf=conf_threshold, verbose=False)
            annotated = results[0].plot()

            num_cattle = 0
            if results[0].boxes is not None:
                num_cattle = results[0].boxes.xyxy.shape[0]

            cv2.putText(
                annotated,
                f'Cattle: {num_cattle}',
                (20, 50),
                cv2.FONT_HERSHEY_SIMPLEX,
                1.4,
                (0, 255, 0),
                3
            )

            if save_output:
                out.write(annotated)

            cv2.imshow('Cattle Detection', annotated)

            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

        cap.release()

        if save_output:
            out.release()
            print(f"Saved output: {output_path}")

        cv2.destroyAllWindows()
        print(f"Processed {frame_count} frames")


# =========================
# TEST FUNCTIONS
# =========================

def test_image():
    detector = CattleDetector()  # uses yolov8n.pt
    detector.detect_image('../tests/sample_images/cattle1.jpg')


def test_video():
    detector = CattleDetector()  # uses yolov8n.pt
    detector.detect_video('../tests/sample_videos/cattle_test.mp4', save_output=True)


if __name__ == "__main__":
    print("=" * 50)
    print("CATTLE DETECTOR")
    print("=" * 50)
    print("1. Test on image")
    print("2. Test on video")

    choice = input("Enter choice (1 or 2): ")

    if choice == '1':
        test_image()
    elif choice == '2':
        test_video()
    else:
        print("Invalid choice")
