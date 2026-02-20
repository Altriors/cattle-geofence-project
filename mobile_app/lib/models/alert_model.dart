import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final String id;
  final DateTime timestamp;
  final int cattleCount;
  final bool boundaryCrossed;
  final String camera;
  final bool resolved;
  final int? cattleId;

  Alert({
    required this.id,
    required this.timestamp,
    required this.cattleCount,
    required this.boundaryCrossed,
    required this.camera,
    required this.resolved,
    this.cattleId,
  });

  factory Alert.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Alert(
      id: doc.id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      cattleCount: data['cattle_count'] ?? 0,
      boundaryCrossed: data['boundary_crossed'] ?? false,
      camera: data['camera'] ?? 'Unknown',
      resolved: data['resolved'] ?? false,
      cattleId: data['cattle_id'],
    );
  }
}