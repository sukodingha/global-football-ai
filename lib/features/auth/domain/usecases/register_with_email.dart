import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

/// Registers a new user with email and password.
class RegisterWithEmail implements UseCase<UserEntity, RegisterParams> {
  const RegisterWithEmail(this._repository);
  final AuthRepository _repository;

  @override
  Future<UserEntity> call(RegisterParams params) {
    return _repository.registerWithEmail(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}
