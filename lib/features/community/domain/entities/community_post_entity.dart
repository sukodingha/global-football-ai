import 'package:equatable/equatable.dart';

/// A user's post on the community wall.
class CommunityPostEntity extends Equatable {
  const CommunityPostEntity({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.content,
    required this.createdAt,
    this.analysisId,
    this.matchId,
    this.matchLabel,
    this.likeCount = 0,
    this.commentCount = 0,
    this.likedByMe = false,
    this.authorBadges = const [],
  });

  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final DateTime createdAt;

  /// Optional linked prediction analysis id.
  final String? analysisId;

  /// Optional linked match id.
  final int? matchId;

  /// Optional match label for display.
  final String? matchLabel;

  final int likeCount;
  final int commentCount;
  final bool likedByMe;
  final List<String> authorBadges;

  @override
  List<Object?> get props => [
        id,
        authorId,
        authorName,
        authorPhotoUrl,
        content,
        createdAt,
        analysisId,
        matchId,
        matchLabel,
        likeCount,
        commentCount,
        likedByMe,
        authorBadges,
      ];

  CommunityPostEntity copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? content,
    DateTime? createdAt,
    String? analysisId,
    int? matchId,
    String? matchLabel,
    int? likeCount,
    int? commentCount,
    bool? likedByMe,
    List<String>? authorBadges,
  }) {
    return CommunityPostEntity(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      analysisId: analysisId ?? this.analysisId,
      matchId: matchId ?? this.matchId,
      matchLabel: matchLabel ?? this.matchLabel,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      likedByMe: likedByMe ?? this.likedByMe,
      authorBadges: authorBadges ?? this.authorBadges,
    );
  }
}
