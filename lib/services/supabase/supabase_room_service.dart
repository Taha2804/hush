import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';
import 'supabase_service.dart';

class SupabaseRoomService {
  final SupabaseClient client;

  SupabaseRoomService(this.client);

  /// Creates a new private room using PostgreSQL RPC
  Future<({String roomId, String code, String playerId})> createRoom({
    required String code,
    required String displayName,
    required int avatar,
    Map<String, dynamic>? config,
  }) async {
    await SupabaseService.ensureAuthenticated();
    final res = await client.rpc('create_room', params: {
      'p_code': code.toUpperCase().trim(),
      'p_display_name': displayName,
      'p_avatar': avatar,
      'p_config': config,
    });

    final data = Map<String, dynamic>.from(res as Map);
    return (
      roomId: data['room_id']?.toString() ?? '',
      code: data['code']?.toString() ?? code,
      playerId: data['player_id']?.toString() ?? SupabaseService.currentUserId ?? '',
    );
  }

  /// Joins an existing room by code
  Future<({String roomId, String code, String hostId, String playerId})> joinRoom({
    required String code,
    required String displayName,
    required int avatar,
  }) async {
    await SupabaseService.ensureAuthenticated();
    final res = await client.rpc('join_room', params: {
      'p_code': code.toUpperCase().trim(),
      'p_display_name': displayName,
      'p_avatar': avatar,
    });

    final data = Map<String, dynamic>.from(res as Map);
    return (
      roomId: data['room_id']?.toString() ?? '',
      code: data['code']?.toString() ?? code,
      hostId: data['host_id']?.toString() ?? '',
      playerId: data['player_id']?.toString() ?? SupabaseService.currentUserId ?? '',
    );
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
