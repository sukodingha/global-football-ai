import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/admin_repository.dart';
import './datasources/admin_remote_data_source.dart';
import './repositories/admin_repository_impl.dart';

/// Admin remote data source.
final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  return AdminRemoteDataSource();
});

/// Admin repository.
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final dataSource = ref.watch(adminRemoteDataSourceProvider);
  return AdminRepositoryImpl(dataSource: dataSource);
});
