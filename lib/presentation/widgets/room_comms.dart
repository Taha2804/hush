import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../services/supabase/chat_service.dart';
import '../../services/supabase/models.dart';
import '../../services/supabase/multiplayer_providers.dart';
import '../../services/supabase/social_service.dart';
import '../../services/supabase/supabase_service.dart';
import '../../services/supabase/voice_service.dart';
import '../theme.dart';
import 'common.dart';
import 'visuals.dart';

const _micExplanation =
    'Voice chat lets you talk with other players during online games. Your microphone is only used when voice chat is enabled.';

/// Asks for consent, then joins voice. Permission is only ever requested here.
Future<void> joinVoiceWithConsent(BuildContext context, WidgetRef ref) async {
  if (!ref.read(settingsProvider).voiceEnabled) {
    toast(context, 'Voice chat is turned off in Communication settings.');
    return;
  }
  final voice = ref.read(voiceProvider.notifier);
  if (!await voice.microphoneGranted()) {
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: HushbugColors.cardSurface,
        title: const Text('Use your microphone?', style: TextStyle(color: Colors.white, fontSize: 17)),
        content: const Text(_micExplanation, style: TextStyle(color: HushbugColors.textSubtext, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Not now')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Continue')),
        ],
      ),
    );
    if (ok != true) return;
  }
  await voice.join();
}

/// One compact row with voice controls and the chat preview.
class CommBar extends ConsumerWidget {
  const CommBar({super.key, required this.onOpenChat});

  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(roomChatProvider.select((s) => s.error), (_, err) {
      if (err != null) {
        toast(context, err);
        ref.read(roomChatProvider.notifier).clearError();
      }
    });
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
      decoration: BoxDecoration(
        color: HushbugColors.cardSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HushbugColors.cardBorderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const _VoiceControls(),
              const SizedBox(width: 6),
              Expanded(child: _ChatPill(onTap: onOpenChat)),
            ],
          ),
          const _VoiceStatusLine(),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.tooltip, this.onTap, this.color = Colors.white, this.active = false});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkResponse(
          onTap: onTap,
          radius: 22,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? HushbugColors.neonPurple.withValues(alpha: 0.45) : Colors.white10,
            ),
            child: Icon(icon, size: 18, color: onTap == null ? HushbugColors.textMuted : color),
          ),
        ),
      ),
    );
  }
}

class _VoiceControls extends ConsumerWidget {
  const _VoiceControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = ref.watch(voiceProvider);
    final voice = ref.read(voiceProvider.notifier);

    if (!v.inCall) {
      final connecting = v.status == VoiceStatus.connecting;
      return _RoundIcon(
        icon: connecting ? Icons.sync_rounded : Icons.headset_mic_rounded,
        tooltip: connecting ? 'Connecting to voice' : 'Join voice chat',
        color: HushbugColors.neonPurpleLight,
        onTap: connecting ? null : () => joinVoiceWithConsent(context, ref),
      );
    }

    final micBlocked = !v.phaseAllowed;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (v.pushToTalk)
          Listener(
            onPointerDown: micBlocked
                ? null
                : (_) {
                    HapticFeedback.lightImpact();
                    voice.setPushToTalkHeld(true);
                  },
            onPointerUp: (_) => voice.setPushToTalkHeld(false),
            onPointerCancel: (_) => voice.setPushToTalkHeld(false),
            child: _RoundIcon(
              icon: Icons.touch_app_rounded,
              tooltip: 'Hold to talk',
              active: v.pttHeld,
              color: micBlocked ? HushbugColors.textMuted : Colors.white,
            ),
          )
        else
          _RoundIcon(
            icon: v.micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
            tooltip: v.micOn ? 'Mute microphone' : 'Unmute microphone',
            active: v.micOn,
            color: v.micOn ? Colors.white : HushbugColors.imposterRed,
            onTap: micBlocked ? null : voice.toggleMic,
          ),
        _RoundIcon(
          icon: v.deafened ? Icons.headset_off_rounded : Icons.volume_up_rounded,
          tooltip: v.deafened ? 'Undeafen' : 'Deafen',
          color: v.deafened ? HushbugColors.imposterRed : Colors.white,
          onTap: voice.toggleDeafen,
        ),
        _RoundIcon(
          icon: Icons.call_end_rounded,
          tooltip: 'Leave voice chat',
          color: HushbugColors.imposterRed,
          onTap: voice.leave,
        ),
      ],
    );
  }
}

class _VoiceStatusLine extends ConsumerWidget {
  const _VoiceStatusLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = ref.watch(voiceProvider);
    final voice = ref.read(voiceProvider.notifier);

    String? text;
    var color = HushbugColors.textSubtext;
    var showSettings = false;

    if (v.issue == MicIssue.permanentlyDenied) {
      text = 'Microphone blocked';
      color = HushbugColors.accentYellow;
      showSettings = true;
    } else if (v.issue == MicIssue.revoked) {
      text = 'Microphone access was removed';
      color = HushbugColors.accentYellow;
      showSettings = true;
    } else if (v.issue == MicIssue.denied && v.inCall) {
      text = 'Listening only. Allow the microphone to talk.';
    } else if (v.issue == MicIssue.busy) {
      text = 'Microphone is in use by another app';
      color = HushbugColors.accentYellow;
    } else if (v.issue == MicIssue.unavailable) {
      text = 'Microphone unavailable';
      color = HushbugColors.accentYellow;
    } else if (v.status == VoiceStatus.failed) {
      text = v.error;
      color = HushbugColors.accentYellow;
    } else if (v.status == VoiceStatus.reconnecting) {
      text = 'Reconnecting voice…';
      color = HushbugColors.accentYellow;
    } else if (v.inCall && !v.phaseAllowed) {
      text = 'Voice is off for this phase';
      color = HushbugColors.accentYellow;
    } else if (v.inCall) {
      final speaker = voice.currentSpeakerName();
      text = speaker != null ? '$speaker is speaking' : (v.deafened ? 'Deafened' : 'Voice connected · ${v.peers.length} in call');
      color = speaker != null ? HushbugColors.neonPurpleLight : HushbugColors.civilianEmerald;
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      alignment: Alignment.topCenter,
      child: text == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(8, 3, 8, 1),
              child: Row(
                children: [
                  Expanded(
                    child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  if (showSettings)
                    _MiniLink(label: 'Open Settings', onTap: voice.openSystemSettings)
                  else if (v.inCall)
                    _MiniLink(
                      label: v.pushToTalk ? 'Push-to-talk' : 'Open mic',
                      onTap: () => voice.setPushToTalkMode(!v.pushToTalk),
                    ),
                ],
              ),
            ),
    );
  }
}

class _MiniLink extends StatelessWidget {
  const _MiniLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(label, style: const TextStyle(color: HushbugColors.neonPurpleLight, fontSize: 11, fontWeight: FontWeight.w800)),
        ),
      );
}

/// Chat preview built into the layout, so it can never cover game controls.
class _ChatPill extends ConsumerWidget {
  const _ChatPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chat = ref.watch(roomChatProvider);
    final notify = ref.watch(settingsProvider.select((s) => s.chatNotifications));
    final m = chat.latest;
    final preview = !notify || m == null
        ? 'Chat'
        : (m.isSystem ? m.message : '${m.senderName}: ${m.message}');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.chat_bubble_rounded, size: 15, color: HushbugColors.neonPurpleLight),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(a), child: child),
                ),
                layoutBuilder: (current, previous) => Stack(alignment: Alignment.centerLeft, children: [...previous, ?current]),
                child: Text(
                  preview,
                  key: ValueKey(m?.id ?? 'none'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
            if (chat.unread > 0)
              Semantics(
                label: '${chat.unread} unread messages',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: HushbugColors.accentYellow, borderRadius: BorderRadius.circular(9)),
                  child: Text(
                    chat.unread > 99 ? '99+' : '${chat.unread}',
                    style: const TextStyle(color: HushbugColors.onAccentYellow, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Wraps an avatar with the speaking highlight and a microphone badge.
class VoiceAvatar extends ConsumerWidget {
  const VoiceAvatar({super.key, required this.playerId, required this.child});

  final String playerId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peer = ref.watch(voiceProvider.select((s) => s.peers[playerId]));
    final speaking = peer?.speaking ?? false;
    final showMuted = peer != null && peer.muted;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: speaking ? HushbugColors.neonPurpleLight : Colors.transparent, width: 2),
            boxShadow: speaking ? [BoxShadow(color: HushbugColors.neonPurple.withValues(alpha: 0.6), blurRadius: 10)] : null,
          ),
          child: child,
        ),
        if (speaking)
          const Positioned(right: -3, bottom: -3, child: _ActivityBadge())
        else if (showMuted)
          Positioned(
            right: -3,
            bottom: -3,
            child: Semantics(
              label: 'Muted',
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: HushbugColors.background, shape: BoxShape.circle),
                child: const Icon(Icons.mic_off_rounded, size: 11, color: HushbugColors.imposterRed),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActivityBadge extends StatefulWidget {
  const _ActivityBadge();

  @override
  State<_ActivityBadge> createState() => _ActivityBadgeState();
}

class _ActivityBadgeState extends State<_ActivityBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
      _c.value = 1;
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Speaking',
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(color: HushbugColors.neonPurple, shape: BoxShape.circle),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.55, end: 1).animate(_c),
            child: const Icon(Icons.graphic_eq_rounded, size: 11, color: Colors.white),
          ),
        ),
      );
}

const _emojis = [
  '😀', '😂', '🤣', '😅', '😉', '😎', '🤔', '🤨', '😏', '😱', '😭', '😡', '🥳', '🤫', '🙄', '😴',
  '👍', '👎', '👏', '🙌', '🙏', '💪', '👀', '🤝', '❤️', '🔥', '🎉', '💯', '🐞', '🕵️', '🎭', '🗳️',
];

class ChatComposer extends ConsumerStatefulWidget {
  const ChatComposer({super.key});

  @override
  ConsumerState<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends ConsumerState<ChatComposer> {
  final _ctrl = TextEditingController();
  bool _showEmoji = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text;
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    ref.read(roomChatProvider.notifier).send(text);
  }

  void _insertEmoji(String e) {
    final v = _ctrl.value;
    final at = v.selection.isValid ? v.selection.start : v.text.length;
    _ctrl.value = TextEditingValue(
      text: v.text.replaceRange(at, v.selection.isValid ? v.selection.end : at, e),
      selection: TextSelection.collapsed(offset: at + e.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.bottomCenter,
          child: !_showEmoji
              ? const SizedBox(width: double.infinity)
              : SizedBox(
                  height: 92,
                  child: GridView.count(
                    crossAxisCount: 8,
                    children: [
                      for (final e in _emojis)
                        InkResponse(onTap: () => _insertEmoji(e), child: Center(child: Text(e, style: const TextStyle(fontSize: 20)))),
                    ],
                  ),
                ),
        ),
        Row(
          children: [
            IconButton(
              tooltip: 'Emoji',
              onPressed: () => setState(() => _showEmoji = !_showEmoji),
              icon: Icon(_showEmoji ? Icons.keyboard_rounded : Icons.emoji_emotions_outlined, color: HushbugColors.neonPurpleLight),
            ),
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLength: RoomChatNotifier.maxLength,
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  counterText: '',
                  isDense: true,
                  hintText: 'Message',
                  hintStyle: const TextStyle(color: HushbugColors.textMuted),
                  filled: true,
                  fillColor: const Color(0xFF161224),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Send',
              onPressed: _send,
              icon: const Icon(Icons.send_rounded, color: HushbugColors.accentYellow),
            ),
          ],
        ),
      ],
    );
  }
}

class ChatMessageList extends ConsumerWidget {
  const ChatMessageList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(roomChatProvider);
    ref.watch(blockedProvider);
    final messages = ref.read(roomChatProvider.notifier).visible.reversed.toList();
    if (messages.isEmpty) {
      return const Center(child: Text('No messages yet. Say hi!', style: TextStyle(color: HushbugColors.textMuted, fontSize: 13)));
    }
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      itemCount: messages.length,
      itemBuilder: (c, i) => _MessageRow(key: ValueKey(messages[i].clientId ?? messages[i].id), message: messages[i]),
    );
  }
}

class _MessageRow extends ConsumerWidget {
  const _MessageRow({super.key, required this.message});
  final ChatMessage message;

  void _showActions(BuildContext context, WidgetRef ref) {
    final chat = ref.read(roomChatProvider.notifier);
    final isHost = ref.read(onlineLobbyProvider).isHost;
    if (message.delivery == ChatDelivery.failed) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: HushbugColors.cardSurface,
        builder: (c) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(leading: const Icon(Icons.refresh_rounded), title: const Text('Try again'), onTap: () {
              Navigator.pop(c);
              chat.retry(message);
            }),
            ListTile(leading: const Icon(Icons.delete_outline_rounded), title: const Text('Discard'), onTap: () {
              Navigator.pop(c);
              chat.discard(message);
            }),
          ]),
        ),
      );
      return;
    }
    if (message.isDeleted || message.isSystem || !(message.isMine || isHost)) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: HushbugColors.cardSurface,
      builder: (c) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline_rounded, color: HushbugColors.imposterRed),
          title: const Text('Delete message'),
          onTap: () {
            Navigator.pop(c);
            chat.delete(message);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showTime = ref.watch(settingsProvider.select((s) => s.chatTimestamps));
    final m = message;

    final Widget row;
    if (m.isSystem) {
      row = Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Center(child: Text(m.message, style: const TextStyle(color: HushbugColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600))),
      );
    } else {
      final time = DateFormat.jm().format(m.createdAt);
      row = InkWell(
        onLongPress: () => _showActions(context, ref),
        onTap: m.delivery == ChatDelivery.failed ? () => _showActions(context, ref) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VoiceAvatar(
                playerId: m.senderId ?? '',
                child: PlayerAvatar(index: 0, name: m.senderName, radius: 14, avatarIndex: m.senderAvatar),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(
                          m.senderName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: m.isMine ? HushbugColors.accentYellow : HushbugColors.neonPurpleLight, fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (showTime) ...[
                        const SizedBox(width: 6),
                        Text(time, style: const TextStyle(color: HushbugColors.textMuted, fontSize: 10)),
                      ],
                    ]),
                    Text(
                      m.isDeleted ? 'Message deleted' : m.message,
                      style: TextStyle(
                        color: m.isDeleted ? HushbugColors.textMuted : Colors.white,
                        fontSize: 14,
                        fontStyle: m.isDeleted ? FontStyle.italic : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (m.isMine && !m.isDeleted) ...[
                const SizedBox(width: 6),
                _DeliveryIcon(m.delivery),
              ],
            ],
          ),
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      builder: (c, t, child) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child)),
      child: row,
    );
  }
}

class _DeliveryIcon extends StatelessWidget {
  const _DeliveryIcon(this.delivery);
  final ChatDelivery delivery;

  @override
  Widget build(BuildContext context) => switch (delivery) {
        ChatDelivery.sending => const Icon(Icons.schedule_rounded, size: 13, color: HushbugColors.textMuted, semanticLabel: 'Sending'),
        ChatDelivery.sent => const Icon(Icons.check_rounded, size: 13, color: HushbugColors.civilianEmerald, semanticLabel: 'Sent'),
        ChatDelivery.failed => const Icon(Icons.error_outline_rounded, size: 15, color: HushbugColors.imposterRed, semanticLabel: 'Failed. Tap to retry'),
      };
}

/// The compact in-game chat. Stays on top of the game without leaving it.
Future<void> showGameChat(BuildContext context, WidgetRef ref) async {
  final chat = ref.read(roomChatProvider.notifier);
  chat.setOpen(true);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: HushbugColors.cardSurface,
    barrierColor: Colors.black38,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (c) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(c).bottom),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(c).height * 0.5,
          child: const Column(children: [
            SizedBox(height: 6),
            Text('Room chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            Expanded(child: ChatMessageList()),
            ChatComposer(),
          ]),
        ),
      ),
    ),
  );
  chat.setOpen(false);
}

/// Add friend, block, report, and host moderation for one player.
Future<void> showPlayerActions(BuildContext context, WidgetRef ref, OnlineRoomPlayer p) async {
  if (p.playerId == SupabaseService.currentUserId) return;
  final social = ref.read(socialServiceProvider);
  final lobby = ref.read(onlineLobbyProvider);
  final room = lobby.room;
  if (social == null || room == null) return;
  final notifier = ref.read(onlineLobbyProvider.notifier);

  Future<void> run(BuildContext c, Future<void> Function() action, String done) async {
    Navigator.pop(c);
    try {
      await action();
      if (context.mounted) toast(context, done);
    } catch (e) {
      if (context.mounted) toast(context, friendlyError(e));
    }
  }

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: HushbugColors.cardSurface,
    builder: (c) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(p.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1_rounded),
              title: const Text('Add friend'),
              onTap: () => run(c, () => social.sendRequestInRoom(room.id, p.playerId), 'Friend request sent'),
            ),
            if (lobby.isHost) ...[
              ListTile(
                leading: Icon(p.chatMuted ? Icons.comment_rounded : Icons.comments_disabled_rounded),
                title: Text(p.chatMuted ? 'Allow chat' : 'Mute in chat'),
                onTap: () => run(c, () => notifier.moderate(p.playerId, p.chatMuted ? 'unmute' : 'mute'), 'Updated'),
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Remove from room'),
                onTap: () => run(c, () => notifier.moderate(p.playerId, 'kick'), '${p.displayName} was removed'),
              ),
            ],
            ListTile(
              leading: const Icon(Icons.block_rounded, color: HushbugColors.imposterRed),
              title: const Text('Block'),
              subtitle: const Text('Hides their chat messages'),
              onTap: () => run(c, () async {
                await social.block(p.playerId);
                ref.invalidate(blockedProvider);
              }, '${p.displayName} blocked'),
            ),
            ListTile(
              leading: const Icon(Icons.flag_rounded, color: HushbugColors.accentYellow),
              title: const Text('Report'),
              onTap: () => run(c, () => social.report(playerId: p.playerId, roomId: room.id, reason: 'in_room_behaviour'), 'Report sent. Thank you.'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Shows friends' room invites anywhere in the app, and keeps the player's
/// online status fresh.
class InviteOverlay extends ConsumerStatefulWidget {
  const InviteOverlay({super.key, required this.child, required this.onAccept});

  final Widget child;
  final void Function(String code) onAccept;

  @override
  ConsumerState<InviteOverlay> createState() => _InviteOverlayState();
}

class _InviteOverlayState extends ConsumerState<InviteOverlay> {
  dynamic _channel;
  Timer? _presence;
  RoomInvite? _invite;
  String? _userId;

  @override
  void initState() {
    super.initState();
    ref.listenManual(authUserProvider.select((u) => u.value?.id), (_, id) => _bind(id), fireImmediately: true);
  }

  void _bind(String? userId) {
    if (userId == _userId) return;
    _channel?.unsubscribe();
    _presence?.cancel();
    _channel = null;
    _userId = userId;
    final social = ref.read(socialServiceProvider);
    if (userId == null || social == null) return;
    social.touchPresence().catchError((_) {});
    _presence = Timer.periodic(const Duration(seconds: 45), (_) {
      social.touchPresence().catchError((_) {});
    });
    _channel = social.subscribeInvites(userId, (invite) {
      if (mounted) setState(() => _invite = invite);
    });
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _presence?.cancel();
    super.dispose();
  }

  void _dismiss() {
    final invite = _invite;
    setState(() => _invite = null);
    if (invite != null) ref.read(socialServiceProvider)?.dismissInvite(invite.id).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final invite = _invite;
    final inRoom = ref.watch(onlineLobbyProvider.select((s) => s.room != null));
    return Stack(
      children: [
        widget.child,
        if (invite != null && !inRoom)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 12,
            right: 12,
            child: Material(
              color: HushbugColors.cardSurfaceElevated,
              borderRadius: BorderRadius.circular(16),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
                child: Row(children: [
                  Expanded(
                    child: Text('${invite.fromName} invited you to play', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                  TextButton(onPressed: _dismiss, child: const Text('Later')),
                  FilledButton(
                    onPressed: () {
                      final code = invite.roomCode;
                      _dismiss();
                      widget.onAccept(code);
                    },
                    child: const Text('Join'),
                  ),
                ]),
              ),
            ),
          ),
      ],
    );
  }
}

extension OpenRoomChat on BuildContext {
  void openRoomChat() => push('/multiplayer/chat');
}

