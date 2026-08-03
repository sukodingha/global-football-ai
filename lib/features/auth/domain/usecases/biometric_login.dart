import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

/// Signs the user in using biometrics and the stored session.
class BiometricLogin implements UseCase<UserEntity, NoParams> {
  const BiometricLogin(this._repository);
  final AuthRepository _repository;

  @override
  Future<UserEntity> call(NoParams params) => _repository.loginWithBiometrics();
}
