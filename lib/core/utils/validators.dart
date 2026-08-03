import '../../core/constants/app_constants.dart';

/// Result object for validation.
class ValidationResult {
  const ValidationResult(this.isValid, this.message);
  final bool isValid;
  final String? message;
}

/// RFC 5322-compliant email validation.
class EmailValidator {
  static ValidationResult validate(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return const ValidationResult(false, 'Email is required.');
    }
    if (!AppConstants.emailRegex.hasMatch(email)) {
      return const ValidationResult(false, 'Please enter a valid email address.');
    }
    return const ValidationResult(true, null);
  }
}

/// Password validation with strength rules.
class PasswordValidator {
  static ValidationResult validate(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return const ValidationResult(false, 'Password is required.');
    }
    if (password.length < AppConstants.minPasswordLength) {
      return const ValidationResult(
        false,
        'Password must be at least ${AppConstants.minPasswordLength} characters.',
      );
    }
    if (!AppConstants.passwordRegex.hasMatch(password)) {
      return const ValidationResult(
        false,
        'Password must contain uppercase, lowercase, a number, and a symbol.',
      );
    }
    return const ValidationResult(true, null);
  }
}

/// Password confirmation validator.
class ConfirmPasswordValidator {
  static ValidationResult validate(String? value, String password) {
    if (value == null || value.isEmpty) {
      return const ValidationResult(false, 'Please confirm your password.');
    }
    if (value != password) {
      return const ValidationResult(false, 'Passwords do not match.');
    }
    return const ValidationResult(true, null);
  }
}

/// Phone number validation (E.164 format).
class PhoneValidator {
  static ValidationResult validate(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return const ValidationResult(false, 'Phone number is required.');
    }
    if (!AppConstants.phoneRegex.hasMatch(phone)) {
      return const ValidationResult(false, 'Please enter a valid phone number.');
    }
    return const ValidationResult(true, null);
  }
}

/// OTP code validation.
class OtpValidator {
  static ValidationResult validate(String? value) {
    final otp = value?.trim() ?? '';
    if (otp.isEmpty) {
      return const ValidationResult(false, 'Verification code is required.');
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(otp)) {
      return const ValidationResult(false, 'Verification code must contain only digits.');
    }
    if (otp.length != AppConstants.otpLength) {
      return const ValidationResult(
        false,
        'Verification code must be ${AppConstants.otpLength} digits.',
      );
    }
    return const ValidationResult(true, null);
  }
}
