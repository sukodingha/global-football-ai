import 'package:equatable/equatable.dart';

/// A row in a fantasy leaderboard (global or league-specific).
class LeaderboardEntryEntity extends Equatable {
  const LeaderboardEntryEntity({
    required this.teamId,
    required this.teamName,
    required this.userId,
    required this.userName,
    required this.totalPoints,
    this.rank = 0,
    this.gameweekPoints = 0,
  });

  final String teamId;
  final String teamName;
  final String userId;
  final String userName;

  /// Rank position; 1 = first.
  final int rank;
  final double totalPoints;

  /// Points earned in the current gameweek (for dynamic movement).
  final double gameweekPoints;

  LeaderboardEntryEntity copyWith({
    String? teamName,
    String? userName,
    int? rank,
    double? totalPoints,
    double? gameweekPoints,
  }) {
    return LeaderboardEntryEntity(
      teamId: teamId,
      teamName: teamName ?? this.teamName,
      userId: userId,
      userName: userName ?? this.userName,
      rank: rank ?? this.rank,
      totalPoints: totalPoints ?? this.totalPoints,
      gameweekPoints: gameweekPoints ?? this.gameweekPoints,
    );
  }

  @override
  List<Object?> get props => [
        teamId,
        teamName,
        userId,
        userName,
        rank,
        totalPoints,
        gameweekPoints,
      ];
}

