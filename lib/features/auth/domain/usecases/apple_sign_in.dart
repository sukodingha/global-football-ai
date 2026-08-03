import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

/// Signs the user in with Apple.
class AppleSignIn implements UseCase<UserEntity, NoParams> {
  const AppleSignIn(this._repository);
  final AuthRepository _repository;

  @override
  Future<UserEntity> call(NoParams params) => _repository.signInWithApple();
}
