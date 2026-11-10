import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/prefs/settings.dart';
import '../../domain/models/game_config.dart';
import '../theme.dart';
import '../widgets/common.dart';

final _onlineCacheSizeProvider = FutureProvider.autoDispose<int>((ref) => ref.watch(onlineSourceProvider).cacheSize());
final _offlineInfoProvider = FutureProvider.autoDispose<(int, int)>((ref) async {
  final packs = await ref.watch(offlineSourceProvider).packs();
  return (packs.length, packs.fold<int>(0, (a, p) => a + p.count));
});
final _myWordsInfoProvider = FutureProvider.autoDispose<(int, int)>((ref) async {
  final packs = await ref.watch(myWordsSourceProvider).packs();
  return (packs.length, packs.fold<int>(0, (a, p) => a + p.wordCount));
});

/// Game rules only. Everything else lives in [AppPreferencesScreen].
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final g = ref.watch(settingsProvider.select((s) => s.game));
    final n = ref.read(settingsProvider.notifier);
    void game(GameConfig Function(GameConfig) f) => n.update((s) => s.copyWith(game: f(s.game)));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.gameRules)),
      body: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
        Body(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Text(l.gameRulesIntro, style: TextStyle(color: cs.onSurfaceVariant)),
            ),

            // ---------------- Round flow ----------------
            _Section(icon: Icons.loop_rounded, title: l.secRoundFlow, children: [
              _Choice<int>(
                title: l.discussionTimer,
                description: g.discussionSeconds == 0
                    ? l.discussionTimerOffDesc
                    : l.discussionTimerOnDesc(l.minutes(g.discussionSeconds ~/ 60)),
                value: g.discussionSeconds,
                options: {0: l.off, for (var m = 1; m <= 10; m++) m * 60: l.minutes(m)},
                onChanged: (v) => game((g) => g.copyWith(discussionSeconds: v)),
              ),
              _Choice<int>(
                title: l.clueRounds,
                description: l.clueRoundsDesc,
                value: g.clueRounds,
                options: const {1: '1', 2: '2'},
                onChanged: (v) => game((g) => g.copyWith(clueRounds: v)),
              ),
              _Choice<int>(
                title: l.speedRound,
                description: l.speedRoundSettingDesc,
                value: g.speedRound ? g.speedSeconds : 0,
                options: {0: l.off, for (final x in [10, 15, 20, 30]) x: l.seconds(x)},
                onChanged: (v) => game((g) => g.copyWith(speedRound: v > 0, speedSeconds: v > 0 ? v : g.speedSeconds)),
              ),
              _Choice<RevealStyle>(
                title: l.revealStyle,
                description: g.revealStyle == RevealStyle.hold ? l.revealHoldDesc : l.revealTapDesc,
                value: g.revealStyle,
                options: {RevealStyle.hold: l.revealHold, RevealStyle.tap: l.revealTap},
                onChanged: (v) => game((g) => g.copyWith(revealStyle: v)),
              ),
              _Choice<SeatingMode>(
                title: l.seating,
                description:
                    g.seating == SeatingMode.seatingFromStarter ? l.seatingFromStarterDesc : l.seatingShuffledDesc,
                value: g.seating,
                options: {SeatingMode.seatingFromStarter: l.seatingFromStarter, SeatingMode.fullyShuffled: l.seatingShuffled},
                onChanged: (v) => game((g) => g.copyWith(seating: v)),
              ),
            ]),

            // ---------------- Imposter rules ----------------
            _Section(icon: Icons.person_search_rounded, title: l.secImposterRules, children: [
              _Choice<HintDifficulty>(
                title: l.hintLevel,
                description: l.hintLevelDesc,
                value: g.hintDifficulty,
                options: {HintDifficulty.easy: l.easy, HintDifficulty.medium: l.medium, HintDifficulty.hard: l.hard},
                onChanged: (v) => game((g) => g.copyWith(hintDifficulty: v)),
              ),
              _Switch(
                title: l.avoidSameImposter,
                description: l.avoidSameImposterDesc,
                value: g.avoidSameImposter,
                onChanged: (v) => game((g) => g.copyWith(avoidSameImposter: v)),
              ),
              _Switch(
                title: l.lastChanceSetting,
                description: l.lastChanceSettingDesc,
                value: g.lastChance,
                onChanged: (v) => game((g) => g.copyWith(lastChance: v)),
              ),
              _Switch(
                title: l.maybeNobody,
                description: l.maybeNobodySettingDesc,
                value: g.maybeNobody,
                onChanged: (v) => game((g) => g.copyWith(maybeNobody: v)),
              ),
              if (g.maybeNobody)
                ListTile(
                  title: Text('${l.maybeNobodyChance}: ${(g.maybeNobodyChance * 100).round()}%'),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.maybeNobodyChanceDesc),
                    Slider(
                      value: g.maybeNobodyChance,
                      min: 0.05,
                      max: 0.5,
                      divisions: 9,
                      label: '${(g.maybeNobodyChance * 100).round()}%',
                      onChanged: (v) => game((g) => g.copyWith(maybeNobodyChance: v)),
                    ),
                  ]),
                ),
            ]),

            // ---------------- Voting & scoring ----------------
            _Section(icon: Icons.how_to_vote_rounded, title: l.secVoting, children: [
              _Choice<VoteStyle>(
                title: l.voteStyle,
                description: g.voteStyle == VoteStyle.simple ? l.voteSimpleDesc : l.votePrivateDesc,
                value: g.voteStyle,
                options: {VoteStyle.simple: l.voteSimple, VoteStyle.private: l.votePrivate},
                onChanged: (v) => game((g) => g.copyWith(voteStyle: v)),
              ),
              _Choice<TieRule>(
                title: l.tieRule,
                description: g.tieRule == TieRule.revote ? l.tieRevoteDesc : l.tieImpostersDesc,
                value: g.tieRule,
                options: {TieRule.revote: l.tieRevote, TieRule.impostersWin: l.tieImposters},
                onChanged: (v) => game((g) => g.copyWith(tieRule: v)),
              ),
              _Switch(
                title: l.scoreboardSetting,
                description: l.scoreboardDesc,
                value: g.scoreboard,
                onChanged: (v) => game((g) => g.copyWith(scoreboard: v)),
              ),
            ]),

            // ---------------- Fun extras ----------------
            _Section(icon: Icons.celebration_rounded, title: l.secFun, subtitle: l.secFunDesc, children: [
              _Switch(
                title: l.roundTwists,
                description: l.roundTwistsDesc,
                value: g.roundTwists,
                onChanged: (v) => game((g) => g.copyWith(roundTwists: v)),
              ),
              _Switch(
                title: l.impostersKnowEachOther,
                description: l.impostersKnowEachOtherDesc,
                value: g.impostersKnowEachOther,
                onChanged: (v) => game((g) => g.copyWith(impostersKnowEachOther: v)),
              ),
              _Switch(
                title: l.crewStarts,
                description: l.crewStartsDesc,
                value: g.crewStarts,
                onChanged: (v) => game((g) => g.copyWith(crewStarts: v)),
              ),
            ]),

            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.tune_rounded),
                title: Text(l.appPreferences, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(l.appPreferencesDesc),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/settings/app'),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// Theme, language, sound, start-up and word-data settings.
class AppPreferencesScreen extends ConsumerWidget {
  const AppPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    void set(AppSettings Function(AppSettings) f) => n.update(f);

    return Scaffold(
      appBar: AppBar(title: Text(l.appPreferences)),
      body: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
        Body(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _Section(icon: Icons.palette_rounded, title: l.appearance, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.theme),
                  const SizedBox(height: 8),
                  SegmentedButton<AppThemeMode>(
                    segments: [
                      ButtonSegment(value: AppThemeMode.system, label: Text(l.themeSystem)),
                      ButtonSegment(value: AppThemeMode.light, label: Text(l.themeLight)),
                      ButtonSegment(value: AppThemeMode.dark, label: Text(l.themeDark)),
                      ButtonSegment(value: AppThemeMode.amoled, label: Text(l.themeAmoled)),
                    ],
                    selected: {s.themeMode},
                    onSelectionChanged: (v) => set((s) => s.copyWith(themeMode: v.first)),
                  ),
                  const SizedBox(height: 16),
                  Text(l.accentColor),
                  const SizedBox(height: 8),
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    for (var i = 0; i < accentColors.length; i++)
                      Semantics(
                        label: '${l.accentColor} ${i + 1}',
                        selected: s.accent == i,
                        button: true,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => set((s) => s.copyWith(accent: i)),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: accentColors[i],
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: s.accent == i ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                                  width: 3),
                            ),
                            child: s.accent == i ? const Icon(Icons.check_rounded, color: Colors.white) : null,
                          ),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 16),
                  Text(l.language),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'en', label: Text('English')),
                      ButtonSegment(value: 'hi', label: Text('हिन्दी')),
                    ],
                    selected: {s.language},
                    onSelectionChanged: (v) => set((s) => s.copyWith(language: v.first)),
                  ),
                  const SizedBox(height: 16),
                  Text('${l.textSize}: ${(s.textScale * 100).round()}%'),
                  Slider(
                    value: s.textScale,
                    min: 0.85,
                    max: 1.5,
                    divisions: 13,
                    label: '${(s.textScale * 100).round()}%',
                    onChanged: (v) => set((s) => s.copyWith(textScale: v)),
                  ),
                ]),
              ),
            ]),
            _Section(icon: Icons.volume_up_rounded, title: '${l.sound} & ${l.haptics}', children: [
              _Switch(title: l.sound, description: l.soundDesc, value: s.sound, onChanged: (v) => set((s) => s.copyWith(sound: v))),
              _Switch(
                  title: l.haptics, description: l.hapticsDesc, value: s.haptics, onChanged: (v) => set((s) => s.copyWith(haptics: v))),
              _Switch(
                  title: l.reduceMotion,
                  description: l.reduceMotionDesc,
                  value: s.reduceMotion,
                  onChanged: (v) => set((s) => s.copyWith(reduceMotion: v))),
            ]),
            _Section(icon: Icons.rocket_launch_rounded, title: l.startup, children: [
              _Switch(
                title: l.askEveryLaunch,
                description: l.askEveryLaunchDesc,
                value: s.askSourceEveryLaunch,
                onChanged: (v) => set((s) => s.copyWith(askSourceEveryLaunch: v)),
              ),
            ]),
            _Section(icon: Icons.storage_rounded, title: l.dataSection, children: [
              Consumer(builder: (context, ref, _) {
                final size = ref.watch(_onlineCacheSizeProvider).value;
                return ListTile(
                  leading: const Icon(Icons.travel_explore_rounded),
                  title: Text(l.sourceOnlineName),
                  subtitle: Text(size == null ? l.loading : l.cachedWords(size)),
                  trailing: Wrap(children: [
                    IconButton(
                      tooltip: l.refresh,
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () {
                        final online = ref.read(onlineSourceProvider);
                        final cats = s.selectedCategories['online'] ?? const ['animals', 'food'];
                        for (final c in cats) {
                          online.refresh(c).then((_) => ref.invalidate(_onlineCacheSizeProvider)).catchError((_) {});
                        }
                        toast(context, l.refreshing);
                      },
                    ),
                    IconButton(
                      tooltip: l.clearCache,
                      icon: const Icon(Icons.delete_sweep_rounded),
                      onPressed: () async {
                        await ref.read(onlineSourceProvider).clearCache();
                        await ref.read(stateStoreProvider).clearSource('online');
                        ref.invalidate(_onlineCacheSizeProvider);
                        if (context.mounted) toast(context, l.cacheCleared);
                      },
                    ),
                  ]),
                );
              }),
              Consumer(builder: (context, ref, _) {
                final info = ref.watch(_offlineInfoProvider).value;
                return ListTile(
                  leading: const Icon(Icons.inventory_2_rounded),
                  title: Text(l.sourceOfflineName),
                  subtitle: Text(info == null ? l.loading : l.packsInfo(info.$1, info.$2)),
                );
              }),
              Consumer(builder: (context, ref, _) {
                final info = ref.watch(_myWordsInfoProvider).value;
                return ListTile(
                  leading: const Icon(Icons.edit_note_rounded),
                  title: Text(l.sourceMyWordsName),
                  subtitle: Text(info == null ? l.loading : l.packsInfo(info.$1, info.$2)),
                  trailing: IconButton(
                    tooltip: l.deleteAllPacks,
                    icon: Icon(Icons.delete_forever_rounded, color: Theme.of(context).colorScheme.error),
                    onPressed: info == null || info.$1 == 0
                        ? null
                        : () async {
                            if (!await confirmDialog(context,
                                title: l.deleteAllPacks, body: l.deleteAllPacksConfirm, action: l.delete)) {
                              return;
                            }
                            await ref.read(myWordsSourceProvider).deleteAllPacks();
                            await ref.read(stateStoreProvider).clearSource('mywords');
                            set((s) => s.copyWith(selectedCategories: {...s.selectedCategories}..remove('mywords')));
                            ref.invalidate(_myWordsInfoProvider);
                            if (context.mounted) toast(context, l.allPacksDeleted);
                          },
                  ),
                );
              }),
              ListTile(
                leading: const Icon(Icons.history_rounded),
                title: Text(l.resetHistory),
                onTap: () async {
                  final store = ref.read(stateStoreProvider);
                  await store.kv.deletePrefix('bag:');
                  await store.kv.deletePrefix('hint:');
                  await store.kv.deletePrefix('fake:');
                  await store.saveHistory(const []);
                  if (context.mounted) toast(context, l.historyReset);
                },
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.children, this.subtitle});
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
        child: Row(children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: cs.primary)),
              if (subtitle != null) Text(subtitle!, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
            ]),
          ),
        ]),
      ),
      Card(
        child: Column(children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            children[i],
          ],
        ]),
      ),
    ]);
  }
}

class _Switch extends StatelessWidget {
  const _Switch({required this.title, required this.description, required this.value, required this.onChanged});
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 2), child: Text(description)),
        value: value,
        onChanged: onChanged,
      );
}

class _Choice<T> extends StatelessWidget {
  const _Choice({
    required this.title,
    required this.description,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String title;
  final String description;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = options.containsKey(value) ? value : options.keys.first;
    // Few options -> tappable chips under the text; many -> a dropdown.
    final Widget picker = options.length <= 4
        ? Wrap(spacing: 8, runSpacing: 4, children: [
            for (final e in options.entries)
              ChoiceChip(
                label: Text(e.value),
                selected: e.key == current,
                onSelected: (_) => onChanged(e.key),
              ),
          ])
        : DropdownButton<T>(
            value: current,
            items: [for (final e in options.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
            onChanged: (v) => v == null ? null : onChanged(v),
          );
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 2, bottom: 8), child: Text(description)),
        picker,
        const SizedBox(height: 4),
      ]),
    );
  }
}
