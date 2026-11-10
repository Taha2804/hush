import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/game_controller.dart';
import '../../app/providers.dart';
import '../../app/services.dart';
import '../../domain/game_engine.dart';
import '../../domain/models/game_config.dart';
import '../../domain/vote_resolver.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import '../widgets/visuals.dart';

class PlayScreen extends ConsumerStatefulWidget {
  const PlayScreen({super.key});

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> {
  @override
  void initState() {
    super.initState();
    SecureScreen.set(true);
  }

  @override
  void dispose() {
    SecureScreen.set(false);
    super.dispose();
  }

  Future<void> _leave() async {
    final l = context.l10n;
    final round = ref.read(gameProvider).round;
    if (round != null && round.phase != GamePhase.result) {
      final ok = await confirmDialog(context, title: l.leaveGameTitle, body: l.leaveGameBody, action: l.leave);
      if (!ok || !mounted) return;
    }
    ref.read(gameProvider.notifier).endGame();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameProvider);
    final round = session.round;
    final l = context.l10n;

    ref.listen(gameProvider.select((s) => s.notice), (_, n) {
      if (n != null && mounted) {
        toast(context, noticeText(context, n));
        ref.read(gameProvider.notifier).clearNotice();
      }
    });

    if (round == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: HushbugColors.scaffoldGradient),
          child: Center(child: session.loading ? const CircularProgressIndicator(color: HushbugColors.neonPurpleLight) : Text(l.noticeNoWords)),
        ),
      );
    }

    final view = switch (round.phase) {
      GamePhase.reveal => RevealView(key: ValueKey('reveal-${round.revealIndex}'), round: round),
      GamePhase.clue => ClueView(round: round),
      GamePhase.discussion => DiscussionView(key: ValueKey('disc-${round.eliminated.length}'), round: round),
      GamePhase.vote => VoteView(key: ValueKey('vote-${round.eliminated.length}-${round.revotes}'), round: round),
      GamePhase.lastChance => LastChanceView(round: round),
      GamePhase.result => ResultView(round: round, onExit: _leave),
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): _leave},
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: HushbugColors.scaffoldGradient),
            child: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(key: ValueKey(round.phase), child: view),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// 1. REVEAL VIEW (Prototypes stitch_flutter_imposter_party_game & (2))
// ======================================================================

class RevealView extends ConsumerStatefulWidget {
  const RevealView({super.key, required this.round});
  final RoundState round;

  @override
  ConsumerState<RevealView> createState() => _RevealViewState();
}

class _RevealViewState extends ConsumerState<RevealView> with SingleTickerProviderStateMixin {
  /// Whether the secret dossier is currently revealed
  bool _showing = false;

  /// Global touch tracking: pointer ID that initiated the hold
  int? _activePointerId;

  /// Animation controller for Hushbug opening/closing eyes and secret card reveal
  late final AnimationController _revealAnimCtrl;
  late final Animation<double> _eyeOpenAnim;
  late final Animation<double> _cardRevealAnim;

  bool get _seen => widget.round.revealSeen;

  @override
  void initState() {
    super.initState();
    // Eye opening: 300ms, closing: 180ms
    _revealAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _eyeOpenAnim = CurvedAnimation(
      parent: _revealAnimCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInQuad,
    );

    _cardRevealAnim = CurvedAnimation(
      parent: _revealAnimCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInQuad,
    );
  }

  @override
  void dispose() {
    _revealAnimCtrl.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_seen) return;
    // Only accept touch if no active pointer is already holding
    if (_activePointerId == null) {
      _activePointerId = event.pointer;
      _startReveal();
    }
  }

  void _onGlobalPointerUp(PointerUpEvent event) {
    if (_activePointerId == event.pointer) {
      _activePointerId = null;
      _endReveal();
    }
  }

  void _onGlobalPointerCancel(PointerCancelEvent event) {
    if (_activePointerId == event.pointer) {
      _activePointerId = null;
      _endReveal();
    }
  }

  void _startReveal() {
    if (_showing) return;
    setState(() => _showing = true);
    _revealAnimCtrl.forward();
    final s = ref.read(settingsProvider);
    ref.read(soundProvider).play('reveal', enabled: s.sound);
    Haptics.tick(enabled: s.haptics);
  }

  void _endReveal() {
    if (!_showing) return;
    setState(() => _showing = false);
    _revealAnimCtrl.reverse();
    ref.read(gameProvider.notifier).markRevealed();
    Haptics.tick(enabled: ref.read(settingsProvider).haptics);
  }

  void _next() {
    if (_seen && !_showing) ref.read(gameProvider.notifier).nextReveal();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.round;
    final player = r.players[r.revealIndex];
    final card = ref.read(gameProvider.notifier).engine.cardFor(r, r.revealIndex);

    // Global Listener wraps the full screen to track pointer lift anywhere
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerUp: _onGlobalPointerUp,
      onPointerCancel: _onGlobalPointerCancel,
      child: Column(
        children: [
          // Top Pass Prompt Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: HushbugColors.cardSurface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: HushbugColors.neonPurple.withValues(alpha: 0.4), width: 1.2),
                boxShadow: [
                  BoxShadow(color: HushbugColors.neonPurple.withValues(alpha: 0.2), blurRadius: 16),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [HushbugColors.accentYellow, HushbugColors.neonPurpleLight]),
                            ),
                            child: PlayerAvatar(index: r.revealIndex, name: player, radius: 18),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: HushbugColors.civilianEmerald,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PASS DEVICE TO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: HushbugColors.textSubtext,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                player,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: HushbugColors.neonPurple.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: HushbugColors.neonPurpleLight.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  'Turn #${r.revealIndex + 1}',
                                  style: const TextStyle(color: HushbugColors.neonPurpleLight, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Turn Dots
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Player ${r.revealIndex + 1} of ${r.playerCount}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: HushbugColors.textSubtext),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          for (var i = 0; i < r.playerCount; i++)
                            Container(
                              margin: const EdgeInsets.only(left: 3),
                              width: i == r.revealIndex ? 16 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: i < r.revealIndex
                                    ? HushbugColors.civilianEmerald
                                    : i == r.revealIndex
                                        ? HushbugColors.accentYellow
                                        : const Color(0xFF332C47),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Strictly Confidential Badge
          Container(
            margin: const EdgeInsets.only(top: 2, bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: HushbugColors.cardSurface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: HushbugColors.cardBorder, width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3, backgroundColor: HushbugColors.accentYellow),
                SizedBox(width: 8),
                Text(
                  'STRICTLY CONFIDENTIAL',
                  style: TextStyle(color: HushbugColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                ),
              ],
            ),
          ),

          // Central Secret Card Stage with Mascot Peeking Integration
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _revealAnimCtrl,
                builder: (context, _) {
                  return _buildInteractiveCard(card, r);
                },
              ),
            ),
          ),

          // Status & Helper Instruction below card
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _showing ? HushbugColors.imposterRed : HushbugColors.neonPurpleLight,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _showing
                      ? 'Peeking at your secret role! [Release to re-mask]'
                      : (_seen
                          ? 'Dossier checked! Pass device to next player.'
                          : 'Hold Space or Touch sensor to reveal'),
                  style: TextStyle(
                    color: _showing ? HushbugColors.imposterRed : HushbugColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Footer Action & Security Compliance Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              children: [
                TactileButton(
                  onPressed: _seen && !_showing ? _next : null,
                  style: TactileButtonStyle.golden,
                  height: 50,
                  icon: const Icon(Icons.lock_rounded, color: HushbugColors.onAccentYellow, size: 20),
                  child: Text('Ready? Lock & Pass (${r.revealIndex + 1} / ${r.playerCount})'),
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_rounded, color: Color(0xFF34D399), size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Android FLAG_SECURE Active - Screenshots Blocked',
                      style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive Card with integrated Peeking Hushbug Mascot at bottom edge
  Widget _buildInteractiveCard(RoleCard card, RoundState r) {
    final isImp = card.showsImposter;
    final progress = _cardRevealAnim.value;
    final eyeProgress = _eyeOpenAnim.value;

    // Card dimensions
    const cardWidth = 320.0;
    const cardHeight = 390.0;

    return SizedBox(
      width: cardWidth,
      height: cardHeight + 40, // Extra space at bottom for peeking mascot
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 1. The Main Secret Card
          Container(
            width: cardWidth,
            height: cardHeight,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            decoration: BoxDecoration(
              color: progress > 0.05
                  ? Color.lerp(const Color(0xFF1E1733), isImp ? const Color(0xFF2B1124) : const Color(0xFF132822), progress)
                  : const Color(0xFF1E1733),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: progress > 0.05
                    ? Color.lerp(
                        HushbugColors.neonPurpleLight.withValues(alpha: 0.7),
                        isImp ? HushbugColors.imposterRed : HushbugColors.civilianEmerald,
                        progress,
                      )!
                    : HushbugColors.neonPurpleLight.withValues(alpha: 0.7),
                width: 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (progress > 0.05
                          ? (isImp ? HushbugColors.imposterRed : HushbugColors.civilianEmerald)
                          : HushbugColors.neonPurple)
                      .withValues(alpha: 0.4 + (0.2 * progress)),
                  blurRadius: 28 + (10 * progress),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Unrevealed / Encrypted Card Face
                Opacity(
                  opacity: (1.0 - (progress * 1.5)).clamp(0.0, 1.0),
                  child: IgnorePointer(
                    ignoring: progress > 0.1,
                    child: _buildEncryptedCardContent(r),
                  ),
                ),

                // Revealed Secret Role / Word Face (Only mounted when visible for privacy)
                if (progress > 0.02)
                  Opacity(
                    opacity: progress,
                    child: _buildRevealedDossierContent(card, r, isImp),
                  ),
              ],
            ),
          ),

          // 2. Hushbug Mascot Peeking over the bottom edge of the card
          // Bottom alignment ensures hands rest exactly on the lower edge/surface
          Positioned(
            bottom: 6,
            child: CardPeekingMascot(
              width: 104,
              height: 76,
              eyesOpenProgress: eyeProgress,
              isDetective: card.showsImposter,
            ),
          ),

          // 3. Touch Initiator Listener (Transparent overlay covering the reveal sensor area)
          // When touch begins here, _activePointerId is recorded.
          // Once recorded, finger can move anywhere on screen and reveal persists until pointer-up.
          if (!_seen && !_showing)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 40,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _onPointerDown,
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );
  }

  /// Encrypted Front Card Content
  Widget _buildEncryptedCardContent(RoundState r) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top Card Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2E1955),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: HushbugColors.neonPurpleLight.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_rounded, size: 12, color: HushbugColors.accentYellow),
                  SizedBox(width: 5),
                  Text('ENCRYPTED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const Text('HUSH PROTOCOL', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),

        // Central Icon & Instruction
        Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HushbugColors.neonPurple.withValues(alpha: 0.25),
                border: Border.all(color: HushbugColors.neonPurpleLight.withValues(alpha: 0.6), width: 1.5),
              ),
              child: const Center(
                child: Icon(Icons.masks_rounded, size: 40, color: HushbugColors.neonPurpleLight),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hold to Reveal',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your Secret Word',
              style: TextStyle(fontSize: 13, color: HushbugColors.textSubtext, fontWeight: FontWeight.w600),
            ),
          ],
        ),

        // Biometric Touch & Press Sensor
        const Column(
          children: [
            BiometricSensor(size: 54),
            SizedBox(height: 4),
            Text(
              'Touch & Press Sensor',
              style: TextStyle(color: HushbugColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ),

        // Spacing for mascot resting at bottom
        const SizedBox(height: 20),
      ],
    );
  }

  /// Revealed Secret Role / Word Dossier Content
  Widget _buildRevealedDossierContent(RoleCard card, RoundState r, bool isImp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Dossier Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isImp ? const Color(0x33EF4444) : const Color(0x3310B981),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: isImp ? HushbugColors.imposterRed : HushbugColors.civilianEmerald),
              ),
              child: Text(
                isImp ? 'TOP SECRET DISCLOSURE' : 'CONFIDENTIAL DOSSIER',
                style: TextStyle(
                  color: isImp ? HushbugColors.imposterRed : const Color(0xFF34D399),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Text(
              'DO NOT SHARE',
              style: TextStyle(color: HushbugColors.imposterRed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),

        // Assigned Identity
        Column(
          children: [
            Text(
              'YOUR ASSIGNED IDENTITY',
              style: TextStyle(
                color: isImp ? const Color(0xFFFCA5A5) : const Color(0xFFA7F3D0),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isImp ? HushbugColors.imposterRed.withValues(alpha: 0.2) : HushbugColors.civilianEmerald.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isImp ? HushbugColors.imposterRed : HushbugColors.civilianEmerald,
                  width: 2,
                ),
              ),
              child: Text(
                isImp ? 'ROLE: IMPOSTER' : 'ROLE: CIVILIAN',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isImp ? HushbugColors.imposterRed : const Color(0xFF34D399),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isImp ? 'You do not know the actual secret word. Blend in!' : 'Civilians hold the true secret word.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 11),
            ),
          ],
        ),

        // Clue / Word Panel (Prominently displayed)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: isImp
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (card.word != null) ...[
                      const Text('ASSIGNED COUNTER-WORD:', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 9, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(card.word!, style: const TextStyle(color: HushbugColors.accentYellow, fontSize: 18, fontWeight: FontWeight.w900)),
                      const Divider(color: Colors.white24, height: 12),
                    ],
                    if (card.hint != null) ...[
                      const Text('TIER 1 HINT CLUE:', style: TextStyle(color: Color(0xFF34D399), fontSize: 9, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('"${card.hint}"', style: const TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                    if (card.partners.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Partners: ${card.partners.map((i) => r.players[i]).join(', ')}',
                        style: const TextStyle(color: HushbugColors.imposterRed, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                )
              : Column(
                  children: [
                    const Text('SECRET WORD', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                    const SizedBox(height: 4),
                    Text(
                      card.word ?? r.word,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: HushbugColors.accentYellow,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
        ),

        // Privacy note
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_clock_rounded, size: 12, color: HushbugColors.textMuted),
            SizedBox(width: 4),
            Text(
              'RELEASE HOLD TO RE-MASK IMMEDIATELY',
              style: TextStyle(color: HushbugColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
          ],
        ),

        // Spacing for mascot at bottom
        const SizedBox(height: 20),
      ],
    );
  }
}

// ======================================================================
// 2. CLUES VIEW (Suspense roulette + Turn Order)
// ======================================================================

class ClueView extends ConsumerStatefulWidget {
  const ClueView({super.key, required this.round});
  final RoundState round;

  @override
  ConsumerState<ClueView> createState() => _ClueViewState();
}

class _ClueViewState extends ConsumerState<ClueView> {
  bool _spinning = true;
  int _spinIndex = 0;
  Timer? _spinTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRoulette());
  }

  void _startRoulette() {
    final n = widget.round.playerCount;
    final steps = 14 + n;
    var step = 0;
    void tick() {
      if (!mounted) return;
      step++;
      final remaining = steps - step;
      setState(() => _spinIndex = (widget.round.starter - remaining) % n);
      if (remaining <= 0) {
        setState(() {
          _spinning = false;
          _spinIndex = widget.round.starter;
        });
        Haptics.tick(enabled: ref.read(settingsProvider).haptics);
        return;
      }
      _spinTimer = Timer(Duration(milliseconds: 45 + (step * step * 1.6).round()), tick);
    }

    tick();
  }

  void _next() {
    if (_spinning) return;
    ref.read(gameProvider.notifier).nextClue();
  }

  @override
  void dispose() {
    _spinTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(gameProvider).round ?? widget.round;
    if (r.phase != GamePhase.clue) return const SizedBox.shrink();

    if (_spinning) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascot(size: 110, mood: MascotMood.suspicious),
            const SizedBox(height: 20),
            const Text('Picking starting player...', style: TextStyle(fontSize: 16, color: HushbugColors.textSubtext)),
            const SizedBox(height: 12),
            Text(
              r.players[_spinIndex],
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: HushbugColors.accentYellow),
            ),
          ],
        ),
      );
    }

    final current = r.currentCluePlayer;
    final posInRound = r.clueStep % r.turnOrder.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Header info
          Text(
            'Round ${r.currentClueRound} of ${r.config.clueRounds}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: HushbugColors.textSubtext),
          ),
          const SizedBox(height: 6),
          Text(
            '${r.players[current]} says ONE word',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 14),

          // Speaking highlight card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HushbugColors.cardSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: HushbugColors.cardBorderActive, width: 2),
              boxShadow: [
                BoxShadow(color: HushbugColors.neonPurple.withValues(alpha: 0.3), blurRadius: 16),
              ],
            ),
            child: Row(
              children: [
                PlayerAvatar(index: current, name: r.players[current], radius: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            r.players[current],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: HushbugColors.neonPurple.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: HushbugColors.neonPurpleLight),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SoundwaveIndicator(),
                                SizedBox(width: 5),
                                Text('SPEAKING', style: TextStyle(color: HushbugColors.accentYellow, fontSize: 9, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Clue #${posInRound + 1}', style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Turn order list
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HushbugColors.cardSurface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: HushbugColors.cardBorder),
              ),
              child: ListView.builder(
                itemCount: r.turnOrder.length,
                itemBuilder: (context, i) {
                  final pIdx = r.turnOrder[i];
                  final isDone = i < posInRound;
                  final isCurrent = i == posInRound;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCurrent ? const Color(0xFF281C4F) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: isCurrent ? Border.all(color: HushbugColors.cardBorderActive) : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            PlayerAvatar(index: pIdx, name: r.players[pIdx], radius: 14),
                            const SizedBox(width: 12),
                            Text(
                              r.players[pIdx],
                              style: TextStyle(
                                color: isCurrent ? Colors.white : (isDone ? HushbugColors.textMuted : HushbugColors.textSecondary),
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (isDone)
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18)
                        else if (isCurrent)
                          const SoundwaveIndicator(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Next speaker CTA
          TactileButton(
            onPressed: _next,
            style: TactileButtonStyle.neonPurple,
            child: const Text('Next Speaker'),
          ),
          TextButton(
            onPressed: () => ref.read(gameProvider.notifier).skipToDiscussion(),
            child: const Text('Skip to Discussion', style: TextStyle(color: HushbugColors.textSubtext)),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// 3. DISCUSSION VIEW (Prototype stitch_flutter_imposter_party_game (4))
// ======================================================================

class DiscussionView extends ConsumerStatefulWidget {
  const DiscussionView({super.key, required this.round});
  final RoundState round;

  @override
  ConsumerState<DiscussionView> createState() => _DiscussionViewState();
}

class _DiscussionViewState extends ConsumerState<DiscussionView> {
  int _secondsRemaining = 180;
  int _totalSeconds = 180;
  Timer? _ticker;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    final secs = widget.round.config.discussionSeconds;
    _secondsRemaining = secs > 0 ? secs : 180;
    _totalSeconds = _secondsRemaining;
    _startTimer();
  }

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isPaused && _secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
        if (_secondsRemaining == 0) {
          final s = ref.read(settingsProvider);
          ref.read(soundProvider).play('timeup', enabled: s.sound);
          Haptics.buzz(enabled: s.haptics);
        }
      }
    });
  }

  void _togglePause() => setState(() => _isPaused = !_isPaused);

  void _add30s() {
    setState(() {
      _secondsRemaining += 30;
      if (_secondsRemaining > _totalSeconds) _totalSeconds = _secondsRemaining;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _vote() => ref.read(gameProvider.notifier).startVote();

  @override
  Widget build(BuildContext context) {
    final r = widget.round;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              const Column(
                children: [
                  Text('Round 2 of 3', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text('DISCUSSION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: HushbugColors.neonPurpleLight)),
                ],
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),

          // Timer Dial with Peeking Mascot
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircularTimerDial(
                secondsRemaining: _secondsRemaining,
                totalSeconds: _totalSeconds,
                isPaused: _isPaused,
                onPauseToggle: _togglePause,
                onAdd30s: _add30s,
              ),
              const Positioned(
                right: -10,
                top: 0,
                child: PeekingCornerMascot(width: 60, height: 40),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Clues this round section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CLUES THIS ROUND', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11, fontWeight: FontWeight.w800)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF281C4F), borderRadius: BorderRadius.circular(10)),
                child: Text('${r.alive.length} Players Alive', style: const TextStyle(color: HushbugColors.neonPurpleLight, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Players Clue List
          Expanded(
            child: ListView.builder(
              itemCount: r.alive.length,
              itemBuilder: (context, i) {
                final pIdx = r.alive[i];
                final isSpeaking = i == 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSpeaking ? const Color(0xFF281C4F) : HushbugColors.cardSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSpeaking ? HushbugColors.cardBorderActive : HushbugColors.cardBorder,
                      width: isSpeaking ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          PlayerAvatar(index: pIdx, name: r.players[pIdx], radius: 18),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.players[pIdx], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Clue #${i + 1}', style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1733),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: HushbugColors.cardBorder),
                        ),
                        child: Text(
                          'Turn ${i + 1}',
                          style: const TextStyle(color: HushbugColors.accentYellow, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Accuse link & Next: Vote CTA
          TextButton.icon(
            onPressed: _vote,
            icon: const Icon(Icons.warning_amber_rounded, color: HushbugColors.accentYellow, size: 16),
            label: const Text('Suspect someone already? Tap to Vote', style: TextStyle(color: HushbugColors.accentYellow, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          TactileButton(
            onPressed: _vote,
            style: TactileButtonStyle.neonPurple,
            child: const Text('Next: Vote'),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// 4. VOTE VIEW (Prototype stitch_flutter_imposter_party_game (5))
// ======================================================================

class VoteView extends ConsumerStatefulWidget {
  const VoteView({super.key, required this.round});
  final RoundState round;

  @override
  ConsumerState<VoteView> createState() => _VoteViewState();
}

class _VoteViewState extends ConsumerState<VoteView> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(gameProvider).round ?? widget.round;
    if (r.phase != GamePhase.vote) return const SizedBox.shrink();

    final options = [
      for (final p in r.candidates) p,
      if (r.config.maybeNobody) noImposterVote,
    ];

    void confirm() {
      if (_selected == null) return;
      ref.read(gameProvider.notifier).chooseTarget(_selected!);
      setState(() => _selected = null);
    }

    return Stack(
      children: [
        // Peeking Detective Mascot at bottom-right
        const Positioned(
          right: -10,
          bottom: 70,
          child: IgnorePointer(
            child: Mascot(
              size: 160,
              mood: MascotMood.detective,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Vote to Eliminate',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Who do you think is an imposter?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: HushbugColors.textSubtext, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              // Player Voting Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: options.length,
                  itemBuilder: (context, i) {
                    final target = options[i];
                    final isSelected = _selected == target;
                    final name = target == noImposterVote ? 'No Imposter' : r.players[target];

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _selected = target),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2C2445) : HushbugColors.cardSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? HushbugColors.accentYellow : HushbugColors.cardBorder,
                              width: isSelected ? 2.5 : 1.2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    const BoxShadow(color: Color(0x66FFC107), blurRadius: 18),
                                  ]
                                : [],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (target == noImposterVote)
                                    const CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Color(0xFF2E1955),
                                      child: Icon(Icons.do_not_disturb_on_rounded, color: Colors.white, size: 28),
                                    )
                                  else
                                    PlayerAvatar(index: target, name: name, radius: 22),
                                  const SizedBox(height: 8),
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isSelected ? HushbugColors.accentYellow : Colors.white,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              if (isSelected)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: HushbugColors.accentYellow,
                                    ),
                                    child: const Icon(Icons.check, size: 14, color: Colors.black),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Votes counter / progress bar
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Votes: ${_selected != null ? 1 : 0} / 1',
                      style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _selected != null ? 1.0 : 0.0,
                        backgroundColor: const Color(0xFF231D36),
                        valueColor: const AlwaysStoppedAnimation(HushbugColors.neonPurple),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),

              // Cast Vote CTA
              TactileButton(
                onPressed: _selected == null ? null : confirm,
                style: TactileButtonStyle.golden,
                child: const Text('Cast Vote'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// 5. LAST CHANCE VIEW (Imposter guess steal)
// ======================================================================

class LastChanceView extends ConsumerStatefulWidget {
  const LastChanceView({super.key, required this.round});
  final RoundState round;

  @override
  ConsumerState<LastChanceView> createState() => _LastChanceViewState();
}

class _LastChanceViewState extends ConsumerState<LastChanceView> {
  final _guess = TextEditingController();

  @override
  void dispose() {
    _guess.dispose();
    super.dispose();
  }

  void _submit({bool? accepted}) => ref.read(gameProvider.notifier).submitGuess(_guess.text, accepted: accepted);

  @override
  Widget build(BuildContext context) {
    final r = widget.round;
    final names = r.imposters.map((i) => r.players[i]).join(', ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: Mascot(size: 96, mood: MascotMood.suspicious)),
          const SizedBox(height: 16),
          Text(names, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 6),
          const Text(
            'Imposters caught! Last chance to guess the secret word and steal the victory!',
            textAlign: TextAlign.center,
            style: TextStyle(color: HushbugColors.textSubtext, fontSize: 13),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _guess,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(labelText: 'Secret Word Guess'),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          TactileButton(
            onPressed: () => _submit(),
            style: TactileButtonStyle.golden,
            child: const Text('Submit Guess'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _submit(accepted: true),
            child: const Text('Group Accepts (Close enough!)'),
          ),
          TextButton(
            onPressed: () => _submit(accepted: false),
            child: const Text('Give up', style: TextStyle(color: HushbugColors.textMuted)),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// 6. RESULT VIEW (Prototype stitch_flutter_imposter_party_game (6))
// ======================================================================

class ResultView extends ConsumerStatefulWidget {
  const ResultView({super.key, required this.round, required this.onExit});
  final RoundState round;
  final VoidCallback onExit;

  @override
  ConsumerState<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends ConsumerState<ResultView> {
  @override
  void initState() {
    super.initState();
    SecureScreen.set(false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(settingsProvider);
      final crew = widget.round.winner == Winner.crew;
      ref.read(soundProvider).play(crew ? 'win' : 'lose', enabled: s.sound);
      Haptics.buzz(enabled: s.haptics);
    });
  }

  Future<void> _again() async {
    final ok = await ref.read(gameProvider.notifier).startRound();
    if (ok) SecureScreen.set(true);
    if (!ok && mounted) toast(context, context.l10n.noticeNoWords);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.round;
    final session = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);

    final isCrewWin = r.winner == Winner.crew;
    final title = isCrewWin ? 'IMPOSTER CAUGHT!' : 'IMPOSTERS WIN!';

    return Stack(
      children: [
        // Floating Confetti Overlay
        const Positioned.fill(child: ConfettiOverlay()),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Celebratory Stage with Party Mascot & Ribbon Banner
              Column(
                children: [
                  const Mascot(size: 110, mood: MascotMood.celebrating),
                  const SizedBox(height: 8),
                  RibbonBanner(text: title, isVictory: isCrewWin),
                ],
              ),

              // Imposter Unmasked Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HushbugColors.cardSurface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: HushbugColors.neonPurple.withValues(alpha: 0.4), width: 1.2),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [Colors.purple, Colors.pinkAccent]),
                          ),
                          child: PlayerAvatar(
                            index: r.imposters.isNotEmpty ? r.imposters.first : 0,
                            name: r.imposters.isNotEmpty ? r.players[r.imposters.first] : 'Nobody',
                            radius: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('THE IMPOSTER WAS', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 10, fontWeight: FontWeight.bold)),
                              Text(
                                r.imposters.isEmpty ? 'Nobody (Chaos Round!)' : r.imposters.map((i) => r.players[i]).join(', '),
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: HushbugColors.imposterRed,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text('IMPOSTER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const Divider(color: HushbugColors.cardBorder, height: 24),
                    // Word Comparison
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Secret Word:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0x3310B981),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0x6610B981)),
                          ),
                          child: Text(
                            r.word,
                            style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    if (r.fakeWord != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Fake Word:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0x33EF4444),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0x66EF4444)),
                            ),
                            child: Text(
                              r.fakeWord!,
                              style: const TextStyle(color: Color(0xFFFCA5A5), fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Round Scoreboard Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HushbugColors.cardSurface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: HushbugColors.cardBorder, width: 1.2),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.emoji_events_rounded, color: HushbugColors.accentYellow, size: 18),
                        SizedBox(width: 8),
                        Text('ROUND SCOREBOARD', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < math.min(r.players.length, 3); i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('${i + 1}', style: const TextStyle(color: HushbugColors.accentYellow, fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(width: 10),
                                PlayerAvatar(index: i, name: r.players[i], radius: 12),
                                const SizedBox(width: 8),
                                Text(r.players[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                            Row(
                              children: [
                                Text('${(settings.scores[r.players[i]] ?? 0) * 100} pts', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0x3310B981),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('+${(session.lastDelta[r.players[i]] ?? 0) * 100}', style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Footer: Play Again + Lobby Buttons
              Row(
                children: [
                  Expanded(
                    child: TactileButton(
                      onPressed: session.loading ? null : _again,
                      style: TactileButtonStyle.golden,
                      height: 52,
                      icon: const Icon(Icons.replay_rounded, color: HushbugColors.onAccentYellow, size: 20),
                      child: const Text('Play Again'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TactileButton(
                      onPressed: () {
                        ref.read(gameProvider.notifier).endGame();
                        context.go('/lobby');
                      },
                      style: TactileButtonStyle.secondary,
                      height: 52,
                      icon: const Icon(Icons.home_rounded, color: HushbugColors.neonPurpleLight, size: 20),
                      child: const Text('Lobby'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}