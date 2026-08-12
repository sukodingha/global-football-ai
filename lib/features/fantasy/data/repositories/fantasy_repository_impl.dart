import   '../../../../core/errors/exceptions.dart';
import   '../../../../core/errors/failures.dart';
import '../../domain/entities/fantasy_league_entity.dart';
import '../../domain/entities/fantasy_player_entity.dart';
import '../../domain/entities/fantasy_team_entity.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';
import '../../domain/repositories/fantasy_repository.dart';
import '../datasources/fantasy_remote_data_source.dart';

/// Implementation of [FantasyRepository] backed by [FantasyRemoteDataSource].
class FantasyRepositoryImpl implements FantasyRepository {
  FantasyRepositoryImpl({required FantasyRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final FantasyRemoteDataSource _dataSource;

  Future<T> _safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Exception catch (e) {
      throw _mapException(e);
    }
  }

  Failure _mapException(Exception e) {
    final message = e.toString();
    if (e is NetworkException || message.contains('network')) {
      return Failure.networkFailure(message: message);
    }
    if (e is CacheException || message.contains('cache')) {
      return Failure.cacheFailure(message: message);
    }
    if (e is AuthenticationException || message.contains('sign in')) {
      return Failure.serverFailure(message: message);
    }
    return Failure.unknown(message: message);
  }

  @override
  Future<FantasyLeagueEntity> createLeague(CreateLeagueParams params) {
    return _safeCall(() => _dataSource.createLeague(params));
  }

  @override
  Future<FantasyLeagueEntity> joinLeagueByCode(JoinLeagueParams params) {
    return _safeCall(() => _dataSource.joinLeagueByCode(params));
  }

  @override
  Future<FantasyLeagueEntity> getLeague(String leagueId) {
    return _safeCall(() => _dataSource.getLeague(leagueId));
  }

  @override
  Stream<FantasyLeagueEntity> watchLeague(String leagueId) {
    return _dataSource.watchLeague(leagueId);
  }

  @override
  Future<List<FantasyLeagueEntity>> getLeaguesForUser(String userId) {
    return _safeCall(() => _dataSource.getLeaguesForUser(userId));
  }

  @override
  Future<List<FantasyLeagueEntity>> getPublicLeagues({int limit = 20}) {
    return _safeCall(() => _dataSource.getPublicLeagues(limit: limit));
  }

  @override
  Stream<List<FantasyLeagueEntity>> watchPublicLeagues({int limit = 20}) {
    return _dataSource.watchPublicLeagues(limit: limit);
  }

  @override
  Future<FantasyTeamEntity> createTeam({
    required String name,
    required String userId,
    required String leagueId,
    double budget = 100,
  }) {
    return _safeCall(() => _dataSource.createTeam(
          name: name,
          userId: userId,
          leagueId: leagueId,
          budget: budget,
        ));
  }

  @override
  Future<FantasyTeamEntity?> getTeamInLeague({
    required String userId,
    required String leagueId,
  }) {
    return _safeCall(() =>
        _dataSource.getTeamInLeague(userId: userId, leagueId: leagueId));
  }

  @override
  Stream<FantasyTeamEntity> watchTeam(String teamId) {
    return _dataSource.watchTeam(teamId);
  }

  @override
  Future<FantasyTeamEntity> addPlayerToTeam({
    required String teamId,
    required FantasyPlayerEntity player,
  }) {
    return _safeCall(() =>
        _dataSource.addPlayerToTeam(teamId: teamId, player: player));
  }

  @override
  Future<FantasyTeamEntity> removePlayerFromTeam({
    required String teamId,
    required int playerId,
  }) {
    return _safeCall(() =>
        _dataSource.removePlayerFromTeam(teamId: teamId, playerId: playerId));
  }

  @override
  Future<FantasyTeamEntity> setCaptain({
    required String teamId,
    required int playerId,
  }) {
    return _safeCall(
        () => _dataSource.setCaptain(teamId: teamId, playerId: playerId));
  }

  @override
  Future<FantasyTeamEntity> setViceCaptain({
    required String teamId,
    required int playerId,
  }) {
    return _safeCall(
        () => _dataSource.setViceCaptain(teamId: teamId, playerId: playerId));
  }

  @override
  Stream<List<LeaderboardEntryEntity>> watchGlobalLeaderboard(
      {int limit = 50}) {
    return _dataSource.watchGlobalLeaderboard(limit: limit);
  }

  @override
  Stream<List<LeaderboardEntryEntity>> watchLeagueLeaderboard(
    String leagueId, {
    int limit = 50,
  }) {
    return _dataSource.watchLeagueLeaderboard(leagueId, limit: limit);
  }

  @override
  Future<List<FantasyPlayerEntity>> getPlayerPool({String? position}) {
    return _safeCall(() => _dataSource.getPlayerPool(position: position));
  }

  @override
  Stream<List<FantasyPlayerEntity>> watchPlayerPool({String? position}) {
    return _dataSource.watchPlayerPool(position: position);
  }

  @override
  Future<FantasyPlayerEntity> applyScoringEvent({
    required int playerId,
    required String eventType,
    int quantity = 1,
  }) {
    return _safeCall(() => _dataSource.applyScoringEvent(
          playerId: playerId,
          eventType: eventType,
          quantity: quantity,
        ));
  }
}

