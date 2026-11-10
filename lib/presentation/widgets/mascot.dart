import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme.dart';

enum MascotMood {
  shush,
  suspicious,
  happy,
  sad,
  detective,
  celebrating,
  researcher,
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
        painter: _PeekingMascotPainter(isDetective: isDetective),
      ),
    );
  }
}

class _PeekingMascotPainter extends CustomPainter {
  _PeekingMascotPainter({this.isDetective = false});
  final bool isDetective;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    canvas.save();
    canvas.scale(s);

    final outline = Paint()
      ..color = const Color(0xFF1E1A2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    // Antennae
    final pL = Path()
      ..moveTo(38, 38)
      ..quadraticBezierTo(28, 22, 22, 24);
    canvas.drawPath(pL, outline);
    canvas.drawCircle(const Offset(22, 24), 3.5, Paint()..color = HushbugColors.accentYellow);

    final pR = Path()
      ..moveTo(62, 38)
      ..quadraticBezierTo(72, 22, 78, 24);
    canvas.drawPath(pR, outline);
    canvas.drawCircle(const Offset(78, 24), 3.5, Paint()..color = HushbugColors.accentYellow);

    // Head / body peeking up
    const headC = Offset(50, 52);
    canvas.drawCircle(headC, 28, Paint()..color = HushbugColors.neonPurple);
    canvas.drawCircle(headC, 24, Paint()..color = const Color(0xFFFFE0BD));
    canvas.drawCircle(headC, 24, outline);

    // Blush
    final blush = Paint()..color = const Color(0xFFFF8FA3).withValues(alpha: 0.6);
    canvas.drawCircle(const Offset(38, 56), 4, blush);
    canvas.drawCircle(const Offset(62, 56), 4, blush);

    // Eyes looking up
    canvas.drawCircle(const Offset(43, 46), 4.2, Paint()..color = const Color(0xFF15131D));
    canvas.drawCircle(const Offset(44, 44.5), 1.6, Paint()..color = Colors.white);

    canvas.drawCircle(const Offset(57, 46), 4.2, Paint()..color = const Color(0xFF15131D));
    canvas.drawCircle(const Offset(58, 44.5), 1.6, Paint()..color = Colors.white);

    // Smile
    final mouth = Path()
      ..moveTo(47, 54)
      ..quadraticBezierTo(50, 57, 53, 54);
    canvas.drawPath(mouth, outline);

    if (isDetective) {
      // Fedora Brim & Crown
      final fedora = Path()
        ..moveTo(26, 42)
        ..quadraticBezierTo(50, 36, 74, 42)
        ..lineTo(70, 26)
        ..quadraticBezierTo(50, 20, 30, 26)
        ..close();
      canvas.drawPath(fedora, Paint()..color = const Color(0xFF6B4C35));
      canvas.drawPath(fedora, outline);
      // Fedora Band
      final band = Path()
        ..moveTo(28, 40)
        ..quadraticBezierTo(50, 35, 72, 40);
      canvas.drawPath(band, Paint()..color = const Color(0xFF2A1A10)..strokeWidth = 3..style = PaintingStyle.stroke);
    }

    // Paws clutching frame border
    final skin = Paint()..color = const Color(0xFFFFD39B);
    final pawL = RRect.fromRectAndRadius(const Rect.fromLTWH(30, 56, 12, 10), const Radius.circular(5));
    canvas.drawRRect(pawL, skin);
    canvas.drawRRect(pawL, outline);

    final pawR = RRect.fromRectAndRadius(const Rect.fromLTWH(58, 56, 12, 10), const Radius.circular(5));
    canvas.drawRRect(pawR, skin);
    canvas.drawRRect(pawR, outline);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PeekingMascotPainter old) => old.isDetective != isDetective;
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
      case MascotMood.suspicious:
        drawStandardEye(43, squint: true);
        drawStandardEye(57);
        break;
      case MascotMood.happy:
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
        final p = Path()
          ..moveTo(44, 40)
          ..quadraticBezierTo(50, 48, 56, 40);
        canvas.drawPath(p, outline);
        canvas.drawPath(p, Paint()..color = const Color(0xFF831843));
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
