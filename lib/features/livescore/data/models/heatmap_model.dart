import '../../domain/entities/heatmap_entity.dart';

/// Data model for a single heat map coordinate point.
class HeatmapPointModel {
  const HeatmapPointModel({
    required this.x,
    required this.y,
    required this.intensity,
    this.eventType,
  });

  final double x;
  final double y;
  final double intensity;
  final String? eventType;

  /// Parses a heat map point from a (x, y, intensity) API response.
  factory HeatmapPointModel.fromCoord({
    required double x,
    required double y,
    required double intensity,
    String? eventType,
  }) {
    return HeatmapPointModel(
      x: x.clamp(0.0, 1.0),
      y: y.clamp(0.0, 1.0),
      intensity: intensity.clamp(0.0, 1.0),
      eventType: eventType,
    );
  }

  HeatmapPointEntity toEntity() {
    return HeatmapPointEntity(
      x: x,
      y: y,
      intensity: intensity,
      eventType: eventType,
    );
  }
}
