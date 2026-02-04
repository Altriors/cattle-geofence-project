from ultralytics import YOLO
import os

def train_cattle_detector():
    """
    Train YOLO model on cattle dataset
    """
    print("="*50)
    print("CATTLE DETECTION MODEL TRAINING")
    print("="*50)
    
    # Load pre-trained YOLOv8 nano model
    print("\n[1/5] Loading pre-trained YOLOv8n model...")
    model = YOLO('yolov8n.pt')  # Smallest, fastest
    
    # Path to dataset config
    data_yaml = '../dataset/data.yaml'
    
    # Check if dataset exists
    if not os.path.exists(data_yaml):
        print("❌ ERROR: data.yaml not found!")
        print(f"Expected location: {os.path.abspath(data_yaml)}")
        return
    
    print("✓ Dataset config found")
    
    # Training parameters
    print("\n[2/5] Setting training parameters...")
    epochs = 50           # Number of training cycles
    batch_size = 16       # Images per batch (reduce if out of memory)
    img_size = 640        # Image size
    
    print(f"  - Epochs: {epochs}")
    print(f"  - Batch size: {batch_size}")
    print(f"  - Image size: {img_size}")
    
    # Start training
    print("\n[3/5] Starting training...")
    print("This will take 30-60 minutes on GPU, 4-6 hours on CPU")
    print("-"*50)
    
    results = model.train(
        data=data_yaml,
        epochs=epochs,
        imgsz=img_size,
        batch=batch_size,
        name='cattle_detector',
        patience=10,          # Early stopping
        save=True,
        device='cpu',         # Change to 0 for GPU
        verbose=True
    )
    
    print("\n[4/5] Training completed!")
    
    # Validate model
    print("\n[5/5] Validating model...")
    metrics = model.val()
    
    print("\n" + "="*50)
    print("TRAINING RESULTS")
    print("="*50)
    print(f"mAP50: {metrics.box.map50:.3f}")
    print(f"mAP50-95: {metrics.box.map:.3f}")
    print(f"Precision: {metrics.box.mp:.3f}")
    print(f"Recall: {metrics.box.mr:.3f}")
    
    # Model saved location
    print("\n📁 Trained model saved at:")
    print("   runs/detect/cattle_detector/weights/best.pt")
    
    print("\n✅ Training complete!")
    print("\nNext steps:")
    print("1. Copy best.pt to backend/models/")
    print("2. Test detection with detect_cattle.py")

if __name__ == "__main__":
    train_cattle_detector()