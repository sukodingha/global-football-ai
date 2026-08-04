import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/entities/user_badge_entity.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_data_source.dart';

/// Implementation of [CommunityRepository] backed by Firestore.
class CommunityRepositoryImpl implements CommunityRepository {
  CommunityRepositoryImpl({required CommunityRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final CommunityRemoteDataSource _dataSource;

  Future<T> _safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Exception catch (e) {
      throw _mapException(e);
    }
  }

  Failure _mapException(Exception e) {
    final message = e.toString();
    if (e is NetworkException || message.contains('network')) {
      return Failure.networkFailure(message: message);
    }
    if (e is CacheException || message.contains('cache')) {
      return Failure.cacheFailure(message: message);
    }
    if (e is AuthenticationException || message.contains('sign in')) {
      return Failure.serverFailure(message: message);
    }
    return Failure.unknown(message: message);
  }

  @override
  Stream<List<CommunityPostEntity>> watchFeed({int limit = 50}) {
    return _dataSource.watchFeed(limit: limit);
  }

  @override
  Future<List<CommunityPostEntity>> getFeed({int limit = 50}) {
    return _safeCall(() => _dataSource.getFeed(limit: limit));
  }

  @override
  Future<CommunityPostEntity> createPost({
    required String userId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
    String? analysisId,
    int? matchId,
    String? matchLabel,
  }) {
    return _safeCall(() => _dataSource.createPost(
          userId: userId,
          authorName: authorName,
          authorPhotoUrl: authorPhotoUrl,
          content: content,
          analysisId: analysisId,
          matchId: matchId,
          matchLabel: matchLabel,
        ));
  }

  @override
  Future<(int, bool)> toggleLike({
    required String postId,
    required String userId,
  }) {
    return _safeCall(() => _dataSource.toggleLike(
          postId: postId,
          userId: userId,
        ));
  }

  @override
  Stream<List<CommentEntity>> watchComments(String postId) {
    return _dataSource.watchComments(postId);
  }

  @override
  Future<CommentEntity> addComment({
    required String postId,
    required String userId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  }) {
    return _safeCall(() => _dataSource.addComment(
          postId: postId,
          userId: userId,
          authorName: authorName,
          authorPhotoUrl: authorPhotoUrl,
          content: content,
        ));
  }

  @override
  Future<List<UserBadgeEntity>> getBadges(String userId) {
    return _safeCall(() => _dataSource.getBadges(userId));
  }

  @override
  Future<List<UserBadgeEntity>> getMyBadges(String userId) {
    return _safeCall(() => _dataSource.getMyBadges(userId));
  }
}
