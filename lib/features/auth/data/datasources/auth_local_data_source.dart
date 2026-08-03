import 'dart:convert';

import '../../../../core/services/secure_storage_service.dart';
import '../models/user_model.dart';

/// Local data source for caching auth session data.
class AuthLocalDataSource {
  AuthLocalDataSource({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  /// Caches the signed-in user locally.
  Future<void> cacheUser(UserModel user) async {
    await _secureStorage.cacheUser(jsonEncode(user.toJson()));
  }

  /// Reads the locally cached user.
  Future<UserModel?> getCachedUser() async {
    final jsonString = await _secureStorage.getCachedUser();
    if (jsonString == null) {
      return null;
    }
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Stores the biometric-enabled flag.
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.setBiometricEnabled(enabled);
  }

  /// Returns whether biometric login is enabled.
  Future<bool> isBiometricEnabled() async {
    return _secureStorage.isBiometricEnabled();
  }

  /// Removes all cached auth data.
  Future<void> clearCache() async {
    await _secureStorage.clearAll();
  }
}
