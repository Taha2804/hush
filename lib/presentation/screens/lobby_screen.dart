import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/game_controller.dart';
import '../../app/providers.dart';
import '../../domain/game_engine.dart';
import '../theme.dart';
import '../widgets/mascot.dart' show HeroFloatingMascot;
import '../widgets/neon.dart';
import '../widgets/visuals.dart';

/// Home: mascot with a mystery card, one big Play button, online and word
/// sources, and a bottom bar for stats, achievements and custom words.
class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final game = ref.watch(gameProvider);
    final hasActiveRound = game.round != null && game.round?.phase != GamePhase.result;

    return NeonBackdrop(
      lamp: true,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final roomy = c.maxHeight > 700;
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              child: Column(children: [
                // Profile pill and settings.
                Row(children: [
                  Semantics(
                    button: true,
                    label: 'Level ${stats.playerLevel}, ${stats.totalGames} games. Open stats',
                    child: InkWell(
                      onTap: () => context.push('/stats'),
                      borderRadius: BorderRadius.circular(26),
                      child: GlassPanel(
                        radius: 26,
                        padding: const EdgeInsets.fromLTRB(5, 5, 14, 5),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: HushbugColors.neonPurpleGradient),
                            alignment: Alignment.center,
                            child: Text('${stats.playerLevel}',
                                style: const TextStyle(fontFamily: 'Fredoka', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                          const SizedBox(width: 10),
                          Text('${stats.totalGames} games',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                        ]),
                      ),
                    ),
                  ),
                  const Spacer(),
                  NeonRoundButton(icon: Icons.settings_rounded, label: 'Settings', onPressed: () => context.push('/settings')),
                ]),

                // Mascot scene.
                Expanded(
                  child: Stack(alignment: Alignment.center, children: [
                    const Positioned(left: 4, top: 30, child: _FloatingIcon(icon: Icons.person_search_rounded, angle: -0.18)),
                    const Positioned(right: 4, top: 80, child: _FloatingIcon(icon: Icons.search_rounded, angle: 0.2)),
                    Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(
                        width: 250,
                        height: roomy ? 230 : 170,
                        child: Stack(alignment: Alignment.center, children: [
                          HeroFloatingMascot(size: roomy ? 170 : 130),
                          Positioned(right: 6, bottom: roomy ? 30 : 14, child: const _MysteryCard()),
                        ]),
                      ),
                      const SizedBox(height: 4),
                      const Text('Hushbug',
                          style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: [Shadow(color: Color(0x99A06BFF), blurRadius: 18)])),
                      const Text('Everyone knows the word. Except one.',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: HushbugColors.textSubtext)),
                    ]),
                  ]),
                ),

                // Actions.
                if (hasActiveRound) ...[
                  TactileButton(
                    onPressed: () => context.push('/play'),
                    style: TactileButtonStyle.golden,
                    height: 70,
                    icon: const Icon(Icons.play_arrow_rounded, size: 34),
                    child: const Text('Continue game', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(height: 12),
                  TactileButton(
                    onPressed: () => context.push('/setup'),
                    style: TactileButtonStyle.secondary,
                    height: 52,
                    child: const Text('New game'),
                  ),
                ] else
                  TactileButton(
                    onPressed: () => context.push('/setup'),
                    style: TactileButtonStyle.golden,
                    height: 74,
                    icon: const Icon(Icons.play_arrow_rounded, size: 38),
                    child: const Text('Play', style: TextStyle(fontSize: 24)),
                  ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: TactileButton(
                      onPressed: () => context.push('/multiplayer'),
                      style: TactileButtonStyle.neonPurple,
                      height: 58,
                      icon: const Icon(Icons.groups_rounded, size: 26),
                      child: const Text('Online'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TactileButton(
                      onPressed: () => context.push('/source'),
                      style: TactileButtonStyle.neonPurple,
                      height: 58,
                      icon: const Icon(Icons.sports_esports_rounded, size: 26),
                      child: const Text('Words'),
                    ),
                  ),
                ]),
                const SizedBox(height: 14),

                // Bottom bar.
                GlassPanel(
                  radius: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    NeonRoundButton(icon: Icons.home_rounded, label: 'Home', active: true, onPressed: () {}),
                    NeonRoundButton(icon: Icons.bar_chart_rounded, label: 'Stats', onPressed: () => context.push('/stats')),
                    NeonRoundButton(icon: Icons.emoji_events_rounded, label: 'Achievements', onPressed: () => context.push('/achievements')),
                    NeonRoundButton(icon: Icons.menu_book_rounded, label: 'My words', onPressed: () => context.push('/mywords')),
                  ]),
                ),
              ]),
            );
          },
        ),
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  const _FloatingIcon({required this.icon, required this.angle});
  final IconData icon;
  final double angle;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Transform.rotate(
          angle: angle,
          child: GlassPanel(
            radius: 20,
            padding: const EdgeInsets.all(14),
            child: Icon(icon, size: 36, color: const Color(0xFFC9B0FF)),
          ),
        ),
      );
}

/// The glowing "?" card the mascot shows off.
class _MysteryCard extends StatefulWidget {
  const _MysteryCard();

  @override
  State<_MysteryCard> createState() => _MysteryCardState();
}

class _MysteryCardState extends State<_MysteryCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 0.5;
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) => Transform.rotate(
            angle: 0.22 + 0.04 * (_c.value - 0.5),
            child: Container(
              width: 70,
              height: 92,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFF9EC2), Color(0xFFE0559A)]),
                border: Border.all(color: HushbugColors.accentYellowLight, width: 3),
                boxShadow: [BoxShadow(color: HushbugColors.accentYellow.withValues(alpha: 0.5 + 0.3 * _c.value), blurRadius: 22)],
              ),
              alignment: Alignment.center,
              child: const Text('?',
                  style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: HushbugColors.accentYellowLight,
                      shadows: [Shadow(color: Color(0xCCFFC61A), blurRadius: 12)])),
            ),
          ),
        ),
      );
}

