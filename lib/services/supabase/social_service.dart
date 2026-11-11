import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'multiplayer_providers.dart';

class FriendEntry {
  const FriendEntry({
    required this.friendshipId,
    required this.userId,
    required this.displayName,
    required this.avatarIndex,
    required this.status,
    required this.online,
  });

  final String friendshipId;
  final String userId;
  final String displayName;
  final int avatarIndex;

  /// One of friend, incoming, outgoing.
  final String status;
  final bool online;

  factory FriendEntry.fromJson(Map<String, dynamic> j) => FriendEntry(
        friendshipId: j['friendship_id'].toString(),
        userId: j['user_id'].toString(),
        displayName: j['display_name']?.toString() ?? 'Player',
        avatarIndex: (j['avatar_index'] as num?)?.toInt() ?? 0,
        status: j['status'].toString(),
        online: j['online'] == true,
      );
}

class BlockedPlayer {
  const BlockedPlayer(this.userId, this.displayName, this.avatarIndex);
  final String userId;
  final String displayName;
  final int avatarIndex;
}

class MyProfile {
  const MyProfile(this.displayName, this.avatarIndex, this.friendCode);
  final String displayName;
  final int avatarIndex;
  final String friendCode;
}

class RoomInvite {
  const RoomInvite(this.id, this.roomCode, this.fromName);
  final String id;
  final String roomCode;
  final String fromName;
}

class SocialService {
  SocialService(this.client);
  final SupabaseClient client;

  Future<MyProfile> myProfile({String? displayName, int? avatar}) async {
    final res = await client.rpc('my_profile', params: {'p_display_name': displayName, 'p_avatar': avatar});
    final j = Map<String, dynamic>.from(res as Map);
    return MyProfile(j['display_name'].toString(), (j['avatar_index'] as num).toInt(), j['friend_code'].toString());
  }

  Future<void> touchPresence() => client.rpc('touch_presence');

  /// Returns the outcome: requested, accepted, already_friends or already_requested.
  Future<String> sendRequest(String code) async {
    final res = await client.rpc('send_friend_request', params: {'p_code': code});
    return (res as Map)['status'].toString();
  }

  Future<String> sendRequestInRoom(String roomId, String playerId) async {
    final res = await client.rpc('send_friend_request_in_room', params: {'p_room_id': roomId, 'p_player': playerId});
    return (res as Map)['status'].toString();
  }

  Future<void> respond(String friendshipId, bool accept) =>
      client.rpc('respond_friend_request', params: {'p_friendship_id': friendshipId, 'p_accept': accept});

  Future<void> remove(String friendshipId) => client.rpc('remove_friend', params: {'p_friendship_id': friendshipId});

  Future<List<FriendEntry>> list() async {
    final res = await client.rpc('list_friends');
    return (res as List).map((e) => FriendEntry.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> block(String playerId) => client.rpc('block_player', params: {'p_player': playerId});

  Future<void> unblock(String playerId) => client.rpc('unblock_player', params: {'p_player': playerId});

  Future<List<BlockedPlayer>> blocked() async {
    final res = await client.rpc('list_blocked');
    return (res as List).map((e) {
      final j = Map<String, dynamic>.from(e as Map);
      return BlockedPlayer(j['user_id'].toString(), j['display_name'].toString(), (j['avatar_index'] as num).toInt());
    }).toList();
  }

  Future<void> report({required String playerId, String? roomId, required String reason}) =>
      client.rpc('report_player', params: {'p_player': playerId, 'p_room_id': roomId, 'p_reason': reason, 'p_details': null});

  Future<void> invite(String roomId, String friendId) =>
      client.rpc('invite_friend', params: {'p_room_id': roomId, 'p_friend': friendId});

  Future<void> dismissInvite(String inviteId) => client.rpc('dismiss_invite', params: {'p_invite_id': inviteId});

  RealtimeChannel subscribeInvites(String userId, void Function(RoomInvite invite) onInvite) {
    return client
        .channel('room_invites:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'room_invites',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'to_id', value: userId),
          callback: (p) => onInvite(RoomInvite(
            p.newRecord['id'].toString(),
            p.newRecord['room_code'].toString(),
            p.newRecord['from_name'].toString(),
          )),
        )
        .subscribe();
  }
}

final socialServiceProvider = Provider<SocialService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SocialService(client);
});

final myProfileProvider = FutureProvider.autoDispose<MyProfile?>((ref) async {
  final user = ref.watch(authUserProvider).value;
  final svc = ref.watch(socialServiceProvider);
  if (user == null || svc == null) return null;
  return svc.myProfile();
});

final friendsProvider = FutureProvider.autoDispose<List<FriendEntry>>((ref) async {
  final user = ref.watch(authUserProvider).value;
  final svc = ref.watch(socialServiceProvider);
  if (user == null || svc == null) return const [];
  return svc.list();
});

final blockedProvider = FutureProvider<List<BlockedPlayer>>((ref) async {
  final user = ref.watch(authUserProvider).value;
  final svc = ref.watch(socialServiceProvider);
  if (user == null || svc == null) return const [];
  return svc.blocked();
});
