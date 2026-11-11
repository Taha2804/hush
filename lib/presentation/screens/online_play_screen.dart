import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/services.dart';
import '../../services/supabase/chat_service.dart';
import '../../services/supabase/models.dart';
import '../../services/supabase/multiplayer_providers.dart';
import '../../services/supabase/supabase_service.dart';
import '../../services/supabase/voice_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import '../widgets/motion.dart';
import '../widgets/neon.dart';
import '../widgets/room_comms.dart';
import '../widgets/visuals.dart';

/// Online game in the neon style. Every rule shown here is also enforced by
/// the database; the screen only reflects it.
class OnlinePlayScreen extends ConsumerStatefulWidget {
  const OnlinePlayScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<OnlinePlayScreen> createState() => _OnlinePlayScreenState();
}

class _OnlinePlayScreenState extends ConsumerState<OnlinePlayScreen> with TickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  int? _pointer;
  bool _open = false;
  final _clueCtrl = TextEditingController();
  Timer? _ticker;
  int _secondsLeft = 0;
  bool _timerSynced = false;
  String? _answeredRequestId;
  String? _picked;
  bool _secure = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(onlineGameProvider.notifier).initGame(widget.sessionId));
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final game = ref.read(onlineGameProvider);
    final s = game.session;
    if (s == null || !mounted) return;
    if (s.phase == 'discussion' && s.discussionEndTime != null) {
      final left = s.discussionEndTime!.toUtc().difference(DateTime.now().toUtc()).inSeconds;
      setState(() => _secondsLeft = left > 0 ? left : 0);
      if (left <= 0 && !_timerSynced) {
        _timerSynced = true;
        ref.read(onlineGameProvider.notifier).syncTimers();
      }
    } else {
      _timerSynced = false;
    }
    if (game.endRequest?.status == 'pending') setState(() {});
  }

  void _setSecure(bool on) {
    if (on == _secure) return;
    _secure = on;
    SecureScreen.set(on);
  }

  @override
  void dispose() {
    _setSecure(false);
    _flip.dispose();
    _clueCtrl.dispose();
    _ticker?.cancel();
    super.dispose();
  }

  void _hold(bool open) {
    setState(() => _open = open);
    open ? _flip.forward() : _flip.reverse();
    open ? HapticFeedback.mediumImpact() : HapticFeedback.lightImpact();
  }

  String _name(OnlineGameState g, String? id) => g.players.where((p) => p.playerId == id).firstOrNull?.displayName ?? 'Player';
  OnlineGamePlayer? _p(OnlineGameState g, String? id) => g.players.where((p) => p.playerId == id).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(onlineGameProvider);
    final lobby = ref.watch(onlineLobbyProvider);
    final s = game.session;
    final isHost = lobby.isHost;

    ref.listen(onlineGameProvider.select((x) => x.error), (_, err) {
      if (err != null && ref.read(onlineGameProvider).session != null) {
        toast(context, err);
        ref.read(onlineGameProvider.notifier).clearError();
      }
    });
    ref.listen(onlineGameProvider.select((x) => (x.session?.phase, x.session?.revotes)), (prev, next) {
      if (prev != next) setState(() => _picked = null);
    });
    ref.listen(onlineLobbyProvider.select((x) => x.room?.id), (_, roomId) {
      if (roomId == null && mounted) context.go('/multiplayer');
    });

    _setSecure(s?.phase == 'reveal');

    if (s == null) {
      return NeonBackdrop(
        child: Center(
          child: game.error != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Mascot(size: 100, mood: MascotMood.sad),
                    const SizedBox(height: 14),
                    Text(game.error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 18),
                    TactileButton(
                      onPressed: () => ref.read(onlineGameProvider.notifier).initGame(widget.sessionId),
                      style: TactileButtonStyle.golden,
                      child: const Text('Try again'),
                    ),
                    TextButton(onPressed: () => context.pop(), child: const Text('Back to lobby')),
                  ]),
                )
              : const Column(mainAxisSize: MainAxisSize.min, children: [
                  Mascot(size: 100, mood: MascotMood.detective),
                  SizedBox(height: 14),
                  Text('Loading the game…', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
        ),
      );
    }

    final room = lobby.room;
    final total = room?.totalRounds ?? 1;
    const steps = ['reveal', 'clue', 'discussion', 'vote'];
    final step = s.phase == 'result' ? steps.length : steps.indexOf(s.phase);

    return NeonBackdrop(
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
            child: Row(children: [
              NeonRoundButton(icon: Icons.close_rounded, label: 'Back to lobby', size: 46, onPressed: () => context.pop()),
              Expanded(
                child: Column(children: [
                  StepDots(count: steps.length + 1, current: step),
                  const SizedBox(height: 6),
                  Text('Round ${s.matchRound} of $total · ${s.category}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 13, fontWeight: FontWeight.w800)),
                ]),
              ),
              const SizedBox(width: 46),
            ]),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: CommBar(onOpenChat: () => showGameChat(context, ref))),
          if (lobby.offline)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('Connection lost. Reconnecting…', style: TextStyle(color: HushbugColors.accentYellow, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              child: AnimatedSwitcher(
                duration: motionDuration(context, 260),
                transitionBuilder: swapTransition,
                child: KeyedSubtree(
                  key: ValueKey('${s.id}-${s.phase}-${s.revotes}'),
                  child: switch (s.phase) {
                    'clue' => _clues(game, isHost),
                    'discussion' => _discussion(game),
                    'vote' => _vote(game, isHost),
                    'result' => _result(game, isHost, room),
                    _ => _reveal(game, isHost),
                  },
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ------------------------------------------------------------ reveal

  Widget _reveal(OnlineGameState g, bool isHost) {
    final a = g.assignment;
    final imposterCard = (a?.isImposter ?? false) && a?.fakeWord == null;

    return LayoutBuilder(
      builder: (context, c) => Column(children: [
        const NeonTitle('Your secret card', size: 24),
        Expanded(
          child: Center(
            child: Listener(
              onPointerDown: (e) {
                if (_pointer != null) return;
                _pointer = e.pointer;
                _hold(true);
              },
              onPointerUp: (e) {
                if (e.pointer != _pointer) return;
                _pointer = null;
                _hold(false);
              },
              onPointerCancel: (e) {
                if (e.pointer != _pointer) return;
                _pointer = null;
                _hold(false);
              },
              child: Semantics(
                button: true,
                label: 'Press and hold to see your word',
                child: AnimatedBuilder(
                  animation: _flip,
                  builder: (context, _) {
                    final t = easeOutStrong.transform(_flip.value);
                    final opened = t > 0.5 && _open;
                    final h = (c.maxHeight * 0.55).clamp(240.0, 380.0);
                    return Transform.rotate(
                      angle: -0.07 * (1 - t),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY((opened ? 1 - t : t) * 0.35),
                        child: Container(
                          width: h * 0.82,
                          height: h,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3A1F78), Color(0xFF1E1046)]),
                            border: Border.all(color: opened && imposterCard ? HushbugColors.imposterRed : const Color(0xFFE58BFF), width: 3),
                            boxShadow: [
                              BoxShadow(color: (opened && imposterCard ? HushbugColors.imposterRed : const Color(0xFFE58BFF)).withValues(alpha: 0.7), blurRadius: 34),
                              const BoxShadow(color: Color(0x2EE58BFF), spreadRadius: 6),
                            ],
                          ),
                          // The word only exists in the widget tree while held.
                          child: opened ? _openCard(a, imposterCard) : _closedCard(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        if (c.maxHeight > 520) Mascot(size: 90, mood: _open ? MascotMood.peeking : MascotMood.sleeping),
        const SizedBox(height: 8),
        if (isHost)
          TactileButton(
            onPressed: g.busy ? null : () => ref.read(onlineGameProvider.notifier).advancePhase('clue'),
            style: TactileButtonStyle.golden,
            height: 64,
            icon: g.busy ? const _Spinner() : const Icon(Icons.play_arrow_rounded, size: 32),
            child: const Text('Everyone has seen it'),
          )
        else
          const _Hint('The host starts clues once everyone has looked.'),
      ]),
    );
  }

  Widget _closedCard() => const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.public_rounded, size: 86, color: Color(0xFFC9A4FF), shadows: [Shadow(color: Color(0xAAE58BFF), blurRadius: 20)]),
        SizedBox(height: 18),
        Icon(Icons.fingerprint_rounded, size: 44, color: Color(0xFFF0C8FF)),
        SizedBox(height: 8),
        Text('Press and hold', style: TextStyle(fontFamily: 'Fredoka', fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
        SizedBox(height: 2),
        Text('Let go to hide it', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 13, fontWeight: FontWeight.w700)),
      ]);

  Widget _openCard(OnlinePrivateAssignment? a, bool imposterCard) {
    if (a == null) return const Center(child: CircularProgressIndicator());
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(imposterCard ? Icons.masks_rounded : Icons.lock_open_rounded, size: 40, color: imposterCard ? HushbugColors.imposterRed : HushbugColors.accentYellow),
      const SizedBox(height: 10),
      Text(imposterCard ? 'You are the' : 'Your word', style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 14, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(imposterCard ? 'IMPOSTER' : a.word,
            style: TextStyle(fontFamily: 'Fredoka', fontSize: 36, fontWeight: FontWeight.w700, color: imposterCard ? HushbugColors.imposterRed : Colors.white)),
      ),
      if (!imposterCard && a.description != null) ...[
        const SizedBox(height: 10),
        Text(a.description!,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFE0CCFF), fontSize: 13, fontWeight: FontWeight.w700, height: 1.35)),
      ],
      if (a.hint != null) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0x26FFC61A), borderRadius: BorderRadius.circular(12)),
          child: Text('Hint: ${a.hint}', style: const TextStyle(color: HushbugColors.accentYellowLight, fontSize: 13, fontWeight: FontWeight.w800)),
        ),
      ],
      if (imposterCard) ...[
        const SizedBox(height: 10),
        const Text('Blend in. Give clues as if you know it.',
            textAlign: TextAlign.center, style: TextStyle(color: HushbugColors.textSubtext, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    ]);
  }

  // ------------------------------------------------------------ clues

  Widget _clues(OnlineGameState g, bool isHost) {
    final s = g.session!;
    final uid = SupabaseService.currentUserId;
    final order = g.aliveOrder;
    final current = g.currentCluePlayerId;
    final done = {for (final c in g.clues) if (c.roundNumber == s.roundNumber) c.playerId};
    final mine = current == uid;
    final pos = order.indexOf(current ?? '') + 1;
    final offline = ref.watch(onlineLobbyProvider).players.where((p) => p.playerId == current && !p.isConnected).firstOrNull;
    final speaker = _p(g, current);

    return Column(children: [
      _PlayerStrip(
        ids: order,
        game: g,
        highlight: current,
        done: done,
      ),
      const SizedBox(height: 14),
      if (speaker != null)
        AnimatedSwitcher(
          duration: motionDuration(context, 240),
          transitionBuilder: swapTransition,
          child: Column(key: ValueKey(current), children: [
            NeonSeat(name: speaker.displayName, avatarIndex: speaker.avatarIndex, size: 108, highlight: true, showName: false),
            const SizedBox(height: 10),
            NeonTitle(mine ? 'Your turn!' : "${speaker.displayName}'s turn", size: 26, color: mine ? HushbugColors.accentYellow : Colors.white),
            Text('Clue $pos of ${order.length}', style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 14, fontWeight: FontWeight.w800)),
          ]),
        )
      else
        const NeonTitle('All clues are in', size: 24),
      const SizedBox(height: 10),
      Expanded(
        child: g.clues.isEmpty
            ? const Center(child: _Hint('Clues appear here.'))
            : ListView(reverse: true, children: [
                for (final c in g.clues.reversed)
                  Appear(
                    key: ValueKey(c.id),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        NeonSeat(name: _name(g, c.playerId), avatarIndex: _p(g, c.playerId)?.avatarIndex, size: 38, showName: false),
                        const SizedBox(width: 8),
                        Flexible(
                          child: GlassPanel(
                            radius: 20,
                            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(c.playerId == uid ? 'You' : _name(g, c.playerId),
                                  style: const TextStyle(color: Color(0xFFC9B0FF), fontSize: 12, fontWeight: FontWeight.w800)),
                              Text(c.clueText, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                            ]),
                          ),
                        ),
                      ]),
                    ),
                  ),
              ]),
      ),
      if (mine) ...[
        GlassPanel(
          radius: 34,
          borderColor: const Color(0x99DCB4FF),
          padding: const EdgeInsets.fromLTRB(20, 2, 14, 2),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _clueCtrl,
                maxLength: 60,
                autofocus: true,
                enabled: !g.busy,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendClue(),
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: 'Type your clue…',
                  hintStyle: TextStyle(color: Color(0xFFC9B0FF)),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const Icon(Icons.edit_rounded, color: Color(0xFFE6D2FF)),
          ]),
        ),
        const SizedBox(height: 12),
        TactileButton(
          onPressed: g.busy ? null : _sendClue,
          style: TactileButtonStyle.golden,
          height: 64,
          icon: g.busy ? const _Spinner() : const Icon(Icons.send_rounded, size: 28),
          child: const Text('Send clue'),
        ),
      ] else if (current != null)
        _Hint('Waiting for ${_name(g, current)}…'),
      if (isHost && offline != null)
        TextButton.icon(
          onPressed: g.busy ? null : () => ref.read(onlineGameProvider.notifier).skipTurn(),
          icon: const Icon(Icons.skip_next_rounded, color: HushbugColors.accentYellow),
          label: Text('${offline.displayName} is offline. Skip turn', style: const TextStyle(color: HushbugColors.accentYellow)),
        ),
      if (isHost)
        TextButton(
          onPressed: g.busy ? null : () => ref.read(onlineGameProvider.notifier).advancePhase('discussion'),
          child: const Text('Host: start the discussion now'),
        ),
    ]);
  }

  Future<void> _sendClue() async {
    final text = _clueCtrl.text.trim();
    if (text.isEmpty) return;
    if (await ref.read(onlineGameProvider.notifier).submitClue(text)) _clueCtrl.clear();
  }

  // ------------------------------------------------------------ discussion

  Widget _discussion(OnlineGameState g) {
    final uid = SupabaseService.currentUserId;
    final alive = g.players.any((p) => p.playerId == uid && p.isAlive);
    final req = g.endRequest;
    final pending = req != null && req.isPending;
    final total = (ref.watch(onlineLobbyProvider).room?.config['discussionSeconds'] as num? ?? 180).toInt();
    final out = g.session!.lastVoteSummary?['eliminated']?.toString();
    final voice = ref.watch(voiceProvider);
    final unread = ref.watch(roomChatProvider.select((c) => c.unread));
    final hostId = ref.watch(onlineLobbyProvider).room?.hostId;
    final mm = (_secondsLeft ~/ 60).toString();
    final ss = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Column(children: [
      if (out != null) _Hint('${_name(g, out)} was voted out. The game goes on!', color: HushbugColors.accentYellow),
      if (pending) Appear(key: ValueKey(req.id), scaleFrom: 0.96, child: _endRequest(g, req)),
      Expanded(
        child: LayoutBuilder(builder: (context, c) {
          final cx = c.maxWidth / 2;
          final cy = c.maxHeight / 2 + 10;
          final rx = math.min(c.maxWidth / 2 - 40, 150.0);
          final ry = math.min(c.maxHeight / 2 - 50, 170.0);
          final players = g.players;
          final n = players.length;
          return Stack(children: [
            // Timer ring at the top of the circle.
            Positioned(
              left: cx - 46,
              top: 0,
              child: Semantics(
                label: '$mm minutes $ss seconds left',
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: Stack(alignment: Alignment.center, children: [
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: CircularProgressIndicator(
                        value: total <= 0 ? 0 : (_secondsLeft / total).clamp(0, 1),
                        strokeWidth: 7,
                        backgroundColor: const Color(0xFF3B2470),
                        color: _secondsLeft <= 15 ? HushbugColors.imposterRed : HushbugColors.accentYellow,
                      ),
                    ),
                    Text('$mm:$ss', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
              ),
            ),
            // The mic in the middle joins voice or mutes you.
            Positioned(
              left: cx - 54,
              top: cy - 54,
              child: Semantics(
                button: true,
                label: !voice.inCall ? 'Join voice chat' : (voice.micOn ? 'Mute microphone' : 'Unmute microphone'),
                child: InkResponse(
                  onTap: () => !voice.inCall ? joinVoiceWithConsent(context, ref) : ref.read(voiceProvider.notifier).toggleMic(),
                  radius: 60,
                  child: Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(colors: [Color(0xFF6A3FD0), Color(0xFF3A1D80)]),
                      border: Border.all(color: voice.micOn ? HushbugColors.accentYellow : const Color(0xFFD9C2FF), width: 3),
                      boxShadow: [
                        BoxShadow(color: (voice.micOn ? HushbugColors.accentYellow : const Color(0xFFC8A0FF)).withValues(alpha: 0.55), blurRadius: 30),
                        const BoxShadow(color: Color(0x1FC8A0FF), spreadRadius: 12),
                      ],
                    ),
                    child: Icon(voice.inCall && !voice.micOn ? Icons.mic_off_rounded : Icons.mic_rounded, size: 48, color: Colors.white),
                  ),
                ),
              ),
            ),
            for (var i = 0; i < n; i++)
              Builder(builder: (context) {
                // Seats around an ellipse, starting top-left and leaving room for the timer.
                final angle = math.pi * (0.75 + 1.5 * (n == 1 ? 0.5 : i / (n - 1)));
                final x = cx + rx * math.cos(angle) - 40;
                final y = cy + ry * math.sin(angle) * -1 - 44;
                final p = players[i];
                final peer = voice.peers[p.playerId];
                return Positioned(
                  left: x,
                  top: y.clamp(96.0, c.maxHeight - 100),
                  child: SizedBox(
                    width: 80,
                    child: NeonSeat(
                      name: p.playerId == uid ? 'You' : p.displayName,
                      avatarIndex: p.avatarIndex,
                      size: 62,
                      crown: p.playerId == hostId,
                      highlight: peer?.speaking ?? false,
                      dim: !p.isAlive,
                      caption: !p.isAlive ? 'Out' : (peer?.speaking ?? false ? 'Speaking' : null),
                      captionColor: !p.isAlive ? HushbugColors.imposterRed : HushbugColors.neonPurpleLight,
                    ),
                  ),
                );
              }),
          ]);
        }),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        NeonRoundButton(
          icon: voice.deafened ? Icons.headset_off_rounded : Icons.volume_up_rounded,
          label: voice.deafened ? 'Undeafen' : 'Deafen',
          size: 58,
          onPressed: voice.inCall ? () => ref.read(voiceProvider.notifier).toggleDeafen() : null,
        ),
        NeonRoundButton(
          icon: Icons.chat_bubble_rounded,
          label: unread > 0 ? 'Open chat, $unread new' : 'Open chat',
          size: 58,
          badge: unread > 0 ? NeonCount(unread) : null,
          onPressed: () => showGameChat(context, ref),
        ),
        if (alive && !pending)
          Semantics(
            button: true,
            label: 'Ask everyone to vote now',
            child: InkResponse(
              onTap: g.busy ? null : () => ref.read(onlineGameProvider.notifier).requestEndDiscussion(),
              radius: 36,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFF7A92), Color(0xFFE0364F)]),
                  border: Border.all(color: const Color(0xFFFF9AAE), width: 1.5),
                  boxShadow: const [BoxShadow(color: Color(0x8CFF5A78), blurRadius: 16)],
                ),
                child: g.busy ? const Center(child: _Spinner(color: Colors.white)) : const Icon(Icons.back_hand_rounded, color: Colors.white, size: 28),
              ),
            ),
          ),
      ]),
      if (!alive) const _Hint('Voting starts when the timer ends.'),
    ]);
  }

  Widget _endRequest(OnlineGameState g, DiscussionEndRequest req) {
    final uid = SupabaseService.currentUserId;
    final mine = req.requesterId == uid;
    final answered = mine || _answeredRequestId == req.id;
    final alive = g.players.any((p) => p.playerId == uid && p.isAlive);
    final left = req.expiresAt.difference(DateTime.now()).inSeconds.clamp(0, 99);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        glow: true,
        borderColor: HushbugColors.accentYellow,
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Text(mine ? 'You asked to vote now.' : '${req.requesterName} wants to vote now',
              textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          Text('${req.approvals} of ${req.eligible} agree · ${left}s to answer',
              style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 13, fontWeight: FontWeight.w700)),
          if (!answered && alive) ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TactileButton(onPressed: g.busy ? null : () => _answer(req, false), style: TactileButtonStyle.secondary, height: 48, child: const Text('Keep talking'))),
              const SizedBox(width: 10),
              Expanded(child: TactileButton(onPressed: g.busy ? null : () => _answer(req, true), style: TactileButtonStyle.golden, height: 48, child: const Text('Vote now'))),
            ]),
          ] else
            const Padding(padding: EdgeInsets.only(top: 6), child: _Hint('Waiting for everyone to answer…')),
        ]),
      ),
    );
  }

  Future<void> _answer(DiscussionEndRequest req, bool approve) async {
    setState(() => _answeredRequestId = req.id);
    if (!await ref.read(onlineGameProvider.notifier).respondEndDiscussion(approve) && mounted) {
      setState(() => _answeredRequestId = null);
    }
  }

  // ------------------------------------------------------------ vote

  Widget _vote(OnlineGameState g, bool isHost) {
    final s = g.session!;
    final uid = SupabaseService.currentUserId;
    final order = g.aliveOrder;
    final alive = order.contains(uid);
    final voted = s.voters.contains(uid) || g.myVote != null;
    final current = g.currentVoterId;
    final myTurn = s.isSequentialVote ? current == uid : true;
    final canVote = alive && !voted && myTurn && !g.busy;
    final tie = s.revotes > 0 && s.lastVoteSummary?['tie'] == true;
    final offline = current == null ? null : ref.watch(onlineLobbyProvider).players.where((p) => p.playerId == current && !p.isConnected).firstOrNull;

    // After voting (or when out), show who has handed in a ballot.
    if (!canVote && (voted || !alive || (s.isSequentialVote && !myTurn))) {
      return Column(children: [
        if (tie) const _Hint("It's a tie! Vote again.", color: HushbugColors.accentYellow),
        NeonTimerBar(fraction: order.isEmpty ? 0 : s.voters.length / order.length, label: '${s.voters.length}/${order.length}'),
        const SizedBox(height: 12),
        NeonTitle(voted ? 'Vote locked in' : (s.isSequentialVote && current != null ? "${_name(g, current)}'s turn to vote" : 'Waiting for votes'), size: 24),
        if (voted && g.myVote != null) _Hint('You picked ${_name(g, g.myVote)}.', color: HushbugColors.civilianEmerald),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(children: [
            for (final id in order)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassPanel(
                  radius: 34,
                  borderColor: id == current ? HushbugColors.accentYellow : null,
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                  child: Row(children: [
                    NeonSeat(name: _name(g, id), avatarIndex: _p(g, id)?.avatarIndex, size: 48, showName: false),
                    const SizedBox(width: 12),
                    Expanded(child: Text(id == uid ? 'You' : _name(g, id), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
                    AnimatedSwitcher(
                      duration: motionDuration(context, 200),
                      child: s.voters.contains(id)
                          ? Container(
                              key: const ValueKey('done'),
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(color: Color(0xFF2FC46B), shape: BoxShape.circle),
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 18, semanticLabel: 'Voted'),
                            )
                          : Text(id == current ? 'Voting…' : 'Waiting',
                              key: ValueKey(id == current),
                              style: TextStyle(color: id == current ? HushbugColors.accentYellowLight : HushbugColors.textSubtext, fontSize: 13, fontWeight: FontWeight.w800)),
                    ),
                  ]),
                ),
              ),
          ]),
        ),
        if (isHost && offline != null)
          TextButton.icon(
            onPressed: g.busy ? null : () => ref.read(onlineGameProvider.notifier).skipTurn(),
            icon: const Icon(Icons.skip_next_rounded, color: HushbugColors.accentYellow),
            label: Text('${offline.displayName} is offline. Skip vote', style: const TextStyle(color: HushbugColors.accentYellow)),
          ),
        if (isHost && s.voters.isNotEmpty)
          TextButton(
            onPressed: g.busy ? null : () => ref.read(onlineGameProvider.notifier).tallyVotes(),
            child: const Text('Host: reveal the votes now'),
          ),
      ]);
    }

    final candidates = [for (final id in order) if (id != uid) id];
    return Column(children: [
      if (tie) const _Hint("It's a tie! Vote again.", color: HushbugColors.accentYellow),
      NeonTitle(s.isSequentialVote ? 'Your turn to vote' : "Who's the imposter?", size: 26),
      const _Hint('Pick one, then tap the tick. Your vote is secret and final.'),
      const SizedBox(height: 8),
      Expanded(
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
          children: [
            for (final id in candidates)
              _VoteTile(
                name: _name(g, id),
                avatarIndex: _p(g, id)?.avatarIndex,
                selected: _picked == id,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _picked = id);
                },
              ),
          ],
        ),
      ),
      Row(children: [
        Expanded(
          child: TactileButton(
            onPressed: _picked == null ? null : () => setState(() => _picked = null),
            style: TactileButtonStyle.secondary,
            height: 64,
            icon: const Icon(Icons.close_rounded, size: 28),
            child: const Text('Clear'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: TactileButton(
            onPressed: _picked == null || g.busy ? null : () => _castVote(_picked!),
            style: TactileButtonStyle.golden,
            height: 64,
            icon: g.busy ? const _Spinner() : const Icon(Icons.check_rounded, size: 32),
            child: Text(_picked == null ? 'Pick someone' : 'Vote ${_name(g, _picked)}'),
          ),
        ),
      ]),
    ]);
  }

  Future<void> _castVote(String targetId) async {
    HapticFeedback.heavyImpact();
    if (await ref.read(onlineGameProvider.notifier).castVote(targetId) && mounted) {
      toast(context, 'Your vote is in.');
    }
  }

  // ------------------------------------------------------------ result

  Widget _result(OnlineGameState g, bool isHost, OnlineRoom? room) {
    final r = g.result;
    if (r == null) return const Center(child: _Hint('Counting the votes…'));
    final crewWon = r.winner == 'crew';
    final uid = SupabaseService.currentUserId;
    final summary = g.session!.lastVoteSummary;
    final ballots = summary?['ballots'] is Map ? Map<String, dynamic>.from(summary!['ballots'] as Map) : null;
    final round = g.session!.matchRound;
    final total = room?.totalRounds ?? round;
    final over = round >= total;
    Duration at(int i) => Duration(milliseconds: 110 * i);

    return ListView(children: [
      Appear(
        scaleFrom: 0.85,
        child: Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(alignment: Alignment.center, children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x4D7846DC),
                  border: Border.all(color: const Color(0xFFC9A4FF), width: 3),
                  boxShadow: const [BoxShadow(color: Color(0x80A06BFF), blurRadius: 30)],
                ),
              ),
              Mascot(size: 140, mood: crewWon ? MascotMood.celebrating : MascotMood.shocked),
              const Positioned(
                top: 0,
                child: Icon(Icons.workspace_premium_rounded, size: 54, color: HushbugColors.accentYellow, shadows: [Shadow(color: Color(0xCCFFC61A), blurRadius: 16)]),
              ),
            ]),
          ),
        ),
      ),
      Appear(
        delay: at(2),
        child: Center(
          child: GlassPanel(
            radius: 30,
            glow: true,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Text(crewWon ? 'Crew wins!' : 'Imposter wins!',
                style: TextStyle(fontFamily: 'Fredoka', fontSize: 26, fontWeight: FontWeight.w700, color: crewWon ? HushbugColors.accentYellowLight : HushbugColors.imposterRed)),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Appear(
        delay: at(3),
        child: Text.rich(
          TextSpan(text: 'The word was ', children: [TextSpan(text: r.secretWord, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))]),
          textAlign: TextAlign.center,
          style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      const SizedBox(height: 18),
      Appear(
        delay: at(4),
        child: Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 14, children: [
          for (final p in g.players)
            SizedBox(
              width: 76,
              child: NeonSeat(
                name: p.playerId == uid ? 'You' : p.displayName,
                avatarIndex: p.avatarIndex,
                size: 58,
                tick: !r.imposters.contains(p.playerId),
                ringColor: r.imposters.contains(p.playerId) ? HushbugColors.imposterRed : null,
                highlight: r.imposters.contains(p.playerId),
                caption: r.imposters.contains(p.playerId) ? 'Imposter' : null,
                captionColor: HushbugColors.imposterRed,
              ),
            ),
        ]),
      ),
      if (ballots != null) ...[
        const SizedBox(height: 14),
        Appear(
          delay: at(5),
          child: GlassPanel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('How everyone voted', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              for (final e in ballots.entries)
                Text('${_name(g, e.key)} → ${_name(g, e.value.toString())}', style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 14, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ],
      const SizedBox(height: 14),
      Appear(
        delay: at(6),
        child: Column(children: [
          NeonTitle(over ? 'Final scores' : 'Scores after round $round of $total', size: 20),
          const SizedBox(height: 8),
          if (g.standings.isEmpty) const _Hint('Adding up the scores…'),
          for (final (i, st) in g.standings.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                height: 58,
                padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(29),
                  gradient: i == 0 ? const LinearGradient(colors: [Color(0xFFFFC61A), Color(0xFFFFE680)]) : null,
                  color: i == 0 ? null : const Color(0x59462882),
                  border: i == 0 ? null : Border.all(color: const Color(0x4DBE96FF), width: 1.5),
                  boxShadow: i == 0 ? const [BoxShadow(color: Color(0x73FFC61A), blurRadius: 18)] : null,
                ),
                child: Row(children: [
                  SizedBox(
                    width: 26,
                    child: Text('${i + 1}', style: TextStyle(fontFamily: 'Fredoka', fontSize: 20, fontWeight: FontWeight.w700, color: i == 0 ? HushbugColors.onAccentYellow : const Color(0xFFE3E3F0))),
                  ),
                  if (i == 0) const Icon(Icons.workspace_premium_rounded, color: Color(0xFFB87800), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(st.playerId == uid ? 'You' : st.displayName,
                        style: TextStyle(color: i == 0 ? HushbugColors.onAccentYellow : Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                  Text('${st.points}', style: TextStyle(fontFamily: 'Fredoka', fontSize: 20, fontWeight: FontWeight.w600, color: i == 0 ? HushbugColors.onAccentYellow : Colors.white)),
                  const SizedBox(width: 4),
                  Icon(Icons.star_rounded, color: i == 0 ? const Color(0xFFB87800) : HushbugColors.accentYellow, size: 22),
                ]),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          flex: 3,
          child: !over && isHost
              ? TactileButton(
                  onPressed: g.busy ? null : () => ref.read(onlineGameProvider.notifier).startNextRound(),
                  style: TactileButtonStyle.golden,
                  height: 64,
                  icon: g.busy ? const _Spinner() : const Icon(Icons.refresh_rounded, size: 30),
                  child: Text('Round ${round + 1}'),
                )
              : !over
                  ? _Hint('Waiting for the host to start round ${round + 1}…')
                  : TactileButton(
                      onPressed: () => context.pop(),
                      style: TactileButtonStyle.golden,
                      height: 64,
                      icon: const Icon(Icons.refresh_rounded, size: 30),
                      child: const Text('Play again'),
                    ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: TactileButton(
            onPressed: () => context.go('/'),
            style: TactileButtonStyle.neonPurple,
            height: 64,
            icon: const Icon(Icons.home_rounded, size: 28),
            child: const Text('Home'),
          ),
        ),
      ]),
      const SizedBox(height: 6),
    ]);
  }
}

// ------------------------------------------------------------ pieces

class _Spinner extends StatelessWidget {
  const _Spinner({this.color = HushbugColors.onAccentYellow});
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: color));
}

class _Hint extends StatelessWidget {
  const _Hint(this.text, {this.color = HushbugColors.textSubtext});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
      );
}

/// Glass pill with every player's seat; the current one glows.
class _PlayerStrip extends StatelessWidget {
  const _PlayerStrip({required this.ids, required this.game, required this.highlight, required this.done});
  final List<String> ids;
  final OnlineGameState game;
  final String? highlight;
  final Set<String> done;

  @override
  Widget build(BuildContext context) => GlassPanel(
        radius: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: ids.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final p = game.players.where((x) => x.playerId == ids[i]).firstOrNull;
              final on = ids[i] == highlight;
              return Center(
                child: NeonSeat(
                  name: p?.displayName ?? '',
                  avatarIndex: p?.avatarIndex,
                  size: on ? 54 : 44,
                  showName: false,
                  highlight: on,
                  ringColor: on ? const Color(0xFFFFB3C7) : null,
                  tick: done.contains(ids[i]) && !on,
                  dim: !on && !done.contains(ids[i]),
                ),
              );
            },
          ),
        ),
      );
}

class _VoteTile extends StatelessWidget {
  const _VoteTile({required this.name, required this.avatarIndex, required this.selected, required this.onTap});
  final String name;
  final int? avatarIndex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: name,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedScale(
            scale: selected ? 1.04 : 1,
            duration: motionDuration(context, 180),
            curve: easeOutStrong,
            child: AnimatedContainer(
              duration: motionDuration(context, 180),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: selected ? const [Color(0xFF8A55F0), Color(0xFF5A2FC0)] : const [Color(0x99503096), Color(0x992C185C)],
                ),
                border: Border.all(color: selected ? const Color(0xFFF0C8FF) : const Color(0x66BE96FF), width: selected ? 3 : 2),
                boxShadow: selected ? const [BoxShadow(color: Color(0xBFDCA0FF), blurRadius: 24)] : null,
              ),
              child: Stack(clipBehavior: Clip.none, children: [
                Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    PlayerAvatar(index: 0, name: name, radius: 28, avatarIndex: avatarIndex),
                    const SizedBox(height: 6),
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                  ]),
                ),
                if (selected)
                  Positioned(
                    top: -8,
                    right: -6,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: HushbugColors.accentYellow, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1A0D38), width: 3)),
                      child: const Icon(Icons.check_rounded, size: 16, color: HushbugColors.onAccentYellow),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      );
}
