import 'package:equatable/equatable.dart';

/// A user's vote on a prediction.
class UserVoteEntity extends Equatable {
  const UserVoteEntity({
    required this.predictionId,
    required this.userId,
    required this.vote,
    required this.votedAt,
    this.previousVote,
  });

  final String predictionId;
  final String userId;

  /// 'up' | 'down' | 'neutral'
  final String vote;
  final DateTime votedAt;

  /// The prior vote before this one, if any.
  final String? previousVote;

  @override
  List<Object?> get props =>
      [predictionId, userId, vote, votedAt, previousVote];

  UserVoteEntity copyWith({
    String? predictionId,
    String? userId,
    String? vote,
    DateTime? votedAt,
    String? previousVote,
  }) {
    return UserVoteEntity(
      predictionId: predictionId ?? this.predictionId,
      userId: userId ?? this.userId,
      vote: vote ?? this.vote,
      votedAt: votedAt ?? this.votedAt,
      previousVote: previousVote ?? this.previousVote,
    );
  }
}

/// Aggregate vote counts for a prediction.
class VoteCountsEntity extends Equatable {
  const VoteCountsEntity({
    required this.upvotes,
    required this.downvotes,
    required this.totalVotes,
  });

  final int upvotes;
  final int downvotes;
  final int totalVotes;

  /// Percentage of upvotes 0-100.
  double get approvalPercentage {
    if (totalVotes == 0) return 0;
    return (upvotes / totalVotes) * 100;
  }

  @override
  List<Object?> get props => [upvotes, downvotes, totalVotes];
}
