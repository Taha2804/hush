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
      GamePhase.reveal => RevealView(key: ValueKey('reveal-${round.revealIndex}'), round: round, onBack: _leave),
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
// 1. REVEAL VIEW (Recreated from Hushbug Secret Card UI Showcase)
// ======================================================================

class RevealView extends ConsumerStatefulWidget {
  const RevealView({super.key, required this.round, this.onBack});
  final RoundState round;
  final VoidCallback? onBack;

  @override
  ConsumerState<RevealView> createState() => _RevealViewState();
}

class _RevealViewState extends ConsumerState<RevealView> with SingleTickerProviderStateMixin {
  /// Whether the secret word is currently actively revealed
  bool _showing = false;

  /// Global touch tracking: pointer ID that initiated the hold
  int? _activePointerId;

  /// Animation controller for 3D card flip & synchronized mascot eye slide
  late final AnimationController _revealAnimCtrl;
  late final Animation<double> _cardFlipAnim;
  late final Animation<double> _eyeOpenAnim;

  final FocusNode _focusNode = FocusNode();

  bool get _seen => widget.round.revealSeen;

  @override
  void initState() {
    super.initState();
    // Card flip & Eye opening: 380ms, quick reverse on release: 180ms
    _revealAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _cardFlipAnim = CurvedAnimation(
      parent: _revealAnimCtrl,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _eyeOpenAnim = CurvedAnimation(
      parent: _revealAnimCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInQuad,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _revealAnimCtrl.dispose();
    super.dispose();
  }

  void _onCardPointerDown(PointerDownEvent event) {
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
    // CRITICAL: Prioritize privacy over animation. Immediately conceal secret word
    setState(() => _showing = false);
    _revealAnimCtrl.reverse();
    ref.read(gameProvider.notifier).markRevealed();
    final s = ref.read(settingsProvider);
    ref.read(soundProvider).play('whoosh', enabled: s.sound);
    Haptics.tick(enabled: s.haptics);
  }

  void _next() {
    if (_seen && !_showing) {
      final s = ref.read(settingsProvider);
      Haptics.tick(enabled: s.haptics);
      ref.read(soundProvider).play('whoosh', enabled: s.sound);
      ref.read(gameProvider.notifier).nextReveal();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.round;
    final card = ref.read(gameProvider.notifier).engine.cardFor(r, r.revealIndex);

    // Global Listener wraps the full screen to track pointer lift anywhere
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.space) {
          if (event is KeyDownEvent) {
            _startReveal();
            return KeyEventResult.handled;
          } else if (event is KeyUpEvent) {
            _endReveal();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerUp: _onGlobalPointerUp,
        onPointerCancel: _onGlobalPointerCancel,
        child: Column(
          children: [
            // 1. Clean Top Bar matching UI showcase
            _buildTopBar(r),

            const SizedBox(height: 6),

            // 2. Center Secret Card Stage + Mascot
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The 3D Flipping Secret Card
                      _buildFlippingCard(card, r),

                      const SizedBox(height: 10),

                      // Hushbug Mascot with synchronized eye animation
                      AnimatedBuilder(
                        animation: _eyeOpenAnim,
                        builder: (context, _) => CardPeekingMascot(
                          width: 126,
                          height: 82,
                          eyesOpenProgress: _eyeOpenAnim.value,
                          isDetective: false, // Strictly neutral for all players
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Helper text from UI showcase
                      const Text(
                        'Hold to Reveal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        '(Hold anywhere on the card)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFA78BFA),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Simplified Pass-to-Next-Player Section
            _buildPassFooter(r),
          ],
        ),
      ),
    );
  }

  /// Top Bar with back button, "Secret Card", "Player X of Y" and progress pills
  Widget _buildTopBar(RoundState r) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
            tooltip: 'Leave game',
          ),

          // Title & Player Progress Indicator
          Column(
            children: [
              const Text(
                'Secret Card',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Player ${r.revealIndex + 1} of ${r.playerCount}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFA78BFA),
                ),
              ),
              const SizedBox(height: 8),
              // Horizontal Turn Indicator Capsules
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < r.playerCount; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 32,
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: i == r.revealIndex
                            ? const Color(0xFFA78BFA)
                            : (i < r.revealIndex
                                ? const Color(0xFF6D28D9)
                                : const Color(0xFF31254A)),
                        boxShadow: i == r.revealIndex
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFA78BFA).withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Invisible anchor for symmetrical centering
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  /// 3D Flipping Card with smooth perspective rotation
  Widget _buildFlippingCard(RoleCard card, RoundState r) {
    const cardWidth = 310.0;
    const cardHeight = 350.0;

    return AnimatedBuilder(
      animation: _cardFlipAnim,
      builder: (context, _) {
        final flipVal = _cardFlipAnim.value; // 0.0 to 1.0
        final angle = flipVal * math.pi;
        final isShowingBack = angle < (math.pi / 2);

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015) // Realistic 3D perspective
            ..rotateY(angle),
          child: isShowingBack
              ? _buildCardBack(cardWidth, cardHeight)
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi), // Compensate flip for front face
                  child: _buildCardFront(card, r, cardWidth, cardHeight),
                ),
        );
      },
    );
  }

  /// Card Back: Fedora hat + shades, "Your Secret Word", biometric fingerprint sensor
  Widget _buildCardBack(double width, double height) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onCardPointerDown,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2B1B54),
              Color(0xFF1B1138),
              Color(0xFF130A28),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFB388FF),
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.5),
              blurRadius: 28,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFFA78BFA).withValues(alpha: 0.25),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 1. Stylish Fedora Hat with Sunglasses Icon (Secret Agent Motif)
            const _SecretAgentIcon(size: 68),

            // 2. Secret Word Label
            const Text(
              'Your Secret Word',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),

            // 3. Biometric Fingerprint Sensor
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E1955).withValues(alpha: 0.5),
                border: Border.all(
                  color: const Color(0xFFA78BFA).withValues(alpha: 0.6),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.fingerprint_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card Front: Cosmic planet with ring, "Your Word" pill, big bold secret word
  /// Note: Card borders & styling are IDENTICAL for imposters & civilians so role is never exposed!
  Widget _buildCardFront(RoleCard card, RoundState r, double width, double height) {
    final isImp = card.showsImposter;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2B1B54),
            Color(0xFF1B1138),
            Color(0xFF130A28),
          ],
        ),
        // Identical purple/lavender glowing border for all players
        border: Border.all(
          color: const Color(0xFFB388FF),
          width: 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.55),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFFA78BFA).withValues(alpha: 0.3),
            blurRadius: 42,
            spreadRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Cosmic Planet with Rings & Sparkles
          const _CosmicPlanetIcon(size: 64),

          // 2. Role / Word Container Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: isImp
                  ? const Color(0xFFEF4444).withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isImp
                    ? const Color(0xFFF87171).withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.2),
                width: 1.2,
              ),
            ),
            child: Text(
              isImp ? 'Role: Imposter' : 'Your Word',
              style: TextStyle(
                color: isImp ? const Color(0xFFFCA5A5) : const Color(0xFFDDD6FE),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),

          // 3. Secret Word Display (or Imposter briefing)
          // Privacy protection: Secret word is strictly masked whenever _showing is false
          if (!isImp) ...[
            Text(
              _showing ? (card.word ?? r.word) : '••••••••',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.6,
                shadows: [
                  Shadow(
                    color: Color(0x66000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Imposter Role assignment & hints
            if (card.word != null) ...[
              Text(
                _showing ? card.word! : '••••••••',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const Text(
                '(Assigned Counter-Word)',
                style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ] else ...[
              Text(
                _showing ? 'IMPOSTER' : '••••••••',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const Text(
                "You don't know the word. Blend in!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFDDD6FE), fontSize: 11),
              ),
            ],
            if (card.hint != null) ...[
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Hint: "${card.hint}"',
                  style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
            ],
            if (card.partners.isNotEmpty) ...[
              Text(
                'Partners: ${card.partners.map((i) => r.players[i]).join(', ')}',
                style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ],

          // 4. Subtle Privacy Guidance
          const Text(
            'Release finger to conceal word immediately',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B7AA8),
            ),
          ),
        ],
      ),
    );
  }

  /// Simplified Pass-to-Next-Player Footer: Single prominent purple pill button
  Widget _buildPassFooter(RoundState r) {
    final isLastPlayer = r.revealIndex + 1 >= r.playerCount;
    final buttonLabel = isLastPlayer
        ? 'Start Game (${r.playerCount} / ${r.playerCount})'
        : 'Next Player (${r.revealIndex + 1} / ${r.playerCount})';
    final isEnabled = _seen && !_showing;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: _ShowcaseNextButton(
        enabled: isEnabled,
        label: buttonLabel,
        onPressed: isEnabled ? _next : null,
      ),
    );
  }
}

/// Prominent purple button matching the UI showcase reference with tactile press & corner sparkle
class _ShowcaseNextButton extends StatefulWidget {
  const _ShowcaseNextButton({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final String label;
  final VoidCallback? onPressed;

  @override
  State<_ShowcaseNextButton> createState() => _ShowcaseNextButtonState();
}

class _ShowcaseNextButtonState extends State<_ShowcaseNextButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: widget.enabled ? 1.0 : 0.45,
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => _pressCtrl.forward() : null,
        onTapUp: widget.enabled
            ? (_) {
                _pressCtrl.reverse();
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: widget.enabled ? () => _pressCtrl.reverse() : null,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(
            scale: _scale.value,
            child: child,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF7C3AED),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFA78BFA).withValues(alpha: 0.6),
                    width: 1.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: widget.enabled ? 0.45 : 0.15),
                      blurRadius: 22,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Corner celebratory sparkle burst (as shown in reference image)
              if (widget.enabled)
                Positioned(
                  top: -6,
                  right: 12,
                  child: CustomPaint(
                    size: const Size(20, 16),
                    painter: _ButtonSparklePainter(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Little golden sparkle rays on the corner of the Next button
class _ButtonSparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFFFD166)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(6, 12), const Offset(2, 4), p);
    canvas.drawLine(const Offset(11, 13), const Offset(11, 2), p);
    canvas.drawLine(const Offset(16, 12), const Offset(20, 4), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stylish Secret Agent Fedora + Sunglasses Icon
class _SecretAgentIcon extends StatelessWidget {
  const _SecretAgentIcon({this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SecretAgentIconPainter(),
      ),
    );
  }
}

class _SecretAgentIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64;
    canvas.save();
    canvas.scale(s);

    final line = Paint()
      ..color = const Color(0xFFDDD6FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = const Color(0xFFDDD6FE).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    // 1. Fedora Crown (with center dent)
    final crown = Path()
      ..moveTo(20, 28)
      ..cubicTo(20, 16, 26, 12, 32, 14)
      ..cubicTo(38, 12, 44, 16, 44, 28)
      ..close();
    canvas.drawPath(crown, fill);
    canvas.drawPath(crown, line);

    // Fedora brim
    final brim = Path()
      ..moveTo(10, 30)
      ..cubicTo(20, 26, 44, 26, 54, 30)
      ..cubicTo(44, 33, 20, 33, 10, 30)
      ..close();
    canvas.drawPath(brim, fill);
    canvas.drawPath(brim, line);

    // Ribbon band
    final band = Path()
      ..moveTo(20, 27)
      ..cubicTo(26, 25, 38, 25, 44, 27);
    canvas.drawPath(band, Paint()..color = const Color(0xFFA78BFA)..style = PaintingStyle.stroke..strokeWidth = 2.6);

    // 2. Sunglasses below brim
    final shades = Paint()..color = const Color(0xFF160D2E);
    // Left lens
    final lensL = RRect.fromRectAndRadius(const Rect.fromLTWH(19, 36, 11, 9), const Radius.circular(4));
    canvas.drawRRect(lensL, shades);
    canvas.drawRRect(lensL, line..strokeWidth = 2.0);
    // Right lens
    final lensR = RRect.fromRectAndRadius(const Rect.fromLTWH(34, 36, 11, 9), const Radius.circular(4));
    canvas.drawRRect(lensR, shades);
    canvas.drawRRect(lensR, line..strokeWidth = 2.0);

    // Bridge between lenses
    canvas.drawLine(const Offset(30, 39), const Offset(34, 39), line..strokeWidth = 2.2);

    // Reflection glints across lenses
    final glint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(22, 38), const Offset(26, 42), glint);
    canvas.drawLine(const Offset(37, 38), const Offset(41, 42), glint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Cosmic Planet (Saturn with glowing rings and stars)
class _CosmicPlanetIcon extends StatelessWidget {
  const _CosmicPlanetIcon({this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CosmicPlanetPainter(),
      ),
    );
  }
}

class _CosmicPlanetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64;
    canvas.save();
    canvas.scale(s);

    const center = Offset(32, 32);

    // 1. Background half of the ring (behind the planet)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.38); // Angle ring
    canvas.translate(-center.dx, -center.dy);

    final ringRect = Rect.fromCenter(center: center, width: 50, height: 18);
    final ringPaint = Paint()
      ..color = const Color(0xFFE9D5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2;

    // Draw top half of ring
    canvas.drawArc(ringRect, math.pi, math.pi, false, ringPaint);
    canvas.restore();

    // 2. Planet Sphere with gradient
    final sphereRect = Rect.fromCircle(center: center, radius: 17);
    final spherePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFC084FC),
          Color(0xFF8B5CF6),
          Color(0xFF581C87),
        ],
      ).createShader(sphereRect);
    canvas.drawCircle(center, 17, spherePaint);

    // Atmosphere highlight arc
    final atmo = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawArc(Rect.fromCircle(center: center, radius: 15.5), -math.pi * 0.8, math.pi * 0.6, false, atmo);

    // 3. Foreground half of the ring (in front of the planet)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.38);
    canvas.translate(-center.dx, -center.dy);

    // Draw bottom half of ring
    canvas.drawArc(ringRect, 0, math.pi, false, ringPaint);
    canvas.restore();

    // 4. Little 4-point Diamond Twinkle Stars
    void drawTwinkle(Offset pt, double r) {
      final star = Path()
        ..moveTo(pt.dx, pt.dy - r)
        ..quadraticBezierTo(pt.dx, pt.dy, pt.dx + r, pt.dy)
        ..quadraticBezierTo(pt.dx, pt.dy, pt.dx, pt.dy + r)
        ..quadraticBezierTo(pt.dx, pt.dy, pt.dx - r, pt.dy)
        ..quadraticBezierTo(pt.dx, pt.dy, pt.dx, pt.dy - r)
        ..close();
      canvas.drawPath(star, Paint()..color = const Color(0xFFFDE047));
    }

    drawTwinkle(const Offset(12, 16), 3.2);
    drawTwinkle(const Offset(52, 46), 2.6);
    drawTwinkle(const Offset(54, 18), 1.8);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(settingsProvider);
      ref.read(soundProvider).play('bell', enabled: s.sound);
    });
  }

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isPaused && _secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
        final s = ref.read(settingsProvider);
        if (_secondsRemaining > 0 && _secondsRemaining <= 10) {
          ref.read(soundProvider).play('suspense_tick', enabled: s.sound);
          Haptics.tick(enabled: s.haptics);
        } else if (_secondsRemaining > 10 && _secondsRemaining % 10 == 0) {
          ref.read(soundProvider).play('tick', enabled: s.sound);
        }
        if (_secondsRemaining == 0) {
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
              Positioned(
                right: -10,
                top: 0,
                child: Mascot(
                  size: 46,
                  mood: _secondsRemaining <= 10
                      ? MascotMood.nervous
                      : (_secondsRemaining < 30 ? MascotMood.suspicious : MascotMood.peeking),
                ),
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
                        onTap: () {
                          setState(() => _selected = target);
                          final s = ref.read(settingsProvider);
                          ref.read(soundProvider).play('heartbeat', enabled: s.sound);
                          Haptics.selection(enabled: s.haptics);
                        },
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

class _LastChanceViewState extends ConsumerState<LastChanceView> with SingleTickerProviderStateMixin {
  final _guess = TextEditingController();
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(settingsProvider);
      ref.read(soundProvider).play('impact', enabled: s.sound);
      Haptics.buzz(enabled: s.haptics);
    });
  }

  @override
  void dispose() {
    _guess.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _submit({bool? accepted}) => ref.read(gameProvider.notifier).submitGuess(_guess.text, accepted: accepted);

  @override
  Widget build(BuildContext context) {
    final r = widget.round;
    final names = r.imposters.map((i) => r.players[i]).join(', ');

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0812), // Darkened dramatic backdrop
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Alert Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: HushbugColors.imposterRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: HushbugColors.imposterRed),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: HushbugColors.imposterRed, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'SUSPICION CONFIRMED',
                      style: TextStyle(
                        color: HushbugColors.imposterRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              // Suspicious Mascot & Dramatic One Last Chance Header
              Column(
                children: [
                  const Mascot(size: 110, mood: MascotMood.suspicious),
                  const SizedBox(height: 12),
                  const Text(
                    'ONE LAST CHANCE!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: HushbugColors.accentYellow,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(color: Color(0x99FFD166), blurRadius: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$names was uncovered!',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Guess the secret word correctly to steal the victory from the crew.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: HushbugColors.textSubtext, fontSize: 13),
                  ),
                ],
              ),

              // Guess Input Container
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: HushbugColors.cardSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: HushbugColors.neonPurple.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x337351D8), blurRadius: 18),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _guess,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'Enter secret word...',
                        hintStyle: TextStyle(color: HushbugColors.textMuted, fontSize: 15),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),

              // Action Options
              Column(
                children: [
                  TactileButton(
                    onPressed: () => _submit(),
                    style: TactileButtonStyle.golden,
                    height: 52,
                    icon: const Icon(Icons.flash_on_rounded, color: HushbugColors.onAccentYellow, size: 22),
                    child: const Text('Steal Victory'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => _submit(accepted: true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: HushbugColors.civilianEmerald,
                      side: const BorderSide(color: HushbugColors.civilianEmerald),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('Squad Accepts (Close Enough!)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => _submit(accepted: false),
                    child: const Text('Concede Defeat', style: TextStyle(color: HushbugColors.textMuted, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
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

      // Record match in statsProvider
      ref.read(statsProvider.notifier).recordGame(
            secretWord: widget.round.word,
            fakeWord: widget.round.fakeWord,
            category: widget.round.category,
            winner: crew ? 'crew' : 'imposter',
            players: widget.round.players,
            imposters: widget.round.imposters.map((i) => widget.round.players[i]).toList(),
            scores: s.scores,
          );
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
        // Floating Confetti Overlay for Crew Victory, Dark Mist for Imposter Win
        if (isCrewWin) const Positioned.fill(child: ConfettiOverlay()),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Celebratory / Mischievous Stage with dynamic mascot
              Column(
                children: [
                  Mascot(
                    size: 110,
                    mood: isCrewWin ? MascotMood.celebrating : MascotMood.laughing,
                  ),
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