import 'package:local_auth/local_auth.dart';

import '../../core/errors/exceptions.dart';

/// Wrapper around the platform biometric authentication API.
class BiometricService {
  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// Checks whether biometric hardware is available on the device.
  Future<bool> isBiometricAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Checks whether the user has enrolled any biometrics.
  Future<bool> hasEnrolledBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Returns the list of available biometric types.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  /// Authenticates the user using biometrics.
  ///
  /// Returns `true` if authentication succeeds, otherwise throws.
  Future<bool> authenticate() async {
    if (!await isBiometricAvailable()) {
      throw const BiometricException('Biometric authentication is not available on this device.');
    }
    if (!await hasEnrolledBiometrics()) {
      throw const BiometricException('No biometrics are enrolled on this device.');
    }

    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to securely access your Global Football AI account.',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (!authenticated) {
        throw const BiometricException('Biometric authentication failed.');
      }
      return true;
    } on BiometricException {
      rethrow;
    } catch (_) {
      throw const BiometricException('Biometric authentication failed.');
    }
  }
}
