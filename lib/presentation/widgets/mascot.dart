import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme.dart';

enum MascotMood {
  normal,
  sleeping,
  peeking,
  suspicious,
  shocked,
  laughing,
  celebrating,
  nervous,
  detective,
  researcher,
  shush,
  happy,
  sad,
}

/// Base procedural Hushbug mascot drawn entirely with CustomPainter.
class Mascot extends StatelessWidget {
  const Mascot({
    super.key,
    this.size = 120,
    this.mood = MascotMood.shush,
    this.semanticLabel,
    this.customShellColor,
  });

  final double size;
  final MascotMood mood;
  final String? semanticLabel;
  final Color? customShellColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shell = customShellColor ?? cs.primary;
    return Semantics(
      label: semanticLabel ?? 'Hushbug mascot',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: HushbugMascotPainter(
            shell: shell,
            light: Colors.white,
            accent: HushbugColors.accentYellow,
            mood: mood,
          ),
        ),
      ),
    );
  }
}

/// 1. Hero Floating Mascot (Lobby / Home) with floating bobbing, antenna wiggle,
/// and blinking eyes on a glowing backplate.
class HeroFloatingMascot extends StatefulWidget {
  const HeroFloatingMascot({super.key, this.size = 140});
  final double size;

  @override
  State<HeroFloatingMascot> createState() => _HeroFloatingMascotState();
}

class _HeroFloatingMascotState extends State<HeroFloatingMascot>
    with TickerProviderStateMixin {
  late final AnimationController _bobCtrl;
  late final AnimationController _antennaLCtrl;
  late final AnimationController _antennaRCtrl;
  late final AnimationController _blinkCtrl;

  late final Animation<double> _bobAnim;
  late final Animation<double> _antennaLAnim;
  late final Animation<double> _antennaRAnim;
  late final Animation<double> _blinkAnim;

  @override
  void initState() {
    super.initState();
    // Bobbing: translateY 0 -> -8 -> 0 over 4.0s
    _bobCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _bobAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bobCtrl, curve: Curves.easeInOut),
    );

    // Left antenna wiggle: -8° to +6° over 3.5s
    _antennaLCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3500))
      ..repeat(reverse: true);
    _antennaLAnim = Tween<double>(begin: -0.14, end: 0.10).animate(
      CurvedAnimation(parent: _antennaLCtrl, curve: Curves.easeInOut),
    );

    // Right antenna wiggle: +8° to -6° over 3.2s
    _antennaRCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);
    _antennaRAnim = Tween<double>(begin: 0.14, end: -0.10).animate(
      CurvedAnimation(parent: _antennaRCtrl, curve: Curves.easeInOut),
    );

    // Blinking eyes: scaleY 1.0 -> 0.1 at 96% of 4.2s cycle
    _blinkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200))
      ..repeat();
    _blinkAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 94),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.1), weight: 3),
      TweenSequenceItem(tween: Tween<double>(begin: 0.1, end: 1.0), weight: 3),
    ]).animate(_blinkCtrl);
  }

  @override
  void dispose() {
    _bobCtrl.dispose();
    _antennaLCtrl.dispose();
    _antennaRCtrl.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bobCtrl, _antennaLCtrl, _antennaRCtrl, _blinkCtrl]),
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, _bobAnim.value),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ambient Glow Backplate
                Container(
                  width: widget.size * 0.82,
                  height: widget.size * 0.82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: HushbugColors.neonPurple.withValues(alpha: 0.45),
                        blurRadius: 36,
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: Colors.pinkAccent.withValues(alpha: 0.25),
                        blurRadius: 48,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
                ),
                // Glowing Disc Stage
                Container(
                  width: widget.size * 0.78,
                  height: widget.size * 0.78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF342953), Color(0xFF1E1733)],
                    ),
                    border: Border.all(
                      color: HushbugColors.neonPurpleLight.withValues(alpha: 0.45),
                      width: 2.2,
                    ),
                  ),
                ),
                // Procedural Mascot
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: HushbugMascotPainter(
                    shell: HushbugColors.neonPurple,
                    light: Colors.white,
                    accent: HushbugColors.accentYellow,
                    mood: MascotMood.happy,
                    antennaLAngle: _antennaLAnim.value,
                    antennaRAngle: _antennaRAnim.value,
                    eyeScaleY: _blinkAnim.value,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 2. Peeking Corner Mascot (Lobby & Voting Screen)
class PeekingCornerMascot extends StatelessWidget {
  const PeekingCornerMascot({
    super.key,
    this.width = 110,
    this.height = 80,
    this.isDetective = false,
  });

  final double width;
  final double height;
  final bool isDetective;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _PeekingMascotPainter(
          isDetective: isDetective,
          eyesOpenProgress: 1.0,
        ),
      ),
    );
  }
}

/// Dedicated Card Peeking Mascot for the Secret Reveal Card.
/// - In default state: Eyes completely closed (peaceful sleeping/innocent curved lines), subtle idle antenna/breathing motion, paws on the edge.
/// - On hold: Hushbug's eye-covering eyelids smoothly slide to reveal eyes, looking up at secret word (peeking expression), subtle head lift.
/// - On release: Eyes quickly close again back to innocent sleeping expression.
/// - Completely neutral: 100% identical appearance for all players (no imposter hat or role cues).
class CardPeekingMascot extends StatefulWidget {
  const CardPeekingMascot({
    super.key,
    required this.eyesOpenProgress, // 0.0 = completely closed, 1.0 = peeking open looking up
    this.width = 120,
    this.height = 84,
    this.isDetective = false,
  });

  final double eyesOpenProgress;
  final double width;
  final double height;
  final bool isDetective;

  @override
  State<CardPeekingMascot> createState() => _CardPeekingMascotState();
}

class _CardPeekingMascotState extends State<CardPeekingMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _idleCtrl;
  late final Animation<double> _breathAnim;
  late final Animation<double> _antennaAnim;

  @override
  void initState() {
    super.initState();
    // Subtle idle animation: gentle breathing (up/down ~1.5px) and soft antenna sway
    _idleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat(reverse: true);
    _breathAnim = Tween<double>(begin: 0.0, end: -2.0).animate(
      CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOutSine),
    );
    _antennaAnim = Tween<double>(begin: -0.06, end: 0.06).animate(
      CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _idleCtrl,
      builder: (context, _) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: CustomPaint(
            painter: _PeekingMascotPainter(
              eyesOpenProgress: widget.eyesOpenProgress,
              breathOffset: _breathAnim.value,
              antennaWiggle: _antennaAnim.value,
            ),
          ),
        );
      },
    );
  }
}

class _PeekingMascotPainter extends CustomPainter {
  _PeekingMascotPainter({
    this.isDetective = false,
    this.eyesOpenProgress = 1.0,
    this.breathOffset = 0.0,
    this.antennaWiggle = 0.0,
  });

  // Maintained for backward compatibility, but strictly ignored so mascot is 100% neutral
  final bool isDetective;
  /// 0.0 = completely closed (innocent curved arcs), 1.0 = peeking open looking up
  final double eyesOpenProgress;
  final double breathOffset;
  final double antennaWiggle;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 120;
    canvas.save();
    canvas.scale(s);

    final outline = Paint()
      ..color = const Color(0xFF1E1435)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final clampedP = eyesOpenProgress.clamp(0.0, 1.0);

    // Apply subtle breathing and peek head lift
    // When peeking, the head and antennae rise slightly
    final peekLift = -3.5 * clampedP;
    final totalYOffset = breathOffset + peekLift;
    const cx = 60.0;
    final cy = 48.0 + totalYOffset;

    // 0. Sparkle rays when peeking / revealed (accent rays beside head, as in reference image)
    if (clampedP > 0.4) {
      final rayOpacity = ((clampedP - 0.4) / 0.6).clamp(0.0, 1.0);
      final rayPaint = Paint()
        ..color = const Color(0xFFFFD166).withValues(alpha: rayOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      // Left rays
      canvas.drawLine(Offset(22, cy - 8), Offset(14, cy - 12), rayPaint);
      canvas.drawLine(Offset(21, cy - 1), Offset(12, cy - 1), rayPaint);
      canvas.drawLine(Offset(23, cy + 6), Offset(15, cy + 9), rayPaint);

      // Right rays
      canvas.drawLine(Offset(98, cy - 8), Offset(106, cy - 12), rayPaint);
      canvas.drawLine(Offset(99, cy - 1), Offset(108, cy - 1), rayPaint);
      canvas.drawLine(Offset(97, cy + 6), Offset(105, cy + 9), rayPaint);
    }

    // 1. Antennae with glowing tips (pink/purple tips, subtle wiggle)
    final antennaAngleAdjust = 0.08 * clampedP;

    // Left Antenna
    canvas.save();
    canvas.translate(45, cy - 20);
    canvas.rotate(-antennaWiggle - antennaAngleAdjust);
    canvas.translate(-45, -(cy - 20));
    final pL = Path()
      ..moveTo(46, cy - 18)
      ..cubicTo(40, cy - 32, 34, cy - 38, 28, cy - 36);
    canvas.drawPath(pL, outline..strokeWidth = 2.4);
    // Glowing pink/purple bulb tip
    final bulbL = Offset(28, cy - 36);
    canvas.drawCircle(bulbL, 6.0, Paint()..color = const Color(0xFFF43F5E).withValues(alpha: 0.35));
    canvas.drawCircle(bulbL, 4.4, Paint()..color = const Color(0xFFEC4899));
    canvas.drawCircle(bulbL, 4.4, outline..strokeWidth = 1.4);
    canvas.drawCircle(Offset(bulbL.dx - 1.2, bulbL.dy - 1.2), 1.2, Paint()..color = Colors.white);
    canvas.restore();

    // Right Antenna
    canvas.save();
    canvas.translate(75, cy - 20);
    canvas.rotate(antennaWiggle + antennaAngleAdjust);
    canvas.translate(-75, -(cy - 20));
    final pR = Path()
      ..moveTo(74, cy - 18)
      ..cubicTo(80, cy - 32, 86, cy - 38, 92, cy - 36);
    canvas.drawPath(pR, outline..strokeWidth = 2.4);
    // Glowing pink/purple bulb tip
    final bulbR = Offset(92, cy - 36);
    canvas.drawCircle(bulbR, 6.0, Paint()..color = const Color(0xFFF43F5E).withValues(alpha: 0.35));
    canvas.drawCircle(bulbR, 4.4, Paint()..color = const Color(0xFFEC4899));
    canvas.drawCircle(bulbR, 4.4, outline..strokeWidth = 1.4);
    canvas.drawCircle(Offset(bulbR.dx - 1.2, bulbR.dy - 1.2), 1.2, Paint()..color = Colors.white);
    canvas.restore();

    outline.strokeWidth = 2.4;

    // 2. Body / Head (Cute rounded purple bug dome)
    final bodyRect = Rect.fromCenter(center: Offset(cx, cy + 2), width: 76, height: 48);
    final bodyRRect = RRect.fromRectAndCorners(
      bodyRect,
      topLeft: const Radius.circular(38),
      topRight: const Radius.circular(38),
      bottomLeft: const Radius.circular(24),
      bottomRight: const Radius.circular(24),
    );

    // Purple Gradient Shell
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF9D6EF8),
          Color(0xFF8B5CF6),
          Color(0xFF6D28D9),
        ],
      ).createShader(bodyRect);

    canvas.drawRRect(bodyRRect, bodyPaint);
    canvas.drawRRect(bodyRRect, outline);

    // 3. Cute Cheek Blush
    final blushColor = const Color(0xFFFF72A3).withValues(alpha: 0.55 + 0.25 * clampedP);
    final blushPaint = Paint()..color = blushColor;
    canvas.drawOval(Rect.fromCenter(center: Offset(35, cy + 7), width: 9, height: 6.5), blushPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(85, cy + 7), width: 9, height: 6.5), blushPaint);

    // 4. Eyes Animation: Synchronized Eyelid Slide from Innocent Closed to Peeking Upwards
    for (final isLeft in [true, false]) {
      final eyeX = isLeft ? 45.0 : 75.0;
      final eyeY = cy - 2.0;
      const eyeW = 15.0;
      const eyeH = 17.0;

      final eyeRect = Rect.fromCenter(center: Offset(eyeX, eyeY), width: eyeW, height: eyeH);
      final eyeRRect = RRect.fromRectAndRadius(eyeRect, const Radius.circular(7.5));

      if (clampedP <= 0.02) {
        // --- DEFAULT STATE: Eyes completely closed (innocent, relaxed sleeping expression) ---
        final closedEye = Path()
          ..moveTo(eyeX - 6.5, eyeY + 1.0)
          ..quadraticBezierTo(eyeX, eyeY + 4.8, eyeX + 6.5, eyeY + 1.0);
        canvas.drawPath(closedEye, outline..strokeWidth = 2.2);
      } else {
        // --- REVEAL / PEEKING STATE: Eyelids smoothly slide down to reveal eye ---
        canvas.save();
        canvas.clipRRect(eyeRRect);

        // White Sclera
        canvas.drawRRect(eyeRRect, Paint()..color = Colors.white);

        // Large expressive dark pupil looking upwards towards the secret card
        // Interpolate pupil position to glance up towards the word
        final pupilY = eyeY - 2.6 * clampedP;
        final pupilX = eyeX + (isLeft ? 0.3 : -0.3) * clampedP;
        const pupilRadius = 4.8;
        canvas.drawCircle(Offset(pupilX, pupilY), pupilRadius, Paint()..color = const Color(0xFF1E1138));

        // Catchlight / sparkly glint reflection inside pupil
        canvas.drawCircle(Offset(pupilX + 1.4, pupilY - 1.4), 1.5, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(pupilX - 1.2, pupilY + 1.6), 0.7, Paint()..color = Colors.white);

        // Eyelid smoothly covering the top portion of the eye
        // At clampedP == 0.02, eyelid covers ~98%. At clampedP == 1.0, eyelid covers top 45% (peeking)
        final eyelidCoverage = (1.0 - (0.55 * clampedP)).clamp(0.45, 1.0);
        final eyelidBottomY = eyeRect.top + (eyeH * eyelidCoverage);

        final eyelidPath = Path()
          ..moveTo(eyeRect.left - 2, eyeRect.top - 2)
          ..lineTo(eyeRect.right + 2, eyeRect.top - 2)
          ..lineTo(eyeRect.right + 2, eyelidBottomY)
          // Sly cartoon peeking curve: slightly lower on the outer corner
          ..quadraticBezierTo(
            eyeX,
            eyelidBottomY + (isLeft ? 1.0 : 1.0),
            eyeRect.left - 2,
            eyelidBottomY + (isLeft ? 1.5 : -0.5),
          )
          ..close();

        // Shaded eyelid matching body skin
        final eyelidPaint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9D6EF8), Color(0xFF8B5CF6)],
          ).createShader(eyeRect);
        canvas.drawPath(eyelidPath, eyelidPaint);

        // Eyelid crease line
        final creaseLine = Path()
          ..moveTo(eyeRect.left - 1, eyelidBottomY + (isLeft ? 1.5 : -0.5))
          ..quadraticBezierTo(
            eyeX,
            eyelidBottomY + 1.0,
            eyeRect.right + 1,
            eyelidBottomY,
          );
        canvas.drawPath(creaseLine, outline..strokeWidth = 1.8);

        canvas.restore();

        // Eye socket outline
        canvas.drawRRect(eyeRRect, outline..strokeWidth = 1.6);
      }
    }
    outline.strokeWidth = 2.4;

    // 5. Innocent Subtle Mouth
    final mouthY = cy + 7.5;
    final mouth = Path()
      ..moveTo(cx - 3.2, mouthY)
      ..quadraticBezierTo(cx, mouthY + 2.0, cx + 3.2, mouthY);
    canvas.drawPath(mouth, outline..strokeWidth = 1.8);
    outline.strokeWidth = 2.4;

    // 6. Cute Purple Paws (resting securely at bottom-left and bottom-right edges)
    final pawL = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 33, cy + 13, 14, 11),
      const Radius.circular(6),
    );
    canvas.drawRRect(pawL, Paint()..color = const Color(0xFF7C3AED));
    canvas.drawRRect(pawL, outline..strokeWidth = 2.0);

    final pawR = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx + 19, cy + 13, 14, 11),
      const Radius.circular(6),
    );
    canvas.drawRRect(pawR, Paint()..color = const Color(0xFF7C3AED));
    canvas.drawRRect(pawR, outline..strokeWidth = 2.0);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PeekingMascotPainter old) =>
      old.eyesOpenProgress != eyesOpenProgress ||
      old.breathOffset != breathOffset ||
      old.antennaWiggle != antennaWiggle;
}

/// Comprehensive procedural vector painter for all Hushbug moods & hats.
class HushbugMascotPainter extends CustomPainter {
  HushbugMascotPainter({
    required this.shell,
    required this.light,
    required this.accent,
    required this.mood,
    this.antennaLAngle = 0.0,
    this.antennaRAngle = 0.0,
    this.eyeScaleY = 1.0,
    this.coverEyes = false,
  });

  final Color shell;
  final Color light;
  final Color accent;
  final MascotMood mood;
  final double antennaLAngle;
  final double antennaRAngle;
  final double eyeScaleY;
  final bool coverEyes;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    canvas.save();
    canvas.scale(s);

    final outline = Paint()
      ..color = const Color(0xFF1E1A2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    final dark = Paint()..color = const Color(0xFF1E1A2E);

    // 1. Foundation if Researcher Mood (Stack of books)
    if (mood == MascotMood.researcher) {
      _paintResearcherBooks(canvas, outline);
    }

    // 2. Legs
    for (final side in [-1.0, 1.0]) {
      for (var i = 0; i < 3; i++) {
        final y = 62.0 + i * 9;
        final p = Path()
          ..moveTo(50 + side * 22, y)
          ..quadraticBezierTo(50 + side * 34, y - 2, 50 + side * 38, y + 6);
        canvas.drawPath(p, outline);
      }
    }

    // 3. Antennae with dynamic angles
    // Left
    canvas.save();
    canvas.translate(46, 22);
    canvas.rotate(antennaLAngle);
    canvas.translate(-46, -22);
    final pAL = Path()
      ..moveTo(46, 22)
      ..quadraticBezierTo(38, 8, 28, 6);
    canvas.drawPath(pAL, outline);
    canvas.drawCircle(const Offset(28, 6), 3.4, Paint()..color = accent);
    canvas.drawCircle(const Offset(28, 6), 3.4, outline..strokeWidth = 1.6);
    canvas.restore();

    // Right
    canvas.save();
    canvas.translate(54, 22);
    canvas.rotate(antennaRAngle);
    canvas.translate(-54, -22);
    final pAR = Path()
      ..moveTo(54, 22)
      ..quadraticBezierTo(62, 8, 72, 6);
    canvas.drawPath(pAR, outline);
    canvas.drawCircle(const Offset(72, 6), 3.4, Paint()..color = accent);
    canvas.drawCircle(const Offset(72, 6), 3.4, outline..strokeWidth = 1.6);
    canvas.restore();
    outline.strokeWidth = 2.6;

    // 4. Shell (Body)
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(24, 40, 52, 52),
      const Radius.circular(26),
    );
    canvas.drawRRect(body, Paint()..color = shell);

    // Shell split + spots
    canvas.drawLine(const Offset(50, 46), const Offset(50, 90), outline);
    final spot = Paint()..color = light.withValues(alpha: 0.85);
    canvas.drawCircle(const Offset(38, 62), 4.5, spot);
    canvas.drawCircle(const Offset(62, 70), 5.5, spot);
    canvas.drawCircle(const Offset(40, 79), 3.2, spot);
    canvas.drawRRect(body, outline);

    // 5. Head
    const headC = Offset(50, 34);
    canvas.drawCircle(headC, 18, Paint()..color = const Color(0xFFFFE7C7));
    canvas.drawCircle(headC, 18, outline);

    // Cheeks
    final blush = Paint()..color = const Color(0xFFFF8FA3).withValues(alpha: 0.55);
    canvas.drawCircle(const Offset(38, 39), 3.2, blush);
    canvas.drawCircle(const Offset(62, 39), 3.2, blush);

    // 6. Eyes
    canvas.save();
    canvas.translate(headC.dx, headC.dy);
    canvas.scale(1.0, eyeScaleY);
    canvas.translate(-headC.dx, -headC.dy);

    void drawStandardEye(double x, {bool squint = false}) {
      if (squint) {
        canvas.drawLine(Offset(x - 4, 31), Offset(x + 4, 32.5), outline);
        canvas.drawCircle(Offset(x + 0.8, 34), 1.9, dark);
      } else {
        canvas.drawCircle(Offset(x, 32), 4.6, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(x, 32), 4.6, outline..strokeWidth = 1.6);
        outline.strokeWidth = 2.6;
        canvas.drawCircle(Offset(x + 1, 32.5), 2.1, dark);
      }
    }

    switch (mood) {
      case MascotMood.sleeping:
        // Peaceful curved closed eyes
        for (final x in [43.0, 57.0]) {
          final p = Path()
            ..moveTo(x - 4.5, 33)
            ..quadraticBezierTo(x, 36.5, x + 4.5, 33);
          canvas.drawPath(p, outline..strokeWidth = 2.2);
        }
        break;
      case MascotMood.peeking:
        // Narrow slit with upward-peeking pupils
        for (final x in [43.0, 57.0]) {
          canvas.drawOval(Rect.fromCenter(center: Offset(x, 33), width: 8.5, height: 4), Paint()..color = Colors.white);
          canvas.drawOval(Rect.fromCenter(center: Offset(x, 33), width: 8.5, height: 4), outline..strokeWidth = 1.4);
          canvas.drawCircle(Offset(x + 0.5, 32), 1.7, dark);
        }
        break;
      case MascotMood.shocked:
        // Huge round wide-open eyes with tiny stunned pupils
        for (final x in [43.0, 57.0]) {
          canvas.drawCircle(Offset(x, 32), 6.5, Paint()..color = Colors.white);
          canvas.drawCircle(Offset(x, 32), 6.5, outline..strokeWidth = 1.8);
          canvas.drawCircle(Offset(x, 32), 2.2, dark);
          canvas.drawCircle(Offset(x + 1, 31), 0.9, Paint()..color = Colors.white);
        }
        break;
      case MascotMood.nervous:
        // Uneven anxious eyes looking sideways with worried brow
        drawStandardEye(43, squint: true);
        drawStandardEye(57);
        // Anxious sweat drop
        final sweat = Path()
          ..moveTo(65, 23)
          ..quadraticBezierTo(67, 28, 65, 30)
          ..quadraticBezierTo(63, 28, 65, 23);
        canvas.drawPath(sweat, Paint()..color = Colors.cyanAccent);
        break;
      case MascotMood.suspicious:
        drawStandardEye(43, squint: true);
        drawStandardEye(57);
        break;
      case MascotMood.happy:
      case MascotMood.laughing:
      case MascotMood.celebrating:
        // Closed laughing eyes
        for (final x in [43.0, 57.0]) {
          final p = Path()
            ..moveTo(x - 4, 33)
            ..quadraticBezierTo(x, 27, x + 4, 33);
          canvas.drawPath(p, outline);
        }
        break;
      case MascotMood.sad:
        drawStandardEye(43);
        drawStandardEye(57);
        canvas.drawLine(const Offset(39, 26), const Offset(46, 28), outline);
        canvas.drawLine(const Offset(61, 26), const Offset(54, 28), outline);
        break;
      case MascotMood.normal:
      case MascotMood.shush:
      case MascotMood.detective:
      case MascotMood.researcher:
        drawStandardEye(43);
        drawStandardEye(57);
        break;
    }
    canvas.restore();

    // 7. Mouth
    switch (mood) {
      case MascotMood.happy:
      case MascotMood.celebrating:
      case MascotMood.laughing:
        final p = Path()
          ..moveTo(44, 40)
          ..quadraticBezierTo(50, 48, 56, 40);
        canvas.drawPath(p, outline);
        canvas.drawPath(p, Paint()..color = const Color(0xFF831843));
        break;
      case MascotMood.shocked:
        // Open 'O' gasp
        canvas.drawCircle(const Offset(50, 43.5), 3.8, dark);
        break;
      case MascotMood.nervous:
        // Wavy anxious mouth line
        final wave = Path()
          ..moveTo(45, 43)
          ..quadraticBezierTo(47.5, 41.5, 50, 43)
          ..quadraticBezierTo(52.5, 44.5, 55, 43);
        canvas.drawPath(wave, outline..strokeWidth = 1.8);
        break;
      case MascotMood.sleeping:
        // Tiny relaxed sleeping dot/smile
        final p = Path()
          ..moveTo(47, 42)
          ..quadraticBezierTo(50, 44, 53, 42);
        canvas.drawPath(p, outline..strokeWidth = 1.6);
        break;
      case MascotMood.sad:
        final p = Path()
          ..moveTo(45, 44)
          ..quadraticBezierTo(50, 39.5, 55, 44);
        canvas.drawPath(p, outline);
        break;
      case MascotMood.suspicious:
        canvas.drawLine(const Offset(46, 42), const Offset(54, 41), outline);
        break;
      case MascotMood.peeking:
      case MascotMood.normal:
        final p = Path()
          ..moveTo(47, 41)
          ..quadraticBezierTo(50, 44.5, 53, 41);
        canvas.drawPath(p, outline..strokeWidth = 1.8);
        break;
      case MascotMood.shush:
      case MascotMood.detective:
      case MascotMood.researcher:
        canvas.drawOval(const Rect.fromLTWH(46.5, 40.5, 7, 4), dark);
        break;
    }

    // 8. Specific role accessories
    if (mood == MascotMood.shush) {
      // Finger crossing lips
      final skin = Paint()..color = const Color(0xFFFFD39B);
      canvas.save();
      canvas.translate(52, 50);
      canvas.rotate(math.pi / 14);
      canvas.translate(-52, -50);
      final finger = RRect.fromRectAndRadius(
        const Rect.fromLTWH(49.6, 37.5, 4.6, 14),
        const Radius.circular(2.3),
      );
      canvas.drawRRect(finger, skin);
      canvas.drawRRect(finger, outline..strokeWidth = 1.6);
      final fist = RRect.fromRectAndRadius(
        const Rect.fromLTWH(45.5, 49, 13, 9),
        const Radius.circular(4.5),
      );
      canvas.drawRRect(fist, skin);
      canvas.drawRRect(fist, outline);
      canvas.restore();
      outline.strokeWidth = 2.6;
    } else if (mood == MascotMood.detective) {
      _paintDetectiveFedoraAndCoat(canvas, outline);
    } else if (mood == MascotMood.celebrating) {
      _paintPartyHatAndPopper(canvas, outline);
    } else if (mood == MascotMood.researcher) {
      _paintResearcherGlasses(canvas, outline);
    }

    canvas.restore();
  }

  void _paintDetectiveFedoraAndCoat(Canvas canvas, Paint outline) {
    // Fedora Hat
    final hatCrown = Path()
      ..moveTo(34, 25)
      ..quadraticBezierTo(50, 14, 66, 25)
      ..lineTo(64, 22)
      ..quadraticBezierTo(50, 18, 36, 22)
      ..close();
    canvas.drawPath(hatCrown, Paint()..color = const Color(0xFF634832));
    canvas.drawPath(hatCrown, outline..strokeWidth = 2.0);

    // Fedora Brim
    final hatBrim = Path()
      ..moveTo(24, 26)
      ..quadraticBezierTo(50, 20, 76, 26)
      ..quadraticBezierTo(50, 29, 24, 26);
    canvas.drawPath(hatBrim, Paint()..color = const Color(0xFF7D5B3F));
    canvas.drawPath(hatBrim, outline);

    // Ribbon band
    final band = Path()
      ..moveTo(33, 25)
      ..quadraticBezierTo(50, 22, 67, 25);
    canvas.drawPath(band, Paint()..color = const Color(0xFF26180E)..style = PaintingStyle.stroke..strokeWidth = 3);

    // Trenchcoat Collar & Magnifying Glass
    final collarL = Path()
      ..moveTo(36, 50)
      ..lineTo(44, 64)
      ..lineTo(32, 60)
      ..close();
    canvas.drawPath(collarL, Paint()..color = const Color(0xFF8B6343));
    canvas.drawPath(collarL, outline..strokeWidth = 1.8);

    final collarR = Path()
      ..moveTo(64, 50)
      ..lineTo(56, 64)
      ..lineTo(68, 60)
      ..close();
    canvas.drawPath(collarR, Paint()..color = const Color(0xFF8B6343));
    canvas.drawPath(collarR, outline);

    // Magnifying glass held in hand
    canvas.drawLine(const Offset(30, 68), const Offset(22, 78), outline..strokeWidth = 3.5);
    canvas.drawCircle(const Offset(32, 66), 9.0, Paint()..color = Colors.cyan.withValues(alpha: 0.35));
    canvas.drawCircle(const Offset(32, 66), 9.0, outline..strokeWidth = 2.2..color = HushbugColors.accentYellow);
    outline.color = const Color(0xFF1E1A2E);
  }

  void _paintPartyHatAndPopper(Canvas canvas, Paint outline) {
    // Party Cone Hat
    final hat = Path()
      ..moveTo(40, 22)
      ..lineTo(50, 4)
      ..lineTo(60, 22)
      ..close();
    canvas.drawPath(hat, Paint()..color = HushbugColors.accentYellow);
    canvas.drawPath(hat, outline..strokeWidth = 1.8);

    // Hat Stripes
    final stripe = Path()
      ..moveTo(44, 15)
      ..quadraticBezierTo(50, 17, 56, 15);
    canvas.drawPath(stripe, Paint()..color = HushbugColors.imposterRed..style = PaintingStyle.stroke..strokeWidth = 2.5);

    // Pom-pom
    canvas.drawCircle(const Offset(50, 3.5), 3.5, Paint()..color = Colors.pinkAccent);

    // Confetti Popper in hand
    final horn = Path()
      ..moveTo(22, 54)
      ..lineTo(14, 46)
      ..lineTo(26, 42)
      ..close();
    canvas.drawPath(horn, Paint()..color = Colors.pinkAccent);
    canvas.drawPath(horn, outline);

    // Raised Happy Paws
    final paw = Paint()..color = const Color(0xFFFFD39B);
    canvas.drawCircle(const Offset(22, 48), 4.5, paw);
    canvas.drawCircle(const Offset(78, 48), 4.5, paw);
  }

  void _paintResearcherGlasses(Canvas canvas, Paint outline) {
    // Wire-rimmed golden glasses
    final rimPaint = Paint()
      ..color = HushbugColors.accentYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(const Offset(43, 33), 6.5, rimPaint);
    canvas.drawCircle(const Offset(57, 33), 6.5, rimPaint);
    // Bridge
    canvas.drawLine(const Offset(49.5, 33), const Offset(50.5, 33), rimPaint);
  }

  void _paintResearcherBooks(Canvas canvas, Paint outline) {
    // Stack of books below the mascot
    final book1 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(18, 86, 64, 10),
      const Radius.circular(3),
    );
    canvas.drawRRect(book1, Paint()..color = const Color(0xFF4C1D95));
    canvas.drawRRect(book1, outline..strokeWidth = 1.8);

    final book2 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(24, 78, 54, 9),
      const Radius.circular(3),
    );
    canvas.drawRRect(book2, Paint()..color = const Color(0xFF6D28D9));
    canvas.drawRRect(book2, outline);
  }

  @override
  bool shouldRepaint(covariant HushbugMascotPainter old) =>
      old.shell != shell ||
      old.mood != mood ||
      old.accent != accent ||
      old.antennaLAngle != antennaLAngle ||
      old.antennaRAngle != antennaRAngle ||
      old.eyeScaleY != eyeScaleY ||
      old.coverEyes != coverEyes;
}
