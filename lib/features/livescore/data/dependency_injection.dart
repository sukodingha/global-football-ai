import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/football_api_client.dart';
import '../../../core/api/football_data_provider.dart';
import '../datasources/livescore_remote_data_source.dart';
import '../providers/football_data_org_provider.dart';
import '../repositories/livescore_repository_impl.dart';
import '../../domain/repositories/livescore_repository.dart';

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
