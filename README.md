# Global Football AI

A production-ready, scalable Flutter application for global football prediction, built with **Clean Architecture** (Presentation, Application, Domain, Data), **Riverpod** for state management, **Go Router**, and **Firebase**.

## 🏗️ Architecture

```
lib/
├── core/                    # Cross-cutting concerns
│   ├── api/                 # Football data API abstraction (client + provider)
│   ├── config/              # App configuration & API keys
│   ├── constants/           # App-wide constants
│   ├── errors/              # Failures & exceptions
│   ├── router/              # Go Router configuration
│   ├── services/            # Secure storage, biometric, notification, analytics & cache services
│   ├── theme/               # App theme
│   ├── utils/               # Validators & helpers
│   └── widgets/             # Reusable UI widgets (ResponsiveContainer, EmptyStateView, ErrorStateView)
└── features/
    ├── auth/                # Authentication feature
    │   ├── application/     # Riverpod state & controllers
    │   ├── domain/          # Entities, repositories, use cases
    │   ├── data/            # Repositories impl, models, data sources
    │   └── presentation/    # Pages & widgets
    ├── home/                # Home dashboard feature
    │   ├── application/     # Riverpod state & controllers
    │   ├── domain/          # Entities, repositories, use cases
    │   ├── data/            # Repositories impl, models, data sources
    │   └── presentation/    # Pages & widgets
    └── livescore/           # Live Scores & Match Details feature
        ├── application/     # Riverpod state & controllers
        ├── domain/          # Entities, repositories, use cases
        ├── data/            # Repositories impl, models, data sources
        └── presentation/    # Pages & widgets
```

## ✨ Features

### Phase 1: Authentication
- Email/Password Login & Registration
- Google Sign-In
- Apple Sign-In
- Phone Login with OTP verification
- Forgot Password flow
- Biometric login support
- Persistent login state management
- Secure error handling and validation

### Phase 2: Home Dashboard
- Live/trending/today predictions
- Competitions, news, player of the day
- Dark/light theme
- Bottom-navigation HomeShell

### Phase 3: Live Scores & Match Details
- Football API abstraction layer (`FootballDataProvider`) — swap providers without breaking the app
- Real-time live score updates via polling stream (`LiveUpdateStream`)
- Match detail view with:
  - Timeline / events (goals, cards, substitutions)
  - Lineups (starters + substitutes)
  - Advanced statistics (possession, shots, fouls, corners)
  - Cards/goals/substitutions tracker (`MatchEventsView`)
  - Heat map structure (`HeatmapView` pitch painter)
  - Standings table (`StandingsView`)
  - Fixtures list (`FixturesView`)

### Phase 5: Live Scores, Community & Payments
- **Multi-sport live feed** (`SportsFeedPage`) for Football, Tennis, and Basketball via API-Sports, with automatic score/status updates (Live, Halftime, Full Time) and polling streams.
- **Community wall** (`CommunityPage`) — a Facebook-style feed with real-time likes, comments, and user profile badges stored in Firestore.
- **Paystack integration** (`PremiumPage`, `DonationSheet`, `CheckoutLauncherPage`) — hosted checkout for premium subscriptions and donations, with transaction verification and premium permission updates in Firestore.
- **Profile page** (`ProfilePage`) — premium status, donation entry, transaction history, and sign-out.

### Phase 6: Profile Settings, Notifications, Analytics & Polish
- **User Profile & Custom Settings** — `SettingsPage` lets users update display name, favorite teams, notification preferences, and theme mode. Persisted in real time to Firestore and cached locally for offline access.
- **Push Notifications (FCM)** — `NotificationService` handles permission requests, FCM token retrieval, token sync to Firestore, and topic subscriptions. Notification toggles in Settings subscribe/unsubscribe the device to FCM topics (`match_reminders`, `breaking_news`, `community_replies`, `promotions`).
- **Advanced Analytics & Performance** — `AnalyticsService` wraps Firebase Analytics (screen views, custom events) and Firebase Performance (operation traces/latency).
- **Offline Caching** — `NewsCacheService` and `LiveScoresCacheService` persist news and live scores locally (SharedPreferences) with TTLs so key screens render instantly and work offline.
- **Responsive & Accessible UI** — Reusable `ResponsiveContainer`/breakpoint helpers and shared `EmptyStateView`/`ErrorStateView` widgets applied across Home, Settings, Profile, Sports Feed, Predictions, and Community screens.

## 🚀 Getting Started

1. Install Flutter SDK
2. Configure Firebase (see `SETUP.md`)
3. Configure football data API key (see `SETUP.md`)
4. Run `flutter pub get`
5. Run `flutter run`

## 📦 Dependencies

- `flutter_riverpod` — State management
- `go_router` — Navigation
- `firebase_core`, `firebase_auth` — Authentication
- `firebase_messaging` — Push notifications
- `firebase_analytics`, `firebase_performance` — Analytics & performance tracking
- `google_sign_in`, `sign_in_with_apple` — Social auth
- `local_auth` — Biometric
- `flutter_secure_storage` — Secure session storage
- `shared_preferences` — Lightweight local caching (news, live scores)
- `equatable` — Value equality
- `http` — HTTP client for football data APIs
- `intl` — Date formatting

