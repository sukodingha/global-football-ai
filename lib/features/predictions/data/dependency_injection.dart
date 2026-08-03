import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/dependency_injection.dart';
import '../../livescore/data/dependency_injection.dart';
import '../datasources/prediction_local_data_source.dart';
import '../datasources/prediction_remote_data_source.dart';
import '../engine/comparison_engine.dart';
import '../engine/prediction_engine.dart';
import '../repositories/prediction_repository_impl.dart';
import '../../domain/repositories/prediction_repository.dart';

/// The Poisson-based statistical prediction engine.
///
/// Production-ready: computes expected goals, 1X2 probabilities, BTTS,
/// correct score, over/under goals, corners, cards, and player props from
/// real match data — no mock shortcuts.
final predictionEngineProvider = Provider<PredictionEngine>((ref) {
  return const PredictionEngine();
});

/// Compares AI predictions against actual results per market.
final comparisonEngineProvider = Provider<ComparisonEngine>((ref) {
  return const ComparisonEngine();
});

/// Remote data source for generating predictions.
final predictionRemoteDataSourceProvider =
    Provider<PredictionRemoteDataSource>((ref) {
  final engine = ref.watch(predictionEngineProvider);
  return PredictionRemoteDataSource(engine: engine);
});

/// Local (Firestore) data source for history, votes, comparisons, accuracy.
final predictionLocalDataSourceProvider =
    Provider<PredictionLocalDataSource>((ref) {
  return PredictionLocalDataSource();
});

/// Prediction repository combining the statistical engine with Firestore
/// persistence.
final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  final remoteDataSource = ref.watch(predictionRemoteDataSourceProvider);
  final localDataSource = ref.watch(predictionLocalDataSourceProvider);
  final livescoreRepository = ref.watch(livescoreRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final comparisonEngine = ref.watch(comparisonEngineProvider);

  return PredictionRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    livescoreRepository: livescoreRepository,
    authRepository: authRepository,
    comparisonEngine: comparisonEngine,
  );
});
