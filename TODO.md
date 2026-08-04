# Push Notifications Feature - Implementation Steps

## Phase 0: Core Services
- [x] **0a**: Add `flutter_local_notifications` dependency to `pubspec.yaml`
- [ ] **0b**: Extend `NotificationService` with foreground local notification display, init, and click routing
- [ ] **0c**: Create `NotificationAlertEngine` to detect match events (Goal/Kickoff/HalfTime/FullTime/Result) from live streams

## Phase A: Domain Layer
- [ ] **A1**: Create `lib/features/notifications/domain/entities/notification_preferences_entity.dart`
- [ ] **A2**: Create `lib/features/notifications/domain/entities/notification_alert_entity.dart`
- [ ] **A3**: Create `lib/features/notifications/domain/repositories/notification_repository.dart`
- [ ] **A4**: Create `lib/features/notifications/domain/usecases/usecase.dart`
- [ ] **A5**: Create `lib/features/notifications/domain/usecases/get_notification_preferences.dart`
- [ ] **A6**: Create `lib/features/notifications/domain/usecases/watch_notification_preferences.dart`
- [ ] **A7**: Create `lib/features/notifications/domain/usecases/save_notification_preferences.dart`

## Phase B: Data Layer
- [ ] **B1**: Create `lib/features/notifications/data/models/notification_preferences_model.dart`
- [ ] **B2**: Create `lib/features/notifications/data/datasources/notification_remote_data_source.dart`
- [ ] **B3**: Create `lib/features/notifications/data/repositories/notification_repository_impl.dart`
- [ ] **B4**: Create `lib/features/notifications/data/dependency_injection.dart`

## Phase C: Application Layer
- [ ] **C1**: Create `lib/features/notifications/application/notification_state.dart`
- [ ] **C2**: Create `lib/features/notifications/application/notification_notifier.dart`
- [ ] **C3**: Create `lib/features/notifications/application/notification_providers.dart`

## Phase D: Presentation Layer
- [ ] **D1**: Create `lib/features/notifications/presentation/widgets/preference_toggle_tile.dart`
- [ ] **D2**: Create `lib/features/notifications/presentation/widgets/preference_section.dart`
- [ ] **D3**: Create `lib/features/notifications/presentation/widgets/alert_banner.dart`
- [ ] **D4**: Create `lib/features/notifications/presentation/pages/notification_preferences_page.dart`

## Phase E: Integration & Platform Config
- [ ] **E1**: Update `lib/core/constants/app_constants.dart` — add notifications route
- [ ] **E2**: Update `lib/core/router/app_router.dart` — add notifications route
- [ ] **E3**: Update `lib/core/services/dependency_injection.dart` — add alert engine + local notifications providers
- [ ] **E4**: Update `lib/main.dart` — init local notifications + global background handler
- [ ] **E5**: Update `lib/features/settings/presentation/pages/settings_page.dart` — add notification preference center entry
- [ ] **E6**: Update `android/app/src/main/AndroidManifest.xml` — POST_NOTIFICATIONS permission + icon
- [ ] **E7**: Update `ios/Runner/Info.plist` — APNs / notification notes

## Phase F: Verification
- [ ] **F1**: Run `flutter pub get`
- [ ] **F2**: Run `flutter analyze` and fix any issues
- [ ] **F3**: Run `flutter build` / test verification
