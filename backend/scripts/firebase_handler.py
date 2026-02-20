import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
import os

class FirebaseHandler:
    """Handle Firebase operations"""
    
    def __init__(self, key_path='../firebase-key.json'):
        """Initialize Firebase"""
        
        if not firebase_admin._apps:
            if not os.path.exists(key_path):
                print(f" Firebase key not found: {key_path}")
                raise FileNotFoundError("Download from Firebase Console")
            
            cred = credentials.Certificate(key_path)
            firebase_admin.initialize_app(cred)
        
        self.db = firestore.client()
        print(" Firebase connected")
    
    def save_alert(self, cattle_count, crossed=False,cattle_id=None):
        """Save alert to Firestore"""
        alert_data = {
            'timestamp': firestore.SERVER_TIMESTAMP,
            'cattle_count': cattle_count,
            'cattle_id':cattle_id,
            'boundary_crossed': crossed,
            'camera': 'Camera 1',
            'resolved': False
        }
        
        doc_ref = self.db.collection('alerts').add(alert_data)
        print(f" Alert saved: {doc_ref[1].id}")
        return doc_ref[1].id
    
    def test_connection(self):
        """Test Firebase"""
        test_ref = self.db.collection('system').document('test')
        test_ref.set({
            'message': 'Connection successful',
            'timestamp': firestore.SERVER_TIMESTAMP
        })
        print(" Firestore write: OK")
        
        doc = test_ref.get()
        if doc.exists:
            print(f"✓ Firestore read: OK - {doc.to_dict()['message']}")
        return True

if __name__ == "__main__":
    print("Testing Firebase...")
    fb = FirebaseHandler()
    fb.test_connection()
    print("\n Firebase ready!")