import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/game_controller.dart';
import '../../app/providers.dart';
import '../../domain/game_engine.dart';
import '../theme.dart';
import '../widgets/mascot.dart';
import '../widgets/visuals.dart';

/// Screen 1: Home Lobby matching Prototype stitch_flutter_imposter_party_game (1).
class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final gameSession = ref.watch(gameProvider);
    final hasActiveRound = gameSession.round != null && gameSession.round?.phase != GamePhase.result;
    final players = settings.game.players;

    // Calculate total squad score from scoreboard
    final totalScore = settings.scores.values.fold<int>(0, (sum, val) => sum + val);
    final displayScore = totalScore > 0 ? totalScore * 100 : 1240;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: HushbugColors.scaffoldGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Bottom Peeking Mascot in the background
              const Positioned(
                bottom: -8,
                left: -12,
                child: PeekingCornerMascot(width: 110, height: 80),
              ),
              // Main Foreground Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar Header with Player Profile, Win Streak, and Settings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Player Profile & Win Streak pill
                        InkWell(
                          onTap: () => context.push('/stats'),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: HushbugColors.cardSurface.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: HushbugColors.cardBorder, width: 1),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 11,
                                  backgroundColor: HushbugColors.neonPurple,
                                  child: Icon(Icons.person_rounded, size: 14, color: Colors.white),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '3 Win Streak 🔥',
                                  style: TextStyle(
                                    color: HushbugColors.accentYellow,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right Shortcuts: Daily Mission & Settings
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Daily Mission',
                              onPressed: () => context.push('/daily'),
                              style: IconButton.styleFrom(
                                backgroundColor: HushbugColors.cardSurface.withValues(alpha: 0.8),
                                foregroundColor: HushbugColors.accentYellow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(color: HushbugColors.cardBorder, width: 1),
                                ),
                              ),
                              icon: const Icon(Icons.flash_on_rounded, size: 20),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Settings',
                              onPressed: () => context.push('/settings'),
                              style: IconButton.styleFrom(
                                backgroundColor: HushbugColors.cardSurface.withValues(alpha: 0.8),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(color: HushbugColors.cardBorder, width: 1),
                                ),
                              ),
                              icon: const Icon(Icons.settings_rounded, size: 20),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Hero Mascot & Game Branding
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HeroFloatingMascot(size: 130),
                        const SizedBox(height: 12),
                        const Text(
                          'Hushbug',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(color: Color(0x997351D8), blurRadius: 20, offset: Offset(0, 4)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'The Word Deduction Party Game',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: HushbugColors.textSubtext,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),

                    // Primary Action CTAs
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Big Golden Play Button
                        TactileButton(
                          onPressed: () => context.push('/setup'),
                          style: TactileButtonStyle.golden,
                          height: 56,
                          icon: const Icon(Icons.play_arrow_rounded, color: HushbugColors.onAccentYellow, size: 28),
                          child: const Text('Play Game'),
                        ),
                        if (hasActiveRound) ...[
                          const SizedBox(height: 10),
                          // Continue Game Button
                          TactileButton(
                            onPressed: () => context.push('/play'),
                            style: TactileButtonStyle.secondary,
                            height: 48,
                            icon: const Icon(Icons.replay_rounded, color: HushbugColors.neonPurpleLight, size: 22),
                            badge: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: HushbugColors.civilianEmerald,
                                boxShadow: [
                                  BoxShadow(
                                    color: HushbugColors.civilianEmerald,
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            child: const Text('Continue Game'),
                          ),
                        ],
                      ],
                    ),

                    // 5-Tile Feature Hub Grid
                    Row(
                      children: [
                        // Stats Tile
                        Expanded(
                          child: _HubTile(
                            icon: Icons.bar_chart_rounded,
                            iconColor: HushbugColors.neonPurpleLight,
                            iconBg: HushbugColors.neonPurple.withValues(alpha: 0.2),
                            label: 'Stats',
                            onTap: () => context.push('/stats'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Achievements / Trophies Tile
                        Expanded(
                          child: _HubTile(
                            icon: Icons.emoji_events_rounded,
                            iconColor: HushbugColors.accentYellow,
                            iconBg: Colors.amber.withValues(alpha: 0.2),
                            label: 'Badges',
                            onTap: () => context.push('/achievements'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Word Source Tile
                        Expanded(
                          child: _HubTile(
                            icon: Icons.layers_rounded,
                            iconColor: const Color(0xFF818CF8),
                            iconBg: const Color(0xFF4338CA).withValues(alpha: 0.3),
                            label: 'Source',
                            badge: true,
                            onTap: () => context.push('/source'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Online / Multiplayer Tile
                        Expanded(
                          child: _HubTile(
                            icon: Icons.cell_tower_rounded,
                            iconColor: Colors.cyanAccent,
                            iconBg: Colors.cyan.withValues(alpha: 0.2),
                            label: 'Online',
                            onTap: () => context.push('/multiplayer'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Custom Packs Tile
                        Expanded(
                          child: _HubTile(
                            icon: Icons.inventory_2_rounded,
                            iconColor: Colors.pinkAccent,
                            iconBg: Colors.pink.withValues(alpha: 0.2),
                            label: 'Packs',
                            onTap: () => context.push('/mywords'),
                          ),
                        ),
                      ],
                    ),

                    // Squad Snapshot Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: HushbugColors.cardSurface.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: HushbugColors.cardBorder, width: 1.2),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'YOUR SQUAD',
                                style: TextStyle(
                                  color: HushbugColors.textSubtext,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              PlayerAvatarCluster(players: players),
                            ],
                          ),
                          // Squad Points Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF171322),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: HushbugColors.accentYellow.withValues(alpha: 0.3),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.emoji_events_rounded, color: HushbugColors.accentYellow, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  '$displayScore',
                                  style: const TextStyle(
                                    color: HushbugColors.accentYellow,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Text(
                                  ' pts',
                                  style: TextStyle(
                                    color: HushbugColors.textSubtext,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatsDialog(BuildContext context, List<String> players, Map<String, int> scores) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HushbugColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: HushbugColors.accentYellow),
            SizedBox(width: 8),
            Text('Squad Scoreboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < players.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          PlayerAvatar(index: i, name: players[i], radius: 14),
                          const SizedBox(width: 10),
                          Text(players[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Text(
                        '${(scores[players[i]] ?? 0) * 100} pts',
                        style: const TextStyle(color: HushbugColors.accentYellow, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: HushbugColors.neonPurpleLight)),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: HushbugColors.cardSurface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: HushbugColors.cardBorder, width: 1.2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (badge)
                Positioned(
                  top: -2,
                  right: 8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: HushbugColors.civilianEmerald,
                    ),
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: HushbugColors.textSubtext,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
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
