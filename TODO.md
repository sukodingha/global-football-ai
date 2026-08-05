# TODO - Global Football AI

## Phase 6 & 7: Fantasy Football ✅

### Phase 0: Setup & Planning
- [x] Analyze existing codebase architecture (Clean Architecture, Riverpod, Firestore)
- [x] Review existing feature patterns (community, predictions, livescore)
- [x] Plan fantasy feature structure

### Phase A: Domain Layer
- [x] Create `fantasy_league_entity.dart`
- [x] Create `fantasy_player_entity.dart`
- [x] Create `fantasy_team_entity.dart`
- [x] Create `leaderboard_entry_entity.dart`
- [x] Create `scoring_rule_entity.dart`
- [x] Create `fantasy_repository.dart` (repository interface + result wrapper + params)

### Phase B: Data Layer
- [x] Create `fantasy_league_model.dart`
- [x] Create `fantasy_player_model.dart`
- [x] Create `fantasy_team_model.dart`
- [x] Create `leaderboard_entry_model.dart`
- [x] Create `scoring_engine.dart` (automated scoring)
- [x] Create `fantasy_remote_data_source.dart` (Firestore-backed, real-time)
- [x] Create `fantasy_repository_impl.dart`
- [x] Create `dependency_injection.dart`

### Phase C: Application Layer
- [x] Create `fantasy_state.dart` (sealed states)
- [x] Create `fantasy_notifier.dart` (StateNotifier)
- [x] Create `fantasy_providers.dart` (providers + selectors)

### Phase D: Presentation Layer
- [x] Create `fantasy_hub_page.dart` (main hub)
- [x] Create `league_detail_page.dart`
- [x] Create `team_management_page.dart` (roster, transfers, captain/vc)
- [x] Create `player_stats_hub_page.dart` (player stats hub)
- [x] Create widgets (league_card, team_card, player_pick_card, leaderboard_table, points_breakdown, captain_badge, create/join dialogs)

### Phase E: Integration & Production Readiness
- [x] Add fantasy routes to `app_constants.dart`
- [x] Add fantasy routes to `app_router.dart`
- [x] Add Fantasy tab to `home_shell.dart`
- [x] Add secure Firestore rules for league data (`firestore.rules`)
- [x] Link Firestore rules in `firebase.json`

## Phase 9: Admin Dashboard (Part 1 - Core Management) ✅

### Phase 0: Setup & Planning
- [x] Analyze existing codebase architecture (Clean Architecture, Riverpod, Firestore)
- [x] Review existing entities (User, Subscription, Competition, CommunityPost, MatchPrediction)
- [x] Review existing data source patterns (Firestore remote data sources)
- [x] Plan admin feature structure

### Phase A: Domain Layer
- [x] Create `admin_user_entity.dart` (AdminUser, UserRole enum)
- [x] Create `admin_competition_entity.dart` (AdminCompetition)
- [x] Create `admin_prediction_entity.dart` (AdminPrediction, PredictionStatus)
- [x] Create `admin_audit_log_entity.dart` (AdminAuditLog)
- [x] Create `admin_repository.dart` (repository interface + result wrapper)

### Phase B: Data Layer
- [x] Create `admin_roles.dart` (RBAC role constants + helpers)
- [x] Create `admin_user_model.dart`
- [x] Create `admin_competition_model.dart`
- [x] Create `admin_prediction_model.dart`
- [x] Create `admin_audit_log_model.dart`
- [x] Create `admin_remote_data_source.dart` (Firestore-backed)
- [x] Create `admin_repository_impl.dart`
- [x] Create `dependency_injection.dart`

### Phase C: Application Layer
- [x] Create `admin_state.dart` (sealed states)
- [x] Create `admin_notifier.dart` (StateNotifier)
- [x] Create `admin_providers.dart` (providers + RBAC guard)

### Phase D: Presentation Layer
- [x] Create `admin_scaffold.dart` (widget)
- [x] Create `user_tile.dart` (widget)
- [x] Create `role_badge.dart` (widget)
- [x] Create `subscription_tile.dart` (widget)
- [x] Create `competition_tile.dart` (widget)
- [x] Create `prediction_audit_tile.dart` (widget)
- [x] Create `post_moderation_tile.dart` (widget)
- [x] Create `admin_dashboard_page.dart` (main hub)
- [x] Create `admin_users_page.dart`
- [x] Create `admin_subscriptions_page.dart`
- [x] Create `admin_competitions_page.dart`
- [x] Create `admin_predictions_page.dart`
- [x] Create `admin_moderation_page.dart`

### Phase E: Integration & Production Readiness
- [x] Add admin routes to `app_constants.dart`
- [x] Add admin routes + RBAC redirect to `app_router.dart`
- [x] Add admin entry point (settings menu)
- [x] Add Firestore RBAC rules documentation

### Phase F: Verification
- [ ] Run `flutter analyze`
- [ ] Verify build
