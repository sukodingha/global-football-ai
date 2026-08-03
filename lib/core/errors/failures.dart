/// Base class for all domain-level failures.
///
/// Failures represent errors that are safe to surface to the UI layer.
abstract class Failure {
  const Failure(this.message);

  /// Human-readable, user-safe error message.
  final String message;

  // ── Factory helpers (named parameters style) ──────────────────────
  static Failure serverFailure({String? message}) => ServerFailure(message);
  static Failure networkFailure({String? message}) => NetworkFailure(message);
  static Failure cacheFailure({String? message}) => CacheFailure(message);
  static Failure invalidCredentials({String? message}) =>
      InvalidCredentialsFailure(message);
  static Failure userNotFound({String? message}) => UserNotFoundFailure(message);
  static Failure emailAlreadyInUse({String? message}) =>
      EmailAlreadyInUseFailure(message);
  static Failure weakPassword({String? message}) => WeakPasswordFailure(message);
  static Failure invalidEmail({String? message}) => InvalidEmailFailure(message);
  static Failure operationNotAllowed({String? message}) =>
      OperationNotAllowedFailure(message);
  static Failure tooManyRequests({String? message}) =>
      TooManyRequestsFailure(message);
  static Failure requiresRecentLogin({String? message}) =>
      RequiresRecentLoginFailure(message);
  static Failure credentialAlreadyInUse({String? message}) =>
      CredentialAlreadyInUseFailure(message);
  static Failure invalidOtp({String? message}) => InvalidOtpFailure(message);
  static Failure otpExpired({String? message}) => OtpExpiredFailure(message);
  static Failure biometricNotAvailable({String? message}) =>
      BiometricNotAvailableFailure(message);
  static Failure biometricNotEnrolled({String? message}) =>
      BiometricNotEnrolledFailure(message);
  static Failure biometricAuthenticationFailed({String? message}) =>
      BiometricAuthenticationFailedFailure(message);
  static Failure unknown({String? message}) => UnknownFailure(message);
}

/// Generic server-side error.
class ServerFailure extends Failure {
  const ServerFailure([String? message])
      : super(message ?? 'An unexpected server error occurred. Please try again.');

  ServerFailure.official(String message) : super(message);
}

/// Network connectivity error.
class NetworkFailure extends Failure {
  const NetworkFailure([String? message])
      : super(message ??
            'Network connection lost. Please check your internet connection.');

  NetworkFailure.official(String message) : super(message);
}

/// Local cache/storage error.
class CacheFailure extends Failure {
  const CacheFailure([String? message])
      : super(message ?? 'Unable to access local storage. Please try again.');

  CacheFailure.official(String message) : super(message);
}

/// Invalid email or password.
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([String? message])
      : super(message ?? 'Invalid email or password. Please try again.');

  InvalidCredentialsFailure.official(String message) : super(message);
}

/// No account registered with the given email.
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([String? message])
      : super(message ?? 'No account found with this email. Please sign up.');

  UserNotFoundFailure.official(String message) : super(message);
}

/// An account already exists with the given email.
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure([String? message])
      : super(message ??
            'An account already exists with this email. Please sign in.');

  EmailAlreadyInUseFailure.official(String message) : super(message);
}

/// Password does not meet the strength requirements.
class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([String? message])
      : super(message ??
            'Password is too weak. Use at least 8 characters with a mix of letters, numbers, and symbols.');

  WeakPasswordFailure.official(String message) : super(message);
}

/// The email address format is invalid.
class InvalidEmailFailure extends Failure {
  const InvalidEmailFailure([String? message])
      : super(message ?? 'The email address is not valid.');

  InvalidEmailFailure.official(String message) : super(message);
}

/// The operation is not permitted.
class OperationNotAllowedFailure extends Failure {
  const OperationNotAllowedFailure([String? message])
      : super(message ?? 'This operation is not allowed. Please contact support.');

  OperationNotAllowedFailure.official(String message) : super(message);
}

/// Too many requests.
class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure([String? message])
      : super(message ?? 'Too many attempts. Please try again later.');

  TooManyRequestsFailure.official(String message) : super(message);
}

/// The user must re-authenticate recently.
class RequiresRecentLoginFailure extends Failure {
  const RequiresRecentLoginFailure([String? message])
      : super(message ?? 'Please sign in again to continue.');

  RequiresRecentLoginFailure.official(String message) : super(message);
}

/// The credential is already associated with another account.
class CredentialAlreadyInUseFailure extends Failure {
  const CredentialAlreadyInUseFailure([String? message])
      : super(message ??
            'This credential is already linked to another account.');

  CredentialAlreadyInUseFailure.official(String message) : super(message);
}

/// The OTP code is incorrect.
class InvalidOtpFailure extends Failure {
  const InvalidOtpFailure([String? message])
      : super(message ?? 'The verification code is incorrect. Please try again.');

  InvalidOtpFailure.official(String message) : super(message);
}

/// The OTP code has expired.
class OtpExpiredFailure extends Failure {
  const OtpExpiredFailure([String? message])
      : super(message ??
            'The verification code has expired. Please request a new one.');

  OtpExpiredFailure.official(String message) : super(message);
}

/// Biometric authentication is unavailable.
class BiometricNotAvailableFailure extends Failure {
  const BiometricNotAvailableFailure([String? message])
      : super(message ??
            'Biometric authentication is not available on this device.');

  BiometricNotAvailableFailure.official(String message) : super(message);
}

/// No biometrics are enrolled on the device.
class BiometricNotEnrolledFailure extends Failure {
  const BiometricNotEnrolledFailure([String? message])
      : super(message ??
            'No biometrics are enrolled on this device. Please set up fingerprint or face ID.');

  BiometricNotEnrolledFailure.official(String message) : super(message);
}

/// Biometric authentication failed.
class BiometricAuthenticationFailedFailure extends Failure {
  const BiometricAuthenticationFailedFailure([String? message])
      : super(message ?? 'Biometric authentication failed. Please try again.');

  BiometricAuthenticationFailedFailure.official(String message)
      : super(message);
}

/// Unknown / unhandled error.
class UnknownFailure extends Failure {
  const UnknownFailure([String? message])
      : super(message ?? 'Something went wrong. Please try again.');

  UnknownFailure.official(String message) : super(message);
}
