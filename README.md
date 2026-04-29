# Cattle Geo-Fencing and Boundary Violation Detection

Real-time livestock monitoring system using YOLOv8-based object detection and Firebase Cloud Messaging to detect cattle boundary violations and notify farmers instantly.

**Academic Project** — Department of Computer Science and Engineering, Mahatma Gandhi Institute of Technology, Hyderabad (2025–2026)

**Authors:** T. Venu (23261A05B7), T.M. Nikilesh Kumar (23261A05B9)  
**Guide:** Mrs. K. Shirisha, Assistant Professor, Dept. of CSE

---

## Overview

Traditional cattle monitoring depends on manual supervision, which is labor-intensive, error-prone, and unscalable. This system eliminates that dependency by combining computer vision with cloud infrastructure to provide automated, real-time boundary monitoring.

When a camera detects cattle crossing a predefined virtual boundary, the system stores an alert in Firebase Firestore and immediately dispatches a push notification to the farmer's mobile device via Firebase Cloud Messaging.

---

## System Architecture

The system is composed of two subsystems:

**Backend Detection Engine**
- Captures live video from CCTV/IP cameras using OpenCV
- Runs YOLOv8 inference per frame for cattle detection
- Applies virtual geo-fence boundary validation
- Uploads violation alerts to Firebase Firestore
- Triggers push notifications via Firebase Cloud Messaging

**Flutter Mobile Application**
- User authentication and session management
- Real-time alert display and incident management
- Dashboard statistics and alert history
- Push notification handling and acknowledgement

---

## Technology Stack

| Layer | Technologies |
|---|---|
| Object Detection | YOLOv8, OpenCV, NumPy |
| Backend / Cloud | Python 3.10+, Firebase Firestore, Firebase Cloud Messaging, Firebase Authentication |
| Mobile Application | Flutter, Dart, Provider |

---

## Performance

| Metric | Value |
|---|---|
| mAP@0.5 | 89% |
| Precision | 91% |
| Recall | 88% |
| F1 Score | 89% |
| Inference Time | ~30 ms/frame |
| Alert Latency | < 2 seconds |

---

## Repository Structure

```
cattle-geofence-project/
├── backend/
│   ├── models/
│   │   ├── best.pt                  # Trained YOLOv8 weights
│   │   └── best.tflite              # TFLite export for mobile inference
│   ├── scripts/
│   │   ├── train_model.py           # Model training script (Colab)
│   │   ├── detect_cattle.py         # Detection and inference logic
│   │   ├── boundary_checker.py      # Geo-fence boundary algorithm
│   │   └── firebase_handler.py      # Firestore alert writer
│   ├── cloud_functions/
│   │   ├── main.py                  # Firebase Cloud Function entry point
│   │   ├── requirements.txt
│   │   └── config.yaml
│   ├── dataset/
│   │   ├── images/
│   │   │   ├── train/               # 70% of dataset
│   │   │   ├── val/                 # 20% of dataset
│   │   │   └── test/                # 10% of dataset
│   │   ├── labels/
│   │   │   ├── train/
│   │   │   ├── val/
│   │   │   └── test/
│   │   └── data.yaml
│   ├── notebooks/
│   │   └── train_yolo.ipynb         # Google Colab training notebook
│   └── tests/
│       ├── test_detection.py
│       └── test_boundary.py
│
├── mobile_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/
│   │   │   ├── alert_model.dart
│   │   │   ├── detection_model.dart
│   │   │   └── user_model.dart
│   │   ├── screens/
│   │   │   ├── camera/
│   │   │   ├── farmer/
│   │   │   └── auth/
│   │   ├── services/
│   │   │   ├── firebase_service.dart
│   │   │   ├── notification_service.dart
│   │   │   ├── camera_service.dart
│   │   │   ├── storage_service.dart
│   │   │   └── auth_service.dart
│   │   ├── providers/
│   │   │   ├── alert_provider.dart
│   │   │   ├── camera_provider.dart
│   │   │   └── auth_provider.dart
│   │   └── widgets/
│   │       ├── alert_card.dart
│   │       ├── boundary_line_painter.dart
│   │       └── custom_button.dart
│   ├── pubspec.yaml
│   └── firebase.json
│
├── tests/
│   ├── sample_videos/
│   └── sample_images/
├── requirements.txt
└── README.md
```

---

## Firestore Alert Schema

| Field | Type | Description |
|---|---|---|
| timestamp | Timestamp | Time of boundary violation |
| cattle_count | Integer | Number of cattle detected |
| cattle_id | Integer | Optional tracked cattle identifier |
| boundary_crossed | Boolean | Violation status |
| camera | String | Camera source identifier |
| resolved | Boolean | Alert acknowledgement status |

---

## Requirements

**Software**
- Python 3.10+
- Flutter SDK
- Firebase CLI
- VS Code or PyCharm
- Git

**Hardware (Development)**
- Processor: Intel i5 / AMD Ryzen 5 or higher
- RAM: 8 GB minimum (16 GB recommended)
- GPU: NVIDIA GPU recommended for training

**Hardware (Deployment)**
- CCTV or IP camera at farm boundary
- Android or iOS smartphone
- Active internet connection

---

## Installation

Clone the repository:

```bash
git clone https://github.com/Altriors/cattle-geofence-project.git
cd cattle-geofence-project
```

Install Python dependencies:

```bash
pip install -r requirements.txt
```

---

## Running the Backend

Before running, ensure the following are in place:

- Firebase Admin SDK credentials JSON is configured in the backend directory
- YOLOv8 model weights (`best.pt`) are placed in `backend/models/`
- A webcam, CCTV, or IP camera is connected and accessible

```bash
python backend/scripts/live_camera.py
```

The backend will begin real-time detection, apply geo-fence validation, and push alerts to Firestore on boundary violations.

---

## Running the Mobile Application

```bash
cd mobile_app
flutter pub get
flutter run
```

Ensure the following Firebase configuration files are present before running:

- `google-services.json` — for Android (`android/app/`)
- `GoogleService-Info.plist` — for iOS (`ios/Runner/`)

---

## How It Works

1. Camera captures a continuous live video feed from the farm boundary
2. Each frame is processed in real time using YOLOv8
3. Detected cattle are bounded and their positions recorded
4. Geo-fencing logic checks detected positions against the virtual boundary
5. A violation is confirmed after detection across multiple consecutive frames
6. Alert data is written to Firebase Firestore
7. A push notification is dispatched to the farmer via FCM
8. The Flutter application displays the alert on the dashboard

---

## Comparison with Existing Methods

| Approach | Hardware Cost | Real-Time Alert | Mobile App | Per-Animal Device |
|---|---|---|---|---|
| GPS Collar Systems | High | Yes | No | Required |
| IoT / LoRaWAN Tracking | Medium | Yes | No | Required |
| YOLO + Camera Only | Low | No | No | Not Required |
| Proposed System | Low | Yes | Yes | Not Required |

---

## Future Scope

- Individual cattle identification and tracking using deep learning
- Multi-camera centralized monitoring with alert aggregation
- Edge deployment on Raspberry Pi or NVIDIA Jetson
- Offline functionality for low-connectivity environments
- Night vision and thermal imaging support
- Analytics dashboard for cattle movement pattern analysis

---

## License

This project is developed for academic and research purposes under Mahatma Gandhi Institute of Technology, Hyderabad.
