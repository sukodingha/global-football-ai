import 'package:firebase_auth/firebase_auth.dart';

/// Base class for data-layer exceptions.
class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thrown when network connectivity fails.
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network connection failed.']);
}

/// Thrown when a cache/storage operation fails.
class CacheException extends AppException {
  const CacheException([super.message = 'Cache operation failed.']);
}

/// Thrown when a Firebase authentication operation fails.
class AuthenticationException extends AppException {
  const AuthenticationException(super.message);
}

/// Thrown when biometric authentication fails.
class BiometricException extends AppException {
  const BiometricException(super.message);
}

/// Maps a FirebaseAuthException code to a user-friendly message.
String mapFirebaseAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'user-disabled':
      return 'This user account has been disabled.';
    case 'user-not-found':
      return 'No user found with this email.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'email-already-in-use':
      return 'An account already exists with this email.';
    case 'weak-password':
      return 'Password is too weak. Use at least 8 characters.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    case 'operation-not-allowed':
      return 'This operation is not allowed.';
    case 'invalid-verification-code':
      return 'The verification code is incorrect.';
    case 'invalid-verification-id':
      return 'The verification session is invalid. Please request a new code.';
    case 'credential-already-in-use':
      return 'This credential is already linked to another account.';
    case 'requires-recent-login':
      return 'Please sign in again to continue.';
    case 'network-request-failed':
      return 'Network connection failed. Please check your internet.';
    case 'missing-verification-code':
      return 'Please enter the verification code.';
    case 'captcha-check-failed':
      return 'Please complete the captcha verification.';
    default:
      return 'Authentication failed. Please try again.';
  }
}
