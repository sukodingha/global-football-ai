import 'dart:async';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

/// Watches authentication state changes.
class WatchAuthState implements UseCase<Stream<UserEntity?>, NoParams> {
  const WatchAuthState(this._repository);
  final AuthRepository _repository;

  @override
  Stream<UserEntity?> call(NoParams params) => _repository.authStateChanges;
}
