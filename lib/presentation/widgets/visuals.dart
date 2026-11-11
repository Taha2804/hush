import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../theme.dart';
import 'common.dart';
import 'mascot.dart';

/// 1. Tactile 3D Buttons with gradient styling & tactile press feedback.
enum TactileButtonStyle {
  golden,
  neonPurple,
  secondary,
  danger,
}

class TactileButton extends StatefulWidget {
  const TactileButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style = TactileButtonStyle.neonPurple,
    this.height = 54,
    this.icon,
    this.badge,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final TactileButtonStyle style;
  final double height;
  final Widget? icon;
  final Widget? badge;

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    LinearGradient? gradient;
    Color? solidColor;
    Color textColor;
    List<BoxShadow> shadows = [];
    Border? border;

    switch (widget.style) {
      case TactileButtonStyle.golden:
        gradient = HushbugColors.goldButtonGradient;
        textColor = HushbugColors.onAccentYellow;
        shadows = [
          const BoxShadow(color: Color(0x66FFD166), blurRadius: 20, offset: Offset(0, 8)),
          const BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2)),
        ];
        break;
      case TactileButtonStyle.neonPurple:
        gradient = HushbugColors.neonPurpleGradient;
        textColor = Colors.white;
        border = Border.all(color: HushbugColors.cardBorderActive.withValues(alpha: 0.5), width: 1.2);
        shadows = [
          const BoxShadow(color: Color(0x557351D8), blurRadius: 18, offset: Offset(0, 6)),
        ];
        break;
      case TactileButtonStyle.secondary:
        solidColor = HushbugColors.cardSurfaceElevated;
        textColor = HushbugColors.textSecondary;
        border = Border.all(color: HushbugColors.cardBorder, width: 1.5);
        shadows = [
          const BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4)),
        ];
        break;
      case TactileButtonStyle.danger:
        solidColor = HushbugColors.imposterRed;
        textColor = Colors.white;
        shadows = [
          BoxShadow(color: HushbugColors.imposterRed.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(0, 6)),
        ];
        break;
    }

    return GestureDetector(
      onTapDown: enabled ? (_) => _controller.forward() : null,
      onTapUp: enabled
          ? (_) {
              _controller.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: enabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: gradient,
            color: solidColor,
            borderRadius: BorderRadius.circular(20),
            border: border,
            boxShadow: shadows,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              DefaultTextStyle(
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
                child: widget.child,
              ),
              if (widget.badge != null) ...[
                const SizedBox(width: 8),
                widget.badge!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 2. Biometric Sensor Widget (Press & Hold with pulsing ping rings).
class BiometricSensor extends StatefulWidget {
  const BiometricSensor({super.key, this.size = 64});
  final double size;

  @override
  State<BiometricSensor> createState() => _BiometricSensorState();
}

class _BiometricSensorState extends State<BiometricSensor> with SingleTickerProviderStateMixin {
  late final AnimationController _pingCtrl;
  late final Animation<double> _pingScale;
  late final Animation<double> _pingOpacity;

  @override
  void initState() {
    super.initState();
    _pingCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    _pingScale = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _pingCtrl, curve: Curves.easeOut),
    );
    _pingOpacity = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(parent: _pingCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.6,
      height: widget.size * 1.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Ping Ripple
          AnimatedBuilder(
            animation: _pingCtrl,
            builder: (context, _) => Transform.scale(
              scale: _pingScale.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: HushbugColors.neonPurpleLight.withValues(alpha: _pingOpacity.value),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          // Inner Glowing Sensor Circle
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HushbugColors.neonPurple.withValues(alpha: 0.25),
              border: Border.all(color: HushbugColors.neonPurpleLight, width: 2),
              boxShadow: [
                BoxShadow(
                  color: HushbugColors.neonPurple.withValues(alpha: 0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.fingerprint_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. Circular Neon Countdown Timer Dial with controls.
class CircularTimerDial extends StatelessWidget {
  const CircularTimerDial({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.isPaused,
    required this.onPauseToggle,
    required this.onAdd30s,
  });

  final int secondsRemaining;
  final int totalSeconds;
  final bool isPaused;
  final VoidCallback onPauseToggle;
  final VoidCallback onAdd30s;

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? (secondsRemaining / totalSeconds).clamp(0.0, 1.0) : 0.0;
    final mins = secondsRemaining ~/ 60;
    final secs = secondsRemaining % 60;
    final timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pause Button
        IconButton.filledTonal(
          onPressed: onPauseToggle,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF24174A),
            foregroundColor: HushbugColors.textSecondary,
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: HushbugColors.cardBorder, width: 1.2),
            ),
          ),
          icon: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 24),
        ),
        const SizedBox(width: 20),
        // Dial Canvas
        SizedBox(
          width: 136,
          height: 136,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(136, 136),
                painter: _TimerDialPainter(progress: progress),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(color: Color(0x99000000), blurRadius: 10, offset: Offset(0, 3)),
                      ],
                    ),
                  ),
                  const Text(
                    'REMAINING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: HushbugColors.textSubtext,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // +30s / Skip Button
        IconButton.filledTonal(
          onPressed: onAdd30s,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF24174A),
            foregroundColor: HushbugColors.textSecondary,
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: HushbugColors.cardBorder, width: 1.2),
            ),
          ),
          icon: const Icon(Icons.fast_forward_rounded, size: 24),
        ),
      ],
    );
  }
}

class _TimerDialPainter extends CustomPainter {
  _TimerDialPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;

    // Track
    final trackPaint = Paint()
      ..color = const Color(0xFF2E1C5E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Active arc with Sweep Gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepGradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: const [
        Color(0xFFFBBF24),
        Color(0xFFF59E0B),
        Color(0xFFA855F7),
      ],
    );

    final activePaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _TimerDialPainter old) => old.progress != progress;
}

/// 4. Soundwave Indicator for active speaker in Clues round.
class SoundwaveIndicator extends StatefulWidget {
  const SoundwaveIndicator({super.key});

  @override
  State<SoundwaveIndicator> createState() => _SoundwaveIndicatorState();
}

class _SoundwaveIndicatorState extends State<SoundwaveIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final val = _ctrl.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _bar(4 + val * 10),
            const SizedBox(width: 2.5),
            _bar(14 - val * 8),
            const SizedBox(width: 2.5),
            _bar(6 + val * 8),
          ],
        );
      },
    );
  }

  Widget _bar(double h) => Container(
        width: 2.5,
        height: h,
        decoration: BoxDecoration(
          color: HushbugColors.accentYellow,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

/// 5. Stacked circular avatar cluster for Squad Overview (e.g. M, A, S, +3).
class PlayerAvatarCluster extends StatelessWidget {
  const PlayerAvatarCluster({super.key, required this.players});
  final List<String> players;

  @override
  Widget build(BuildContext context) {
    final showCount = math.min(players.length, 3);
    final remaining = players.length - showCount;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < showCount; i++)
          Align(
            widthFactor: 0.72,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: HushbugColors.cardSurface, width: 2),
              ),
              child: PlayerAvatar(index: i, name: players[i], radius: 14),
            ),
          ),
        if (remaining > 0)
          Align(
            widthFactor: 0.72,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF332C47),
                border: Border.all(color: HushbugColors.cardSurface, width: 2),
              ),
              child: Center(
                child: Text(
                  '+$remaining',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 6. Celebratory Festive Curved Ribbon Banner ("IMPOSTER CAUGHT!" / "IMPOSTERS WIN!").
class RibbonBanner extends StatelessWidget {
  const RibbonBanner({super.key, required this.text, this.isVictory = true});
  final String text;
  final bool isVictory;

  @override
  Widget build(BuildContext context) {
    final gradient = isVictory
        ? const LinearGradient(colors: [Color(0xFFFF4E50), Color(0xFFE02424)])
        : const LinearGradient(colors: [Color(0xFF7351D8), Color(0xFF5538A9)]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(color: Color(0x73E02424), blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          shadows: [
            Shadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
      ),
    );
  }
}

/// 7. Confetti Overlay Celebration.
class ConfettiOverlay extends StatelessWidget {
  const ConfettiOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: 160,
        child: CustomPaint(
          painter: _ConfettiPainter(),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);
    final colors = [
      HushbugColors.accentYellow,
      Colors.pinkAccent,
      Colors.cyanAccent,
      Colors.amber,
      HushbugColors.civilianEmerald,
      HushbugColors.neonPurpleLight,
    ];

    for (var i = 0; i < 36; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final color = colors[i % colors.length];
      final isCircle = i % 2 == 0;

      if (isCircle) {
        canvas.drawCircle(Offset(x, y), 3.0 + rand.nextDouble() * 2.5, Paint()..color = color);
      } else {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rand.nextDouble() * math.pi);
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(-3, -6, 6, 12), const Radius.circular(2)),
          Paint()..color = color,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Icons for categories
const categoryIcons = <String, IconData>{
  'animals': Icons.pets_rounded,
  'food': Icons.local_pizza_rounded,
  'drinks': Icons.local_cafe_rounded,
  'fruits_vegetables': Icons.eco_rounded,
  'countries': Icons.flag_rounded,
  'cities': Icons.location_city_rounded,
  'movies': Icons.movie_rounded,
  'sports': Icons.sports_soccer_rounded,
  'jobs': Icons.work_rounded,
  'household': Icons.chair_rounded,
  'clothing': Icons.checkroom_rounded,
  'transport': Icons.directions_car_rounded,
  'nature': Icons.forest_rounded,
  'technology': Icons.devices_rounded,
  'school': Icons.school_rounded,
  'hobbies': Icons.palette_rounded,
  'instruments': Icons.music_note_rounded,
  'places': Icons.store_rounded,
  'body_health': Icons.favorite_rounded,
  'holidays': Icons.celebration_rounded,
  'landmarks': Icons.account_balance_rounded,
  'mythical': Icons.auto_awesome_rounded,
};

IconData categoryIcon(String id) => categoryIcons[id] ?? Icons.category_rounded;

const _playerHues = <double>[265, 165, 12, 42, 215, 330, 120, 190, 290, 25];

Color playerColor(int index, Brightness b) => HSLColor.fromAHSL(
      1,
      _playerHues[index % _playerHues.length],
      0.62,
      b == Brightness.dark ? 0.62 : 0.52,
    ).toColor();

final _numbered = RegExp(r'^(.*?)\s*(\d+)$');

String avatarLabel(String name, int index, {String localizedPlayerPrefix = 'Player 0'}) {
  final n = name.trim();
  if (n.isEmpty) return '${index + 1}';
  final m = _numbered.firstMatch(n);
  if (m != null) {
    final prefix = m.group(1)!.toLowerCase();
    final localized = localizedPlayerPrefix.replaceAll('0', '').trim().toLowerCase();
    if (prefix == 'player' || prefix == localized) return m.group(2)!;
  }
  return n.characters.first.toUpperCase();
}

MascotMood avatarIndexToMood(int id) {
  switch (id % 8) {
    case 0:
      return MascotMood.normal;
    case 1:
      return MascotMood.detective;
    case 2:
      return MascotMood.researcher;
    case 3:
      return MascotMood.celebrating;
    case 4:
      return MascotMood.sleeping;
    case 5:
      return MascotMood.suspicious;
    case 6:
      return MascotMood.laughing;
    case 7:
      return MascotMood.shocked;
    default:
      return MascotMood.normal;
  }
}

String avatarIndexName(int id) {
  switch (id % 8) {
    case 0:
      return 'Classic Bug';
    case 1:
      return 'Detective Bug';
    case 2:
      return 'Researcher Bug';
    case 3:
      return 'Party Bug';
    case 4:
      return 'Sleepy Bug';
    case 5:
      return 'Suspicious Bug';
    case 6:
      return 'Mischief Bug';
    case 7:
      return 'Shocked Bug';
    default:
      return 'Bug';
  }
}

class PlayerAvatar extends ConsumerWidget {
  const PlayerAvatar({
    super.key,
    required this.index,
    required this.name,
    this.radius = 18,
    this.avatarIndex,
    this.showInitialFallback = false,
  });

  final int index;
  final String name;
  final double radius;
  final int? avatarIndex;
  final bool showInitialFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = playerColor(index, Theme.of(context).brightness);
    final settings = ref.watch(settingsProvider);
    final chosenIdx = avatarIndex ?? settings.playerAvatars[name] ?? (index % 8);
    final mood = avatarIndexToMood(chosenIdx);

    if (showInitialFallback || radius < 14) {
      final initial = avatarLabel(name, index, localizedPlayerPrefix: context.l10n.playerN(0));
      return CircleAvatar(
        radius: radius,
        backgroundColor: c,
        child: Text(
          initial,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: radius * 0.9),
        ),
      );
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.withValues(alpha: 0.22),
        border: Border.all(color: c, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipOval(
        child: OverflowBox(
          maxWidth: radius * 2.3,
          maxHeight: radius * 2.3,
          alignment: Alignment.center,
          child: Mascot(
            size: radius * 2.2,
            mood: mood,
            customShellColor: c,
          ),
        ),
      ),
    );
  }
}

class HeroBackdrop extends StatelessWidget {
  const HeroBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: HushbugColors.scaffoldGradient,
      ),
      child: child,
    );
  }
}
