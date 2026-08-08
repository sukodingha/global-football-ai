import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

/// Signs a user in with email and password.
class LoginWithEmail implements UseCase<Future<UserEntity>, LoginParams> {
  const LoginWithEmail(this._repository);
  final AuthRepository _repository;

  @override
  Future<UserEntity> call(LoginParams params) {
    return _repository.loginWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}
