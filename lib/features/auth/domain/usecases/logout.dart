import '../repositories/auth_repository.dart';
import 'usecase.dart';

/// Signs out the current user.
class Logout implements UseCase<void, NoParams> {
  const Logout(this._repository);
  final AuthRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.signOut();
}
