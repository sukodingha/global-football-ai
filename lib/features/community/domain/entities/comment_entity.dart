import 'package:equatable/equatable.dart';

/// A comment on a community post.
class CommentEntity extends Equatable {
  const CommentEntity({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.content,
    required this.createdAt,
    this.authorBadges = const [],
  });

  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final DateTime createdAt;
  final List<String> authorBadges;

  @override
  List<Object?> get props => [
        id,
        postId,
        authorId,
        authorName,
        authorPhotoUrl,
        content,
        createdAt,
        authorBadges,
      ];
}
