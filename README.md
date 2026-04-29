# Cattle Geo-Fencing and Detection System

A real-time livestock monitoring system that uses computer vision to detect cattle movement near farm boundaries and notifies farmers instantly when a violation occurs.

## Team

- T.M Nikilesh Kumar
- T.Venu

---
Department of Computer Science and Engineering  
Mahatma Gandhi Institute of Technology, Hyderabad
---

## Overview

The system processes live camera feeds using a fine-tuned YOLOv8 model to detect cattle and monitor their position relative to a user-defined virtual boundary. When cattle cross the boundary, an alert is logged to Firebase Firestore and a push notification is sent to the farmer's mobile device via Firebase Cloud Messaging.

The project consists of two components: a Python backend handling detection and alert logic, and a Flutter mobile application for real-time alert monitoring and management.

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
├── .gitignore
├── README.md
└── requirements.txt
```

---

## Tech Stack

**Backend**
- Python 3.10+
- YOLOv8 (Ultralytics)
- OpenCV
- Firebase Admin SDK (Firestore, FCM)
- NumPy

**Mobile**
- Flutter 3.x (Dart)
- Firebase Firestore
- Firebase Cloud Messaging
- Provider (state management)
- Camera plugin

---

## How It Works

1. A camera placed at the farm boundary streams live video to the backend.
2. Each frame is processed by the YOLOv8 model to detect cattle.
3. Detected bounding boxes are checked against the predefined virtual boundary using a point-in-polygon algorithm.
4. If a cattle object's reference point crosses the boundary for a set number of consecutive frames, a violation is recorded.
5. The alert document is written to Firestore with cattle count, camera ID, timestamp, and resolution status.
6. An FCM push notification is dispatched to the farmer's device immediately.
7. The Flutter app displays live alerts, statistics, and allows the farmer to resolve or dismiss incidents.

---

## Alert Schema (Firestore)

| Field             | Type      | Description                        |
|-------------------|-----------|------------------------------------|
| timestamp         | Timestamp | Server-generated event time        |
| cattle_count      | Integer   | Number of cattle detected          |
| cattle_id         | Integer   | Optional individual identifier     |
| boundary_crossed  | Boolean   | True if boundary was violated      |
| camera            | String    | Camera source identifier           |
| resolved          | Boolean   | Whether the alert was acknowledged |

---

## Setup

### Backend

```bash
git clone https://github.com/Altriors/cattle-geofence-project.git
cd cattle-geofence-project
pip install -r requirements.txt
```

Place your Firebase service account key at `backend/firebase/serviceAccountKey.json`, then run:

```bash
python backend/scripts/detect_cattle.py
```

### Mobile App

```bash
cd mobile_app
flutter pub get
flutter run
```

Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is placed in the appropriate directory before building.

---

## Model Training

Open `backend/notebooks/train_yolo.ipynb` in Google Colab. The notebook covers dataset loading, augmentation configuration, YOLOv8 fine-tuning, and weight export. Trained weights are saved to `backend/models/best.pt`.

---

## Performance

| Metric           | Value         |
|------------------|---------------|
| mAP@0.5          | 89%           |
| Precision        | 91%           |
| Recall           | 88%           |
| F1 Score         | 89%           |
| Inference Time   | ~30 ms/frame  |
| Alert Latency    | < 2 seconds   |

---

