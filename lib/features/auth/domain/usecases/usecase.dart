/// Base contract for all use cases.
abstract class UseCase<Type, Params> {
  Type call(Params params);
}

/// Marker class for use cases with no parameters.
class NoParams {
  const NoParams();
}

/// Params for login with email and password.
class LoginParams {
  const LoginParams({required this.email, required this.password});
  final String email;
  final String password;
}

/// Params for registration.
class RegisterParams {
  const RegisterParams({
    required this.email,
    required this.password,
    required this.displayName,
  });
  final String email;
  final String password;
  final String displayName;
}

/// Params for phone verification code.
class PhoneCodeParams {
  const PhoneCodeParams({
    required this.phoneNumber,
    required this.onCodeSent,
  });
  final String phoneNumber;
  final void Function(String verificationId) onCodeSent;
}

/// Params for OTP verification.
class OtpVerificationParams {
  const OtpVerificationParams({
    required this.verificationId,
    required this.otpCode,
  });
  final String verificationId;
  final String otpCode;
}

/// Params for enabling/disabling biometrics.
class BiometricToggleParams {
  const BiometricToggleParams(this.enabled);
  final bool enabled;
}
