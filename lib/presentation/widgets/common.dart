import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/gen/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Whether animations should be reduced (setting or OS preference).
bool reduceMotionOf(BuildContext context, WidgetRef ref) =>
    ref.watch(settingsProvider).reduceMotion || MediaQuery.of(context).disableAnimations;

/// Centers content with a max width so tablets/desktops look good.
class Body extends StatelessWidget {
  const Body({super.key, required this.child, this.maxWidth = 640, this.padding});
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        // Size to the child vertically; otherwise Align expands to fill all
        // available height (e.g. inside bottomNavigationBar).
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(padding: padding ?? const EdgeInsets.symmetric(horizontal: 16), child: child),
        ),
      );
}

/// Space/Enter = next, Esc = back, for mouse + keyboard play.
class KeyNav extends StatelessWidget {
  const KeyNav({super.key, required this.child, this.onNext, this.onBack});
  final Widget child;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.space): ?onNext,
          const SingleActivator(LogicalKeyboardKey.enter): ?onNext,
          const SingleActivator(LogicalKeyboardKey.numpadEnter): ?onNext,
          const SingleActivator(LogicalKeyboardKey.escape): ?onBack,
        },
        child: Focus(autofocus: true, child: child),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
        child: Row(children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
          ?trailing,
        ]),
      );
}

/// Simple countdown with pause/resume used by clue + discussion timers.
class CountdownController extends ChangeNotifier {
  CountdownController(this.total);
  final int total;
  late int remaining = total;
  Timer? _t;
  bool get running => _t != null;
  bool get finished => remaining <= 0;
  VoidCallback? onFinished;
  VoidCallback? onTick;

  void start() {
    if (_t != null || finished) return;
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      remaining--;
      onTick?.call();
      if (remaining <= 0) {
        remaining = 0;
        stop();
        onFinished?.call();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void stop() {
    _t?.cancel();
    _t = null;
    notifyListeners();
  }

  void toggle() => running ? stop() : start();

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }
}

String formatSeconds(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

class TimerRing extends StatelessWidget {
  const TimerRing({super.key, required this.controller, this.size = 200});
  final CountdownController controller;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final f = controller.total == 0 ? 0.0 : controller.remaining / controller.total;
        final low = controller.remaining <= 10;
        return Semantics(
          liveRegion: true,
          label: formatSeconds(controller.remaining),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: f,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  backgroundColor: cs.surfaceContainerHighest,
                  color: low ? cs.error : cs.primary,
                ),
              ),
              Text(formatSeconds(controller.remaining),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()])),
            ]),
          ),
        );
      },
    );
  }
}

/// Lightweight confetti burst painted with CustomPainter (no packages).
class Confetti extends StatefulWidget {
  const Confetti({super.key, this.enabled = true});
  final bool enabled;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));
  final _rnd = math.Random();
  late final List<_Piece> _pieces = List.generate(
    90,
    (_) => _Piece(
      x: _rnd.nextDouble(),
      delay: _rnd.nextDouble() * 0.35,
      speed: 0.55 + _rnd.nextDouble() * 0.6,
      drift: (_rnd.nextDouble() - 0.5) * 0.3,
      spin: _rnd.nextDouble() * 10,
      size: 6 + _rnd.nextDouble() * 7,
      hue: _rnd.nextDouble() * 360,
    ),
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();
    return IgnorePointer(
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(painter: _ConfettiPainter(_pieces, _c.value), size: Size.infinite),
        ),
      ),
    );
  }
}

class _Piece {
  _Piece({required this.x, required this.delay, required this.speed, required this.drift, required this.spin, required this.size, required this.hue});
  final double x, delay, speed, drift, spin, size, hue;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);
  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final y = -20 + local * p.speed * (size.height + 60);
      final x = (p.x + p.drift * local + math.sin(local * 8 + p.spin) * 0.02) * size.width;
      final paint = Paint()
        ..color = HSVColor.fromAHSV((1 - local * 0.6).clamp(0, 1), p.hue, 0.75, 0.95).toColor();
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin + local * 12);
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
              const Radius.circular(1.5)),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}

Future<bool> confirmDialog(BuildContext context, {required String title, String? body, required String action}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: body == null ? null : Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(context.l10n.cancel)),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(action)),
      ],
    ),
  );
  return r ?? false;
}

void toast(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
}

String noticeText(BuildContext context, String? code) {
  final l = context.l10n;
  return switch (code) {
    'offline_using_cache' => l.noticeCache,
    'offline_using_packs' => l.noticePacks,
    'no_words' => l.noticeNoWords,
    'fake_fallback' => l.noticeFakeFallback,
    null => '',
    _ => code,
  };
}
