import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../theme.dart';
import '../widgets/mascot.dart';

class _Avail {
  const _Avail(this.ok, this.reason);
  final bool ok;
  final String? reason;
}

final _availabilityProvider = FutureProvider.autoDispose.family<_Avail, String>((ref, id) async {
  final src = ref.watch(registryProvider).byId(id);
  final ok = await src.isAvailable();
  return _Avail(ok, ok ? null : await src.unavailableReason());
});

/// Screen 3: Choose Word Source matching Prototype stitch_flutter_imposter_party_game (7).
class SourceSelectScreen extends ConsumerWidget {
  const SourceSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final current = ref.watch(currentSourceProvider) ?? 'offline';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: HushbugColors.scaffoldGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar with Peeking Mascot
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 8),
                child: Column(
                  children: [
                    // Peeking Mascot on top of navigation
                    const PeekingCornerMascot(width: 80, height: 44),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/lobby');
                            }
                          },
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
                          'Choose Word Source',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 44), // Balancer
                      ],
                    ),
                  ],
                ),
              ),

              // Main Selection Area
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    // Card 1: Online Search
                    _SourceCard(
                      sourceId: 'online',
                      isSelected: current == 'online',
                      icon: Icons.public_rounded,
                      iconBg: HushbugColors.neonPurple.withValues(alpha: 0.2),
                      iconBorder: HushbugColors.neonPurpleLight.withValues(alpha: 0.5),
                      iconColor: HushbugColors.neonPurpleLight,
                      title: 'Online Search',
                      description: 'Find fresh words from Wikipedia & Wikidata',
                      statusBadge: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x2E10B981),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: const Color(0x6610B981), width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 3, backgroundColor: Color(0xFF34D399)),
                            SizedBox(width: 6),
                            Text(
                              'Live API connection ready',
                              style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        ref.read(currentSourceProvider.notifier).set('online');
                        context.go('/setup');
                      },
                    ),
                    const SizedBox(height: 14),

                    // Card 2: Offline Packs
                    _SourceCard(
                      sourceId: 'offline',
                      isSelected: current == 'offline',
                      icon: Icons.layers_rounded,
                      iconBg: Colors.amber.withValues(alpha: 0.15),
                      iconBorder: Colors.amber.withValues(alpha: 0.4),
                      iconColor: const Color(0xFFFFD166),
                      title: 'Offline Packs',
                      description: 'Play anytime with 22 packs (3,386 words)',
                      statusBadge: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: HushbugColors.neonPurple.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: HushbugColors.neonPurple.withValues(alpha: 0.35), width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wb_sunny_rounded, color: HushbugColors.accentYellow, size: 12),
                            SizedBox(width: 5),
                            Text(
                              'Always Available',
                              style: TextStyle(color: HushbugColors.neonPurpleLight, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        ref.read(currentSourceProvider.notifier).set('offline');
                        context.go('/setup');
                      },
                    ),
                    const SizedBox(height: 14),

                    // Card 3: Custom Topic / My Words
                    _SourceCard(
                      sourceId: 'mywords',
                      isSelected: current == 'mywords',
                      icon: Icons.search_rounded,
                      iconBg: Colors.pinkAccent.withValues(alpha: 0.15),
                      iconBorder: Colors.pinkAccent.withValues(alpha: 0.4),
                      iconColor: Colors.pinkAccent,
                      title: 'Custom Topic',
                      description: 'Search any topic and create your own pack',
                      statusBadge: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.pink.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.3), width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('✨', style: TextStyle(fontSize: 11)),
                            SizedBox(width: 5),
                            Text(
                              'My Words',
                              style: TextStyle(color: Colors.pinkAccent, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        ref.read(currentSourceProvider.notifier).set('mywords');
                        context.push('/mywords');
                      },
                    ),
                  ],
                ),
              ),

              // Bottom Preferences Toggle Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: HushbugColors.cardSurface.withValues(alpha: 0.95),
                  border: const Border(top: BorderSide(color: Color(0x337351D8), width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: HushbugColors.neonPurpleLight, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Ask me every time the app opens',
                          style: TextStyle(
                            color: HushbugColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: settings.askSourceEveryLaunch,
                      activeColor: Colors.white,
                      activeTrackColor: HushbugColors.neonPurple,
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: const Color(0xFF25194D),
                      onChanged: (v) => ref.read(settingsProvider.notifier).update((s) => s.copyWith(askSourceEveryLaunch: v)),
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
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.sourceId,
    required this.isSelected,
    required this.icon,
    required this.iconBg,
    required this.iconBorder,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.statusBadge,
    required this.onTap,
  });

  final String sourceId;
  final bool isSelected;
  final IconData icon;
  final Color iconBg;
  final Color iconBorder;
  final Color iconColor;
  final String title;
  final String description;
  final Widget statusBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF261B58) : HushbugColors.cardSurface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? HushbugColors.cardBorderActive : HushbugColors.cardBorder,
              width: isSelected ? 2.0 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: HushbugColors.neonPurple.withValues(alpha: 0.35),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Glowing Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: iconBorder, width: 1.2),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              // Content Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: HushbugColors.textSubtext,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    statusBadge,
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Checkmark or radio indicator
              if (isSelected)
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
                    ),
                    boxShadow: [
                      BoxShadow(color: Color(0x66A855F7), blurRadius: 8, spreadRadius: 1),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 16),
                  ),
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E1733),
                    border: Border.all(color: HushbugColors.cardBorder, width: 1.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
