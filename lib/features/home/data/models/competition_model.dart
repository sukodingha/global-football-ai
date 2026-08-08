import '../../domain/entities/competition_entity.dart';

/// Data model for a competition, mapped from the football-data.org API.
class CompetitionModel {
  const CompetitionModel({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    this.emblem,
    this.country,
    this.currentMatchday,
  });

  final int id;
  final String name;
  final String code;
  final String type;
  final String? emblem;
  final String? country;
  final int? currentMatchday;

  /// Parses a competition from the football-data.org API response.
  factory CompetitionModel.fromJson(Map<String, dynamic> json) {
    final area = json['area'] as Map<String, dynamic>? ?? const {};
    return CompetitionModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      code: json['code'] as String? ?? 'N/A',
      type: json['type'] as String? ?? 'LEAGUE',
      emblem: json['emblem'] as String?,
      country: area['name'] as String?,
      currentMatchday: json['currentMatchday'] as int?,
    );
  }

  /// Converts to a domain entity.
  CompetitionEntity toEntity() {
    return CompetitionEntity(
      id: id,
      name: name,
      code: code,
      type: type,
      emblem: emblem,
      country: country,
      currentMatchday: currentMatchday,
    );
  }
}
