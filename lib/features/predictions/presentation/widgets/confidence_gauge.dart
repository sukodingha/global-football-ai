import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A circular confidence gauge showing a 0-100 percentage.
class ConfidenceGauge extends StatelessWidget {
  const ConfidenceGauge({
    super.key,
    required this.confidence,
    this.size = 96,
  });

  /// Confidence percentage 0-100.
  final double confidence;
  final double size;

  @override
  Widget build(BuildContext context) {
    final clamped = confidence.clamp(0, 100).toDouble();
    final color = _colorFor(clamped);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: clamped / 100,
            strokeWidth: 8,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
        ),
        SizedBox(
          width: size * 0.72,
          height: size * 0.72,
          child: CustomPaint(painter: _InnerShadowPainter(color)),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${clamped.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              'confidence',
              style: TextStyle(
                fontSize: size * 0.09,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _colorFor(double value) {
    if (value >= 70) return const Color(0xFF2E7D32); // Green
    if (value >= 50) return const Color(0xFFF9A825); // Amber
    return const Color(0xFFC62828); // Red
  }
}

/// Simple inner arc painter to give the gauge depth.
class _InnerShadowPainter extends CustomPainter {
  const _InnerShadowPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color.withOpacity(0.35);
    final arc = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    canvas.drawArc(arc, math.pi * 0.75, math.pi * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant _InnerShadowPainter oldDelegate) =>
      oldDelegate.color != color;
}
