import 'package:flutter/material.dart';

import '../theme.dart';
import 'mascot.dart';

/// Hushbug's loading indicator: the mascot hopping with three pulsing dots.
class HushbugLoader extends StatefulWidget {
  const HushbugLoader({super.key, this.size = 90, this.text, this.mood = MascotMood.detective});

  final double size;
  final String? text;
  final MascotMood mood;

  @override
  State<HushbugLoader> createState() => _HushbugLoaderState();
}

class _HushbugLoaderState extends State<HushbugLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
      _c.value = 0.5;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final small = widget.size < 60;
    return Semantics(
      label: widget.text ?? 'Loading',
      liveRegion: true,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            // A little hop: up quickly, settle back down.
            final t = _c.value;
            final hop = t < 0.5 ? Curves.easeOut.transform(t * 2) : Curves.easeIn.transform((1 - t) * 2);
            return Column(mainAxisSize: MainAxisSize.min, children: [
              Transform.translate(
                offset: Offset(0, -widget.size * 0.12 * hop),
                child: Transform.scale(
                  scaleX: 1 + 0.04 * (1 - hop),
                  scaleY: 1 - 0.04 * (1 - hop),
                  child: Mascot(size: widget.size, mood: widget.mood),
                ),
              ),
              SizedBox(height: small ? 4 : 10),
              Row(mainAxisSize: MainAxisSize.min, children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    width: small ? 6 : 9,
                    height: small ? 6 : 9,
                    margin: EdgeInsets.symmetric(horizontal: small ? 2 : 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: HushbugColors.neonPurpleLight.withValues(
                        alpha: 0.3 + 0.7 * (1 - ((t * 3 - i) % 3).abs().clamp(0.0, 1.0)),
                      ),
                    ),
                  ),
              ]),
              if (widget.text != null) ...[
                SizedBox(height: small ? 4 : 10),
                Text(widget.text!, textAlign: TextAlign.center, style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ]);
          },
        ),
      ),
    );
  }
}
