import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';
import 'supabase_game_service.dart';
import 'supabase_room_service.dart';
import 'supabase_service.dart';

final supabaseClientProvider = Provider<SupabaseClient?>((ref) => SupabaseService.client);

/// The signed-in user, or null. Emits on sign-in, sign-out and account linking.
final authUserProvider = StreamProvider<User?>((ref) async* {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    yield null;
    return;
  }
  yield client.auth.currentUser;
  await for (final e in client.auth.onAuthStateChange) {
    yield e.session?.user;
  }
});

final supabaseRoomServiceProvider = Provider<SupabaseRoomService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseRoomService(client);
});

final supabaseGameServiceProvider = Provider<SupabaseGameService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseGameService(client);
});

/// State for the online waiting lobby.
class OnlineLobbyState {
  const OnlineLobbyState({
    this.room,
    this.players = const [],
    this.isLoading = false,
    this.error,
    this.offline = false,
    this.resumable,
  });

  final OnlineRoom? room;
  final List<OnlineRoomPlayer> players;
  final bool isLoading;
  final String? error;

  /// The last heartbeat failed; the app keeps retrying.
  final bool offline;

  /// A room this player can go back to after restarting the app.
  final ({String roomId, String code, String status})? resumable;

  bool get isHost {
    final uid = SupabaseService.currentUserId;
    if (uid == null || room == null) return false;
    return room!.hostId == uid;
  }

  bool get isReady {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return false;
    final me = players.where((p) => p.playerId == uid).firstOrNull;
    return me?.isReady ?? false;
  }

  OnlineLobbyState copyWith({
    OnlineRoom? Function()? room,
    List<OnlineRoomPlayer>? players,
    bool? isLoading,
    String? Function()? error,
    bool? offline,
    ({String roomId, String code, String status})? Function()? resumable,
  }) =>
      OnlineLobbyState(
        room: room != null ? room() : this.room,
        players: players ?? this.players,
        isLoading: isLoading ?? this.isLoading,
        error: error != null ? error() : this.error,
        offline: offline ?? this.offline,
        resumable: resumable != null ? resumable() : this.resumable,
      );
}

class OnlineLobbyNotifier extends Notifier<OnlineLobbyState> {
  static const _heartbeatEvery = Duration(seconds: 15);

  RealtimeChannel? _playersSub;
  RealtimeChannel? _roomSub;
  Timer? _heartbeat;

  @override
  OnlineLobbyState build() {
    ref.onDispose(_unsubscribe);
    return const OnlineLobbyState();
  }

  Future<bool> createRoom({
    required String displayName,
    required int avatar,
    Map<String, dynamic>? config,
  }) =>
      _enter((svc) async => (await svc.createRoom(displayName: displayName, avatar: avatar, config: config)).roomId);

  Future<bool> joinRoom({
    required String code,
    required String displayName,
    required int avatar,
  }) =>
      _enter((svc) async => (await svc.joinRoom(code: code, displayName: displayName, avatar: avatar)).roomId);

  Future<bool> _enter(Future<String> Function(SupabaseRoomService svc) action) async {
    final svc = ref.read(supabaseRoomServiceProvider);
    if (svc == null) {
      state = state.copyWith(error: () => 'Online play is unavailable right now.');
      return false;
    }
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final roomId = await action(svc);
      final room = await svc.fetchRoom(roomId);
      final players = await svc.fetchRoomPlayers(roomId);
      state = OnlineLobbyState(room: room, players: players);
      _subscribe(roomId);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => friendlyError(e));
      return false;
    }
  }

  /// Looks for a room left open by a previous launch of the app.
  Future<void> checkResumable() async {
    final svc = ref.read(supabaseRoomServiceProvider);
    if (svc == null || state.room != null || SupabaseService.currentUser == null) return;
    try {
      final active = await svc.activeRoom();
      state = state.copyWith(resumable: () => active);
    } catch (_) {
      // Only a convenience; the normal join flow still works.
    }
  }

  Future<void> toggleReady() async {
    final svc = ref.read(supabaseRoomServiceProvider);
    final room = state.room;
    if (svc == null || room == null) return;
    try {
      await svc.toggleReady(roomId: room.id, isReady: !state.isReady);
      state = state.copyWith(players: await svc.fetchRoomPlayers(room.id));
    } catch (e) {
      state = state.copyWith(error: () => friendlyError(e));
    }
  }

  Future<void> moderate(String playerId, String action) async {
    final svc = ref.read(supabaseRoomServiceProvider);
    final room = state.room;
    if (svc == null || room == null) return;
    try {
      await svc.moderate(roomId: room.id, playerId: playerId, action: action);
      await refresh();
    } catch (e) {
      state = state.copyWith(error: () => friendlyError(e));
    }
  }

  Future<void> updateSettings({required int totalRounds, required String voteMode, required String voteVisibility, int clueSeconds = 60}) async {
    final svc = ref.read(supabaseRoomServiceProvider);
    final room = state.room;
    if (svc == null || room == null) return;
    try {
      await svc.updateSettings(roomId: room.id, totalRounds: totalRounds, voteMode: voteMode, voteVisibility: voteVisibility, clueSeconds: clueSeconds);
      await refresh();
    } catch (e) {
      state = state.copyWith(error: () => friendlyError(e));
    }
  }

  Future<void> setVoicePolicy({required bool clue, required bool vote}) async {
    final svc = ref.read(supabaseRoomServiceProvider);
    final room = state.room;
    if (svc == null || room == null) return;
    try {
      await svc.setVoicePolicy(roomId: room.id, clue: clue, vote: vote);
      await refresh();
    } catch (e) {
      state = state.copyWith(error: () => friendlyError(e));
    }
  }

  void clearError() => state = state.copyWith(error: () => null);

  Future<void> leave() async {
    final svc = ref.read(supabaseRoomServiceProvider);
    final room = state.room;
    _unsubscribe();
    state = const OnlineLobbyState();
    if (svc != null && room != null) {
      try {
        await svc.leaveRoom(room.id);
      } catch (_) {
        // If this fails, the heartbeat sweep will mark the player as gone.
      }
    }
  }

  /// Heartbeat plus a full re-read, which also recovers anything missed while offline.
  Future<void> refresh() async {
    final svc = ref.read(supabaseRoomServiceProvider);
    final room = state.room;
    if (svc == null || room == null) return;
    try {
      final member = await svc.heartbeat(room.id);
      if (state.room?.id != room.id) return;
      if (!member) {
        _unsubscribe();
        state = const OnlineLobbyState(error: 'You are no longer in that room.');
        return;
      }
      final latest = await svc.fetchRoom(room.id);
      final players = await svc.fetchRoomPlayers(room.id);
      if (state.room?.id != room.id) return;
      state = state.copyWith(room: () => latest ?? room, players: players, offline: false);
    } catch (_) {
      state = state.copyWith(offline: true);
    }
  }

  void _subscribe(String roomId) {
    _unsubscribe();
    final svc = ref.read(supabaseRoomServiceProvider);
    if (svc == null) return;

    _playersSub = svc.subscribeRoomPlayers(roomId, (players) {
      if (state.room?.id == roomId) state = state.copyWith(players: players);
    });

    _roomSub = svc.subscribeRoomStatus(roomId, (room) async {
      if (state.room?.id != roomId) return;
      state = state.copyWith(room: () => room);
      // A departure only shows up as a change to the room row.
      final players = await svc.fetchRoomPlayers(roomId);
      if (state.room?.id == roomId) state = state.copyWith(players: players);
    });

    _heartbeat = Timer.periodic(_heartbeatEvery, (_) => refresh());
  }

  void _unsubscribe() {
    _playersSub?.unsubscribe();
    _roomSub?.unsubscribe();
    _heartbeat?.cancel();
    _playersSub = null;
    _roomSub = null;
    _heartbeat = null;
  }
}

final onlineLobbyProvider = NotifierProvider<OnlineLobbyNotifier, OnlineLobbyState>(OnlineLobbyNotifier.new);

/// State for active Online Gameplay
class OnlineGameState {
  const OnlineGameState({
    this.session,
    this.assignment,
    this.players = const [],
    this.clues = const [],
    this.result,
    this.isLoading = false,
    this.error,
    this.endRequest,
    this.myVote,
    this.standings = const [],
    this.busy = false,
  });

  final DiscussionEndRequest? endRequest;

  /// This player's ballot in the current vote, once the server has it.
  final String? myVote;
  final List<MatchStanding> standings;

  /// A submission (clue, vote, request) is on its way to the server.
  final bool busy;
  final OnlineGameSession? session;
  final OnlinePrivateAssignment? assignment;
  final List<OnlineGamePlayer> players;
  final List<OnlineClue> clues;
  final OnlineResult? result;
  final bool isLoading;
  final String? error;

  /// Living players in turn order.
  List<String> get aliveOrder {
    final s = session;
    if (s == null) return const [];
    final alive = {for (final p in players) if (p.isAlive) p.playerId};
    return [for (final id in s.turnOrder) if (alive.contains(id)) id];
  }

  /// Next player due to vote in turn-based voting.
  String? get currentVoterId {
    final s = session;
    if (s == null || s.phase != 'vote' || !s.isSequentialVote) return null;
    return aliveOrder.where((id) => !s.voters.contains(id)).firstOrNull;
  }

  String? get currentCluePlayerId {
    if (session == null || session!.turnOrder.isEmpty) return null;
    return session!.turnOrder[session!.clueStep % session!.turnOrder.length];
  }

  bool get isMyClueTurn {
    final uid = SupabaseService.currentUserId;
    return uid != null && currentCluePlayerId == uid;
  }

  OnlineGameState copyWith({
    OnlineGameSession? Function()? session,
    OnlinePrivateAssignment? Function()? assignment,
    List<OnlineGamePlayer>? players,
    List<OnlineClue>? clues,
    OnlineResult? Function()? result,
    bool? isLoading,
    String? Function()? error,
    DiscussionEndRequest? Function()? endRequest,
    String? Function()? myVote,
    List<MatchStanding>? standings,
    bool? busy,
  }) =>
      OnlineGameState(
        session: session != null ? session() : this.session,
        assignment: assignment != null ? assignment() : this.assignment,
        players: players ?? this.players,
        clues: clues ?? this.clues,
        result: result != null ? result() : this.result,
        isLoading: isLoading ?? this.isLoading,
        error: error != null ? error() : this.error,
        endRequest: endRequest != null ? endRequest() : this.endRequest,
        myVote: myVote != null ? myVote() : this.myVote,
        standings: standings ?? this.standings,
        busy: busy ?? this.busy,
      );
}

class OnlineGameNotifier extends Notifier<OnlineGameState> {
  RealtimeChannel? _sessionSub;
  RealtimeChannel? _playersSub;
  RealtimeChannel? _cluesSub;
  RealtimeChannel? _requestSub;
  Timer? _resync;

  @override
  OnlineGameState build() {
    ref.onDispose(_unsubscribe);
    // Stop following a game once the player is out of its room.
    ref.listen(onlineLobbyProvider.select((s) => s.room?.id), (_, roomId) {
      if (roomId == null) {
        _unsubscribe();
        state = const OnlineGameState();
      }
    });
    return const OnlineGameState();
  }

  Future<void> _refresh(String sessionId) async {
    final svc = ref.read(supabaseGameServiceProvider);
    if (svc == null) return;
    try {
      final session = await svc.fetchSession(sessionId);
      final players = await svc.fetchGamePlayers(sessionId);
      final clues = await svc.fetchClues(sessionId);
      final result = session?.phase == 'result' ? await svc.fetchResult(sessionId) : null;
      final request = session?.phase == 'discussion' ? await svc.fetchEndRequest(sessionId) : null;
      final myVote = session != null && session.phase == 'vote' ? await svc.fetchMyVote(session) : null;
      final roomId = ref.read(onlineLobbyProvider).room?.id;
      final standings = session?.phase == 'result' && roomId != null ? await svc.matchStandings(roomId) : state.standings;
      if (state.session?.id != sessionId) return;
      state = state.copyWith(
        session: () => session,
        players: players,
        clues: clues,
        result: () => result,
        endRequest: () => request,
        myVote: () => myVote,
        standings: standings,
      );
    } catch (_) {
      // Still offline; the next tick tries again.
    }
  }

  void clearError() => state = state.copyWith(error: () => null);

  Future<void> initGame(String sessionId) async {
    final gameService = ref.read(supabaseGameServiceProvider);
    if (gameService == null) return;

    _acked = false;
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final session = await gameService.fetchSession(sessionId);
      final assignment = await gameService.getMyAssignment(sessionId);
      final players = await gameService.fetchGamePlayers(sessionId);
      final clues = await gameService.fetchClues(sessionId);
      final result = await gameService.fetchResult(sessionId);

      state = OnlineGameState(
        session: session,
        assignment: assignment,
        players: players,
        clues: clues,
        result: result,
      );

      _subscribe(sessionId);
      unawaited(_refresh(sessionId));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => friendlyError(e));
    }
  }

  /// Runs one submission with a busy flag, mapping failures to [error].
  Future<bool> _submit(Future<void> Function(SupabaseGameService svc, OnlineGameSession s) action) async {
    final svc = ref.read(supabaseGameServiceProvider);
    final s = state.session;
    if (svc == null || s == null || state.busy) return false;
    state = state.copyWith(busy: true);
    try {
      await action(svc, s).timeout(rpcTimeout);
      return true;
    } catch (e) {
      state = state.copyWith(error: () => friendlyError(e));
      return false;
    } finally {
      state = state.copyWith(busy: false);
      unawaited(_refresh(s.id));
    }
  }

  Future<bool> submitClue(String text) => _submit((svc, s) => svc.submitClue(sessionId: s.id, clueText: text));

  Future<bool> advancePhase(String targetPhase) =>
      _submit((svc, s) => svc.advancePhase(sessionId: s.id, targetPhase: targetPhase));

  Future<bool> castVote(String targetId) async {
    final ok = await _submit((svc, s) => svc.castVote(sessionId: s.id, targetId: targetId));
    if (ok) state = state.copyWith(myVote: () => targetId);
    return ok;
  }

  Future<bool> tallyVotes() => _submit((svc, s) => svc.tallyVotes(s.id));

  /// Returns how many players have not seen their word when the host must
  /// confirm, 0 when the round started, or -1 on failure.
  Future<int> startClueRound({bool force = false}) async {
    var waiting = -1;
    await _submit((svc, s) async {
      final r = await svc.startClueRound(s.id, force: force);
      waiting = r.status == 'needs_confirm' ? r.waiting : 0;
    });
    return waiting;
  }

  Future<bool> startDiscussion() => _submit((svc, s) => svc.startDiscussion(s.id));

  bool _acked = false;

  /// Called the first time this player actually holds their card open.
  Future<void> ackWordViewed() async {
    final svc = ref.read(supabaseGameServiceProvider);
    final s = state.session;
    if (svc == null || s == null || _acked) return;
    _acked = true;
    try {
      await svc.ackWordViewed(s.id);
    } catch (_) {
      _acked = false; // Try again on the next hold.
    }
  }

  Future<bool> skipTurn() => _submit((svc, s) => svc.skipTurn(s.id));

  Future<bool> requestEndDiscussion() => _submit((svc, s) => svc.requestEndDiscussion(s.id));

  Future<bool> respondEndDiscussion(bool approve) async {
    final req = state.endRequest;
    if (req == null) return false;
    return _submit((svc, s) => svc.respondEndDiscussion(req.id, approve));
  }

  /// Called when this device's discussion countdown reaches zero.
  Future<void> syncTimers() async {
    final svc = ref.read(supabaseGameServiceProvider);
    final s = state.session;
    if (svc == null || s == null) return;
    try {
      await svc.syncGame(s.id);
    } catch (_) {
      // The heartbeat applies the same rule shortly.
    }
  }

  Future<bool> startNextRound() async {
    final svc = ref.read(supabaseGameServiceProvider);
    final roomId = ref.read(onlineLobbyProvider).room?.id;
    if (svc == null || roomId == null || state.busy) return false;
    state = state.copyWith(busy: true);
    try {
      await svc.startNextRound(roomId);
      return true;
    } catch (e) {
      state = state.copyWith(error: () => friendlyError(e));
      return false;
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  void _subscribe(String sessionId) {
    _unsubscribe();
    final gameService = ref.read(supabaseGameServiceProvider);
    if (gameService == null) return;

    _sessionSub = gameService.subscribeSession(sessionId, (session) {
      final changedBallot = state.session?.revotes != session.revotes || state.session?.phase != session.phase;
      state = state.copyWith(session: () => session, myVote: changedBallot ? () => null : null);
      unawaited(_refresh(sessionId));
    });

    _requestSub = gameService.subscribeEndRequests(sessionId, () => unawaited(_refresh(sessionId)));

    _playersSub = gameService.subscribeGamePlayers(sessionId, (players) {
      state = state.copyWith(players: players);
    });

    _cluesSub = gameService.subscribeClues(sessionId, (clues) {
      state = state.copyWith(clues: clues);
    });

    _resync = Timer.periodic(const Duration(seconds: 15), (_) => _refresh(sessionId));
  }

  void _unsubscribe() {
    _sessionSub?.unsubscribe();
    _playersSub?.unsubscribe();
    _cluesSub?.unsubscribe();
    _requestSub?.unsubscribe();
    _requestSub = null;
    _resync?.cancel();
    _resync = null;
    _sessionSub = null;
    _playersSub = null;
    _cluesSub = null;
  }
}

final onlineGameProvider = NotifierProvider<OnlineGameNotifier, OnlineGameState>(OnlineGameNotifier.new);
