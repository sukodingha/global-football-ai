import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/post_match_comparison_entity.dart';
import '../../domain/entities/prediction_entity.dart';
import '../../domain/entities/prediction_history_entity.dart';
import '../../domain/entities/user_vote_entity.dart';
import '../models/post_match_comparison_model.dart';
import '../models/prediction_history_model.dart';

/// Local data source backed by Cloud Firestore.
///
/// Persists prediction history, votes, and comparison results securely per
/// authenticated user. Firestore rules enforce per-user access.
class PredictionLocalDataSource {
  PredictionLocalDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userHistory(String userId) =>
      _firestore.collection('users').doc(userId).collection('predictions');

  CollectionReference<Map<String, dynamic>> _votes(String predictionId) =>
      _firestore
          .collection('predictions')
          .doc(predictionId)
          .collection('votes');

  // ─── History ──────────────────────────────────────────────────────

  Future<List<PredictionHistoryEntity>> getHistory(String userId,
      {int limit = 50}) async {
    try {
      final snapshot = await _userHistory(userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => PredictionHistoryModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      throw CacheException('Unable to load prediction history: $e');
    }
  }

  Future<void> saveHistory({
    required String userId,
    required MatchPredictionEntity prediction,
    DateTime? matchDate,
  }) async {
    try {
      final model = PredictionHistoryModel.fromEntity(
        entity: PredictionHistoryEntity(
          id: '${prediction.matchId}_${DateTime.now().millisecondsSinceEpoch}',
          matchId: prediction.matchId,
          homeTeam: prediction.homeTeam,
          awayTeam: prediction.awayTeam,
          prediction: prediction,
          createdAt: DateTime.now(),
          matchDate: matchDate,
        ),
        userId: userId,
      );

      await _userHistory(userId).doc(model.id).set(model.toJson());
    } catch (e) {
      throw CacheException('Unable to save prediction to history: $e');
    }
  }

  Future<void> resolvePrediction({
    required String historyId,
    required String userId,
    required bool isCorrect,
  }) async {
    try {
      await _userHistory(userId).doc(historyId).update({
        'status': isCorrect ? 'won' : 'lost',
        'isCorrect': isCorrect,
      });
    } catch (e) {
      throw CacheException('Unable to resolve prediction: $e');
    }
  }

  // ─── Votes ────────────────────────────────────────────────────────

  Future<VoteCountsEntity> voteOnPrediction({
    required String predictionId,
    required String userId,
    required String vote,
  }) async {
    try {
      final docRef = _votes(predictionId).doc(userId);
      final existing = await docRef.get();

      if (existing.exists) {
        final previous = existing.data()?['vote'] as String? ?? 'neutral';
        if (previous == vote) {
          // Toggle to neutral.
          vote = 'neutral';
        }
        await docRef.set({
          'vote': vote,
          'votedAt': DateTime.now(),
          'previousVote': previous,
        });
      } else {
        await docRef.set({
          'vote': vote,
          'votedAt': DateTime.now(),
          'previousVote': null,
        });
      }

      return await _voteCounts(predictionId);
    } catch (e) {
      throw CacheException('Unable to submit vote: $e');
    }
  }

  Future<VoteCountsEntity> _voteCounts(String predictionId) async {
    final snapshot = await _votes(predictionId).get();
    var upvotes = 0;
    var downvotes = 0;
    for (final doc in snapshot.docs) {
      final vote = doc.data()['vote'] as String?;
      if (vote == 'up') upvotes++;
      if (vote == 'down') downvotes++;
    }
    return VoteCountsEntity(
      upvotes: upvotes,
      downvotes: downvotes,
      totalVotes: upvotes + downvotes,
    );
  }

  Future<(VoteCountsEntity, String?)> getVoteState({
    required String predictionId,
    required String userId,
  }) async {
    try {
      final counts = await _voteCounts(predictionId);
      final doc = await _votes(predictionId).doc(userId).get();
      final myVote = doc.exists ? (doc.data()?['vote'] as String?) : null;
      return (counts, myVote);
    } catch (e) {
      throw CacheException('Unable to load vote state: $e');
    }
  }

  // ─── Comparisons ──────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _userComparisons(String userId) =>
      _firestore.collection('users').doc(userId).collection('comparisons');

  Future<void> saveComparison({
    required String userId,
    required PostMatchComparisonEntity comparison,
  }) async {
    try {
      final model = PostMatchComparisonModel.fromEntity(
        entity: comparison,
        userId: userId,
      );
      await _userComparisons(userId).doc(model.id).set(model.toJson());
    } catch (e) {
      throw CacheException('Unable to save comparison: $e');
    }
  }

  Future<List<PostMatchComparisonEntity>> getComparisons(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _userComparisons(userId)
          .orderBy('comparisonDate', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map(
              (doc) => PostMatchComparisonModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      throw CacheException('Unable to load comparisons: $e');
    }
  }

  /// Auto-resolves the 'correct' field on a history record using the
  /// comparison accuracy. Predictions with overallAccuracy >= 50 are
  /// considered correct, otherwise they are marked as lost. Pending
  /// predictions with an explicit actual scoreline are resolved directly.
  Future<void> resolvePendingPredictions(String userId) async {
    try {
      final snapshot = await _userHistory(userId)
          .where('status', isEqualTo: 'pending')
          .get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final actualHome = data['actualHomeScore'] as int?;
        final actualAway = data['actualAwayScore'] as int?;
        if (actualHome == null || actualAway == null) continue;

        final predictionMap = data['prediction'];
        String? predicted;
        if (predictionMap is Map) {
          final winner = predictionMap['matchWinner'];
          if (winner is Map) {
            final outcome = winner['predictedOutcome'];
            if (outcome is String) {
              predicted = outcome;
            }
          }
        }

        final bool isCorrect;
        if (actualHome > actualAway) {
          isCorrect = predicted == 'home';
        } else if (actualAway > actualHome) {
          isCorrect = predicted == 'away';
        } else {
          isCorrect = predicted == 'draw';
        }
        await doc.reference.update({
          'status': isCorrect ? 'won' : 'lost',
          'isCorrect': isCorrect,
        });
      }
    } catch (e) {
      throw CacheException('Unable to resolve pending predictions: $e');
    }
  }

  // ─── Accuracy stats ───────────────────────────────────────────────

  Future<AccuracyStatsEntity> getAccuracyStats(String userId) async {
    try {
      final snapshot = await _userHistory(userId).get();
      var total = 0;
      var correct = 0;
      var incorrect = 0;
      var voided = 0;

      for (final doc in snapshot.docs) {
        final status = doc.data()['status'] as String? ?? 'pending';
        total++;
        switch (status) {
          case 'won':
            correct++;
            break;
          case 'lost':
            incorrect++;
            break;
          case 'voided':
            voided++;
            break;
        }
      }

      return AccuracyStatsEntity(
        totalPredictions: total,
        correctPredictions: correct,
        incorrectPredictions: incorrect,
        voidedPredictions: voided,
      );
    } catch (e) {
      throw CacheException('Unable to load accuracy stats: $e');
    }
  }
}
