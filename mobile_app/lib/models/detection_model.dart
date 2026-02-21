class DetectionModel {
  final String id;
  final int cattleCount;
  final List<BoundingBox> boundingBoxes;
  final bool boundaryCrossed;
  final double confidence;
  final DateTime detectedAt;

  DetectionModel({
    required this.id,
    required this.cattleCount,
    required this.boundingBoxes,
    required this.boundaryCrossed,
    required this.confidence,
    required this.detectedAt,
  });

  factory DetectionModel.fromMap(Map<String, dynamic> map) {
    return DetectionModel(
      id: map['id'] ?? '',
      cattleCount: map['cattle_count'] ?? 0,
      boundingBoxes: (map['bounding_boxes'] as List<dynamic>?)
              ?.map((b) => BoundingBox.fromMap(b))
              .toList() ??
          [],
      boundaryCrossed: map['boundary_crossed'] ?? false,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      detectedAt: map['detected_at'] != null
          ? DateTime.parse(map['detected_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'cattle_count': cattleCount,
        'bounding_boxes': boundingBoxes.map((b) => b.toMap()).toList(),
        'boundary_crossed': boundaryCrossed,
        'confidence': confidence,
        'detected_at': detectedAt.toIso8601String(),
      };
}

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;
  final double confidence;
  final int? cattleId;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
    this.cattleId,
  });

  factory BoundingBox.fromMap(Map<String, dynamic> map) => BoundingBox(
        x: (map['x'] as num).toDouble(),
        y: (map['y'] as num).toDouble(),
        width: (map['width'] as num).toDouble(),
        height: (map['height'] as num).toDouble(),
        confidence: (map['confidence'] as num).toDouble(),
        cattleId: map['cattle_id'],
      );

  Map<String, dynamic> toMap() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'confidence': confidence,
        'cattle_id': cattleId,
      };
}