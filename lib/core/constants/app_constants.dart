/// App-wide constants shared across the application.
class AppConstants {
  AppConstants._();

  /// Secure storage keys.
  static const String storageAuthKey = 'auth_session';
  static const String storageBiometricKey = 'biometric_enabled';
  static const String storageUserKey = 'cached_user';

  /// Route names.
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeForgotPassword = '/forgot-password';
  static const String routePhoneLogin = '/phone-login';
static const String routeOtpVerification = '/otp-verification';
static const String routeHome = '/home';
  static const String routeLiveScores = '/live-scores';
  static const String routeMatchDetail = '/match';
  static const String routeCommunity = '/community';
  static const String routeProfile = '/profile';
static const String routePremium = '/premium';
  static const String routeCheckout = '/checkout';
  static const String routeSettings = '/settings';

  /// Validation regexes.
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phoneRegex = RegExp(
    r'^\+?[0-9]{7,15}$',
  );
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  /// Minimum password length.
  static const int minPasswordLength = 8;

  /// OTP code length.
  static const int otpLength = 6;
}
