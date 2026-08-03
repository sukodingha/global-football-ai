import 'package:equatable/equatable.dart';

/// A football competition (league, cup, etc.).
class CompetitionEntity extends Equatable {
  const CompetitionEntity({
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

  @override
  List<Object?> get props => [id, name, code, type, emblem, country, currentMatchday];
}
