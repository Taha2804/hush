import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/game_controller.dart';
import '../../app/providers.dart';
import '../../app/services.dart';
import '../../data/prefs/settings.dart';
import '../../domain/models/game_config.dart';
import '../../domain/models/power_cards.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import '../widgets/visuals.dart';
import 'player_groups.dart';

/// (id, display name) of each category for a source.
final categoriesProvider = FutureProvider.autoDispose.family<List<(String, String)>, String>((ref, sourceId) async {
  final registry = ref.watch(registryProvider);
  if (sourceId == 'mywords') {
    final packs = await registry.myWords.packs();
    return [for (final p in packs) if (p.wordCount > 0) ('my${p.id}', p.name)];
  }
  final packs = await registry.offline.packs();
  return [for (final p in packs) (p.id, p.name)];
});

/// Screen 2: Game Setup matching Prototype stitch_flutter_imposter_party_game (3).
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final List<TextEditingController> _names = [];

  @override
  void initState() {
    super.initState();
    for (final n in ref.read(settingsProvider).game.players) {
      _names.add(TextEditingController(text: n));
    }
  }

  @override
  void dispose() {
    for (final c in _names) {
      c.dispose();
    }
    super.dispose();
  }

  void _updateGame(GameConfig Function(GameConfig g) f) =>
      ref.read(settingsProvider.notifier).update((s) => s.copyWith(game: f(s.game)));

  void _syncPlayers() {
    final names = <String>[];
    for (var i = 0; i < _names.length; i++) {
      final t = _names[i].text.trim();
      names.add(t.isEmpty ? 'Player ${i + 1}' : t);
    }
    _updateGame((g) => g.copyWith(
          players: names,
          imposterCount: g.imposterCount.clamp(1, GameConfig.maxImpostersFor(names.length)),
        ));
  }

  void _addPlayer() {
    if (_names.length >= GameConfig.maxPlayers) return;
    setState(() {
      _names.add(TextEditingController(text: 'Player ${_names.length + 1}'));
    });
    _syncPlayers();
    final s = ref.read(settingsProvider);
    ref.read(soundProvider).play('pop', enabled: s.sound);
    Haptics.light(enabled: s.haptics);
  }

  void _loadGroup(PlayerGroup group) {
    setState(() {
      for (final c in _names) {
        c.dispose();
      }
      _names
        ..clear()
        ..addAll([for (final p in group.players.take(GameConfig.maxPlayers)) TextEditingController(text: p)]);
      while (_names.length < GameConfig.minPlayers) {
        _names.add(TextEditingController(text: 'Player ${_names.length + 1}'));
      }
    });
    _syncPlayers();
    toast(context, 'Group "${group.name}" loaded with ${_names.length} players');
  }

  void _removePlayer(int i) {
    if (_names.length <= GameConfig.minPlayers) return;
    setState(() {
      _names.removeAt(i).dispose();
    });
    _syncPlayers();
    Haptics.tick(enabled: ref.read(settingsProvider).haptics);
  }

  void _editPlayerDialog(int i) {
    final name = _names[i].text;
    final ctrl = TextEditingController(text: name);
    final currentAvatar = ref.read(settingsProvider).playerAvatars[name] ?? (i % 8);
    var selectedAvatar = currentAvatar;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: HushbugColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              PlayerAvatar(index: i, name: ctrl.text, radius: 18, avatarIndex: selectedAvatar),
              const SizedBox(width: 10),
              Text('Player ${i + 1} Profile', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Player Name'),
                  onChanged: (val) => setDialogState(() {}),
                ),
                const SizedBox(height: 16),
                const Text('Choose Avatar Costume', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var a = 0; a < 8; a++)
                      GestureDetector(
                        onTap: () {
                          setDialogState(() => selectedAvatar = a);
                          Haptics.tick(enabled: ref.read(settingsProvider).haptics);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedAvatar == a ? HushbugColors.accentYellow : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PlayerAvatar(index: i, name: ctrl.text, radius: 20, avatarIndex: a),
                              const SizedBox(height: 2),
                              Text(
                                avatarIndexName(a).split(' ').first,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: selectedAvatar == a ? HushbugColors.accentYellow : HushbugColors.textSubtext,
                                  fontWeight: selectedAvatar == a ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            if (_names.length > GameConfig.minPlayers)
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _removePlayer(i);
                },
                child: const Text('Remove', style: TextStyle(color: HushbugColors.imposterRed)),
              ),
            FilledButton(
              onPressed: () {
                final newName = ctrl.text.trim().isEmpty ? 'Player ${i + 1}' : ctrl.text.trim();
                setState(() {
                  _names[i].text = newName;
                });
                ref.read(settingsProvider.notifier).update((s) => s.copyWith(
                      playerAvatars: {...s.playerAvatars, newName: selectedAvatar},
                    ));
                _syncPlayers();
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _start() async {
    final l = context.l10n;
    _syncPlayers();
    final settings = ref.read(settingsProvider);
    final source = ref.read(currentSourceProvider) ?? 'offline';
    final selected = settings.selectedCategories[source] ?? const [];
    final g = settings.game;

    if (g.players.length < GameConfig.minPlayers) {
      toast(context, l.needThreePlayers);
      return;
    }
    if (!g.randomMix && selected.isEmpty) {
      toast(context, l.pickCategory);
      return;
    }
    _updateGame((g) => g.copyWith(categories: selected));
    final ok = await ref.read(gameProvider.notifier).startRound();
    if (!mounted) return;
    final session = ref.read(gameProvider);
    if (ok) {
      context.push('/play');
    } else {
      toast(context, session.error == 'no_words' ? l.noticeNoWords : (session.error ?? l.noticeNoWords));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final g = settings.game;
    final source = ref.watch(currentSourceProvider) ?? 'offline';
    final cats = ref.watch(categoriesProvider(source));
    final selected = settings.selectedCategories[source] ?? const <String>[];
    final loading = ref.watch(gameProvider.select((s) => s.loading));

    final sourceTitle = switch (source) {
      'online' => 'Online Search',
      'mywords' => 'My Words',
      _ => 'Offline Packs',
    };
    final sourceSubtitle = switch (source) {
      'online' => 'Wikipedia + Wikidata + Live APIs',
      'mywords' => 'Personal custom packs & topics',
      _ => '22 packs (3,386 words) Always Available',
    };

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
              Column(
                children: [
                  // Top Navigation Header with Peeking Mascot Perch
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
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
                          'Setup Game',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        // Presets Action
                        IconButton(
                          tooltip: 'Player Groups',
                          onPressed: () {
                            _syncPlayers();
                            showPlayerGroupsSheet(
                              context,
                              currentPlayers: ref.read(settingsProvider).game.players,
                              onLoad: _loadGroup,
                            );
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: HushbugColors.cardSurface.withValues(alpha: 0.8),
                            foregroundColor: HushbugColors.neonPurpleLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: HushbugColors.cardBorder, width: 1),
                            ),
                          ),
                          icon: const Icon(Icons.groups_rounded, size: 20),
                        ),
                      ],
                    ),
                  ),

                  // Main Scrollable Configuration Area
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 90),
                      children: [
                        // SECTION 1: PLAYERS SQUAD CAROUSEL
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PLAYERS (${_names.length})',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: HushbugColors.textSubtext,
                                letterSpacing: 1.1,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                _syncPlayers();
                                saveCurrentAsGroup(context, ref, ref.read(settingsProvider).game.players);
                              },
                              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                              icon: const Icon(Icons.bookmark_add_rounded, size: 16, color: HushbugColors.neonPurpleLight),
                              label: const Text('Save Group', style: TextStyle(color: HushbugColors.neonPurpleLight, fontSize: 11)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 0; i < _names.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: GestureDetector(
                                    onTap: () => _editPlayerDialog(i),
                                    child: Column(
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: i == 0
                                                    ? const LinearGradient(
                                                        colors: [Color(0xFFFBBF24), Color(0xFFA855F7)],
                                                      )
                                                    : null,
                                                border: i != 0 ? Border.all(color: HushbugColors.cardBorder, width: 2) : null,
                                              ),
                                              child: PlayerAvatar(index: i, name: _names[i].text, radius: 22),
                                            ),
                                            if (i == 0)
                                              Positioned(
                                                top: -4,
                                                right: -2,
                                                child: Container(
                                                  width: 18,
                                                  height: 18,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: HushbugColors.accentYellow,
                                                    boxShadow: [
                                                      BoxShadow(color: Color(0x66000000), blurRadius: 4),
                                                    ],
                                                  ),
                                                  child: const Center(
                                                    child: Text('👑', style: TextStyle(fontSize: 10)),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        SizedBox(
                                          width: 58,
                                          child: Text(
                                            _names[i].text,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: HushbugColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              // Add Player Button
                              if (_names.length < GameConfig.maxPlayers)
                                GestureDetector(
                                  onTap: _addPlayer,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: HushbugColors.neonPurple.withValues(alpha: 0.15),
                                          border: Border.all(color: HushbugColors.neonPurpleLight.withValues(alpha: 0.4), width: 1.5),
                                        ),
                                        child: const Icon(Icons.add_rounded, color: HushbugColors.neonPurpleLight, size: 24),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Add',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: HushbugColors.textSubtext,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // SECTION 2: WORD SOURCE CARD
                        const Text(
                          'WORD SOURCE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: HushbugColors.textSubtext,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/source'),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: HushbugColors.cardSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: HushbugColors.cardBorder, width: 1.2),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0x2E10B981),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0x6610B981), width: 1),
                                    ),
                                    child: const Icon(Icons.layers_rounded, color: Color(0xFF34D399), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF34D399),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              sourceTitle,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          sourceSubtitle,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: HushbugColors.textSubtext,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: HushbugColors.textSubtext),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // SECTION 3: CATEGORIES TAG CLOUD
                        const Text(
                          'CATEGORIES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: HushbugColors.textSubtext,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        cats.when(
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(color: HushbugColors.neonPurpleLight),
                            ),
                          ),
                          error: (e, _) => Text('Error loading categories: $e', style: const TextStyle(color: Colors.red)),
                          data: (allCats) {
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                // Random Mix Chip
                                ChoiceChip(
                                  label: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shuffle_rounded, size: 14, color: HushbugColors.accentYellow),
                                      SizedBox(width: 5),
                                      Text('Random Mix'),
                                    ],
                                  ),
                                  selected: g.randomMix,
                                  selectedColor: HushbugColors.neonPurple,
                                  backgroundColor: HushbugColors.cardSurface,
                                  labelStyle: TextStyle(
                                    color: g.randomMix ? Colors.white : HushbugColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                  onSelected: (v) => _updateGame((g) => g.copyWith(randomMix: v)),
                                ),
                                // Individual Category Chips
                                for (final (id, name) in allCats)
                                  if (g.randomMix || selected.contains(id))
                                    Chip(
                                      backgroundColor: HushbugColors.cardSurfaceElevated,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(100),
                                        side: BorderSide(
                                          color: !g.randomMix && selected.contains(id)
                                              ? HushbugColors.cardBorderActive
                                              : HushbugColors.cardBorder,
                                        ),
                                      ),
                                      label: Text(
                                        name,
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      deleteIcon: g.randomMix ? null : const Icon(Icons.close_rounded, size: 14, color: HushbugColors.textSubtext),
                                      onDeleted: g.randomMix
                                          ? null
                                          : () {
                                              final next = {...selected}..remove(id);
                                              ref.read(settingsProvider.notifier).update((s) => s.copyWith(
                                                    selectedCategories: {...s.selectedCategories, source: next.toList()},
                                                    game: s.game.copyWith(randomMix: next.isEmpty),
                                                  ));
                                            },
                                    ),
                                // Add Category Button
                                ActionChip(
                                  label: const Text('+ Add', style: TextStyle(color: HushbugColors.neonPurpleLight, fontSize: 12, fontWeight: FontWeight.bold)),
                                  backgroundColor: HushbugColors.cardSurface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    side: const BorderSide(color: HushbugColors.cardBorderActive, style: BorderStyle.solid),
                                  ),
                                  onPressed: () => _showCategoryPickerSheet(context, allCats, selected, source),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        // SECTION 4: GAME MODES 4-GRID
                        const Text(
                          'GAME MODE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: HushbugColors.textSubtext,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _ModeTile(
                                mode: GameMode.classic,
                                icon: Icons.masks_rounded,
                                title: 'Classic',
                                isSelected: g.mode == GameMode.classic && !g.speedRound,
                                onSelect: () => _updateGame((g) => g.copyWith(mode: GameMode.classic, speedRound: false)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ModeTile(
                                mode: GameMode.hint,
                                icon: Icons.lightbulb_rounded,
                                title: 'Hint',
                                isSelected: g.mode == GameMode.hint && !g.speedRound,
                                onSelect: () => _updateGame((g) => g.copyWith(mode: GameMode.hint, speedRound: false)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ModeTile(
                                mode: GameMode.fakeWord,
                                icon: Icons.sync_alt_rounded,
                                title: 'Fake Word',
                                isSelected: g.mode == GameMode.fakeWord && !g.speedRound,
                                onSelect: () => _updateGame((g) => g.copyWith(mode: GameMode.fakeWord, speedRound: false)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ModeTile(
                                mode: GameMode.classic,
                                icon: Icons.bolt_rounded,
                                iconColor: Colors.amber,
                                title: 'Speed',
                                isSelected: g.speedRound,
                                onSelect: () => _updateGame((g) => g.copyWith(speedRound: true)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Maybe Nobody Mode Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: HushbugColors.cardSurfaceElevated,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: g.maybeNobody ? HushbugColors.accentYellow : HushbugColors.cardBorder,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.help_outline_rounded, color: HushbugColors.accentYellow, size: 20),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Maybe Nobody Mode', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                      Text('10% chance there is no imposter (Chaos round)', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                              Switch(
                                value: g.maybeNobody,
                                activeColor: HushbugColors.accentYellow,
                                activeTrackColor: HushbugColors.neonPurple,
                                onChanged: (v) {
                                  _updateGame((g) => g.copyWith(maybeNobody: v));
                                  Haptics.tick(enabled: ref.read(settingsProvider).haptics);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // SECTION 5: TACTICAL PARAMETERS STEPPERS
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: HushbugColors.cardSurface.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: HushbugColors.cardBorder, width: 1.2),
                          ),
                          child: Column(
                            children: [
                              // Imposters Stepper
                              _ParameterRow(
                                icon: Icons.person_rounded,
                                iconColor: Colors.amber,
                                label: 'Imposters',
                                valueText: '${g.imposterCount.clamp(1, g.maxImposters)}',
                                onMinus: g.imposterCount > 1
                                    ? () => _updateGame((g) => g.copyWith(imposterCount: g.imposterCount - 1))
                                    : null,
                                onPlus: g.imposterCount < g.maxImposters
                                    ? () => _updateGame((g) => g.copyWith(imposterCount: g.imposterCount + 1))
                                    : null,
                              ),
                              const Divider(color: HushbugColors.cardBorder, height: 20),
                              // Clue Rounds Stepper
                              _ParameterRow(
                                icon: Icons.timer_rounded,
                                iconColor: HushbugColors.neonPurpleLight,
                                label: 'Clue Rounds',
                                valueText: '${g.clueRounds}',
                                onMinus: g.clueRounds > 1
                                    ? () => _updateGame((g) => g.copyWith(clueRounds: g.clueRounds - 1))
                                    : null,
                                onPlus: g.clueRounds < 5
                                    ? () => _updateGame((g) => g.copyWith(clueRounds: g.clueRounds + 1))
                                    : null,
                              ),
                              const Divider(color: HushbugColors.cardBorder, height: 20),
                              // Discussion Time Stepper
                              _ParameterRow(
                                icon: Icons.chat_bubble_outline_rounded,
                                iconColor: Colors.pinkAccent,
                                label: 'Discussion Time',
                                valueText: g.discussionSeconds == 0 ? 'Off' : '${g.discussionSeconds}s',
                                onMinus: g.discussionSeconds > 30
                                    ? () => _updateGame((g) => g.copyWith(discussionSeconds: g.discussionSeconds - 30))
                                    : null,
                                onPlus: g.discussionSeconds < 360
                                    ? () => _updateGame((g) => g.copyWith(discussionSeconds: g.discussionSeconds + 30))
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // SECTION 6: IMPOSTER DIFFICULTY CARDS
                        const Text(
                          'IMPOSTER DIFFICULTY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: HushbugColors.textSubtext,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _DifficultyCard(
                                title: 'EASY',
                                subtitle: 'Helpful clues',
                                isSelected: g.hintDifficulty == HintDifficulty.easy,
                                color: HushbugColors.civilianEmerald,
                                onSelect: () => _updateGame((g) => g.copyWith(hintDifficulty: HintDifficulty.easy)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _DifficultyCard(
                                title: 'NORMAL',
                                subtitle: 'Vague clues',
                                isSelected: g.hintDifficulty == HintDifficulty.medium,
                                color: HushbugColors.accentYellow,
                                onSelect: () => _updateGame((g) => g.copyWith(hintDifficulty: HintDifficulty.medium)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _DifficultyCard(
                                title: 'EXPERT',
                                subtitle: 'No hints',
                                isSelected: g.hintDifficulty == HintDifficulty.hard,
                                color: HushbugColors.imposterRed,
                                onSelect: () => _updateGame((g) => g.copyWith(hintDifficulty: HintDifficulty.hard)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // SECTION 7: SPECIAL ROUND EVENTS
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: HushbugColors.cardSurface.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: HushbugColors.cardBorder, width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.auto_awesome_rounded, color: HushbugColors.accentYellow, size: 20),
                                      SizedBox(width: 10),
                                      Text(
                                        'Special Round Events',
                                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: g.roundTwists,
                                    activeColor: HushbugColors.accentYellow,
                                    activeTrackColor: HushbugColors.neonPurple,
                                    onChanged: (v) {
                                      _updateGame((g) => g.copyWith(roundTwists: v));
                                      Haptics.tick(enabled: ref.read(settingsProvider).haptics);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Random modifiers (Reverse Round, One Chance, Silent Round, Speed Round, Double Trouble)',
                                style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _showSpecialEventsSheet(context),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'View All 5 Event Rules',
                                        style: TextStyle(color: HushbugColors.neonPurpleLight, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_rounded, color: HushbugColors.neonPurpleLight, size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // SECTION 8: SPECIAL POWER CARDS (OPTIONAL ADVANCED MODE)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: HushbugColors.cardSurface.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: HushbugColors.cardBorder, width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.style_rounded, color: Colors.cyanAccent, size: 20),
                                      SizedBox(width: 10),
                                      Text(
                                        'Special Power Cards',
                                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () => _showPowerCardsSheet(context),
                                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                    child: const Text('View Powers', style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const Text(
                                'Optional abilities (Double Vote, Detective, Shield, Spy, Silence, Second Chance)',
                                style: TextStyle(color: HushbugColors.textSubtext, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 70), // Spacing for floating Start Game CTA
                      ],
                    ),
                  ),
                ],
              ),

              // Pinned Bottom Action Button ("Start Game")
              Positioned(
                left: 20,
                right: 20,
                bottom: 16,
                child: TactileButton(
                  onPressed: loading ? null : _start,
                  style: TactileButtonStyle.neonPurple,
                  height: 56,
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Start Game'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryPickerSheet(
    BuildContext context,
    List<(String, String)> allCats,
    List<String> selected,
    String source,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HushbugColors.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Choose Categories', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close_rounded, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (id, name) in allCats)
                            FilterChip(
                              label: Text(name),
                              selected: selected.contains(id),
                              selectedColor: HushbugColors.neonPurple,
                              backgroundColor: HushbugColors.cardSurfaceElevated,
                              labelStyle: TextStyle(
                                color: selected.contains(id) ? Colors.white : HushbugColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (v) {
                                final next = {...selected};
                                v ? next.add(id) : next.remove(id);
                                ref.read(settingsProvider.notifier).update((s) => s.copyWith(
                                      selectedCategories: {...s.selectedCategories, source: next.toList()},
                                      game: s.game.copyWith(randomMix: false),
                                    ));
                                setSheetState(() {});
                                setState(() {});
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSpecialEventsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HushbugColors.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Mascot(size: 36, mood: MascotMood.detective),
                    SizedBox(width: 10),
                    Text('Special Round Events', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close_rounded, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'When enabled, a surprise event modifier triggers on random rounds to shake up deduction:',
              style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12),
            ),
            const SizedBox(height: 12),
            _eventItem('🔄 Reverse Round', 'Players give their one-word clues in reverse seating order.'),
            _eventItem('🎯 One Chance', 'Each player gets strictly one opportunity to speak—no hesitations!'),
            _eventItem('🤫 Silent Round', 'No verbal talking allowed! Clues must be given using emojis or gestures.'),
            _eventItem('⚡ Speed Round', 'Fast-paced action! Players have only 5 seconds to provide their clue.'),
            _eventItem('👥 Double Trouble', 'Multiple imposters receive completely different secret words!'),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Got It'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventItem(String title, String desc) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: HushbugColors.cardSurfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: HushbugColors.cardBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: HushbugColors.accentYellow, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ),
      );

  void _showPowerCardsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HushbugColors.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.style_rounded, color: Colors.cyanAccent, size: 24),
                    SizedBox(width: 10),
                    Text('Special Power Cards', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close_rounded, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Optional advanced abilities dealt to players for strategic tactical play:',
              style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final card in PowerCard.all)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: HushbugColors.cardSurfaceElevated,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: HushbugColors.cardBorder, width: 1.2),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.cyan.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(card.icon, color: Colors.cyanAccent, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(card.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 2),
                                    Text(card.description, style: const TextStyle(color: HushbugColors.textPrimary, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Text('Limit: ${card.limitation}', style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 10, fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.mode,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onSelect,
    this.iconColor,
  });

  final GameMode mode;
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onSelect;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF281C4F) : HushbugColors.cardSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? HushbugColors.cardBorderActive : HushbugColors.cardBorder,
              width: isSelected ? 2 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(color: HushbugColors.neonPurple.withValues(alpha: 0.35), blurRadius: 12),
                  ]
                : [],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (isSelected)
                const Positioned(
                  top: -8,
                  right: 4,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: HushbugColors.accentYellow,
                    child: Icon(Icons.check, size: 10, color: Colors.black),
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: iconColor ?? (isSelected ? Colors.white : HushbugColors.neonPurpleLight), size: 24),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : HushbugColors.textSubtext,
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

class _ParameterRow extends StatelessWidget {
  const _ParameterRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.valueText,
    required this.onMinus,
    required this.onPlus,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String valueText;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: onMinus,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF271A42),
                foregroundColor: Colors.white,
                minimumSize: const Size(32, 32),
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.remove_rounded, size: 16),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 38,
              child: Text(
                valueText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: onPlus,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF271A42),
                foregroundColor: Colors.white,
                minimumSize: const Size(32, 32),
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
            ),
          ],
        ),
      ],
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.color,
    required this.onSelect,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final Color color;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.18) : HushbugColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : HushbugColors.cardBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? color : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

