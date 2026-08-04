import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';

/// Secure storage wrapper around Flutter Secure Storage.
///
/// Stores sensitive data (session tokens, cached user) encrypted at rest.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  /// Saves an auth session token.
  Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: AppConstants.storageAuthKey, value: token);
    } catch (_) {
      throw const CacheException('Unable to save session token.');
    }
  }

  /// Retrieves the saved auth session token.
  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: AppConstants.storageAuthKey);
    } catch (_) {
      throw const CacheException('Unable to read session token.');
    }
  }

  /// Saves the biometric-enabled flag.
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: AppConstants.storageBiometricKey,
        value: enabled.toString(),
      );
    } catch (_) {
      throw const CacheException('Unable to save biometric preference.');
    }
  }

  /// Returns whether biometric login is enabled.
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: AppConstants.storageBiometricKey);
      return value == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Caches the user JSON for offline CRUD.
  Future<void> cacheUser(String userJson) async {
    try {
      await _storage.write(
        key: AppConstants.storageUserKey,
        value: userJson,
      );
    } catch (_) {
      throw const CacheException('Unable to cache user data.');
    }
  }

/// Reads the cached user JSON.
  Future<String?> getCachedUser() async {
    try {
      return await _storage.read(key: AppConstants.storageUserKey);
    } catch (_) {
      return null;
    }
  }

  /// Writes an arbitrary key/value to secure storage.
  Future<void> writeRaw(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      throw const CacheException('Unable to write secure data.');
    }
  }

  /// Reads an arbitrary key from secure storage.
  Future<String?> readRaw(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  /// Deletes an arbitrary key from secure storage.
  Future<void> deleteRaw(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {
      // Best-effort delete.
    }
  }

  /// Clears all auth-related stored data.
  Future<void> clearAll() async {
    try {
      await _storage.delete(key: AppConstants.storageAuthKey);
      await _storage.delete(key: AppConstants.storageBiometricKey);
      await _storage.delete(key: AppConstants.storageUserKey);
    } catch (_) {
      throw const CacheException('Unable to clear session data.');
    }
  }
}
