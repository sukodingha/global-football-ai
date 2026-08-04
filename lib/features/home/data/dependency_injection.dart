import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/dependency_injection.dart';
import '../../../core/services/news_cache_service.dart';
import '../datasources/home_remote_data_source.dart';
import '../repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';

/// Riverpod provider for the remote data source.
final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  return HomeRemoteDataSource();
});

/// Riverpod provider for the home repository.
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  final newsCache = ref.watch(newsCacheServiceProvider);
  return HomeRepositoryImpl(
    remoteDataSource: remoteDataSource,
    newsCache: newsCache,
  );
});
