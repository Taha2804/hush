import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/providers.dart';
import 'multiplayer_providers.dart';
import 'supabase_service.dart';

enum VoiceStatus { off, connecting, connected, reconnecting, failed }

enum MicIssue { none, denied, permanentlyDenied, revoked, unavailable, busy }

class VoicePeer {
  const VoicePeer({this.speaking = false, this.muted = true});
  final bool speaking;
  final bool muted;
}

class VoiceState {
  const VoiceState({
    this.status = VoiceStatus.off,
    this.micOn = false,
    this.deafened = false,
    this.pushToTalk = false,
    this.pttHeld = false,
    this.phaseAllowed = true,
    this.issue = MicIssue.none,
    this.peers = const {},
    this.error,
  });

  final VoiceStatus status;
  final bool micOn;
  final bool deafened;
  final bool pushToTalk;
  final bool pttHeld;

  /// False while the game phase forbids talking (for example the word reveal).
  final bool phaseAllowed;
  final MicIssue issue;

  /// Connected players by user id, including this device.
  final Map<String, VoicePeer> peers;
  final String? error;

  bool get inCall => status == VoiceStatus.connected || status == VoiceStatus.reconnecting;

  VoiceState copyWith({
    VoiceStatus? status,
    bool? micOn,
    bool? deafened,
    bool? pushToTalk,
    bool? pttHeld,
    bool? phaseAllowed,
    MicIssue? issue,
    Map<String, VoicePeer>? peers,
    String? Function()? error,
  }) =>
      VoiceState(
        status: status ?? this.status,
        micOn: micOn ?? this.micOn,
        deafened: deafened ?? this.deafened,
        pushToTalk: pushToTalk ?? this.pushToTalk,
        pttHeld: pttHeld ?? this.pttHeld,
        phaseAllowed: phaseAllowed ?? this.phaseAllowed,
        issue: issue ?? this.issue,
        peers: peers ?? this.peers,
        error: error != null ? error() : this.error,
      );
}

/// Voice is an extra: every failure here stays here, and chat and the game
/// carry on regardless. Speaking rights are enforced by the server; the checks
/// in this class only keep the buttons honest.
class VoiceNotifier extends Notifier<VoiceState> {
  static const _maxRetries = 3;

  lk.Room? _room;
  lk.EventsListener<lk.RoomEvent>? _listener;
  bool _leaving = false;
  bool _micWanted = false;
  int _retries = 0;
  Timer? _retryTimer;

  @override
  VoiceState build() {
    ref.onDispose(() {
      _retryTimer?.cancel();
      _teardown();
    });
    ref.listen(onlineLobbyProvider.select((s) => s.room?.id), (prev, next) {
      if (next != prev) leave();
    });
    ref.listen(onlineLobbyProvider, (_, _) => _applyPhase());
    ref.listen(onlineGameProvider, (_, _) => _applyPhase());
    ref.listen(settingsProvider.select((s) => s.voiceVolume), (_, _) => _applyVolume());
    ref.listen(settingsProvider.select((s) => s.speakerOutput), (_, _) => _applySpeaker());
    return VoiceState(pushToTalk: ref.read(settingsProvider).pushToTalk, phaseAllowed: _computeAllowed());
  }

  bool _computeAllowed() {
    final room = ref.read(onlineLobbyProvider).room;
    if (room == null) return false;
    if (room.status != 'playing') return true;
    final session = ref.read(onlineGameProvider).session;
    if (session == null || session.roomId != room.id) return false;
    return switch (session.phase) {
      'reveal' => false,
      'clue' => room.voicePolicy['clue'] != false,
      'vote' => room.voicePolicy['vote'] != false,
      _ => true,
    };
  }

  void _applyPhase() {
    final allowed = _computeAllowed();
    if (allowed == state.phaseAllowed) return;
    state = state.copyWith(phaseAllowed: allowed);
    if (!allowed) {
      _setPublishing(false);
    } else if (_micWanted && !state.pushToTalk) {
      _setPublishing(true);
    }
  }

  Future<bool> microphoneGranted() async => (await Permission.microphone.status).isGranted;

  Future<void> openSystemSettings() => openAppSettings();

  Future<bool> _ensurePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) status = await Permission.microphone.request();
    if (status.isGranted) {
      if (state.issue != MicIssue.none) state = state.copyWith(issue: MicIssue.none);
      return true;
    }
    state = state.copyWith(issue: status.isPermanentlyDenied ? MicIssue.permanentlyDenied : MicIssue.denied);
    return false;
  }

  /// Joins the room's voice call. Without microphone access the player can
  /// still listen.
  Future<void> join() async {
    if (state.status == VoiceStatus.connecting || state.inCall) return;
    final granted = await _ensurePermission();
    _micWanted = granted && !state.pushToTalk;
    _retries = 0;
    await _connect();
  }

  Future<void> _connect() async {
    final roomId = ref.read(onlineLobbyProvider).room?.id;
    final client = ref.read(supabaseClientProvider);
    if (roomId == null || client == null) return;

    _leaving = false;
    state = state.copyWith(status: VoiceStatus.connecting, error: () => null);
    try {
      final res = await client.functions.invoke('livekit-token', body: {'room_id': roomId});
      final data = Map<String, dynamic>.from(res.data as Map);

      final room = lk.Room(roomOptions: const lk.RoomOptions(adaptiveStream: false, dynacast: false));
      final listener = room.createListener();
      _room = room;
      _listener = listener;
      _bindEvents(listener);

      await room.connect(data['url'] as String, data['token'] as String);
      if (ref.read(onlineLobbyProvider).room?.id != roomId) {
        await leave();
        return;
      }

      state = state.copyWith(status: VoiceStatus.connected, phaseAllowed: _computeAllowed());
      _retries = 0;
      await _applySpeaker();
      _applyVolume();
      if (state.deafened) await _applyDeafen();
      if (_micWanted && state.phaseAllowed) await _setPublishing(true);
      _syncPeers();
    } catch (e) {
      debugPrint('Hushbug voice connect failed: $e');
      await _teardown();
      state = state.copyWith(
        status: VoiceStatus.failed,
        micOn: false,
        peers: const {},
        error: () => e is FunctionException
            ? "Voice isn't available right now. Chat still works."
            : "Couldn't connect to voice. Chat still works.",
      );
    }
  }

  void _bindEvents(lk.EventsListener<lk.RoomEvent> l) {
    l
      ..on<lk.RoomReconnectingEvent>((_) => state = state.copyWith(status: VoiceStatus.reconnecting))
      ..on<lk.RoomReconnectedEvent>((_) {
        state = state.copyWith(status: VoiceStatus.connected);
        _syncPeers();
      })
      ..on<lk.RoomDisconnectedEvent>((e) => _onDisconnected(e.reason))
      ..on<lk.ParticipantConnectedEvent>((_) => _syncPeers())
      ..on<lk.ParticipantDisconnectedEvent>((_) => _syncPeers())
      ..on<lk.ActiveSpeakersChangedEvent>((_) => _syncPeers())
      ..on<lk.TrackMutedEvent>((_) => _syncPeers())
      ..on<lk.TrackUnmutedEvent>((_) => _syncPeers())
      ..on<lk.LocalTrackPublishedEvent>((_) => _syncPeers())
      ..on<lk.LocalTrackUnpublishedEvent>((_) => _syncPeers())
      ..on<lk.ParticipantPermissionsUpdatedEvent>((e) {
        // The server has changed who may speak.
        if (e.participant is lk.LocalParticipant && !e.permissions.canPublish) {
          state = state.copyWith(micOn: false, pttHeld: false);
        }
      })
      ..on<lk.TrackSubscribedEvent>((e) {
        if (state.deafened) {
          e.publication.unsubscribe();
        } else {
          _applyVolume();
        }
        _syncPeers();
      })
      ..on<lk.TrackUnsubscribedEvent>((_) => _syncPeers());
  }

  void _onDisconnected(lk.DisconnectReason? reason) {
    if (_leaving) return;
    _teardown();
    state = state.copyWith(micOn: false, pttHeld: false, peers: const {});
    if (reason == lk.DisconnectReason.participantRemoved || reason == lk.DisconnectReason.roomDeleted) {
      state = state.copyWith(status: VoiceStatus.off);
      return;
    }
    if (_retries >= _maxRetries) {
      state = state.copyWith(status: VoiceStatus.failed, error: () => 'Voice disconnected. Chat still works.');
      return;
    }
    _retries++;
    state = state.copyWith(status: VoiceStatus.reconnecting);
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: 2 * _retries), _connect);
  }

  void _syncPeers() {
    final room = _room;
    if (room == null) return;
    final peers = <String, VoicePeer>{};
    final local = room.localParticipant;
    if (local != null) {
      peers[local.identity] = VoicePeer(speaking: local.isSpeaking, muted: !state.micOn);
    }
    for (final p in room.remoteParticipants.values) {
      peers[p.identity] = VoicePeer(
        speaking: p.isSpeaking,
        muted: p.audioTrackPublications.isEmpty || p.audioTrackPublications.every((t) => t.muted),
      );
    }
    state = state.copyWith(peers: peers);
  }

  Future<void> _setPublishing(bool on) async {
    final local = _room?.localParticipant;
    if (local == null) {
      if (!on) state = state.copyWith(micOn: false);
      return;
    }
    if (on && (!state.phaseAllowed || !local.permissions.canPublish)) return;
    try {
      await local.setMicrophoneEnabled(on);
      state = state.copyWith(micOn: on);
    } catch (e) {
      final text = e.toString().toLowerCase();
      final busy = text.contains('in use') || text.contains('busy') || text.contains('notreadable');
      state = state.copyWith(micOn: false, issue: busy ? MicIssue.busy : MicIssue.unavailable);
    }
    _syncPeers();
  }

  /// The microphone button in open-mic mode.
  Future<void> toggleMic() async {
    if (!state.micOn && !await _ensurePermission()) return;
    _micWanted = !state.micOn;
    await _setPublishing(_micWanted);
  }

  /// Press and release of the push-to-talk button.
  Future<void> setPushToTalkHeld(bool held) async {
    if (held && !await _ensurePermission()) return;
    state = state.copyWith(pttHeld: held);
    await _setPublishing(held);
  }

  Future<void> setPushToTalkMode(bool enabled) async {
    ref.read(settingsProvider.notifier).update((s) => s.copyWith(pushToTalk: enabled));
    state = state.copyWith(pushToTalk: enabled, pttHeld: false);
    _micWanted = false;
    await _setPublishing(false);
  }

  Future<void> toggleDeafen() async {
    state = state.copyWith(deafened: !state.deafened);
    await _applyDeafen();
  }

  Future<void> _applyDeafen() async {
    final room = _room;
    if (room == null) return;
    for (final p in room.remoteParticipants.values) {
      for (final pub in p.audioTrackPublications) {
        state.deafened ? pub.unsubscribe() : pub.subscribe();
      }
    }
  }

  void _applyVolume() {
    final room = _room;
    if (room == null) return;
    final volume = ref.read(settingsProvider).voiceVolume;
    for (final p in room.remoteParticipants.values) {
      for (final pub in p.audioTrackPublications) {
        final track = pub.track;
        if (track != null) unawaited(rtc.Helper.setVolume(volume, track.mediaStreamTrack));
      }
    }
  }

  Future<void> _applySpeaker() async {
    if (_room == null) return;
    try {
      await lk.Hardware.instance.setSpeakerphoneOn(ref.read(settingsProvider).speakerOutput);
    } catch (_) {
      // Not every platform can switch output.
    }
  }

  /// Picks up a microphone permission that was changed in system settings.
  Future<void> onAppResumed() async {
    final granted = await microphoneGranted();
    if (!granted && state.micOn) {
      _micWanted = false;
      await _setPublishing(false);
      state = state.copyWith(issue: MicIssue.revoked);
    } else if (granted && state.issue != MicIssue.none) {
      state = state.copyWith(issue: MicIssue.none);
    }
  }

  Future<void> leave() async {
    _retryTimer?.cancel();
    _leaving = true;
    _micWanted = false;
    await _teardown();
    state = state.copyWith(status: VoiceStatus.off, micOn: false, pttHeld: false, peers: const {}, error: () => null);
  }

  Future<void> _teardown() async {
    final room = _room;
    final listener = _listener;
    _room = null;
    _listener = null;
    try {
      await listener?.dispose();
      await room?.disconnect();
      await room?.dispose();
    } catch (e) {
      debugPrint('Hushbug voice teardown: $e');
    }
  }

  /// Display name of whoever is talking, for the status line.
  String? currentSpeakerName() {
    final uid = SupabaseService.currentUserId;
    final entry = state.peers.entries.where((e) => e.value.speaking && e.key != uid).firstOrNull;
    if (entry == null) return null;
    return ref.read(onlineLobbyProvider).players.where((p) => p.playerId == entry.key).firstOrNull?.displayName;
  }
}

final voiceProvider = NotifierProvider<VoiceNotifier, VoiceState>(VoiceNotifier.new);
