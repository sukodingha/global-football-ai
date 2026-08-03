import 'package:equatable/equatable.dart';

/// A point on the pitch heat map.
class HeatmapPointEntity extends Equatable {
  const HeatmapPointEntity({
    required this.x,
    required this.y,
    required this.intensity,
    this.eventType,
  });

  /// Normalised x-coordinate (0.0 – 1.0, left to right).
  final double x;

  /// Normalised y-coordinate (0.0 – 1.0, top to bottom).
  final double y;

  /// Normalised intensity (0.0 – 1.0, higher = more activity).
  final double intensity;

  /// Optional event type label.
  final String? eventType;

  @override
  List<Object?> get props => [x, y, intensity, eventType];
}
