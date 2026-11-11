import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';
import 'supabase_service.dart';

class SupabaseRoomService {
  final SupabaseClient client;

  SupabaseRoomService(this.client);

  /// Creates a private room. The server generates the code.
  Future<({String roomId, String code})> createRoom({
    required String displayName,
    required int avatar,
    Map<String, dynamic>? config,
  }) async {
    final res = await client.rpc('create_room', params: {
      'p_display_name': displayName,
      'p_avatar': avatar,
      'p_config': config,
    }).timeout(rpcTimeout);
    final data = Map<String, dynamic>.from(res as Map);
    return (roomId: data['room_id'].toString(), code: data['code'].toString());
  }

  /// Joins by code, or returns to a room the player already belongs to.
  Future<({String roomId, String code})> joinRoom({
    required String code,
    required String displayName,
    required int avatar,
  }) async {
    final res = await client.rpc('join_room', params: {
      'p_code': code.toUpperCase().trim(),
      'p_display_name': displayName,
      'p_avatar': avatar,
    }).timeout(rpcTimeout);
    final data = Map<String, dynamic>.from(res as Map);
    return (roomId: data['room_id'].toString(), code: data['code'].toString());
  }

  /// The room this player is still part of, if any.
  Future<({String roomId, String code, String status})?> activeRoom() async {
    final res = await client.rpc('my_active_room');
    if (res == null) return null;
    final data = Map<String, dynamic>.from(res as Map);
    return (roomId: data['room_id'].toString(), code: data['code'].toString(), status: data['status'].toString());
  }

  /// Tells the server this player is still here. False if no longer a member.
  Future<bool> heartbeat(String roomId) async {
    final res = await client.rpc('room_heartbeat', params: {'p_room_id': roomId});
    return (res as Map)['member'] == true;
  }

  Future<void> moderate({required String roomId, required String playerId, required String action}) async {
    await client.rpc('moderate_player', params: {'p_room_id': roomId, 'p_player': playerId, 'p_action': action});
  }

  Future<RoomPreview> peekRoom(String code) async {
    final res = await client.rpc('peek_room', params: {'p_code': code}).timeout(rpcTimeout);
    return RoomPreview.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<void> updateSettings({
    required String roomId,
    required int totalRounds,
    required String voteMode,
    required String voteVisibility,
  }) async {
    await client.rpc('update_room_settings', params: {
      'p_room_id': roomId,
      'p_total_rounds': totalRounds,
      'p_vote_mode': voteMode,
      'p_vote_visibility': voteVisibility,
    }).timeout(rpcTimeout);
  }

  Future<void> setVoicePolicy({required String roomId, required bool clue, required bool vote}) async {
    await client.rpc('set_voice_policy', params: {'p_room_id': roomId, 'p_clue': clue, 'p_vote': vote});
  }

  /// Toggles player ready status
  Future<void> toggleReady({required String roomId, required bool isReady}) async {
    await client.rpc('toggle_ready', params: {
      'p_room_id': roomId,
      'p_is_ready': isReady,
    });
  }

  /// Leaves the room
  Future<void> leaveRoom(String roomId) async {
    try {
      await client.rpc('leave_room', params: {'p_room_id': roomId});
    } catch (e) {
      debugPrint('leaveRoom error: $e');
    }
  }

  /// Fetches current room details
  Future<OnlineRoom?> fetchRoom(String roomId) async {
    final res = await client.from('rooms').select().eq('id', roomId).maybeSingle();
    if (res == null) return null;
    return OnlineRoom.fromJson(Map<String, dynamic>.from(res));
  }

  /// Fetches players in the room
  Future<List<OnlineRoomPlayer>> fetchRoomPlayers(String roomId) async {
    final res = await client
        .from('room_players')
        .select()
        .eq('room_id', roomId)
        .order('joined_at', ascending: true);
    return (res as List).map((e) => OnlineRoomPlayer.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  /// Subscribes to realtime player list updates in a room
  RealtimeChannel subscribeRoomPlayers(String roomId, void Function(List<OnlineRoomPlayer> players) onUpdate) {
    final channel = client.channel('public:room_players:$roomId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'room_players',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) async {
            final players = await fetchRoomPlayers(roomId);
            onUpdate(players);
          },
        )
        .subscribe();

    return channel;
  }

  /// Subscribes to room status changes (e.g., transition from waiting to playing)
  RealtimeChannel subscribeRoomStatus(String roomId, void Function(OnlineRoom room) onRoomChange) {
    final channel = client.channel('public:room:$roomId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'rooms',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: roomId,
          ),
          callback: (payload) async {
            final room = await fetchRoom(roomId);
            if (room != null) {
              onRoomChange(room);
            }
          },
        )
        .subscribe();

    return channel;
  }
}
