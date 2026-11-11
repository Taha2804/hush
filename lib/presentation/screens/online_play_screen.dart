import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../services/supabase/models.dart';
import '../../services/supabase/multiplayer_providers.dart';
import '../../services/supabase/supabase_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import '../widgets/visuals.dart';

/// Server-authoritative online game screen for Supabase multiplayer rounds.
class OnlinePlayScreen extends ConsumerStatefulWidget {
  const OnlinePlayScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<OnlinePlayScreen> createState() => _OnlinePlayScreenState();
}

class _OnlinePlayScreenState extends ConsumerState<OnlinePlayScreen> with TickerProviderStateMixin {
  // Secret Card Flip & Mascot Eye Animation controllers
  late final AnimationController _cardFlipController;
  late final AnimationController _mascotEyeController;
  late final Animation<double> _cardRotation;
  late final Animation<double> _cardElevation;
  late final Animation<double> _mascotEyeCover;

  int? _activePointerId;
  bool _isCardRevealed = false;
  final TextEditingController _clueController = TextEditingController();
  String? _selectedVoteTargetId;
  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();

    _cardFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _cardRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardFlipController, curve: Curves.easeInOutCubic),
    );
    _cardElevation = Tween<double>(begin: 4.0, end: 16.0).animate(
      CurvedAnimation(parent: _cardFlipController, curve: Curves.easeOut),
    );

    _mascotEyeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _mascotEyeCover = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mascotEyeController, curve: Curves.easeInOutSine),
    );

    // Initialize Online Game Session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onlineGameProvider.notifier).initGame(widget.sessionId);
    });

    // Authoritative Sync Countdown Timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final session = ref.read(onlineGameProvider).session;
      if (session != null && session.phase == 'discussion' && session.discussionEndTime != null) {
        final now = DateTime.now().toUtc();
        final diff = session.discussionEndTime!.toUtc().difference(now).inSeconds;
        setState(() {
          _secondsRemaining = diff > 0 ? diff : 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _cardFlipController.dispose();
    _mascotEyeController.dispose();
    _clueController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_activePointerId != null) return;
    _activePointerId = event.pointer;
    setState(() => _isCardRevealed = true);
    _cardFlipController.forward();
    _mascotEyeController.forward();
    HapticFeedback.mediumImpact();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _activePointerId) return;
    _activePointerId = null;
    setState(() => _isCardRevealed = false);
    _cardFlipController.reverse();
    _mascotEyeController.reverse();
    HapticFeedback.lightImpact();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointerId) return;
    _activePointerId = null;
    setState(() => _isCardRevealed = false);
    _cardFlipController.reverse();
    _mascotEyeController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(onlineGameProvider);
    final lobby = ref.watch(onlineLobbyProvider);
    final session = gameState.session;
    final assignment = gameState.assignment;
    final isHost = lobby.isHost;

    if (session == null || gameState.isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: HushbugColors.scaffoldGradient),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: HushbugColors.accentYellow),
                SizedBox(height: 16),
                Text('Connecting to online game session...', style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: HushbugColors.scaffoldGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar with Phase Tracker & Leave button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'Leave Game',
                      onPressed: () {
                        context.pop();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: HushbugColors.cardSurface.withValues(alpha: 0.8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: HushbugColors.cardBorder, width: 1),
                        ),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                    Column(
                      children: [
                        Text(
                          'ROUND ${session.roundNumber} • ${session.category.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: HushbugColors.accentYellow,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _phaseTitle(session.phase),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: HushbugColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: HushbugColors.cardBorder),
                      ),
                      child: Text(
                        '${gameState.players.where((p) => p.isAlive).length} Alive',
                        style: const TextStyle(color: HushbugColors.civilianEmerald, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Phase Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: switch (session.phase) {
                    'reveal' => _buildRevealPhase(assignment, isHost),
                    'clue' => _buildCluePhase(session, gameState, isHost),
                    'discussion' => _buildDiscussionPhase(session, gameState, isHost),
                    'vote' => _buildVotePhase(session, gameState, isHost),
                    'result' => _buildResultPhase(gameState.result, isHost),
                    _ => _buildRevealPhase(assignment, isHost),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _phaseTitle(String phase) => switch (phase) {
        'reveal' => 'Secret Dossier',
        'clue' => 'Give Your Clue',
        'discussion' => 'Open Discussion',
        'vote' => 'Cast Suspicion Vote',
        'result' => 'Round Results',
        _ => phase.toUpperCase(),
      };

  // 1. REVEAL PHASE
  Widget _buildRevealPhase(OnlinePrivateAssignment? assignment, bool isHost) {
    final word = assignment?.word ?? 'Loading...';
    final isImposter = assignment?.isImposter ?? false;
    final hint = assignment?.hint;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Hold to secretly peek at your dossier. Release to conceal.',
          textAlign: TextAlign.center,
          style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12),
        ),

        // Secret Card with 3D Flip
        Listener(
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: AnimatedBuilder(
            animation: _cardFlipController,
            builder: (context, child) {
              final angle = _cardRotation.value * 3.1415926535;
              final isUnder = angle > 1.5707963268;

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateY(angle),
                alignment: Alignment.center,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 320, minHeight: 280),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isUnder ? const Color(0xFF22173F) : HushbugColors.cardSurface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isUnder ? HushbugColors.neonPurpleLight : HushbugColors.cardBorder,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUnder ? HushbugColors.neonPurple.withValues(alpha: 0.4) : const Color(0x33000000),
                        blurRadius: _cardElevation.value,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: isUnder
                      ? Transform(
                          transform: Matrix4.identity()..rotateY(3.1415926535),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isImposter ? Icons.masks_rounded : Icons.lock_open_rounded,
                                color: isImposter ? HushbugColors.imposterRed : HushbugColors.accentYellow,
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                isImposter ? 'SECRET ROLE' : 'YOUR WORD',
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
                                  color: isImposter ? HushbugColors.imposterRed : Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (hint != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Hint: $hint',
                                    style: const TextStyle(color: HushbugColors.accentYellow, fontSize: 12),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fingerprint_rounded, color: HushbugColors.neonPurpleLight, size: 54),
                            const SizedBox(height: 14),
                            const Text(
                              'Hold to Reveal',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Touch and hold anywhere on the card',
                              style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        ),

        // Mascot with animated eye cover
        AnimatedBuilder(
          animation: _mascotEyeController,
          builder: (context, child) {
            return Mascot(
              size: 110,
              mood: _isCardRevealed ? MascotMood.peeking : MascotMood.sleeping,
            );
          },
        ),

        // Host Advance CTA
        if (isHost)
          TactileButton(
            onPressed: () => ref.read(onlineGameProvider.notifier).advancePhase('clue'),
            style: TactileButtonStyle.golden,
            height: 52,
            icon: const Icon(Icons.play_arrow_rounded, color: HushbugColors.onAccentYellow, size: 22),
            child: const Text('Start Clue Round'),
          )
        else
          const Text(
            'Waiting for Host to start the Clue Round...',
            style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12),
          ),
      ],
    );
  }

  // 2. CLUE PHASE
  Widget _buildCluePhase(OnlineGameSession session, OnlineGameState gameState, bool isHost) {
    final isMyTurn = gameState.isMyClueTurn;
    final currentSpeakerId = gameState.currentCluePlayerId;
    final speaker = gameState.players.where((p) => p.playerId == currentSpeakerId).firstOrNull;

    return Column(
      children: [
        // Speaker Indicator Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isMyTurn ? HushbugColors.neonPurple.withValues(alpha: 0.3) : HushbugColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMyTurn ? HushbugColors.accentYellow : HushbugColors.cardBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              PlayerAvatar(index: 0, name: speaker?.displayName ?? 'Player', radius: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMyTurn ? "IT'S YOUR TURN TO SPEAK!" : "${speaker?.displayName ?? 'Player'}'s Turn",
                      style: TextStyle(
                        color: isMyTurn ? HushbugColors.accentYellow : Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const Text('Give a one-word or short clue relating to your word.', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Clue Stream Log
        Expanded(
          child: gameState.clues.isEmpty
              ? const Center(
                  child: Text('No clues submitted yet this round.', style: TextStyle(color: HushbugColors.textMuted, fontSize: 13)),
                )
              : ListView.builder(
                  itemCount: gameState.clues.length,
                  itemBuilder: (context, i) {
                    final c = gameState.clues[i];
                    final p = gameState.players.where((pl) => pl.playerId == c.playerId).firstOrNull;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: HushbugColors.cardSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: HushbugColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          PlayerAvatar(index: i, name: p?.displayName ?? 'P', radius: 12),
                          const SizedBox(width: 10),
                          Text('${p?.displayName ?? 'Player'}:', style: const TextStyle(color: HushbugColors.neonPurpleLight, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(c.clueText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Input or Advance Action
        if (isMyTurn) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _clueController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your clue...',
                    hintStyle: const TextStyle(color: HushbugColors.textMuted),
                    filled: true,
                    fillColor: HushbugColors.cardSurface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TactileButton(
                onPressed: () {
                  final text = _clueController.text.trim();
                  if (text.isEmpty) return;
                  ref.read(onlineGameProvider.notifier).submitClue(text);
                  _clueController.clear();
                },
                style: TactileButtonStyle.golden,
                height: 48,
                child: const Text('Send'),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],

        if (isHost)
          TactileButton(
            onPressed: () => ref.read(onlineGameProvider.notifier).advancePhase('discussion'),
            style: TactileButtonStyle.neonPurple,
            height: 48,
            child: const Text('Move to Discussion'),
          ),
      ],
    );
  }

  // 3. DISCUSSION PHASE (Synchronized Authoritative Timer)
  Widget _buildDiscussionPhase(OnlineGameSession session, OnlineGameState gameState, bool isHost) {
    final mins = _secondsRemaining ~/ 60;
    final secs = _secondsRemaining % 60;
    final timeFormatted = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Synchronized Timer Clock
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: HushbugColors.cardSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: HushbugColors.neonPurpleLight.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(color: HushbugColors.neonPurple.withValues(alpha: 0.2), blurRadius: 16),
            ],
          ),
          child: Column(
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_rounded, color: HushbugColors.accentYellow, size: 20),
                  SizedBox(width: 8),
                  Text('DISCUSSION COUNTDOWN', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                timeFormatted,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              const Text('Debate clues and identify suspicious behavior!', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12)),
            ],
          ),
        ),

        // Live Players Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: GridView.builder(
              itemCount: gameState.players.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, i) {
                final p = gameState.players[i];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: p.isAlive ? HushbugColors.cardSurface : HushbugColors.cardSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: p.isAlive ? HushbugColors.cardBorder : Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      PlayerAvatar(index: i, name: p.displayName, radius: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p.displayName,
                          style: TextStyle(
                            color: p.isAlive ? Colors.white : HushbugColors.textMuted,
                            fontWeight: FontWeight.bold,
                            decoration: p.isAlive ? null : TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Host Advance to Voting CTA
        if (isHost)
          TactileButton(
            onPressed: () => ref.read(onlineGameProvider.notifier).advancePhase('vote'),
            style: TactileButtonStyle.golden,
            height: 52,
            icon: const Icon(Icons.how_to_vote_rounded, color: HushbugColors.onAccentYellow, size: 22),
            child: const Text('Proceed to Voting'),
          )
        else
          const Text('Host will call for voting when discussion completes.', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12)),
      ],
    );
  }

  // 4. VOTING PHASE
  Widget _buildVotePhase(OnlineGameSession session, OnlineGameState gameState, bool isHost) {
    final alivePlayers = gameState.players.where((p) => p.isAlive).toList();
    final myUid = SupabaseService.currentUserId;
    final isAlive = gameState.players.any((p) => p.playerId == myUid && p.isAlive);

    return Column(
      children: [
        const Text(
          'Select the player you suspect is the IMPOSTER.',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: ListView.builder(
            itemCount: alivePlayers.length,
            itemBuilder: (context, i) {
              final p = alivePlayers[i];
              final isMe = p.playerId == myUid;
              final isSelected = _selectedVoteTargetId == p.playerId;

              return InkWell(
                onTap: isMe || !isAlive
                    ? null
                    : () {
                        setState(() => _selectedVoteTargetId = p.playerId);
                        ref.read(onlineGameProvider.notifier).castVote(p.playerId);
                        HapticFeedback.selectionClick();
                      },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? HushbugColors.neonPurple.withValues(alpha: 0.4) : HushbugColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? HushbugColors.accentYellow : HushbugColors.cardBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      PlayerAvatar(index: i, name: p.displayName, radius: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isMe ? '${p.displayName} (You)' : p.displayName,
                          style: TextStyle(
                            color: isMe ? HushbugColors.textSubtext : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: HushbugColors.accentYellow, size: 22),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Host Tally Votes Action
        if (isHost)
          TactileButton(
            onPressed: () => ref.read(onlineGameProvider.notifier).tallyVotes(),
            style: TactileButtonStyle.golden,
            height: 52,
            icon: const Icon(Icons.gavel_rounded, color: HushbugColors.onAccentYellow, size: 22),
            child: const Text('Tally Votes & Reveal'),
          ),
      ],
    );
  }

  // 5. RESULT PHASE
  Widget _buildResultPhase(OnlineResult? result, bool isHost) {
    final winner = result?.winner ?? 'crew';
    final isCrewWin = winner == 'crew';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Mascot(
          size: 110,
          mood: isCrewWin ? MascotMood.celebrating : MascotMood.detective,
        ),
        const SizedBox(height: 16),
        Text(
          isCrewWin ? 'CREW VICTORY!' : 'IMPOSTER WON!',
          style: TextStyle(
            color: isCrewWin ? HushbugColors.civilianEmerald : HushbugColors.imposterRed,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Secret Word: ${result?.secretWord ?? '—'}',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TactileButton(
          onPressed: () {
            context.pop();
          },
          style: TactileButtonStyle.neonPurple,
          height: 52,
          child: const Text('Return to Lobby'),
        ),
      ],
    );
  }
}
