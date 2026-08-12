import 'package:cloud_firestore/cloud_firestore.dart';

import   '../../../../core/errors/exceptions.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/entities/user_badge_entity.dart';

/// Cloud Firestore-backed data source for the community wall.
///
/// Provides real-time post feed, likes, comments, and user profile badges.
class CommunityRemoteDataSource {
  CommunityRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('community_posts');

  CollectionReference<Map<String, dynamic>> _commentsFor(String postId) =>
      _posts.doc(postId).collection('comments');

  CollectionReference<Map<String, dynamic>> _likesFor(String postId) =>
      _posts.doc(postId).collection('likes');

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  // ─── Feed (real-time) ─────────────────────────────────────────────

  Stream<List<CommunityPostEntity>> watchFeed({int limit = 50}) {
    return _posts
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _postFromDoc(doc))
            .toList());
  }

  Future<List<CommunityPostEntity>> getFeed({int limit = 50}) async {
    try {
      final snapshot = await _posts
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => _postFromDoc(doc)).toList();
    } catch (e) {
      throw CacheException('Unable to load community feed: $e');
    }
  }

  // ─── Posts ────────────────────────────────────────────────────────

  Future<CommunityPostEntity> createPost({
    required String userId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
    String? analysisId,
    int? matchId,
    String? matchLabel,
  }) async {
    try {
      final docRef = _posts.doc();
      final now = DateTime.now();
      final badges = await _getBadgeIds(userId);

      await docRef.set({
        'id': docRef.id,
        'authorId': userId,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'content': content,
        'analysisId': analysisId,
        'matchId': matchId,
        'matchLabel': matchLabel,
        'likeCount': 0,
        'commentCount': 0,
        'authorBadges': badges,
        'createdAt': Timestamp.fromDate(now),
      });

      return CommunityPostEntity(
        id: docRef.id,
        authorId: userId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        content: content,
        createdAt: now,
        analysisId: analysisId,
        matchId: matchId,
        matchLabel: matchLabel,
        authorBadges: badges,
      );
    } catch (e) {
      throw CacheException('Unable to create post: $e');
    }
  }

  // ─── Likes ────────────────────────────────────────────────────────

  Future<(int, bool)> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      final likeDoc = _likesFor(postId).doc(userId);
      final existing = await likeDoc.get();
      final postRef = _posts.doc(postId);

      if (existing.exists) {
        // Unlike.
        await likeDoc.delete();
        await _incrementCounter(postRef, 'likeCount', -1);
        final post = await postRef.get();
        final count = (post.data()?['likeCount'] as num?)?.toInt() ?? 0;
        return (count, false);
      } else {
        // Like.
        await likeDoc.set({
          'userId': userId,
          'likedAt': Timestamp.fromDate(DateTime.now()),
        });
        await _incrementCounter(postRef, 'likeCount', 1);
        final post = await postRef.get();
        final count = (post.data()?['likeCount'] as num?)?.toInt() ?? 0;
        return (count, true);
      }
    } catch (e) {
      throw CacheException('Unable to update like: $e');
    }
  }

  Future<void> _incrementCounter(
    DocumentReference<Map<String, dynamic>> ref,
    String field,
    int delta,
  ) async {
    await ref.update({field: FieldValue.increment(delta)});
  }

  // ─── Comments (real-time) ─────────────────────────────────────────

  Stream<List<CommentEntity>> watchComments(String postId) {
    return _commentsFor(postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _commentFromDoc(doc))
            .toList());
  }

  Future<CommentEntity> addComment({
    required String postId,
    required String userId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  }) async {
    try {
      final docRef = _commentsFor(postId).doc();
      final now = DateTime.now();
      final badges = await _getBadgeIds(userId);

      await docRef.set({
        'id': docRef.id,
        'postId': postId,
        'authorId': userId,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'content': content,
        'authorBadges': badges,
        'createdAt': Timestamp.fromDate(now),
      });

      await _incrementCounter(_posts.doc(postId), 'commentCount', 1);

      return CommentEntity(
        id: docRef.id,
        postId: postId,
        authorId: userId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        content: content,
        createdAt: now,
        authorBadges: badges,
      );
    } catch (e) {
      throw CacheException('Unable to add comment: $e');
    }
  }

  // ─── Badges ───────────────────────────────────────────────────────

  Future<List<String>> _getBadgeIds(String userId) async {
    try {
      final doc = await _userDoc(userId).get();
      final badges = doc.data()?['badges'] as List<dynamic>? ?? const [];
      return badges.cast<String>();
    } catch (_) {
      return const [];
    }
  }

  Future<List<UserBadgeEntity>> getBadges(String userId) async {
    try {
      final ids = await _getBadgeIds(userId);
      return ids.map(_badgeFromId).toList();
    } catch (e) {
      throw CacheException('Unable to load badges: $e');
    }
  }

  Future<List<UserBadgeEntity>> getMyBadges(String userId) async {
    return getBadges(userId);
  }

  /// A known badge directory. Badges are stored as ids on the user profile
  /// and resolved here for display.
  static UserBadgeEntity _badgeFromId(String id) {
    switch (id) {
      case 'early_adopter':
        return const UserBadgeEntity(
          id: 'early_adopter',
          name: 'Early Adopter',
          icon: 'rocket_launch',
          description: 'Joined during the early access phase.',
        );
      case 'top_analyst':
        return const UserBadgeEntity(
          id: 'top_analyst',
          name: 'Top Analyst',
          icon: 'insights',
          description: 'Recognised for accurate predictions.',
        );
      case 'premium_member':
        return const UserBadgeEntity(
          id: 'premium_member',
          name: 'Premium Member',
          icon: 'workspace_premium',
          description: 'Unlocked premium AI features.',
        );
      case 'contributor':
        return const UserBadgeEntity(
          id: 'contributor',
          name: 'Contributor',
          icon: 'forum',
          description: 'Active community contributor.',
        );
      default:
        return UserBadgeEntity(id: id, name: id, icon: 'star');
    }
  }

  // ─── Parsers ──────────────────────────────────────────────────────

  CommunityPostEntity _postFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return CommunityPostEntity(
      id: data['id'] as String? ?? doc.id,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Unknown',
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      content: data['content'] as String? ?? '',
      createdAt: _timestamp(data['createdAt']),
      analysisId: data['analysisId'] as String?,
      matchId: (data['matchId'] as num?)?.toInt(),
      matchLabel: data['matchLabel'] as String?,
      likeCount: (data['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
      authorBadges:
          (data['authorBadges'] as List<dynamic>? ?? const []).cast<String>(),
    );
  }

  CommentEntity _commentFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return CommentEntity(
      id: data['id'] as String? ?? doc.id,
      postId: data['postId'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Unknown',
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      content: data['content'] as String? ?? '',
      createdAt: _timestamp(data['createdAt']),
      authorBadges:
          (data['authorBadges'] as List<dynamic>? ?? const []).cast<String>(),
    );
  }

  DateTime _timestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
