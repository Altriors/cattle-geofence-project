import 'package:flutter/material.dart';

class BoundaryLinePainter extends CustomPainter {
  /// Boundary points as fractions of screen size (0.0 to 1.0)
  final List<Offset> boundaryPoints;
  final Color color;
  final bool isAlert;

  const BoundaryLinePainter({
    required this.boundaryPoints,
    this.color = const Color(0xFF4CAF50),
    this.isAlert = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (boundaryPoints.length < 2) return;

    final paint = Paint()
      ..color = isAlert ? const Color(0xFFE53935) : color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = (isAlert
              ? const Color(0xFFE53935)
              : color)
          .withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Convert fractional points to actual pixel positions
    final path = Path();
    final scaledPoints = boundaryPoints
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    path.moveTo(scaledPoints.first.dx, scaledPoints.first.dy);
    for (int i = 1; i < scaledPoints.length; i++) {
      path.lineTo(scaledPoints[i].dx, scaledPoints[i].dy);
    }
    path.close();

    // Draw fill
    canvas.drawPath(path, fillPaint);
    // Draw border
    canvas.drawPath(path, paint);

    // Draw corner dots
    final dotPaint = Paint()
      ..color = isAlert ? const Color(0xFFE53935) : color
      ..style = PaintingStyle.fill;

    for (final point in scaledPoints) {
      canvas.drawCircle(point, 5, dotPaint);
    }

    // Draw "BOUNDARY" label
    _drawLabel(canvas, scaledPoints.first, isAlert ? 'ALERT ZONE' : 'BOUNDARY');
  }

  void _drawLabel(Canvas canvas, Offset position, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isAlert ? const Color(0xFFE53935) : const Color(0xFF4CAF50),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx + 8, position.dy - 20),
    );
  }

  @override
  bool shouldRepaint(BoundaryLinePainter oldDelegate) =>
      oldDelegate.boundaryPoints != boundaryPoints ||
      oldDelegate.isAlert != isAlert;
}