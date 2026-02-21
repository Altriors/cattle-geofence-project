import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final String id;
  final DateTime timestamp;
  final int cattleCount;
  final int? cattleId;
  final bool boundaryCrossed;
  final String camera;
  final bool resolved;

  Alert({
    required this.id,
    required this.timestamp,
    required this.cattleCount,
    this.cattleId,
    required this.boundaryCrossed,
    required this.camera,
    required this.resolved,
  });

  /// Create Alert from Firestore document
  factory Alert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Alert(
      id: doc.id,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cattleCount: (data['cattle_count'] as num?)?.toInt() ?? 0,
      cattleId: (data['cattle_id'] as num?)?.toInt(),
      boundaryCrossed: data['boundary_crossed'] ?? false,
      camera: data['camera'] ?? 'Unknown Camera',
      resolved: data['resolved'] ?? false,
    );
  }

  /// Convert Alert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'cattle_count': cattleCount,
      'cattle_id': cattleId,
      'boundary_crossed': boundaryCrossed,
      'camera': camera,
      'resolved': resolved,
    };
  }

  /// Copy with updated fields
  Alert copyWith({
    String? id,
    DateTime? timestamp,
    int? cattleCount,
    int? cattleId,
    bool? boundaryCrossed,
    String? camera,
    bool? resolved,
  }) {
    return Alert(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      cattleCount: cattleCount ?? this.cattleCount,
      cattleId: cattleId ?? this.cattleId,
      boundaryCrossed: boundaryCrossed ?? this.boundaryCrossed,
      camera: camera ?? this.camera,
      resolved: resolved ?? this.resolved,
    );
  }

  @override
  String toString() {
    return 'Alert(id: $id, cattleCount: $cattleCount, boundaryCrossed: $boundaryCrossed, resolved: $resolved)';
  }
}