import 'package:flutter/material.dart';

import '../theme.dart';
import 'visuals.dart';

/// Shared pieces of the neon look: glass panels, round glass buttons, player
/// seats with crown/tick badges, step dots and timer bars.

/// Full-screen neon background with an optional warm lamp glow at the top.
class NeonBackdrop extends StatelessWidget {
  const NeonBackdrop({super.key, required this.child, this.lamp = false});
  final Widget child;
  final bool lamp;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: HushbugColors.background,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: HushbugColors.scaffoldGradient),
          child: Stack(children: [
            if (lamp)
              Positioned(
                top: -60,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [Color(0x55FFB45A), Color(0x00FFB45A)]),
                    ),
                  ),
                ),
              ),
            Positioned.fill(child: child),
          ]),
        ),
      );
}

/// Frosted purple glass panel with a soft lavender edge.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 28,
    this.glow = false,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool glow;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0x59462882),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor ?? const Color(0x59BE96FF), width: 1.5),
          boxShadow: glow ? const [BoxShadow(color: Color(0x40A06BFF), blurRadius: 22)] : null,
        ),
        child: child,
      );
}

/// Round glass icon button (48dp minimum) with a label for screen readers.
class NeonRoundButton extends StatelessWidget {
  const NeonRoundButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.size = 52,
    this.active = false,
    this.color,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final double size;
  final bool active;
  final Color? color;
  final Widget? badge;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: Tooltip(
          message: label,
          child: InkResponse(
            onTap: onPressed,
            radius: size / 2 + 6,
            child: Stack(clipBehavior: Clip.none, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: active
                      ? const RadialGradient(colors: [Color(0xFF6A3FD0), Color(0xFF3E2286)])
                      : null,
                  color: active ? null : const Color(0x73462882),
                  border: Border.all(
                    color: active ? HushbugColors.accentYellow : const Color(0x73BE96FF),
                    width: active ? 2.5 : 1.5,
                  ),
                  boxShadow: active ? const [BoxShadow(color: Color(0x80FFC61A), blurRadius: 16)] : null,
                ),
                child: Icon(icon, size: size * 0.46, color: color ?? (active ? HushbugColors.accentYellow : const Color(0xFFE6D2FF))),
              ),
              if (badge != null) Positioned(top: -3, right: -3, child: badge!),
            ]),
          ),
        ),
      );
}

/// Small yellow count badge.
class NeonCount extends StatelessWidget {
  const NeonCount(this.count, {super.key});
  final int count;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 20),
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(color: HushbugColors.accentYellow, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Text(count > 99 ? '99+' : '$count',
            style: const TextStyle(color: HushbugColors.onAccentYellow, fontSize: 11, fontWeight: FontWeight.w900)),
      );
}

/// A player in a glowing ring, with optional crown (host), tick (ready/done)
/// or custom badge.
class NeonSeat extends StatelessWidget {
  const NeonSeat({
    super.key,
    required this.name,
    this.avatarIndex,
    this.size = 70,
    this.crown = false,
    this.tick = false,
    this.highlight = false,
    this.dim = false,
    this.ringColor,
    this.badge,
    this.showName = true,
    this.caption,
    this.captionColor,
  });

  final String name;
  final int? avatarIndex;
  final double size;
  final bool crown;
  final bool tick;
  final bool highlight;
  final bool dim;
  final Color? ringColor;
  final Widget? badge;
  final bool showName;
  final String? caption;
  final Color? captionColor;

  @override
  Widget build(BuildContext context) {
    final ring = ringColor ?? (highlight ? const Color(0xFFF0C8FF) : const Color(0x8CBE96FF));
    return Semantics(
      label: [name, if (crown) 'host', if (tick) 'ready', if (caption != null) caption!].join(', '),
      child: Opacity(
        opacity: dim ? 0.5 : 1,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(center: Alignment(0, -0.3), colors: [Color(0xFF3E2584), Color(0xFF22124A)]),
                border: Border.all(color: ring, width: highlight ? 3 : 2.2),
                boxShadow: highlight
                    ? [BoxShadow(color: ring.withValues(alpha: 0.7), blurRadius: 20), BoxShadow(color: ring.withValues(alpha: 0.25), spreadRadius: 5)]
                    : null,
              ),
              alignment: Alignment.center,
              child: PlayerAvatar(index: 0, name: name, radius: size * 0.36, avatarIndex: avatarIndex),
            ),
            if (crown)
              Positioned(
                top: -size * 0.32,
                child: Icon(Icons.workspace_premium_rounded, size: size * 0.42, color: HushbugColors.accentYellow,
                    shadows: const [Shadow(color: Color(0xAAFFC61A), blurRadius: 10)]),
              ),
            if (tick)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2FC46B),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1A0D38), width: 3),
                  ),
                  child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
                ),
              ),
            if (badge != null) Positioned(right: -4, bottom: -4, child: badge!),
          ]),
          if (showName) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: size + 24,
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: highlight ? HushbugColors.accentYellow : Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
            ),
          ],
          if (caption != null)
            Text(caption!, style: TextStyle(color: captionColor ?? HushbugColors.textSubtext, fontSize: 12, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}

/// Progress dots, the current one long and glowing.
class StepDots extends StatelessWidget {
  const StepDots({super.key, required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Step ${current + 1} of $count',
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == current ? 30 : 22,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: i < current ? const Color(0xFF9B6BFF) : (i == current ? const Color(0xFFE6D2FF) : const Color(0xFF3B2470)),
                boxShadow: i == current ? const [BoxShadow(color: Color(0xAAE6D2FF), blurRadius: 10)] : null,
              ),
            ),
        ]),
      );
}

/// Pill-shaped timer bar with an hourglass.
class NeonTimerBar extends StatelessWidget {
  const NeonTimerBar({super.key, required this.fraction, this.label, this.width = 240, this.urgent = false});
  final double fraction;
  final String? label;
  final double width;
  final bool urgent;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label == null ? 'Time left' : '$label left',
        child: GlassPanel(
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SizedBox(
            width: width,
            child: Row(children: [
              const Icon(Icons.hourglass_bottom_rounded, size: 18, color: HushbugColors.accentYellow),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: fraction.clamp(0, 1)),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 12,
                      backgroundColor: const Color(0xFF2A1658),
                      color: urgent ? HushbugColors.imposterRed : HushbugColors.accentYellow,
                    ),
                  ),
                ),
              ),
              if (label != null) ...[
                const SizedBox(width: 8),
                Text(label!, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ]),
          ),
        ),
      );
}

/// Big screen title in the display font.
class NeonTitle extends StatelessWidget {
  const NeonTitle(this.text, {super.key, this.size = 28, this.color = Colors.white});
  final String text;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Fredoka', fontSize: size, fontWeight: FontWeight.w600, color: color, height: 1.1),
      );
}
