import '../repositories/auth_repository.dart';
import 'usecase.dart';

/// Sends a password reset email.
class ForgotPassword implements UseCase<Future<void>, String> {
  const ForgotPassword(this._repository);
  final AuthRepository _repository;

  @override
  Future<void> call(String email) {
    return _repository.sendPasswordResetEmail(email);
  }
}
