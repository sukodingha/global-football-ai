import 'package:flutter/foundation.dart';

/// Central application configuration.
///
/// Centralizes Firebase and application configuration.
class AppConfig {
  AppConfig._();

  /// Whether the app is running in debug mode.
  static bool get isDebug => kDebugMode;

  /// API key for the Firebase project.
  static const String firebaseApiKey = 'AIzaSy-REPLACE_WITH_YOUR_API_KEY';

  /// Google App ID for the Firebase project.
  static const String firebaseAppId = '1:REPLACE_WITH_YOUR_PROJECT_NUMBER:android:REPLACE_WITH_YOUR_APP_ID';

  /// Firebase Messaging Sender ID.
  static const String firebaseMessagingSenderId = '107409845238';

  /// Firebase project ID.
  static const String firebaseProjectId = 'global-football-ai';

  /// Firebase Web API key. Replace with the value from the Firebase Console.
  static const String firebaseWebApiKey =
      'AIzaSyAjQ8Untf_AG19p8mYrkUsmdPpNu-7kXs';

  /// Firebase Web App ID. Replace with the value from the Firebase Console.
  static const String firebaseWebAppId =
      '1:107409845238:web:a2f04ca132a86c1d75d7';

  /// Firebase Web messaging sender ID. Replace with the project value.
  static const String firebaseWebMessagingSenderId = '107409845238';

  /// Google OAuth Web client ID used by Google Sign-In.
  static const String googleWebClientId =
      '107409845238-oe0s5io7s0irlpggdlmpefu005cjnbu1.apps.googleusercontent.com';

  /// Firebase Storage Bucket.
  static const String firebaseStorageBucket = 'global-football-ai.appspot.com';

  /// iOS Bundle ID.
  static const String iosBundleId = 'com.globalfootball.ai';

  /// Android Application ID.
  static const String androidApplicationId = 'com.globalfootball.ai';

  /// App display name.
  static const String appName = 'Global Football AI';

  /// Session timeout in seconds (e.g., 30 days).
  static const Duration sessionTimeout = Duration(days: 30);

  /// OTP timeout duration.
  static const Duration otpTimeout = Duration(seconds: 60);

  /// football-data.org API base URL.
  static const String footballDataBaseUrl = 'https://api.football-data.org/v4';

  /// football-data.org API key. Set this to your real key.
  /// Obtain a free key at https://www.football-data.org/client/register
  static const String footballDataApiKey = 'YOUR_FOOTBALL_DATA_API_KEY';

/// News API key (optional). Set this to a real key.
  static const String newsApiKey = 'YOUR_NEWS_API_KEY';

  /// API-Sports (api-sports.io) base URL for multi-sport live feeds.
  static const String apiSportsBaseUrl = 'https://v1.api-sports.io';

  /// API-Sports key. Obtain at https://www.api-sports.io.
  static const String apiSportsKey = 'YOUR_API_SPORTS_KEY';

  /// Paystack public (publishable) key for client-side checkout.
  static const String paystackPublicKey = 'YOUR_PAYSTACK_PUBLIC_KEY';

  /// Paystack secret key for server-side verification.
  static const String paystackSecretKey = 'YOUR_PAYSTACK_SECRET_KEY';

  /// Paystack API base URL.
  static const String paystackBaseUrl = 'https://api.paystack.co';

  /// Paystack checkout base URL.
  static const String paystackCheckoutUrl = 'https://checkout.paystack.com';
}
