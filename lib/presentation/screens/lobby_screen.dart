import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/game_controller.dart';
import '../../app/providers.dart';
import '../../domain/game_engine.dart';
import '../theme.dart';
import '../widgets/mascot.dart';
import '../widgets/visuals.dart';

/// Screen 1: Home Screen matching Part 3, Screen 1 redesign requirements.
class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _playPulseCtrl;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _playPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.028).animate(
      CurvedAnimation(parent: _playPulseCtrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _playPulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final stats = ref.watch(statsProvider);
    final gameSession = ref.watch(gameProvider);
    final hasActiveRound = gameSession.round != null && gameSession.round?.phase != GamePhase.result;

    final now = DateTime.now().toUtc();
    final endOfDay = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);
    final diff = endOfDay.difference(now);
    final resetCountdown = 'Resets in ${diff.inHours}h ${diff.inMinutes % 60}m';

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
              // Bottom-left Peeking Mascot in the background
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: HushbugColors.cardSurface.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: HushbugColors.cardBorder, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: HushbugColors.neonPurple,
                                  child: Text(
                                    '${stats.playerLevel}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${stats.currentWinStreak} Streak 🔥',
                                  style: const TextStyle(
                                    color: HushbugColors.accentYellow,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: HushbugColors.textSubtext,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${stats.totalGames} Games',
                                  style: const TextStyle(
                                    color: HushbugColors.textSubtext,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
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
                        const SizedBox(height: 10),
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
                          'Find the faker. Keep the secret.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: HushbugColors.textSubtext,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),

                    // Daily Challenge Section Card
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push('/daily'),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: HushbugColors.cardSurface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: stats.dailyChallengeCompleted
                                  ? HushbugColors.civilianEmerald.withValues(alpha: 0.5)
                                  : HushbugColors.neonPurple.withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: stats.dailyChallengeCompleted
                                      ? HushbugColors.civilianBg
                                      : HushbugColors.neonPurple.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  stats.dailyChallengeCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.auto_awesome_rounded,
                                  color: stats.dailyChallengeCompleted
                                      ? HushbugColors.civilianEmerald
                                      : HushbugColors.accentYellow,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'DAILY CHALLENGE',
                                          style: TextStyle(
                                            color: HushbugColors.textPrimary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          stats.dailyChallengeCompleted ? 'Completed' : resetCountdown,
                                          style: TextStyle(
                                            color: stats.dailyChallengeCompleted
                                                ? HushbugColors.civilianEmerald
                                                : HushbugColors.accentYellow,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      stats.dailyChallengeCompleted
                                          ? 'Daily streak extended! See your challenge results.'
                                          : "Today's Mystery Word: Explore clues with friends.",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: HushbugColors.textSubtext,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right_rounded, color: HushbugColors.textSubtext, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Primary Action CTAs with subtle idle pulse & peeking mascot
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Mascot peeking from behind the Play button
                            const Positioned(
                              top: -24,
                              right: 20,
                              child: PeekingCornerMascot(width: 60, height: 38),
                            ),
                            // Big Golden Play Button with subtle breathing animation
                            AnimatedBuilder(
                              animation: _playPulseCtrl,
                              builder: (context, child) => Transform.scale(
                                scale: _pulseScale.value,
                                child: child,
                              ),
                              child: TactileButton(
                                onPressed: () => context.push('/setup'),
                                style: TactileButtonStyle.golden,
                                height: 56,
                                icon: const Icon(Icons.play_arrow_rounded, color: HushbugColors.onAccentYellow, size: 28),
                                child: const Text('Play Game'),
                              ),
                            ),
                          ],
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
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
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
