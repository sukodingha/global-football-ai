import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/heatmap_entity.dart';

/// Displays a football pitch heat map.
///
/// Each [HeatmapPointEntity] has normalized x/y (0.0–1.0) and intensity
/// (0.0–1.0). Points are rendered as translucent circles on a pitch
/// background, with higher intensity producing a larger, more opaque dot.
class HeatmapView extends StatelessWidget {
  const HeatmapView({
    super.key,
    required this.points,
    this.homeName = 'Home',
    this.awayName = 'Away',
    this.height = 240,
  });

  final List<HeatmapPointEntity> points;
  final String homeName;
  final String awayName;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(homeName, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('Activity', style: TextStyle(color: Colors.grey)),
              Text(awayName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              size: Size.fromHeight(height),
              painter: _PitchPainter(points: points),
            ),
          ),
        ),
        if (points.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Heat map data not yet available for this match.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}

class _PitchPainter extends CustomPainter {
  _PitchPainter({required this.points});
  final List<HeatmapPointEntity> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);

    // Draw the pitch markings.
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final w = size.width;
    final h = size.height;

    // Outer boundary.
    canvas.drawRect(
      Rect.fromLTWH(2, 2, w - 4, h - 4),
      linePaint,
    );

    // Halfway line.
    canvas.drawLine(Offset(w / 2, 2), Offset(w / 2, h - 2), linePaint);

    // Centre circle.
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      math.min(w, h) * 0.12,
      linePaint,
    );

    // Penalty areas.
    final boxW = w * 0.2;
    final boxH = h * 0.5;
    canvas.drawRect(
      Rect.fromLTWH(2, h / 2 - boxH / 2, boxW, boxH),
      linePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w - boxW - 2, h / 2 - boxH / 2, boxW, boxH),
      linePaint,
    );

    // Goal areas.
    final goalW = w * 0.08;
    final goalH = h * 0.2;
    canvas.drawRect(
      Rect.fromLTWH(2, h / 2 - goalH / 2, goalW, goalH),
      linePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w - goalW - 2, h / 2 - goalH / 2, goalW, goalH),
      linePaint,
    );

    // Draw the heat points.
    for (final point in points) {
      final dx = (point.x * w).clamp(0.0, w.toDouble());
      final dy = (point.y * h).clamp(0.0, h.toDouble());
      final radius = 4 + (point.intensity * 10);

      final heatPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFF5722),
          const Color(0xFFFFEB3B),
          point.intensity,
        )!.withOpacity(0.25 + point.intensity * 0.4);

      canvas.drawCircle(Offset(dx, dy), radius, heatPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
