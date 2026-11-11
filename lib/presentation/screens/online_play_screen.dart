import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/services.dart';
import '../../services/supabase/models.dart';
import '../../services/supabase/multiplayer_providers.dart';
import '../../services/supabase/supabase_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import '../widgets/motion.dart';
import '../widgets/room_comms.dart';
import '../widgets/visuals.dart';

/// Server-authoritative online game screen. Every rule shown here is also
/// enforced by the database; the screen only reflects it.
class OnlinePlayScreen extends ConsumerStatefulWidget {
  const OnlinePlayScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<OnlinePlayScreen> createState() => _OnlinePlayScreenState();
}

class _OnlinePlayScreenState extends ConsumerState<OnlinePlayScreen> with TickerProviderStateMixin {
  late final AnimationController _cardFlipController;
  late final Animation<double> _cardRotation;
  late final Animation<double> _cardElevation;

  int? _activePointerId;
  bool _isCardRevealed = false;
  final TextEditingController _clueController = TextEditingController();
  Timer? _ticker;
  int _secondsRemaining = 0;
  bool _timerSynced = false;
  String? _answeredRequestId;
  bool _secure = false;

  @override
  void initState() {
    super.initState();
    _cardFlipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _cardRotation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _cardFlipController, curve: Curves.easeInOutCubic));
    _cardElevation = Tween<double>(begin: 4, end: 16).animate(CurvedAnimation(parent: _cardFlipController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(onlineGameProvider.notifier).initGame(widget.sessionId));
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final game = ref.read(onlineGameProvider);
    final session = game.session;
    if (session == null || !mounted) return;
    if (session.phase == 'discussion' && session.discussionEndTime != null) {
      final left = session.discussionEndTime!.toUtc().difference(DateTime.now().toUtc()).inSeconds;
      setState(() => _secondsRemaining = left > 0 ? left : 0);
      if (left <= 0 && !_timerSynced) {
        _timerSynced = true;
        ref.read(onlineGameProvider.notifier).syncTimers();
      }
    } else {
      _timerSynced = false;
    }
    // Keeps the request countdown moving.
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
    _cardFlipController.dispose();
    _clueController.dispose();
    _ticker?.cancel();
    super.dispose();
  }

  void _reveal(bool show) {
    setState(() => _isCardRevealed = show);
    show ? _cardFlipController.forward() : _cardFlipController.reverse();
    show ? HapticFeedback.mediumImpact() : HapticFeedback.lightImpact();
  }

  String _name(OnlineGameState g, String? id) => g.players.where((p) => p.playerId == id).firstOrNull?.displayName ?? 'Player';

  OnlineGamePlayer? _player(OnlineGameState g, String? id) => g.players.where((p) => p.playerId == id).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(onlineGameProvider);
    final lobby = ref.watch(onlineLobbyProvider);
    final session = game.session;
    final isHost = lobby.isHost;

    ref.listen(onlineGameProvider.select((s) => s.error), (_, err) {
      if (err != null && ref.read(onlineGameProvider).session != null) {
        toast(context, err);
        ref.read(onlineGameProvider.notifier).clearError();
      }
    });
    ref.listen(onlineLobbyProvider.select((s) => s.room?.id), (_, roomId) {
      if (roomId == null && mounted) context.go('/multiplayer');
    });

    _setSecure(session?.phase == 'reveal');

    if (session == null) {
      return _Backdrop(
        child: Center(
          child: game.error != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Mascot(size: 90, mood: MascotMood.sad),
                    const SizedBox(height: 12),
                    Text(
                      game.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(onPressed: () => context.pop(), child: const Text('Back')),
                        FilledButton(
                          onPressed: () => ref.read(onlineGameProvider.notifier).initGame(widget.sessionId),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ],
                )
              : const _LoadingBlock(text: 'Loading the game…'),
        ),
      );
    }

    final room = lobby.room;
    final totalRounds = room?.totalRounds ?? 1;

    return _Backdrop(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back to lobby',
                    onPressed: () => context.pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: HushbugColors.cardSurface.withValues(alpha: 0.8),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'ROUND ${session.matchRound} OF $totalRounds • ${session.category.toUpperCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: HushbugColors.accentYellow,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _phaseTitle(session.phase),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  _Pill(text: '${game.players.where((p) => p.isAlive).length} in play', color: HushbugColors.civilianEmerald),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CommBar(onOpenChat: () => showGameChat(context, ref)),
            ),
            if (lobby.offline)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Connection lost. Reconnecting…', style: TextStyle(color: HushbugColors.accentYellow, fontSize: 12)),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                child: AnimatedSwitcher(
                  duration: motionDuration(context, 260),
                  transitionBuilder: swapTransition,
                  child: KeyedSubtree(
                    key: ValueKey('${session.id}-${session.phase}-${session.revotes}'),
                    child: switch (session.phase) {
                      'reveal' => _revealPhase(game, isHost),
                      'clue' => _cluePhase(game, isHost),
                      'discussion' => _discussionPhase(game),
                      'vote' => _votePhase(game, isHost),
                      'result' => _resultPhase(game, isHost, room),
                      _ => _revealPhase(game, isHost),
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _phaseTitle(String phase) => switch (phase) {
    'reveal' => 'Secret Card',
    'clue' => 'Clues',
    'discussion' => 'Discussion',
    'vote' => 'Voting',
    'result' => 'Round Results',
    _ => phase,
  };

  // ---------------------------------------------------------------- reveal
  Widget _revealPhase(OnlineGameState g, bool isHost) {
    final a = g.assignment;
    final word = a?.word ?? '…';
    final showsRole = (a?.isImposter ?? false) && a?.fakeWord == null;

    return LayoutBuilder(
      builder: (context, c) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Hold the card to see your word. Let go to hide it.',
            textAlign: TextAlign.center,
            style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12),
          ),
          Listener(
            onPointerDown: (e) {
              if (_activePointerId != null) return;
              _activePointerId = e.pointer;
              _reveal(true);
            },
            onPointerUp: (e) {
              if (e.pointer != _activePointerId) return;
              _activePointerId = null;
              _reveal(false);
            },
            onPointerCancel: (e) {
              if (e.pointer != _activePointerId) return;
              _activePointerId = null;
              _reveal(false);
            },
            child: AnimatedBuilder(
              animation: _cardFlipController,
              builder: (context, _) {
                final angle = _cardRotation.value * 3.1415926535;
                final back = angle > 1.5707963268;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 320, minHeight: 260),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: back ? const Color(0xFF22173F) : HushbugColors.cardSurface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: back ? HushbugColors.neonPurpleLight : HushbugColors.cardBorder, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: HushbugColors.neonPurple.withValues(alpha: back ? 0.4 : 0.1),
                          blurRadius: _cardElevation.value,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    // The word only exists in the tree while the card is held.
                    child: back && _isCardRevealed
                        ? Transform(
                            transform: Matrix4.identity()..rotateY(3.1415926535),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  showsRole ? Icons.masks_rounded : Icons.lock_open_rounded,
                                  color: showsRole ? HushbugColors.imposterRed : HushbugColors.accentYellow,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  showsRole ? 'SECRET ROLE' : 'YOUR WORD',
                                  style: const TextStyle(
                                    color: HushbugColors.textSubtext,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  word,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: showsRole ? HushbugColors.imposterRed : Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if (!showsRole && a?.description != null) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    a!.description!,
                                    textAlign: TextAlign.center,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFC4B5FD),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                                if (a?.hint != null) ...[
                                  const SizedBox(height: 8),
                                  Text('Hint: ${a!.hint}', style: const TextStyle(color: HushbugColors.accentYellow, fontSize: 12)),
                                ],
                              ],
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fingerprint_rounded, color: HushbugColors.neonPurpleLight, size: 54),
                              SizedBox(height: 14),
                              Text(
                                'Hold to Reveal',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
          if (c.maxHeight > 480) Mascot(size: 96, mood: _isCardRevealed ? MascotMood.peeking : MascotMood.sleeping),
          if (isHost)
            _ActionButton(
              label: 'Start Clues',
              icon: Icons.play_arrow_rounded,
              busy: g.busy,
              onPressed: () => ref.read(onlineGameProvider.notifier).advancePhase('clue'),
            )
          else
            const _WaitingText('Waiting for the host to start clues…'),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- clues
  Widget _cluePhase(OnlineGameState g, bool isHost) {
    final session = g.session!;
    final uid = SupabaseService.currentUserId;
    final order = g.aliveOrder;
    final current = g.currentCluePlayerId;
    final done = {
      for (final c in g.clues)
        if (c.roundNumber == session.roundNumber) c.playerId,
    };
    final isMine = current == uid;
    final position = order.indexOf(current ?? '') + 1;
    final lobbyEntry = ref.watch(onlineLobbyProvider).players.where((p) => p.playerId == current).firstOrNull;

    return Column(
      children: [
        _TurnBanner(
          player: _player(g, current),
          title: isMine ? 'Your Turn to Write a Clue' : "${_name(g, current)}'s Turn to Write a Clue",
          subtitle: position > 0 ? 'Player $position of ${order.length}' : null,
          highlight: isMine,
        ),
        const SizedBox(height: 10),
        _TurnStrip(ids: order, players: g.players, current: current, done: done),
        const SizedBox(height: 10),
        Expanded(
          child: g.clues.isEmpty
              ? const Center(
                  child: Text('No clues yet.', style: TextStyle(color: HushbugColors.textMuted, fontSize: 13)),
                )
              : ListView(
                  children: [
                    for (final c in g.clues)
                      Appear(
                        key: ValueKey(c.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: HushbugColors.cardSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: HushbugColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              PlayerAvatar(
                                index: 0,
                                name: _name(g, c.playerId),
                                radius: 14,
                                avatarIndex: _player(g, c.playerId)?.avatarIndex,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${_name(g, c.playerId)}:',
                                style: const TextStyle(color: HushbugColors.neonPurpleLight, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  c.clueText,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        if (isMine) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _clueController,
                  maxLength: 60,
                  enabled: !g.busy,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendClue(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Your clue…',
                    filled: true,
                    fillColor: HushbugColors.cardSurface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 96,
                child: _ActionButton(label: 'Send', busy: g.busy, onPressed: _sendClue, height: 48),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ] else
          _WaitingText(current == null ? 'All clues are in.' : 'Waiting for ${_name(g, current)}…'),
        if (isHost && lobbyEntry != null && !lobbyEntry.isConnected)
          TextButton.icon(
            onPressed: g.busy ? null : () => ref.read(onlineGameProvider.notifier).skipTurn(),
            icon: const Icon(Icons.skip_next_rounded, color: HushbugColors.accentYellow),
            label: Text('${lobbyEntry.displayName} is offline. Skip turn', style: const TextStyle(color: HushbugColors.accentYellow)),
          ),
        if (isHost)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _ActionButton(
              label: 'Move to Discussion',
              style: TactileButtonStyle.secondary,
              busy: g.busy,
              onPressed: () => ref.read(onlineGameProvider.notifier).advancePhase('discussion'),
            ),
          ),
      ],
    );
  }

  Future<void> _sendClue() async {
    final text = _clueController.text.trim();
    if (text.isEmpty) return;
    if (await ref.read(onlineGameProvider.notifier).submitClue(text)) _clueController.clear();
  }

  // ---------------------------------------------------------------- discussion
  Widget _discussionPhase(OnlineGameState g) {
    final uid = SupabaseService.currentUserId;
    final amAlive = g.players.any((p) => p.playerId == uid && p.isAlive);
    final req = g.endRequest;
    final pending = req != null && req.isPending;
    final mm = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final ss = (_secondsRemaining % 60).toString().padLeft(2, '0');
    final eliminated = g.session!.lastVoteSummary?['eliminated']?.toString();

    return Column(
      children: [
        if (eliminated != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${_name(g, eliminated)} was voted out. The game goes on!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: HushbugColors.accentYellow, fontWeight: FontWeight.w700),
            ),
          ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: HushbugColors.cardSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: HushbugColors.neonPurpleLight.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              const Text(
                'TIME LEFT',
                style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Text(
                '$mm:$ss',
                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const Text('Talk it through. Who is faking?', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: pending
              ? Appear(key: ValueKey(req.id), scaleFrom: 0.96, child: _endRequestCard(g, req))
              : const SizedBox(width: double.infinity),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              for (final p in g.players)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: HushbugColors.cardSurface.withValues(alpha: p.isAlive ? 1 : 0.35),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: p.isAlive ? HushbugColors.cardBorder : Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      VoiceAvatar(
                        playerId: p.playerId,
                        child: PlayerAvatar(index: 0, name: p.displayName, radius: 14, avatarIndex: p.avatarIndex),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: p.isAlive ? Colors.white : HushbugColors.textMuted,
                            fontWeight: FontWeight.bold,
                            decoration: p.isAlive ? null : TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (amAlive && !pending)
          _ActionButton(
            label: 'Ask to End Discussion',
            icon: Icons.how_to_vote_rounded,
            style: TactileButtonStyle.secondary,
            busy: g.busy,
            onPressed: () => ref.read(onlineGameProvider.notifier).requestEndDiscussion(),
          )
        else if (!amAlive)
          const _WaitingText('Voting starts when the timer ends.'),
      ],
    );
  }

  Widget _endRequestCard(OnlineGameState g, DiscussionEndRequest req) {
    final uid = SupabaseService.currentUserId;
    final mine = req.requesterId == uid;
    final answered = mine || _answeredRequestId == req.id;
    final amAlive = g.players.any((p) => p.playerId == uid && p.isAlive);
    final secondsLeft = req.expiresAt.difference(DateTime.now()).inSeconds.clamp(0, 99);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HushbugColors.neonPurple.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HushbugColors.neonPurpleLight),
      ),
      child: Column(
        children: [
          Text(
            mine ? 'You asked to end the discussion.' : '${req.requesterName} wants to end the discussion. Do you want to end it now?',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${req.approvals} of ${req.eligible} agreed · ${secondsLeft}s left',
            style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 12),
          ),
          if (!answered && amAlive) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Continue Discussion',
                    style: TactileButtonStyle.secondary,
                    height: 44,
                    busy: g.busy,
                    onPressed: () => _answer(req, false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(label: 'End Discussion', height: 44, busy: g.busy, onPressed: () => _answer(req, true)),
                ),
              ],
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Waiting for everyone to answer…', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Future<void> _answer(DiscussionEndRequest req, bool approve) async {
    setState(() => _answeredRequestId = req.id);
    final ok = await ref.read(onlineGameProvider.notifier).respondEndDiscussion(approve);
    if (!ok && mounted) setState(() => _answeredRequestId = null);
  }

  // ---------------------------------------------------------------- vote
  Widget _votePhase(OnlineGameState g, bool isHost) {
    final session = g.session!;
    final uid = SupabaseService.currentUserId;
    final order = g.aliveOrder;
    final amAlive = order.contains(uid);
    final iVoted = session.voters.contains(uid) || g.myVote != null;
    final currentVoter = g.currentVoterId;
    final myTurn = session.isSequentialVote ? currentVoter == uid : true;
    final canVote = amAlive && !iVoted && myTurn && !g.busy;
    final tie = session.revotes > 0 && session.lastVoteSummary?['tie'] == true;
    final position = order.indexOf(currentVoter ?? '') + 1;
    final offlineVoter = currentVoter == null
        ? null
        : ref.watch(onlineLobbyProvider).players.where((p) => p.playerId == currentVoter && !p.isConnected).firstOrNull;

    return Column(
      children: [
        if (tie)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              "It's a tie! Vote again.",
              style: TextStyle(color: HushbugColors.accentYellow, fontWeight: FontWeight.w800),
            ),
          ),
        if (session.isSequentialVote && currentVoter != null)
          _TurnBanner(
            player: _player(g, currentVoter),
            title: currentVoter == uid ? 'Your Turn to Vote' : "${_name(g, currentVoter)}'s Turn to Vote",
            subtitle: 'Player $position of ${order.length}',
            highlight: currentVoter == uid,
          )
        else
          _TurnBanner(
            player: null,
            title: 'Everyone votes now',
            subtitle: '${session.voters.length} of ${order.length} have voted',
            highlight: canVote,
          ),
        const SizedBox(height: 8),
        Text(
          iVoted
              ? 'Your vote for ${_name(g, g.myVote)} is locked in.'
              : !amAlive
              ? "You're out, so you can watch the vote."
              : myTurn
              ? 'Tap the player you think is the imposter.'
              : 'Wait for your turn.',
          style: TextStyle(
            color: iVoted ? HushbugColors.civilianEmerald : HushbugColors.textSubtext,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: [
              for (final id in order)
                _VoteRow(
                  player: _player(g, id),
                  isMe: id == uid,
                  isTarget: g.myVote == id,
                  status: session.voters.contains(id)
                      ? _VoteStatus.submitted
                      : (session.isSequentialVote && id == currentVoter ? _VoteStatus.voting : _VoteStatus.waiting),
                  onTap: canVote && id != uid ? () => _confirmVote(g, id) : null,
                ),
            ],
          ),
        ),
        if (g.busy) const _LoadingBlock(text: 'Sending…', compact: true),
        if (isHost && offlineVoter != null)
          TextButton.icon(
            onPressed: g.busy ? null : () => ref.read(onlineGameProvider.notifier).skipTurn(),
            icon: const Icon(Icons.skip_next_rounded, color: HushbugColors.accentYellow),
            label: Text('${offlineVoter.displayName} is offline. Skip vote', style: const TextStyle(color: HushbugColors.accentYellow)),
          ),
        if (isHost && session.voters.isNotEmpty)
          _ActionButton(
            label: 'Close Vote Now',
            icon: Icons.gavel_rounded,
            style: TactileButtonStyle.secondary,
            busy: g.busy,
            onPressed: () => ref.read(onlineGameProvider.notifier).tallyVotes(),
          ),
      ],
    );
  }

  Future<void> _confirmVote(OnlineGameState g, String targetId) async {
    final name = _name(g, targetId);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: HushbugColors.cardSurface,
        title: const Text('Confirm your vote', style: TextStyle(color: Colors.white, fontSize: 17)),
        content: Text(
          'Are you sure you want to vote for $name? You cannot change it afterwards.',
          style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Confirm')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    HapticFeedback.selectionClick();
    if (await ref.read(onlineGameProvider.notifier).castVote(targetId) && mounted) {
      toast(context, 'Your vote has been recorded.');
    }
  }

  // ---------------------------------------------------------------- result
  Widget _resultPhase(OnlineGameState g, bool isHost, OnlineRoom? room) {
    final result = g.result;
    if (result == null) return const Center(child: _LoadingBlock(text: 'Counting the votes…'));
    final crewWon = result.winner == 'crew';
    final imposters = [for (final id in result.imposters) _name(g, id)];
    final summary = g.session!.lastVoteSummary;
    final ballots = summary?['ballots'] is Map ? Map<String, dynamic>.from(summary!['ballots'] as Map) : null;
    final counts = summary?['counts'] is Map ? Map<String, dynamic>.from(summary!['counts'] as Map) : null;
    final round = g.session!.matchRound;
    final total = room?.totalRounds ?? round;
    final matchOver = round >= total;

    Duration step(int i) => Duration(milliseconds: 70 * i);
    return ListView(
      children: [
        Appear(
          scaleFrom: 0.9,
          child: Center(child: Mascot(size: 96, mood: crewWon ? MascotMood.celebrating : MascotMood.detective)),
        ),
        const SizedBox(height: 10),
        Appear(
          delay: step(1),
          scaleFrom: 0.92,
          child: Text(
            crewWon ? 'CREW WINS!' : 'IMPOSTER WINS!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: crewWon ? HushbugColors.civilianEmerald : HushbugColors.imposterRed,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Appear(
          delay: step(2),
          child: Text(
            'Secret word: ${result.secretWord}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (imposters.isNotEmpty)
          Appear(
            delay: step(3),
            child: Text(
              'Imposter: ${imposters.join(', ')}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 14),
            ),
          ),
        if (ballots != null || counts != null) ...[
          const SizedBox(height: 14),
          Appear(
            delay: step(4),
            child: _Section(
              title: 'HOW EVERYONE VOTED',
              children: [
                if (ballots != null)
                  for (final e in ballots.entries)
                    Text('${_name(g, e.key)} → ${_name(g, e.value.toString())}', style: const TextStyle(color: Colors.white, fontSize: 13))
                else
                  for (final e in counts!.entries)
                    Text(
                      '${_name(g, e.key)}: ${e.value} vote${e.value == 1 ? '' : 's'}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Appear(
          delay: step(5),
          child: _Section(
            title: matchOver ? 'FINAL SCORES' : 'SCORES AFTER ROUND $round OF $total',
            children: g.standings.isEmpty
                ? [const _LoadingBlock(text: 'Loading scores…', compact: true)]
                : [
                    for (final (i, s) in g.standings.indexed)
                      Row(
                        children: [
                          SizedBox(
                            width: 22,
                            child: Text('${i + 1}.', style: const TextStyle(color: HushbugColors.textSubtext)),
                          ),
                          Expanded(
                            child: Text(
                              s.displayName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            '${s.points}',
                            style: const TextStyle(color: HushbugColors.accentYellow, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                  ],
          ),
        ),
        const SizedBox(height: 16),
        if (!matchOver && isHost)
          _ActionButton(
            label: 'Start Round ${round + 1} of $total',
            icon: Icons.skip_next_rounded,
            busy: g.busy,
            onPressed: () => ref.read(onlineGameProvider.notifier).startNextRound(),
          )
        else if (!matchOver)
          _WaitingText('Waiting for the host to start round ${round + 1}…')
        else
          _ActionButton(label: 'Back to Lobby', style: TactileButtonStyle.neonPurple, onPressed: () => context.pop()),
      ],
    );
  }
}

// ---------------------------------------------------------------- pieces

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: HushbugColors.scaffoldGradient),
      child: child,
    ),
  );
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({required this.text, this.compact = false});
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(compact ? 6 : 16),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: compact ? 14 : 18,
          height: compact ? 14 : 18,
          child: const CircularProgressIndicator(strokeWidth: 2, color: HushbugColors.neonPurpleLight),
        ),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 13)),
      ],
    ),
  );
}

class _WaitingText extends StatelessWidget {
  const _WaitingText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 12),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: HushbugColors.cardSurface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: HushbugColors.cardBorder),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
    ),
  );
}

/// A tactile button that shows a spinner and ignores taps while busy.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.busy = false,
    this.height = 52,
    this.style = TactileButtonStyle.golden,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool busy;
  final double height;
  final TactileButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final onColor = style == TactileButtonStyle.golden ? HushbugColors.onAccentYellow : Colors.white;
    return TactileButton(
      onPressed: busy ? null : onPressed,
      style: style,
      height: height,
      icon: busy
          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: onColor))
          : (icon == null ? null : Icon(icon, color: onColor, size: 20)),
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: HushbugColors.cardSurface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: HushbugColors.cardBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 11, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        ...children.map((c) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: c)),
      ],
    ),
  );
}

/// Large "whose turn is it" header shared by clues and voting.
class _TurnBanner extends StatelessWidget {
  const _TurnBanner({required this.player, required this.title, this.subtitle, this.highlight = false});
  final OnlineGamePlayer? player;
  final String title;
  final String? subtitle;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: highlight ? HushbugColors.neonPurple.withValues(alpha: 0.3) : HushbugColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: highlight ? HushbugColors.accentYellow : HushbugColors.cardBorder, width: 1.5),
        ),
        child: AnimatedSwitcher(
          duration: motionDuration(context, 220),
          transitionBuilder: swapTransition,
          child: Row(
            key: ValueKey(title),
            children: [
              if (player != null) ...[
                VoiceAvatar(
                  playerId: player!.playerId,
                  child: PlayerAvatar(index: 0, name: player!.displayName, radius: 22, avatarIndex: player!.avatarIndex),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: highlight ? HushbugColors.accentYellow : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    if (subtitle != null) Text(subtitle!, style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row of avatars in turn order: done, current, still to go.
class _TurnStrip extends StatelessWidget {
  const _TurnStrip({required this.ids, required this.players, required this.current, required this.done});
  final List<String> ids;
  final List<OnlineGamePlayer> players;
  final String? current;
  final Set<String> done;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ids.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final p = players.where((x) => x.playerId == ids[i]).firstOrNull;
          final isCurrent = ids[i] == current;
          final isDone = done.contains(ids[i]) && !isCurrent;
          return Semantics(
            label:
                '${p?.displayName ?? 'Player'}, ${isCurrent
                    ? 'writing now'
                    : isDone
                    ? 'clue given'
                    : 'waiting'}',
            child: Opacity(
              opacity: isCurrent || isDone ? 1 : 0.55,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isCurrent ? HushbugColors.accentYellow : Colors.transparent, width: 2),
                        ),
                        child: PlayerAvatar(index: 0, name: p?.displayName ?? '', radius: 15, avatarIndex: p?.avatarIndex),
                      ),
                      if (isDone)
                        const Positioned(
                          right: -2,
                          bottom: -2,
                          child: Icon(Icons.check_circle_rounded, size: 14, color: HushbugColors.civilianEmerald),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 52,
                    child: Text(
                      p?.displayName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _VoteStatus { waiting, voting, submitted }

class _VoteRow extends StatelessWidget {
  const _VoteRow({required this.player, required this.isMe, required this.isTarget, required this.status, this.onTap});
  final OnlineGamePlayer? player;
  final bool isMe;
  final bool isTarget;
  final _VoteStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      _VoteStatus.submitted => ('Voted', HushbugColors.civilianEmerald, Icons.check_circle_rounded),
      _VoteStatus.voting => ('Voting now', HushbugColors.accentYellow, Icons.edit_rounded),
      _VoteStatus.waiting => ('Waiting', HushbugColors.textMuted, Icons.hourglass_empty_rounded),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isTarget ? HushbugColors.neonPurple.withValues(alpha: 0.35) : HushbugColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isTarget ? HushbugColors.accentYellow : HushbugColors.cardBorder, width: isTarget ? 2 : 1),
            ),
            child: Row(
              children: [
                VoiceAvatar(
                  playerId: player?.playerId ?? '',
                  child: PlayerAvatar(index: 0, name: player?.displayName ?? '', radius: 16, avatarIndex: player?.avatarIndex),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isMe ? '${player?.displayName ?? ''} (You)' : player?.displayName ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: onTap == null && !isMe ? Colors.white70 : Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                AnimatedSwitcher(
                  duration: motionDuration(context, 180),
                  transitionBuilder: (child, a) => FadeTransition(
                    opacity: a,
                    child: ScaleTransition(
                      scale: Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: a, curve: easeOutStrong)),
                      child: child,
                    ),
                  ),
                  child: Row(
                    key: ValueKey(status),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 15, color: color),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
