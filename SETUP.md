# Global Football AI — Firebase Setup Guide

This document guides you through configuring Firebase for the Global Football AI app.

## 1. Prerequisites

- Install the [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Install the [Firebase CLI](https://firebase.google.com/docs/cli)
- Sign in to Firebase: `firebase login`

## 2. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named `global-football-ai`
3. Register an Android app with package name `com.globalfootball.ai`
4. Register an iOS app with bundle ID `com.globalfootball.ai`

## 3. Enable Authentication Providers

In the Firebase Console → **Authentication** → **Sign-in method**, enable:

- Email/Password
- Google
- Apple
- Phone

## 4. Add Firebase Config Files

### Android
Download `google-services.json` from Firebase Console and place it at:
```
android/app/google-services.json
```

### iOS
Download `GoogleService-Info.plist` from Firebase Console and place it at:
```
ios/Runner/GoogleService-Info.plist
```

## 5. Run Firebase CLI (optional)

```bash
flutterfire configure
```

This generates the `firebase_options.dart` file.

## 6. Update AppConfig

Update `lib/core/config/app_config.dart` with your real Firebase project values.

## 7. iOS Biometric / Apple Sign-In Setup

In `ios/Runner/Info.plist`, add:
```xml
<key>NSFaceIDUsageDescription</key>
<string>Global Football AI uses Face ID to securely sign you in.</string>
```
Enable "Sign in with Apple" capability in Xcode.

## 8. Android Setup

In `android/app/build.gradle`, ensure:
- `minSdkVersion` is `21` or higher
- Add `google-services` plugin
- Add Google Sign-In configurations

## 9. Run the App

```bash
flutter pub get
flutter run
```

## 10. Configure Football Data API (Phase 3)

Live scores and match details are powered by [football-data.org](https://www.football-data.org/).

1. Register for a free API key: https://www.football-data.org/client/register
2. Set your key in `lib/core/config/app_config.dart`:
   ```dart
   static const String footballDataApiKey = 'YOUR_REAL_API_KEY';
   ```
3. Supported endpoints are exposed through the `FootballDataProvider` abstraction. To swap providers (e.g. API-Football, mock), implement `FootballDataProvider` and swap the concrete instance in `lib/features/livescore/data/dependency_injection.dart`.

### Free tier limits
- 10 requests/minute
- Live matches are available under `/v4/matches?status=LIVE`
- Match detail supports timeline, lineups, and standings

## Troubleshooting

- **Google Sign-In not working**: Ensure the SHA-1 fingerprint is registered in the Firebase console.
- **Phone Auth not working**: Phone auth requires a real device and a valid Firebase project.
- **Biometric not working**: Ensure the device has biometrics enrolled and the correct permission strings are set.
- **Live scores empty**: Obtain and set a valid `football-data.org` API key, and note the free tier has rate limits (10 req/min).
