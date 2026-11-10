import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/models/game_stats.dart';
import '../theme.dart';
import '../widgets/mascot.dart';
import '../widgets/visuals.dart';

/// Screen for the Daily Word Challenge mode.
class DailyChallengeScreen extends ConsumerWidget {
  const DailyChallengeScreen({super.key});

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
                      'Daily Secret Mission',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mascot Stage
                      Column(
                        children: [
                          const Mascot(size: 130, mood: MascotMood.researcher),
                          const SizedBox(height: 12),
                          const Text(
                            "Today's Curated Mystery",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'One unified secret word challenge worldwide every 24 hours. Play with your squad and see how fast you uncover the imposter!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: HushbugColors.textSubtext, fontSize: 13),
                          ),
                        ],
                      ),

                      // Card Info
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: HushbugColors.cardSurface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: HushbugColors.cardBorder, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('CHALLENGE THEME',
                                    style: TextStyle(
                                        color: HushbugColors.textSubtext, fontSize: 10, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: HushbugColors.neonPurple.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('DAY #42',
                                      style: TextStyle(
                                          color: HushbugColors.neonPurpleLight,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Interstellar Astronomy',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: HushbugColors.cardBorder, height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('Streak',
                                        style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11)),
                                    const SizedBox(height: 2),
                                    Text('${stats.dailyStreak} Days 🔥',
                                        style: const TextStyle(
                                            color: Colors.orangeAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Mode',
                                        style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11)),
                                    const SizedBox(height: 2),
                                    const Text('Hint Mode',
                                        style: TextStyle(
                                            color: HushbugColors.accentYellow, fontSize: 15, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Clue Limit',
                                        style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11)),
                                    const SizedBox(height: 2),
                                    const Text('1 Round',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Start Action
                      TactileButton(
                        onPressed: () {
                          // Configure daily topic and route to setup/play
                          ref.read(settingsProvider.notifier).update((s) => s.copyWith(
                                game: s.game.copyWith(
                                  categories: const ['technology'],
                                  randomMix: false,
                                ),
                              ));
                          context.push('/setup');
                        },
                        style: TactileButtonStyle.golden,
                        height: 56,
                        icon: const Icon(Icons.flash_on_rounded, color: HushbugColors.onAccentYellow, size: 24),
                        child: const Text('Play Daily Challenge'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
