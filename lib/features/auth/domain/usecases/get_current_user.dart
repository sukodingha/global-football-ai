import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

/// Returns the currently authenticated user, or null.
class GetCurrentUser implements UseCase<UserEntity?, NoParams> {
  const GetCurrentUser(this._repository);
  final AuthRepository _repository;

  @override
  Future<UserEntity?> call(NoParams params) => _repository.getCurrentUser();
}
