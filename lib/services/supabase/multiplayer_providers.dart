import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';
import 'supabase_config.dart';
import 'supabase_game_service.dart';
import 'supabase_room_service.dart';
import 'supabase_service.dart';

final supabaseClientProvider = Provider<SupabaseClient?>((ref) => SupabaseService.client);

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
  });

  final OnlineRoom? room;
  final List<OnlineRoomPlayer> players;
  final bool isLoading;
  final String? error;

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

  bool get canStart => isHost && players.length >= 3 && players.where((p) => !p.isHost).every((p) => p.isReady);

  OnlineLobbyState copyWith({
    OnlineRoom? Function()? room,
    List<OnlineRoomPlayer>? players,
    bool? isLoading,
    String? Function()? error,
  }) =>
      OnlineLobbyState(
        room: room != null ? room() : this.room,
        players: players ?? this.players,
        isLoading: isLoading ?? this.isLoading,
        error: error != null ? error() : this.error,
      );
}

class OnlineLobbyNotifier extends Notifier<OnlineLobbyState> {
  RealtimeChannel? _playersSub;
  RealtimeChannel? _roomSub;

  @override
  OnlineLobbyState build() => const OnlineLobbyState();

  Future<bool> createRoom({
    required String code,
    required String displayName,
    required int avatar,
    Map<String, dynamic>? config,
  }) async {
    final roomService = ref.read(supabaseRoomServiceProvider);
    if (roomService == null) {
      state = state.copyWith(error: () => 'Supabase is not configured.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final res = await roomService.createRoom(
        code: code,
        displayName: displayName,
        avatar: avatar,
        config: config,
      );
      final room = await roomService.fetchRoom(res.roomId);
      final players = await roomService.fetchRoomPlayers(res.roomId);
      state = state.copyWith(room: () => room, players: players, isLoading: false);
      _subscribe(res.roomId);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
      return false;
    }
  }

  Future<bool> joinRoom({
    required String code,
    required String displayName,
    required int avatar,
  }) async {
    final roomService = ref.read(supabaseRoomServiceProvider);
    if (roomService == null) {
      state = state.copyWith(error: () => 'Supabase is not configured.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final res = await roomService.joinRoom(
        code: code,
        displayName: displayName,
        avatar: avatar,
      );
      final room = await roomService.fetchRoom(res.roomId);
      final players = await roomService.fetchRoomPlayers(res.roomId);
      state = state.copyWith(room: () => room, players: players, isLoading: false);
      _subscribe(res.roomId);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
      return false;
    }
  }

  Future<void> toggleReady() async {
    final roomService = ref.read(supabaseRoomServiceProvider);
    final room = state.room;
    if (roomService == null || room == null) return;

    final nextReady = !state.isReady;
    try {
      await roomService.toggleReady(roomId: room.id, isReady: nextReady);
      final players = await roomService.fetchRoomPlayers(room.id);
      state = state.copyWith(players: players);
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
    }
  }

  Future<void> leave() async {
    final roomService = ref.read(supabaseRoomServiceProvider);
    final room = state.room;
    _unsubscribe();
    if (roomService != null && room != null) {
      await roomService.leaveRoom(room.id);
    }
    state = const OnlineLobbyState();
  }

  void _subscribe(String roomId) {
    _unsubscribe();
    final roomService = ref.read(supabaseRoomServiceProvider);
    if (roomService == null) return;

    _playersSub = roomService.subscribeRoomPlayers(roomId, (players) {
      state = state.copyWith(players: players);
    });

    _roomSub = roomService.subscribeRoomStatus(roomId, (room) {
      state = state.copyWith(room: () => room);
    });
  }

  void _unsubscribe() {
    _playersSub?.unsubscribe();
    _roomSub?.unsubscribe();
    _playersSub = null;
    _roomSub = null;
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
  });

  final OnlineGameSession? session;
  final OnlinePrivateAssignment? assignment;
  final List<OnlineGamePlayer> players;
  final List<OnlineClue> clues;
  final OnlineResult? result;
  final bool isLoading;
  final String? error;

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
  }) =>
      OnlineGameState(
        session: session != null ? session() : this.session,
        assignment: assignment != null ? assignment() : this.assignment,
        players: players ?? this.players,
        clues: clues ?? this.clues,
        result: result != null ? result() : this.result,
        isLoading: isLoading ?? this.isLoading,
        error: error != null ? error() : this.error,
      );
}

class OnlineGameNotifier extends Notifier<OnlineGameState> {
  RealtimeChannel? _sessionSub;
  RealtimeChannel? _playersSub;
  RealtimeChannel? _cluesSub;

  @override
  OnlineGameState build() => const OnlineGameState();

  Future<void> initGame(String sessionId) async {
    final gameService = ref.read(supabaseGameServiceProvider);
    if (gameService == null) return;

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
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> submitClue(String text) async {
    final gameService = ref.read(supabaseGameServiceProvider);
    final s = state.session;
    if (gameService == null || s == null) return;

    try {
      await gameService.submitClue(sessionId: s.id, clueText: text);
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
    }
  }

  Future<void> advancePhase(String targetPhase) async {
    final gameService = ref.read(supabaseGameServiceProvider);
    final s = state.session;
    if (gameService == null || s == null) return;

    try {
      await gameService.advancePhase(sessionId: s.id, targetPhase: targetPhase);
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
    }
  }

  Future<void> castVote(String targetId) async {
    final gameService = ref.read(supabaseGameServiceProvider);
    final s = state.session;
    if (gameService == null || s == null) return;

    try {
      await gameService.castVote(sessionId: s.id, targetId: targetId);
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
    }
  }

  Future<void> tallyVotes() async {
    final gameService = ref.read(supabaseGameServiceProvider);
    final s = state.session;
    if (gameService == null || s == null) return;

    try {
      await gameService.tallyVotes(s.id);
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
    }
  }

  void _subscribe(String sessionId) {
    _unsubscribe();
    final gameService = ref.read(supabaseGameServiceProvider);
    if (gameService == null) return;

    _sessionSub = gameService.subscribeSession(sessionId, (session) async {
      state = state.copyWith(session: () => session);
      if (session.phase == 'result') {
        final res = await gameService.fetchResult(sessionId);
        state = state.copyWith(result: () => res);
      }
    });

    _playersSub = gameService.subscribeGamePlayers(sessionId, (players) {
      state = state.copyWith(players: players);
    });

    _cluesSub = gameService.subscribeClues(sessionId, (clues) {
      state = state.copyWith(clues: clues);
    });
  }

  void _unsubscribe() {
    _sessionSub?.unsubscribe();
    _playersSub?.unsubscribe();
    _cluesSub?.unsubscribe();
    _sessionSub = null;
    _playersSub = null;
    _cluesSub = null;
  }
}

final onlineGameProvider = NotifierProvider<OnlineGameNotifier, OnlineGameState>(OnlineGameNotifier.new);
