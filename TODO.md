# Push Notifications Feature - Implementation Steps

## Phase 0: Core Services
- [x] **0a**: Add `flutter_local_notifications` dependency to `pubspec.yaml`
- [x] **0b**: Extend `NotificationService` with foreground local notification display, init, and click routing
- [x] **0c**: Create `NotificationAlertEngine` to detect match events (Goal/Kickoff/HalfTime/FullTime/Result) from live streams

## Phase A: Domain Layer
- [x] **A1**: Create `lib/features/notifications/domain/entities/notification_preferences_entity.dart`
- [x] **A2**: Create `lib/features/notifications/domain/entities/notification_alert_entity.dart`
- [x] **A3**: Create `lib/features/notifications/domain/repositories/notification_repository.dart`
- [x] **A4**: Create `lib/features/notifications/domain/usecases/usecase.dart`
- [x] **A5**: Create `lib/features/notifications/domain/usecases/get_notification_preferences.dart`
- [x] **A6**: Create `lib/features/notifications/domain/usecases/watch_notification_preferences.dart`
- [x] **A7**: Create `lib/features/notifications/domain/usecases/save_notification_preferences.dart`

## Phase B: Data Layer
- [x] **B1**: Create `lib/features/notifications/data/models/notification_preferences_model.dart`
- [x] **B2**: Create `lib/features/notifications/data/datasources/notification_remote_data_source.dart`
- [x] **B3**: Create `lib/features/notifications/data/repositories/notification_repository_impl.dart`
- [x] **B4**: Create `lib/features/notifications/data/dependency_injection.dart`

## Phase C: Application Layer
- [x] **C1**: Create `lib/features/notifications/application/notification_state.dart`
- [x] **C2**: Create `lib/features/notifications/application/notification_notifier.dart`
- [x] **C3**: Create `lib/features/notifications/application/notification_providers.dart`

## Phase D: Presentation Layer
- [x] **D1**: Create `lib/features/notifications/presentation/widgets/preference_toggle_tile.dart`
- [x] **D2**: Create `lib/features/notifications/presentation/widgets/preference_section.dart`
- [x] **D3**: Create `lib/features/notifications/presentation/widgets/alert_banner.dart`
- [x] **D4**: Create `lib/features/notifications/presentation/pages/notification_preferences_page.dart`

## Phase E: Integration & Platform Config
- [x] **E1**: Update `lib/core/constants/app_constants.dart` — add notifications route
- [x] **E2**: Update `lib/core/router/app_router.dart` — add notifications route
- [x] **E3**: Update `lib/core/services/dependency_injection.dart` — add alert engine + local notifications providers
- [x] **E4**: Update `lib/main.dart` — init local notifications + global background handler
- [x] **E5**: Update `lib/features/settings/presentation/pages/settings_page.dart` — add notification preference center entry
- [x] **E6**: Update `android/app/src/main/AndroidManifest.xml` — POST_NOTIFICATIONS permission + icon
- [x] **E7**: Update `ios/Runner/Info.plist` — APNs / notification notes

## Phase F: Verification
- [ ] **F1**: Run `flutter pub get` (from the IDE Flutter toolchain — flutter binary not on System terminal PATH)
- [ ] **F2**: Run `flutter analyze` and fix any issues
- [ ] **F3**: Run `flutter build` / test verification

