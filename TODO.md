# TODO - Global Football AI

## Phase 10: Admin Dashboard (Analytics & Polish)

### Phase A: Data Layer ✅
- [x] Add analytics/revenue raw-data fetch methods to `admin_remote_data_source.dart`
- [x] Add `moderation_logs` collection read/write to `admin_remote_data_source.dart`
- [x] Implement `getAnalytics()`, `getRevenue()`, `listModerationLogs()`, `logModeration()`, `generateReport()` in `admin_repository_impl.dart`

### Phase B: Application Layer ✅
- [x] Extend `AdminLoaded` state with analytics, revenue, moderationLogs
- [x] Add `loadAnalytics()`, `loadRevenue()`, `loadModerationLogs()` to `admin_notifier.dart`
- [x] Add selectors in `admin_providers.dart`

### Phase C: Presentation Layer ✅
- [x] Create `admin_stat_card.dart`, `admin_bar_chart.dart`, `report_view_dialog.dart` widgets
- [x] Create `admin_analytics_page.dart`
- [x] Create `admin_revenue_page.dart`
- [x] Create `admin_reports_page.dart`
- [x] Create `admin_moderation_logs_page.dart`
- [x] Wire 4 new tabs into `admin_dashboard_page.dart`

### Phase D: Integration & Polish
- [x] Add `moderation_logs` Firestore rules
- [x] Fix analytics refresh button (no-op) -> wired to `refreshInsights()`
- [x] Display prediction accuracy trend on analytics page (`_AccuracyTrendCard`)
- [x] Wire moderation logging into notifier actions (`setUserBanned`, `setPostPinned`, `deletePost`)
- [x] Add downloadable report export (CSV copy)
- [x] Clean up unused dependencies (`crypto`, `flutter_svg`, `cupertino_icons`) in `pubspec.yaml`
- [~] Run `flutter analyze` and fix warnings (Flutter SDK not available in this environment; run locally)
- [x] Update README/SETUP docs

## Phase 9: Admin Dashboard (Part 1 - Core Management) ✅
_(completed - see git history / prior work)_

