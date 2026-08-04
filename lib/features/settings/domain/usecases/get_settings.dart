import '../entities/user_settings_entity.dart';
import '../repositories/settings_repository.dart';
import 'usecase.dart';

/// Gets a user's settings (with local cache fallback).
class GetSettings
    implements UseCase<Future<UserSettingsEntity>, GetSettingsParams> {
  const GetSettings(this._repository);
  final SettingsRepository _repository;

  @override
  Future<UserSettingsEntity> call(GetSettingsParams params) {
    return _repository.getSettings(params.userId);
  }
}
