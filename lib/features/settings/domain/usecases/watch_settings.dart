import '../entities/user_settings_entity.dart';
import '../repositories/settings_repository.dart';
import 'usecase.dart';

/// Watches a user's settings in real time.
class WatchSettings implements UseCase<Stream<UserSettingsEntity>, WatchSettingsParams> {
  const WatchSettings(this._repository);
  final SettingsRepository _repository;

  @override
  Stream<UserSettingsEntity> call(WatchSettingsParams params) {
    return _repository.watchSettings(params.userId);
  }
}
