import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';
import 'supabase_service.dart';

class SupabaseGameService {
  final SupabaseClient client;

  SupabaseGameService(this.client);

  /// Host starts game: allocates roles and creates session server-side
  Future<({String sessionId, int playerCount, String category, String phase})> startGame({
    required String roomId,
    required String category,
    required String word,
    String? hint,
    String? fakeWord,
    int imposterCount = 1,
    int discussionSeconds = 180,
  }) async {
    final res = await client.rpc('start_online_game', params: {
      'p_room_id': roomId,
      'p_category': category,
      'p_word': word,
      'p_hint': hint,
      'p_fake_word': fakeWord,
      'p_imposter_count': imposterCount,
      'p_discussion_seconds': discussionSeconds,
    });

    final data = Map<String, dynamic>.from(res as Map);
    return (
      sessionId: data['session_id']?.toString() ?? '',
      playerCount: (data['player_count'] as num?)?.toInt() ?? 0,
      category: data['category']?.toString() ?? category,
      phase: data['phase']?.toString() ?? 'reveal',
    );
  }

  /// Retrieves current user's strictly private assignment (Word, Role, Hint)
  Future<OnlinePrivateAssignment> getMyAssignment(String sessionId) async {
    final res = await client.rpc('get_my_assignment', params: {
      'p_session_id': sessionId,
    });

    return OnlinePrivateAssignment.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// Host advances game phase ('clue', 'discussion', 'vote')
  Future<void> advancePhase({required String sessionId, required String targetPhase}) async {
    await client.rpc('advance_game_phase', params: {
      'p_session_id': sessionId,
      'p_target_phase': targetPhase,
    });
  }

  /// Submits clue for the active turn player
  Future<void> submitClue({required String sessionId, required String clueText}) async {
    await client.rpc('submit_online_clue', params: {
      'p_session_id': sessionId,
      'p_clue_text': clueText,
    });
  }

  /// Casts confidential vote for target player
  Future<void> castVote({required String sessionId, required String targetId}) async {
    await client.rpc('cast_online_vote', params: {
      'p_session_id': sessionId,
      'p_target_id': targetId,
    });
  }

  /// Server-authoritative vote tally and elimination/win resolution
  Future<Map<String, dynamic>> tallyVotes(String sessionId) async {
    final res = await client.rpc('tally_online_votes', params: {
      'p_session_id': sessionId,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  /// Fetches game session state
  Future<OnlineGameSession?> fetchSession(String sessionId) async {
    final res = await client.from('game_sessions').select().eq('id', sessionId).maybeSingle();
    if (res == null) return null;
    return OnlineGameSession.fromJson(Map<String, dynamic>.from(res));
  }

  /// Fetches latest session for a room
  Future<OnlineGameSession?> fetchSessionByRoom(String roomId) async {
    final res = await client
        .from('game_sessions')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (res == null) return null;
    return OnlineGameSession.fromJson(Map<String, dynamic>.from(res));
  }

  /// Fetches players in the session
  Future<List<OnlineGamePlayer>> fetchGamePlayers(String sessionId) async {
    final res = await client.from('game_players').select().eq('session_id', sessionId);
    return (res as List).map((e) => OnlineGamePlayer.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  /// Fetches clues in the session
  Future<List<OnlineClue>> fetchClues(String sessionId) async {
    final res = await client
        .from('game_clues')
        .select()
        .eq('session_id', sessionId)
        .order('clue_step', ascending: true);
    return (res as List).map((e) => OnlineClue.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  /// Fetches official game result
  Future<OnlineResult?> fetchResult(String sessionId) async {
    final res = await client.from('game_results').select().eq('session_id', sessionId).maybeSingle();
    if (res == null) return null;
    return OnlineResult.fromJson(Map<String, dynamic>.from(res));
  }

  /// Subscribes to game session changes (phase, timer, round, winner)
  RealtimeChannel subscribeSession(String sessionId, void Function(OnlineGameSession session) onUpdate) {
    final channel = client.channel('public:game_sessions:$sessionId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'game_sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: sessionId,
          ),
          callback: (payload) async {
            final s = await fetchSession(sessionId);
            if (s != null) onUpdate(s);
          },
        )
        .subscribe();

    return channel;
  }

  /// Subscribes to clues stream
  RealtimeChannel subscribeClues(String sessionId, void Function(List<OnlineClue> clues) onUpdate) {
    final channel = client.channel('public:game_clues:$sessionId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'game_clues',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'session_id',
            value: sessionId,
          ),
          callback: (payload) async {
            final clues = await fetchClues(sessionId);
            onUpdate(clues);
          },
        )
        .subscribe();

    return channel;
  }

  /// Subscribes to game players elimination changes
  RealtimeChannel subscribeGamePlayers(String sessionId, void Function(List<OnlineGamePlayer> players) onUpdate) {
    final channel = client.channel('public:game_players:$sessionId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'game_players',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'session_id',
            value: sessionId,
          ),
          callback: (payload) async {
            final players = await fetchGamePlayers(sessionId);
            onUpdate(players);
          },
        )
        .subscribe();

    return channel;
  }
}
