# Global Football AI — Phase Tracking

## ✅ Phase 1: Authentication System & Folder Structure
- [x] Clean Architecture folder structure
- [x] Firebase Auth (email, Google, Apple, phone, biometrics, forgot password)
- [x] Persistent session + Riverpod + Go Router

## ✅ Phase 2: Home Feature (Bonus)
- [x] Dashboard with live/trending/today predictions, competitions, news, player of day
- [x] Dark/light theme, bottom-nav HomeShell

## ✅ Phase 3: Live Scores & Match Details
- [x] API abstraction layer (football_api_client.dart, football_data_provider.dart)
- [x] Domain: entities (timeline, lineups, stats, events, heatmap, standings, match_detail)
- [x] Domain: livescore_repository + usecases
- [x] Data: models
- [x] Data: datasources (remote + live update stream)
- [x] Data: repository_impl + dependency_injection
- [x] Application: livescore_state, livescore_notifier, livescore_providers
- [x] Presentation: live_scores_page, match_detail_page
- [x] Presentation: widgets (timeline, lineups, stats, events, heatmap, standings, fixtures)
- [x] Integration: Go Router routes + AppConstants + HomeShell
- [x] README + TODO update

## 🔄 Phase 4: AI Predictions & Analytics Module
- [ ] Domain: prediction entities (match_winner, double_chance, btts, correct_score, over_under, player_props, confidence)
- [ ] Domain: prediction_history_entity + user_vote_entity + post_match_comparison_entity
- [ ] Domain: prediction_repository contract
- [ ] Domain: usecases (get_prediction, get_prediction_history, vote, compare_results, get_accuracy)
- [ ] Data: models for all entities
- [ ] Data: datasources (remote AI + local history)
- [ ] Data: repository implementation
- [ ] Data: dependency_injection
- [ ] Application: prediction_state + prediction_notifier + prediction_providers
- [ ] Presentation: prediction_detail_page, prediction_history_page, comparison_page
- [ ] Presentation: widgets (confidence_gauge, prediction_card, btts_card, correct_score_card, player_props_card, accuracy_tracker, vote_button)
- [ ] Integration: router routes, home_shell tab, constants
