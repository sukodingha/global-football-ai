/// Raw metric DTOs consumed by the analytics engine.
///
/// These are lightweight, Firestore-decoded representations of the raw
/// platform data used to compute aggregates. Kept separate from domain
/// entities because they map 1:1 to Firestore documents rather than to
/// business concepts.

/// A raw user metric from the `users` collection.
class RawUserMetric {
  const RawUserMetric({
    required this.userId,
    this.createdAt,
    this.lastActiveAt,
    this.isBanned = false,
  });

  final String userId;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;
  final bool isBanned;
}

/// A raw community post metric.
class RawPostMetric {
  const RawPostMetric({
    required this.postId,
    required this.commentCount,
    this.createdAt,
  });

  final String postId;
  final int commentCount;
  final DateTime? createdAt;
}

/// A raw prediction metric for accuracy tracking.
class RawPredictionMetric {
  const RawPredictionMetric({
    required this.predictionId,
    required this.createdAt,
    this.competitionName = '',
    this.isCorrect,
  });

  final String predictionId;
  final DateTime createdAt;
  final String competitionName;
  final bool? isCorrect;
}

/// A raw user action metric (for engagement series).
class RawActionMetric {
  const RawActionMetric({
    required this.actionId,
    required this.timestamp,
  });

  final String actionId;
  final DateTime timestamp;
}

/// A raw payment transaction metric.
class RawTransactionMetric {
  const RawTransactionMetric({
    required this.reference,
    required this.amountKobo,
    required this.status,
    required this.createdAt,
    this.planName,
  });

  final String reference;
  final int amountKobo;
  final String status;
  final DateTime createdAt;
  final String? planName;
}

/// A raw subscription metric.
class RawSubscriptionMetric {
  const RawSubscriptionMetric({
    required this.userId,
    this.isPremium = false,
    this.isPremiumActive = false,
    this.createdAt,
  });

  final String userId;
  final bool isPremium;
  final bool isPremiumActive;
  final DateTime? createdAt;
}
