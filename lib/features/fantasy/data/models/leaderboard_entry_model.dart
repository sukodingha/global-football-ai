import '../../domain/entities/leaderboard_entry_entity.dart';

/// JSON model for [LeaderboardEntryEntity].
class LeaderboardEntryModel {
  const LeaderboardEntryModel({
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
  final int rank;
  final double totalPoints;
  final double gameweekPoints;

  Map<String, dynamic> toJson() => {
        'teamId': teamId,
        'teamName': teamName,
        'userId': userId,
        'userName': userName,
        'rank': rank,
        'totalPoints': totalPoints,
        'gameweekPoints': gameweekPoints,
      };

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      teamId: json['teamId'] as String? ?? '',
      teamName: json['teamName'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      totalPoints: (json['totalPoints'] as num?)?.toDouble() ?? 0,
      gameweekPoints: (json['gameweekPoints'] as num?)?.toDouble() ?? 0,
    );
  }

  LeaderboardEntryEntity toEntity() => LeaderboardEntryEntity(
        teamId: teamId,
        teamName: teamName,
        userId: userId,
        userName: userName,
        rank: rank,
        totalPoints: totalPoints,
        gameweekPoints: gameweekPoints,
      );

  factory LeaderboardEntryModel.fromEntity(LeaderboardEntryEntity entity) =>
      LeaderboardEntryModel(
        teamId: entity.teamId,
        teamName: entity.teamName,
        userId: entity.userId,
        userName: entity.userName,
        rank: entity.rank,
        totalPoints: entity.totalPoints,
        gameweekPoints: entity.gameweekPoints,
      );
}

