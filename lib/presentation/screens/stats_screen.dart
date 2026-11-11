import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/models/game_stats.dart';
import '../theme.dart';
import '../widgets/mascot.dart';

/// Screen for Detailed Player Statistics, History, and Progression.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: HushbugColors.scaffoldGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: HushbugColors.cardSurface.withValues(alpha: 0.8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: HushbugColors.cardBorder, width: 1),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                    const Text(
                      'Player Statistics & History',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    // Profile & Level Banner
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: HushbugColors.cardSurface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: HushbugColors.neonPurple.withValues(alpha: 0.4), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Mascot(size: 72, mood: MascotMood.detective),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Level ${stats.playerLevel} Agent',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: HushbugColors.accentYellow.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('${stats.playerXp} XP',
                                          style: const TextStyle(
                                              color: HushbugColors.accentYellow,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: (stats.playerXp % 250) / 250,
                                    backgroundColor: const Color(0xFF1E1733),
                                    valueColor: const AlwaysStoppedAnimation(HushbugColors.accentYellow),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${250 - (stats.playerXp % 250)} XP to Level ${stats.playerLevel + 1}',
                                  style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text('PERFORMANCE METRICS',
                        style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),

                    // Metrics 4-Grid
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Total Games',
                            value: '${stats.totalGames}',
                            icon: Icons.sports_esports_rounded,
                            color: HushbugColors.neonPurpleLight,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            label: 'Win Rate',
                            value: '${stats.winPercentage.toStringAsFixed(0)}%',
                            icon: Icons.pie_chart_rounded,
                            color: HushbugColors.civilianEmerald,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Crew Victories',
                            value: '${stats.crewVictories}',
                            icon: Icons.shield_rounded,
                            color: HushbugColors.civilianEmerald,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            label: 'Imposter Wins',
                            value: '${stats.imposterVictories}',
                            icon: Icons.masks_rounded,
                            color: HushbugColors.imposterRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Favorite Pack',
                            value: stats.mostPlayedCategory,
                            icon: Icons.category_rounded,
                            color: HushbugColors.accentYellow,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text('RECENT GAME HISTORY',
                        style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),

                    if (stats.history.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: HushbugColors.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: HushbugColors.cardBorder),
                        ),
                        child: const Center(
                          child: Text(
                            'Play games to record match history!',
                            style: TextStyle(color: HushbugColors.textSubtext, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      for (final record in stats.history) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: HushbugColors.cardSurface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: record.winner == 'crew'
                                  ? HushbugColors.civilianEmerald.withValues(alpha: 0.3)
                                  : HushbugColors.imposterRed.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: record.winner == 'crew'
                                              ? HushbugColors.civilianEmerald.withValues(alpha: 0.2)
                                              : HushbugColors.imposterRed.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          record.winner == 'crew' ? 'CREW VICTORY' : 'IMPOSTER WIN',
                                          style: TextStyle(
                                            color: record.winner == 'crew'
                                                ? HushbugColors.civilianEmerald
                                                : HushbugColors.imposterRed,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        record.category,
                                        style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Word: ${record.secretWord}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    'Imposter: ${record.imposters.join(", ")}',
                                    style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 11),
                                  ),
                                ],
                              ),
                              const Icon(Icons.chevron_right_rounded, color: HushbugColors.textMuted),
                            ],
                          ),
                        ),
                      ],
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HushbugColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HushbugColors.cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
