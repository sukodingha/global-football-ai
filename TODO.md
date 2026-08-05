# TODO - Global Football AI

## Phase 10: Admin Dashboard (Analytics & Polish)

### Phase A: Data Layer
- [ ] Add analytics/revenue raw-data fetch methods to `admin_remote_data_source.dart`
- [ ] Add `moderation_logs` collection read/write to `admin_remote_data_source.dart`
- [ ] Implement `getAnalytics()`, `getRevenue()`, `listModerationLogs()`, `logModeration()`, `generateReport()` in `admin_repository_impl.dart`

### Phase B: Application Layer
- [ ] Extend `AdminLoaded` state with analytics, revenue, moderationLogs
- [ ] Add `loadAnalytics()`, `loadRevenue()`, `loadModerationLogs()` to `admin_notifier.dart`
- [ ] Wire moderation actions to `logModeration()`
- [ ] Add selectors in `admin_providers.dart`

### Phase C: Presentation Layer
- [ ] Create `admin_stat_card.dart`, `admin_bar_chart.dart`, `report_view_dialog.dart` widgets
- [ ] Create `admin_analytics_page.dart`
- [ ] Create `admin_revenue_page.dart`
- [ ] Create `admin_reports_page.dart`
- [ ] Create `admin_moderation_logs_page.dart`
- [ ] Wire 4 new tabs into `admin_dashboard_page.dart`

### Phase D: Integration & Polish
- [ ] Add `moderation_logs` Firestore rules
- [ ] Run `flutter analyze` and fix warnings
- [ ] Update README/SETUP docs

## Phase 9: Admin Dashboard (Part 1 - Core Management) ✅
_(completed - see git history / prior work)_
