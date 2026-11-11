import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'multiplayer_providers.dart';
import 'social_service.dart';
import 'supabase_service.dart';

enum ChatDelivery { sending, sent, failed }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.message,
    required this.isSystem,
    required this.createdAt,
    this.systemEvent,
    this.clientId,
    this.isDeleted = false,
    this.delivery = ChatDelivery.sent,
  });

  final String id;
  final String? senderId;
  final String senderName;
  final int senderAvatar;
  final String message;
  final bool isSystem;
  final DateTime createdAt;
  final String? systemEvent;
  final String? clientId;
  final bool isDeleted;
  final ChatDelivery delivery;

  bool get isMine => senderId != null && senderId == SupabaseService.currentUserId;

  ChatMessage withDelivery(ChatDelivery d) => ChatMessage(
        id: id,
        senderId: senderId,
        senderName: senderName,
        senderAvatar: senderAvatar,
        message: message,
        isSystem: isSystem,
        createdAt: createdAt,
        systemEvent: systemEvent,
        clientId: clientId,
        isDeleted: isDeleted,
        delivery: d,
      );

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'].toString(),
        senderId: j['sender_id']?.toString(),
        senderName: j['sender_name']?.toString() ?? '',
        senderAvatar: (j['sender_avatar'] as num?)?.toInt() ?? 0,
        message: j['message']?.toString() ?? '',
        isSystem: j['message_type'] == 'system',
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
        systemEvent: j['system_event']?.toString(),
        clientId: j['client_id']?.toString(),
        isDeleted: j['deleted_at'] != null,
      );
}

class RoomChatState {
  const RoomChatState({this.messages = const [], this.unread = 0, this.isOpen = false, this.latest, this.error});

  final List<ChatMessage> messages;
  final int unread;
  final bool isOpen;

  /// Newest message from someone else, shown as the in-game preview.
  final ChatMessage? latest;
  final String? error;

  RoomChatState copyWith({
    List<ChatMessage>? messages,
    int? unread,
    bool? isOpen,
    ChatMessage? Function()? latest,
    String? Function()? error,
  }) =>
      RoomChatState(
        messages: messages ?? this.messages,
        unread: unread ?? this.unread,
        isOpen: isOpen ?? this.isOpen,
        latest: latest != null ? latest() : this.latest,
        error: error != null ? error() : this.error,
      );
}

class RoomChatNotifier extends Notifier<RoomChatState> {
  static const maxLength = 500;
  static const _historySize = 100;

  String? _roomId;
  RealtimeChannel? _channel;

  SupabaseClient? get _client => ref.read(supabaseClientProvider);

  @override
  RoomChatState build() {
    ref.onDispose(_detach);
    ref.listen(onlineLobbyProvider.select((s) => s.room?.id), (_, roomId) => _attach(roomId), fireImmediately: true);
    return const RoomChatState();
  }

  void _detach() {
    _channel?.unsubscribe();
    _channel = null;
    _roomId = null;
  }

  Future<void> _attach(String? roomId) async {
    if (roomId == _roomId) return;
    _detach();
    await Future<void>.value(); // Never assign state while build() is running.
    state = const RoomChatState();
    final client = _client;
    if (roomId == null || client == null) return;
    _roomId = roomId;

    void onRow(PostgresChangePayload p) {
      if (_roomId == roomId) _merge(ChatMessage.fromJson(p.newRecord), live: true);
    }

    final filter = PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'room_id', value: roomId);
    _channel = client
        .channel('room_messages:$roomId')
        .onPostgresChanges(event: PostgresChangeEvent.insert, schema: 'public', table: 'room_messages', filter: filter, callback: onRow)
        .onPostgresChanges(event: PostgresChangeEvent.update, schema: 'public', table: 'room_messages', filter: filter, callback: onRow)
        .subscribe((status, _) {
      // Also runs after every automatic reconnect, recovering what was missed.
      if (status == RealtimeSubscribeStatus.subscribed) loadHistory();
    });
  }

  Future<void> loadHistory() async {
    final client = _client;
    final roomId = _roomId;
    if (client == null || roomId == null) return;
    try {
      final rows = await client
          .from('room_messages')
          .select()
          .eq('room_id', roomId)
          .order('created_at', ascending: false)
          .limit(_historySize);
      if (_roomId != roomId) return;
      for (final r in (rows as List).reversed) {
        _merge(ChatMessage.fromJson(Map<String, dynamic>.from(r as Map)), live: false);
      }
    } catch (_) {
      // Realtime still delivers new messages; history retries on reconnect.
    }
  }

  bool _isHidden(ChatMessage m) {
    final blocked = ref.read(blockedProvider).value ?? const <BlockedPlayer>[];
    return blocked.any((b) => b.userId == m.senderId);
  }

  void _merge(ChatMessage m, {required bool live}) {
    final list = [...state.messages];
    final index = list.indexWhere((e) => e.id == m.id || (m.clientId != null && e.clientId == m.clientId));
    final isNew = index < 0;
    if (isNew) {
      list.add(m);
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      list[index] = m;
    }

    final fromOther = !m.isMine && !_isHidden(m);
    final notify = isNew && live && fromOther && !m.isDeleted;
    state = state.copyWith(
      messages: list.length > 200 ? list.sublist(list.length - 200) : list,
      unread: notify && !m.isSystem && !state.isOpen ? state.unread + 1 : null,
      latest: notify ? () => m : null,
    );
  }

  List<ChatMessage> get visible => [for (final m in state.messages) if (!_isHidden(m)) m];

  void setOpen(bool open) => state = state.copyWith(isOpen: open, unread: open ? 0 : null);

  void clearError() => state = state.copyWith(error: () => null);

  static String _newClientId() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final hex = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _roomId == null) return;
    if (trimmed.length > maxLength) {
      state = state.copyWith(error: () => 'Messages can be up to $maxLength characters.');
      return;
    }
    final clientId = _newClientId();
    final lobby = ref.read(onlineLobbyProvider);
    final me = lobby.players.where((p) => p.playerId == SupabaseService.currentUserId).firstOrNull;
    final pending = ChatMessage(
      id: 'local-$clientId',
      senderId: SupabaseService.currentUserId,
      senderName: me?.displayName ?? '',
      senderAvatar: me?.avatarIndex ?? 0,
      message: trimmed,
      isSystem: false,
      createdAt: DateTime.now(),
      clientId: clientId,
      delivery: ChatDelivery.sending,
    );
    _merge(pending, live: false);
    await _deliver(pending);
  }

  Future<void> retry(ChatMessage m) async {
    _merge(m.withDelivery(ChatDelivery.sending), live: false);
    await _deliver(m);
  }

  void discard(ChatMessage m) {
    state = state.copyWith(messages: [for (final e in state.messages) if (e.id != m.id) e]);
  }

  Future<void> _deliver(ChatMessage m) async {
    try {
      final res = await _client!.rpc('send_room_message', params: {
        'p_room_id': _roomId,
        'p_message': m.message,
        'p_client_id': m.clientId,
      });
      _merge(ChatMessage.fromJson(Map<String, dynamic>.from(res as Map)), live: false);
    } catch (e) {
      _merge(m.withDelivery(ChatDelivery.failed), live: false);
      state = state.copyWith(error: () => friendlyError(e));
    }
  }

  Future<void> delete(ChatMessage m) async {
    try {
      await _client!.rpc('delete_room_message', params: {'p_message_id': m.id});
    } catch (e) {
      state = state.copyWith(error: () => friendlyError(e));
    }
  }
}

final roomChatProvider = NotifierProvider<RoomChatNotifier, RoomChatState>(RoomChatNotifier.new);
