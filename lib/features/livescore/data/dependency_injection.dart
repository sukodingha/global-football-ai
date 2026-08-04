import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/football_api_client.dart';
import '../../../core/api/football_data_provider.dart';
import '../datasources/api_sports_data_source.dart';
import '../datasources/livescore_remote_data_source.dart';
import '../providers/football_data_org_provider.dart';
import '../repositories/livescore_repository_impl.dart';
import '../repositories/multi_sport_repository_impl.dart';
import '../../domain/repositories/livescore_repository.dart';
import '../../domain/repositories/multi_sport_repository.dart';

/// Shared football API client.
final footballApiClientProvider = Provider<FootballApiClient>((ref) {
  return FootballApiClient();
});

/// The active football data provider.
///
/// Swap this provider to change the data source (e.g. API-Football or a mock)
/// without affecting any other part of the application.
final footballDataProviderProvider = Provider<FootballDataProvider>((ref) {
  final client = ref.watch(footballApiClientProvider);
  return FootballDataOrgProvider(client: client);
});

/// Remote data source for live scores.
final livescoreRemoteDataSourceProvider =
    Provider<LivescoreRemoteDataSource>((ref) {
  final provider = ref.watch(footballDataProviderProvider);
  return LivescoreRemoteDataSource(provider: provider);
});

/// Livescore repository.
final livescoreRepositoryProvider = Provider<LivescoreRepository>((ref) {
  final remoteDataSource = ref.watch(livescoreRemoteDataSourceProvider);
  return LivescoreRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Multi-sport (API-Sports) data source.
final apiSportsDataSourceProvider = Provider<ApiSportsDataSource>((ref) {
  return ApiSportsDataSource();
});

/// Multi-sport repository.
final multiSportRepositoryProvider = Provider<MultiSportRepository>((ref) {
  final dataSource = ref.watch(apiSportsDataSourceProvider);
  return MultiSportRepositoryImpl(dataSource: dataSource);
});

