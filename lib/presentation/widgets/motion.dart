import 'dart:async';

import 'package:flutter/material.dart';

/// Strong ease-out for things entering or changing on screen.
const easeOutStrong = Cubic(0.23, 1, 0.32, 1);

/// A UI duration that collapses to zero when the player asked for reduced motion.
Duration motionDuration(BuildContext context, int ms) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : Duration(milliseconds: ms);

/// Fade plus a short rise, for content that swaps in place (phases, turns).
Widget swapTransition(Widget child, Animation<double> animation) {
  final curved = CurvedAnimation(parent: animation, curve: easeOutStrong);
  return FadeTransition(
    opacity: curved,
    child: SlideTransition(
      position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(curved),
      child: child,
    ),
  );
}

/// Plays a one-time entrance: fade, a few pixels of rise, optional slight
/// scale-up. Use [delay] to stagger a group (30-80 ms apart).
class Appear extends StatefulWidget {
  const Appear({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.rise = 8,
    this.scaleFrom = 1,
    this.durationMs = 220,
  });

  final Widget child;
  final Duration delay;
  final double rise;
  final double scaleFrom;
  final int durationMs;

  @override
  State<Appear> createState() => _AppearState();
}

class _AppearState extends State<Appear> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Duration(milliseconds: widget.durationMs));
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: easeOutStrong);
  Timer? _delay;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
    } else if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      _delay = Timer(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _t,
        child: widget.child,
        builder: (context, child) {
          final v = _t.value;
          return Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, widget.rise * (1 - v)),
              child: widget.scaleFrom == 1 ? child : Transform.scale(scale: widget.scaleFrom + (1 - widget.scaleFrom) * v, child: child),
            ),
          );
        },
      );
}
