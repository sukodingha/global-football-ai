import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_data_source.dart';
import '../repositories/community_repository_impl.dart';

/// Cloud Firestore community data source.
final communityRemoteDataSourceProvider = Provider<CommunityRemoteDataSource>((ref) {
  return CommunityRemoteDataSource();
});

/// Community repository.
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final dataSource = ref.watch(communityRemoteDataSourceProvider);
  return CommunityRepositoryImpl(dataSource: dataSource);
});
