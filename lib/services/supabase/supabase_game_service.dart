import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';
import 'supabase_service.dart';

class SupabaseGameService {
  final SupabaseClient client;

  SupabaseGameService(this.client);

  /// Host starts the game. The server picks the word and assigns roles.
  Future<String> startGame(String roomId) async {
    final res = await client.rpc('start_online_game', params: {'p_room_id': roomId}).timeout(rpcTimeout);
    return (res as Map)['session_id'].toString();
  }

  /// Host starts the clue round. Returns 'needs_confirm' when some players
  /// have not seen their word yet and [force] is false.
  Future<({String status, int waiting})> startClueRound(String sessionId, {bool force = false}) async {
    final res = await client.rpc('start_clue_round', params: {'p_session_id': sessionId, 'p_force': force}).timeout(rpcTimeout);
    final j = Map<String, dynamic>.from(res as Map);
    return (status: j['status'].toString(), waiting: (j['waiting'] as num?)?.toInt() ?? 0);
  }

  Future<void> startDiscussion(String sessionId) async {
    await client.rpc('start_discussion', params: {'p_session_id': sessionId}).timeout(rpcTimeout);
  }

  /// Records that this player really looked at their word.
  Future<void> ackWordViewed(String sessionId) async {
    await client.rpc('ack_word_viewed', params: {'p_session_id': sessionId}).timeout(rpcTimeout);
  }

  Future<String> startNextRound(String roomId) async {
    final res = await client.rpc('start_next_round', params: {'p_room_id': roomId}).timeout(rpcTimeout);
    return (res as Map)['session_id'].toString();
  }

  /// Host skips the clue or turn-based vote of a player who has dropped out.
  Future<void> skipTurn(String sessionId) async {
    await client.rpc('skip_turn', params: {'p_session_id': sessionId}).timeout(rpcTimeout);
  }

  /// Applies server timers (discussion end, expired requests) right away.
  Future<void> syncGame(String sessionId) async {
    await client.rpc('sync_game', params: {'p_session_id': sessionId}).timeout(rpcTimeout);
  }

  Future<void> requestEndDiscussion(String sessionId) async {
    await client.rpc('request_end_discussion', params: {'p_session_id': sessionId}).timeout(rpcTimeout);
  }

  Future<String> respondEndDiscussion(String requestId, bool approve) async {
    final res = await client.rpc('respond_end_discussion', params: {'p_request_id': requestId, 'p_approve': approve}).timeout(rpcTimeout);
    return (res as Map)['status'].toString();
  }

  Future<DiscussionEndRequest?> fetchEndRequest(String sessionId) async {
    final res = await client
        .from('discussion_end_requests')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle()
        .timeout(rpcTimeout);
    return res == null ? null : DiscussionEndRequest.fromJson(Map<String, dynamic>.from(res));
  }

  RealtimeChannel subscribeEndRequests(String sessionId, void Function() onChange) {
    return client
        .channel('discussion_end_requests:$sessionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'discussion_end_requests',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'session_id', value: sessionId),
          callback: (_) => onChange(),
        )
        .subscribe();
  }

  /// This player's own ballot in the current vote, if any.
  Future<String?> fetchMyVote(OnlineGameSession s) async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return null;
    final res = await client
        .from('game_votes')
        .select('target_id')
        .eq('session_id', s.id)
        .eq('voter_id', uid)
        .eq('round_number', s.roundNumber)
        .eq('revote_number', s.revotes)
        .maybeSingle()
        .timeout(rpcTimeout);
    return res?['target_id']?.toString();
  }

  Future<List<MatchStanding>> matchStandings(String roomId) async {
    final res = await client.rpc('match_standings', params: {'p_room_id': roomId}).timeout(rpcTimeout);
    return (res as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map((j) => MatchStanding(j['player_id'].toString(), j['display_name'].toString(), (j['points'] as num).toInt()))
        .toList();
  }

  /// Retrieves current user's strictly private assignment (Word, Role, Hint)
  Future<OnlinePrivateAssignment> getMyAssignment(String sessionId) async {
    final res = await client.rpc('get_my_assignment', params: {
      'p_session_id': sessionId,
    }).timeout(rpcTimeout);

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
