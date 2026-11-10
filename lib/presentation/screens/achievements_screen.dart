import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/models/game_stats.dart';
import '../theme.dart';
import '../widgets/mascot.dart';

/// Screen for Achievements and Progression Rewards.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    IconData getIcon(String name) {
      switch (name) {
        case 'masks':
          return Icons.masks_rounded;
        case 'search':
          return Icons.search_rounded;
        case 'visibility_off':
          return Icons.visibility_off_rounded;
        case 'shield':
          return Icons.shield_rounded;
        case 'record_voice_over':
          return Icons.record_voice_over_rounded;
        case 'celebration':
          return Icons.celebration_rounded;
        default:
          return Icons.emoji_events_rounded;
      }
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: HushbugColors.scaffoldGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
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
                      'Trophies & Badges',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // Hero Mascot Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: HushbugColors.cardSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: HushbugColors.neonPurple.withValues(alpha: 0.4), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Mascot(size: 70, mood: MascotMood.celebrating),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Agent Milestones',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(
                              'Unlock badges by mastering social deduction, deception, and deduction.',
                              style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Achievement List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: defaultAchievements.length,
                  itemBuilder: (context, index) {
                    final item = defaultAchievements[index];
                    final isUnlocked = item.unlocked;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? const Color(0xFF221C34)
                            : HushbugColors.cardSurface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isUnlocked
                              ? HushbugColors.accentYellow.withValues(alpha: 0.6)
                              : HushbugColors.cardBorder,
                          width: isUnlocked ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isUnlocked
                                  ? HushbugColors.accentYellow.withValues(alpha: 0.2)
                                  : const Color(0xFF1E1730),
                              border: Border.all(
                                color: isUnlocked ? HushbugColors.accentYellow : HushbugColors.cardBorder,
                              ),
                            ),
                            child: Icon(
                              getIcon(item.iconName),
                              color: isUnlocked ? HushbugColors.accentYellow : HushbugColors.textMuted,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        color: isUnlocked ? Colors.white : HushbugColors.textSubtext,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (isUnlocked)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: HushbugColors.civilianEmerald.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('UNLOCKED',
                                            style: TextStyle(
                                                color: HushbugColors.civilianEmerald,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 11),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (item.progress / item.maxProgress).clamp(0.0, 1.0),
                                    backgroundColor: const Color(0xFF171228),
                                    valueColor: AlwaysStoppedAnimation(
                                      isUnlocked ? HushbugColors.civilianEmerald : HushbugColors.neonPurple,
                                    ),
                                    minHeight: 5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
