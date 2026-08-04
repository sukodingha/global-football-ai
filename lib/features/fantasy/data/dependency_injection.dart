import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/fantasy_repository.dart';
import '../datasources/fantasy_remote_data_source.dart';
import '../engine/scoring_engine.dart';
import '../repositories/fantasy_repository_impl.dart';

/// Scoring engine used to compute fantasy points from match events.
final scoringEngineProvider = Provider<ScoringEngine>((ref) {
  return const ScoringEngine();
});

/// Cloud Firestore fantasy data source.
final fantasyRemoteDataSourceProvider =
    Provider<FantasyRemoteDataSource>((ref) {
  return FantasyRemoteDataSource(scoringEngine: ref.watch(scoringEngineProvider));
});

/// Fantasy repository.
final fantasyRepositoryProvider = Provider<FantasyRepository>((ref) {
  final dataSource = ref.watch(fantasyRemoteDataSourceProvider);
  return FantasyRepositoryImpl(dataSource: dataSource);
});

