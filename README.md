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
│   ├── services/            # Secure storage & biometric services
│   ├── theme/               # App theme
│   ├── utils/               # Validators & helpers
│   └── widgets/             # Reusable UI widgets
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
- `google_sign_in`, `sign_in_with_apple` — Social auth
- `local_auth` — Biometric
- `flutter_secure_storage` — Secure session storage
- `equatable` — Value equality
- `http` — HTTP client for football data APIs
- `intl` — Date formatting

