# Fantasy Football Feature - Implementation Steps

## Phase A: Domain Layer
- [x] **A1**: Create `lib/features/fantasy/domain/entities/fantasy_league_entity.dart`
- [x] **A2**: Create `lib/features/fantasy/domain/entities/fantasy_team_entity.dart`
- [x] **A3**: Create `lib/features/fantasy/domain/entities/fantasy_player_entity.dart`
- [x] **A4**: Create `lib/features/fantasy/domain/entities/leaderboard_entry_entity.dart`
- [x] **A5**: Create `lib/features/fantasy/domain/entities/scoring_rule_entity.dart`
- [x] **A6**: Create `lib/features/fantasy/domain/repositories/fantasy_repository.dart`

## Phase B: Data Layer
- [x] **B1**: Create `lib/features/fantasy/data/models/fantasy_league_model.dart`
- [x] **B2**: Create `lib/features/fantasy/data/models/fantasy_team_model.dart`
- [x] **B3**: Create `lib/features/fantasy/data/models/fantasy_player_model.dart`
- [x] **B4**: Create `lib/features/fantasy/data/models/leaderboard_entry_model.dart`
- [x] **B5**: Create `lib/features/fantasy/data/datasources/fantasy_remote_data_source.dart`
- [x] **B6**: Create `lib/features/fantasy/data/repositories/fantasy_repository_impl.dart`
- [x] **B7**: Create `lib/features/fantasy/data/engine/scoring_engine.dart`
- [x] **B8**: Create `lib/features/fantasy/data/dependency_injection.dart`

## Phase C: Application Layer
- [x] **C1**: Create `lib/features/fantasy/application/fantasy_state.dart`
- [x] **C2**: Create `lib/features/fantasy/application/fantasy_notifier.dart`
- [x] **C3**: Create `lib/features/fantasy/application/fantasy_providers.dart`

## Phase D: Presentation Layer
- [x] **D1**: Create `lib/features/fantasy/presentation/widgets/league_card.dart`
- [x] **D2**: Create `lib/features/fantasy/presentation/widgets/team_card.dart`
- [x] **D3**: Create `lib/features/fantasy/presentation/widgets/player_pick_card.dart`
- [x] **D4**: Create `lib/features/fantasy/presentation/widgets/leaderboard_table.dart`
- [x] **D5**: Create `lib/features/fantasy/presentation/widgets/points_breakdown.dart`
- [x] **D6**: Create `lib/features/fantasy/presentation/widgets/captain_badge.dart`
- [x] **D7**: Create `lib/features/fantasy/presentation/widgets/create_league_dialog.dart`
- [x] **D8**: Create `lib/features/fantasy/presentation/widgets/join_league_dialog.dart`
- [x] **D9**: Create `lib/features/fantasy/presentation/pages/fantasy_hub_page.dart`
- [x] **D10**: Create `lib/features/fantasy/presentation/pages/league_detail_page.dart`
- [x] **D11**: Create `lib/features/fantasy/presentation/pages/team_management_page.dart`
- [x] **D12**: Create `lib/features/fantasy/presentation/pages/player_stats_hub_page.dart`

## Phase E: Integration
- [x] **E1**: Update `lib/core/constants/app_constants.dart` — add fantasy routes
- [x] **E2**: Update `lib/core/router/app_router.dart` — add fantasy routes
- [x] **E3**: Update `lib/home_shell.dart` — add Fantasy bottom nav tab

## Phase F: Verification
- [x] **F1**: Fix import for `CreateLeagueParams` / `JoinLeagueParams` in `fantasy_remote_data_source.dart`
- [x] **F2**: Fix null-safety — guard `_startTeamSubscription` for nullable `currentTeam` in `fantasy_notifier.dart`
- [ ] **F3**: Run `flutter analyze` and fix any issues (requires Flutter SDK on PATH)
- [ ] **F4**: Run `flutter build` / test verification

