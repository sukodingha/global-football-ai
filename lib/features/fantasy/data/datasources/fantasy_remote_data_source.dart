import 'package:cloud_firestore/cloud_firestore.dart';

import   '../../../../core/errors/exceptions.dart';
import '../../domain/entities/fantasy_league_entity.dart';
import '../../domain/entities/fantasy_player_entity.dart';
import '../../domain/entities/fantasy_team_entity.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';
import '../../domain/repositories/fantasy_repository.dart';
import '../engine/scoring_engine.dart';
import '../models/fantasy_league_model.dart';
import '../models/fantasy_player_model.dart';
import '../models/fantasy_team_model.dart';
import '../models/leaderboard_entry_model.dart';

/// Cloud Firestore-backed data source for the fantasy football feature.
///
/// Stores leagues, teams, the player pool, leaderboard entries, and scoring
/// events. Real-time snapshots power dynamic leaderboards and live points.
class FantasyRemoteDataSource {
  FantasyRemoteDataSource({
    FirebaseFirestore? firestore,
    ScoringEngine? scoringEngine,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _scoringEngine = scoringEngine ?? const ScoringEngine();

  final FirebaseFirestore _firestore;
  final ScoringEngine _scoringEngine;

  CollectionReference<Map<String, dynamic>> get _leagues =>
      _firestore.collection('fantasy_leagues');

  CollectionReference<Map<String, dynamic>> get _teams =>
      _firestore.collection('fantasy_teams');

  CollectionReference<Map<String, dynamic>> get _players =>
      _firestore.collection('fantasy_players');

  CollectionReference<Map<String, dynamic>> get _leaderboards =>
      _firestore.collection('fantasy_leaderboards');

  CollectionReference<Map<String, dynamic>> get _scoringEvents =>
      _firestore.collection('fantasy_scoring_events');

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  // ─── Leagues ──────────────────────────────────────────────────────

  Future<FantasyLeagueEntity> createLeague(CreateLeagueParams params) async {
    try {
      final docRef = _leagues.doc();
      final now = DateTime.now();
      final code = _generateJoinCode();
      final league = FantasyLeagueEntity(
        id: docRef.id,
        name: params.name,
        code: code,
        visibility: params.visibility,
        ownerId: params.ownerId,
        memberCount: 1,
        startBudget: params.startBudget,
        createdAt: now,
        description: params.description,
        members: [params.ownerId],
      );

      await _leagues.doc(docRef.id).set(FantasyLeagueModel.fromEntity(league).toJson());
      return league;
    } catch (e) {
      throw CacheException('Unable to create league: $e');
    }
  }

  Future<FantasyLeagueEntity> joinLeagueByCode(JoinLeagueParams params) async {
    try {
      final snapshot = await _leagues
          .where('code', isEqualTo: params.code)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        throw const CacheException('League not found. Check the join code.');
      }

      final doc = snapshot.docs.first;
      final model =
          FantasyLeagueModel.fromJson(doc.data());
      final existingMembers = model.members;

      if (existingMembers.contains(params.userId)) {
        return model.toEntity();
      }

      final updatedMembers = [...existingMembers, params.userId];
      await doc.reference.update({
        'memberCount': FieldValue.increment(1),
        'members': updatedMembers,
      });

      return model.copyWith(
        members: updatedMembers,
        memberCount: model.memberCount + 1,
      ).toEntity();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Unable to join league: $e');
    }
  }

  Future<FantasyLeagueEntity> getLeague(String leagueId) async {
    try {
      final doc = await _leagues.doc(leagueId).get();
      if (!doc.exists) {
        throw const CacheException('League not found.');
      }
      return FantasyLeagueModel.fromJson(doc.data()!).toEntity();
    } catch (e) {
      throw CacheException('Unable to load league: $e');
    }
  }

  Stream<FantasyLeagueEntity> watchLeague(String leagueId) {
    return _leagues.doc(leagueId).snapshots().map((doc) {
      if (!doc.exists) {
        throw const CacheException('League not found.');
      }
      return FantasyLeagueModel.fromJson(doc.data()!).toEntity();
    });
  }

  Future<List<FantasyLeagueEntity>> getLeaguesForUser(String userId) async {
    try {
      final snapshot = await _leagues
          .where('members', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => FantasyLeagueModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      throw CacheException('Unable to load your leagues: $e');
    }
  }

  Future<List<FantasyLeagueEntity>> getPublicLeagues({int limit = 20}) async {
    try {
      final snapshot = await _leagues
          .where('visibility', isEqualTo: 'public')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => FantasyLeagueModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      throw CacheException('Unable to load public leagues: $e');
    }
  }

  Stream<List<FantasyLeagueEntity>> watchPublicLeagues({int limit = 20}) {
    return _leagues
        .where('visibility', isEqualTo: 'public')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FantasyLeagueModel.fromJson(doc.data()).toEntity())
            .toList());
  }

  // ─── Teams ────────────────────────────────────────────────────────

  Future<FantasyTeamEntity> createTeam({
    required String name,
    required String userId,
    required String leagueId,
    double budget = 100,
  }) async {
    try {
      final docRef = _teams.doc();
      final team = FantasyTeamEntity(
        id: docRef.id,
        name: name,
        userId: userId,
        leagueId: leagueId,
        budgetRemaining: budget,
      );
      await _teams.doc(docRef.id).set(FantasyTeamModel.fromEntity(team).toJson());
      await _writeLeaderboardEntry(team, userName: name);
      return team;
    } catch (e) {
      throw CacheException('Unable to create team: $e');
    }
  }

  Future<FantasyTeamEntity?> getTeamInLeague({
    required String userId,
    required String leagueId,
  }) async {
    try {
      final snapshot = await _teams
          .where('userId', isEqualTo: userId)
          .where('leagueId', isEqualTo: leagueId)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final model = FantasyTeamModel.fromJson(doc.data());
      // Hydrate players from the pool.
      final players = await _loadPlayersByIds(model.playerIds);
      return model.toEntity().copyWith(players: players);
    } catch (e) {
      throw CacheException('Unable to load team: $e');
    }
  }

  Stream<FantasyTeamEntity> watchTeam(String teamId) {
    return _teams.doc(teamId).snapshots().asyncMap((doc) async {
      if (!doc.exists) {
        throw const CacheException('Team not found.');
      }
      final model = FantasyTeamModel.fromJson(doc.data()!);
      final players = await _loadPlayersByIds(model.playerIds);
      return model.toEntity().copyWith(players: players);
    });
  }

  Future<FantasyTeamEntity> addPlayerToTeam({
    required String teamId,
    required FantasyPlayerEntity player,
  }) async {
    try {
      final doc = await _teams.doc(teamId).get();
      final model = _teamFromDoc(doc);
      if (model.playerIds.contains(player.id)) {
        return model.toEntity();
      }

      final newBudget = model.budgetRemaining - player.price;
      if (newBudget < 0) {
        throw const CacheException(
          'Insufficient budget. Player costs more than available credits.',
        );
      }

      final newIds = [...model.playerIds, player.id];
      await _teams.doc(teamId).update({
        'playerIds': newIds,
        'budgetRemaining': newBudget,
      });

      final players = await _loadPlayersByIds(newIds);
      return model
          .toEntity()
          .copyWith(budgetRemaining: newBudget, players: players);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Unable to add player to team: $e');
    }
  }

  Future<FantasyTeamEntity> removePlayerFromTeam({
    required String teamId,
    required int playerId,
  }) async {
    try {
      final doc = await _teams.doc(teamId).get();
      final model = _teamFromDoc(doc);

      final removedPlayer = (await _loadPlayersByIds([playerId])).isEmpty
          ? null
          : (await _loadPlayersByIds([playerId])).first;

      final newIds =
          model.playerIds.where((id) => id != playerId).toList();
      final newBudget = model.budgetRemaining + (removedPlayer?.price ?? 0);

      final updates = <String, dynamic>{
        'playerIds': newIds,
        'budgetRemaining': newBudget,
      };

      // Clear captain/vice-captain if they were removed.
      if (model.captainId == '$playerId') {
        updates['captainId'] = FieldValue.delete();
      }
      if (model.viceCaptainId == '$playerId') {
        updates['viceCaptainId'] = FieldValue.delete();
      }

      await _teams.doc(teamId).update(updates);

      final players = await _loadPlayersByIds(newIds);
      return model
          .toEntity()
          .copyWith(budgetRemaining: newBudget, players: players);
    } catch (e) {
      throw CacheException('Unable to remove player from team: $e');
    }
  }

  Future<FantasyTeamEntity> setCaptain({
    required String teamId,
    required int playerId,
  }) async {
    return _setLeadership(teamId, playerId, isCaptain: true);
  }

  Future<FantasyTeamEntity> setViceCaptain({
    required String teamId,
    required int playerId,
  }) async {
    return _setLeadership(teamId, playerId, isCaptain: false);
  }

  Future<FantasyTeamEntity> _setLeadership(
    String teamId,
    int playerId, {
    required bool isCaptain,
  }) async {
    try {
      final doc = await _teams.doc(teamId).get();
      final model = _teamFromDoc(doc);
      if (!model.playerIds.contains(playerId)) {
        throw const CacheException('Player is not in the team.');
      }

      final field = isCaptain ? 'captainId' : 'viceCaptainId';
      await _teams.doc(teamId).update({field: '$playerId'});

      final players = await _loadPlayersByIds(model.playerIds);
      return model.toEntity().copyWith(
            captainId: isCaptain ? '$playerId' : model.captainId,
            viceCaptainId: isCaptain ? model.viceCaptainId : '$playerId',
            players: players,
          );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Unable to update team leadership: $e');
    }
  }

  // ─── Leaderboards ─────────────────────────────────────────────────

  Stream<List<LeaderboardEntryEntity>> watchGlobalLeaderboard(
      {int limit = 50}) {
    return _leaderboards
        .doc('global')
        .collection('entries')
        .orderBy('totalPoints', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaderboardEntryModel.fromJson(doc.data()).toEntity())
            .toList());
  }

  Stream<List<LeaderboardEntryEntity>> watchLeagueLeaderboard(
    String leagueId, {
    int limit = 50,
  }) {
    return _leaderboards
        .doc('league_$leagueId')
        .collection('entries')
        .orderBy('totalPoints', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaderboardEntryModel.fromJson(doc.data()).toEntity())
            .toList());
  }

  Future<void> _writeLeaderboardEntry(
    FantasyTeamEntity team, {
    required String userName,
  }) async {
    final entry = LeaderboardEntryEntity(
      teamId: team.id,
      teamName: team.name,
      userId: team.userId,
      userName: userName,
      totalPoints: team.totalPoints,
    );
    // Global entry.
    await _leaderboards
        .doc('global')
        .collection('entries')
        .doc(team.id)
        .set(LeaderboardEntryModel.fromEntity(entry).toJson());
    // League entry.
    await _leaderboards
        .doc('league_${team.leagueId}')
        .collection('entries')
        .doc(team.id)
        .set(LeaderboardEntryModel.fromEntity(entry).toJson());
  }

  // ─── Player pool ──────────────────────────────────────────────────

  Future<List<FantasyPlayerEntity>> getPlayerPool({String? position}) async {
    try {
      Query<Map<String, dynamic>> query = _players;
      if (position != null) {
        query = query.where('position', isEqualTo: position);
      }
      final snapshot = await query.orderBy('price', descending: true).get();
      return snapshot.docs
          .map((doc) => FantasyPlayerModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      throw CacheException('Unable to load player pool: $e');
    }
  }

  Stream<List<FantasyPlayerEntity>> watchPlayerPool({String? position}) {
    Query<Map<String, dynamic>> query = _players;
    if (position != null) {
      query = query.where('position', isEqualTo: position);
    }
    return query
        .orderBy('price', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FantasyPlayerModel.fromJson(doc.data()).toEntity())
            .toList());
  }

  Future<List<FantasyPlayerEntity>> _loadPlayersByIds(List<int> ids) async {
    if (ids.isEmpty) return const [];
    try {
      final snapshot = await _players
          .where('id', whereIn: ids.toSet().toList())
          .get();
      return snapshot.docs
          .map((doc) => FantasyPlayerModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // ─── Scoring ──────────────────────────────────────────────────────

  Future<FantasyPlayerEntity> applyScoringEvent({
    required int playerId,
    required String eventType,
    int quantity = 1,
  }) async {
    try {
      final snapshot = await _players.where('id', isEqualTo: playerId).limit(1).get();
      if (snapshot.docs.isEmpty) {
        throw const CacheException('Player not found in pool.');
      }
      final doc = snapshot.docs.first;
      final player = FantasyPlayerModel.fromJson(doc.data()).toEntity();

      final (updated, delta) = _scoringEngine.applyEvent(
        player,
        eventType,
        quantity: quantity,
      );

      await doc.reference.update(FantasyPlayerModel.fromEntity(updated).toJson());

      // Record the scoring event.
      await _scoringEvents.add({
        'playerId': playerId,
        'eventType': eventType,
        'quantity': quantity,
        'deltaPoints': delta,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return updated;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Unable to apply scoring event: $e');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  FantasyTeamModel _teamFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) {
      throw const CacheException('Team not found.');
    }
    return FantasyTeamModel.fromJson(doc.data()!);
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    var code = '';
    var seed = random;
    for (var i = 0; i < 6; i++) {
      seed = (seed * 31 + 7) & 0x7fffffff;
      code += chars[seed % chars.length];
    }
    return code;
  }
}

