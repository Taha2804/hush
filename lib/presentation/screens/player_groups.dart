import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/prefs/settings.dart';
import '../../domain/models/game_config.dart';
import '../widgets/common.dart';
import '../widgets/visuals.dart';

/// Adds or replaces [group] (matched by name, case-insensitive).
void _upsertGroup(WidgetRef ref, PlayerGroup group, {String? previousName}) {
  ref.read(settingsProvider.notifier).update((s) {
    final oldKey = (previousName ?? group.name).toLowerCase();
    final newKey = group.name.toLowerCase();
    // Drop any *other* group that already uses the new name (rename-onto).
    final list = [
      for (final g in s.playerGroups)
        if (g.name.toLowerCase() != newKey || g.name.toLowerCase() == oldKey) g,
    ];
    final i = list.indexWhere((g) => g.name.toLowerCase() == oldKey);
    if (i >= 0) {
      list[i] = group;
    } else {
      list.add(group);
    }
    return s.copyWith(playerGroups: list);
  });
}

Future<String?> _askGroupName(BuildContext context, {String initial = ''}) {
  final l = context.l10n;
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.saveAsGroup),
      content: TextField(
        controller: c,
        autofocus: true,
        maxLength: 30,
        decoration: InputDecoration(labelText: l.groupName, hintText: l.groupNameHint),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: Text(l.save)),
      ],
    ),
  );
}

/// "Save these players as a group" flow from the Setup screen.
Future<void> saveCurrentAsGroup(BuildContext context, WidgetRef ref, List<String> players) async {
  final l = context.l10n;
  final name = (await _askGroupName(context))?.trim();
  if (name == null || name.isEmpty || !context.mounted) return;
  final exists = ref.read(settingsProvider).playerGroups.any((g) => g.name.toLowerCase() == name.toLowerCase());
  if (exists && !await confirmDialog(context, title: l.saveAsGroup, body: l.groupExists(name), action: l.replace)) {
    return;
  }
  _upsertGroup(ref, PlayerGroup(name: name, players: List.of(players)));
  if (context.mounted) toast(context, l.groupSaved(name));
}

/// Bottom sheet listing saved groups: tap to load, edit, delete or create.
Future<void> showPlayerGroupsSheet(
  BuildContext context, {
  required List<String> currentPlayers,
  required void Function(PlayerGroup group) onLoad,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetCtx) => Consumer(builder: (context, ref, _) {
      final l = context.l10n;
      final groups = ref.watch(settingsProvider.select((s) => s.playerGroups));
      final cs = Theme.of(context).colorScheme;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
          child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
            Row(children: [
              Icon(Icons.groups_rounded, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(l.savedGroups,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
              TextButton.icon(
                onPressed: () async {
                  final g = await Navigator.of(context).push<PlayerGroup>(MaterialPageRoute(
                    builder: (_) => GroupEditorScreen(initial: PlayerGroup(name: '', players: currentPlayers)),
                  ));
                  if (g != null) _upsertGroup(ref, g);
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(l.newGroup),
              ),
            ]),
            const SizedBox(height: 4),
            Text(groups.isEmpty ? l.noGroupsYet : l.groupsHelp, style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            for (final g in groups)
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 16, right: 4),
                  title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(g.players.join(', '), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      _AvatarStrip(players: g.players),
                    ]),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    onLoad(g);
                  },
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      tooltip: l.editGroup,
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () async {
                        final edited = await Navigator.of(context)
                            .push<PlayerGroup>(MaterialPageRoute(builder: (_) => GroupEditorScreen(initial: g)));
                        if (edited != null) _upsertGroup(ref, edited, previousName: g.name);
                      },
                    ),
                    IconButton(
                      tooltip: l.delete,
                      icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                      onPressed: () async {
                        if (!await confirmDialog(context,
                            title: l.delete, body: l.deleteGroupConfirm(g.name), action: l.delete)) {
                          return;
                        }
                        ref.read(settingsProvider.notifier).update(
                            (s) => s.copyWith(playerGroups: [...s.playerGroups]..removeWhere((x) => x.name == g.name)));
                      },
                    ),
                  ]),
                ),
              ),
          ]),
        ),
      );
    }),
  );
}

class _AvatarStrip extends StatelessWidget {
  const _AvatarStrip({required this.players});
  final List<String> players;

  @override
  Widget build(BuildContext context) {
    const max = 8;
    return Wrap(spacing: 4, runSpacing: 4, children: [
      for (var i = 0; i < players.length && i < max; i++) PlayerAvatar(index: i, name: players[i], radius: 11),
      if (players.length > max)
        CircleAvatar(radius: 11, child: Text('+${players.length - max}', style: const TextStyle(fontSize: 9))),
    ]);
  }
}

/// Full-screen editor for one group: rename, add or remove players.
class GroupEditorScreen extends StatefulWidget {
  const GroupEditorScreen({super.key, required this.initial});
  final PlayerGroup initial;

  @override
  State<GroupEditorScreen> createState() => _GroupEditorScreenState();
}

class _GroupEditorScreenState extends State<GroupEditorScreen> {
  late final _name = TextEditingController(text: widget.initial.name);
  late final List<TextEditingController> _players = [
    for (final p in widget.initial.players) TextEditingController(text: p),
  ];

  @override
  void initState() {
    super.initState();
    while (_players.length < GameConfig.minPlayers) {
      _players.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _name.dispose();
    for (final c in _players) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final l = context.l10n;
    final name = _name.text.trim();
    final players = [
      for (var i = 0; i < _players.length; i++)
        _players[i].text.trim().isEmpty ? l.playerN(i + 1) : _players[i].text.trim(),
    ];
    if (name.isEmpty) {
      toast(context, l.groupName);
      return;
    }
    Navigator.pop(context, PlayerGroup(name: name, players: players));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial.name.isEmpty ? l.newGroup : l.editGroup),
        actions: [TextButton(onPressed: _save, child: Text(l.save))],
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: 96, top: 8), children: [
        Body(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextField(
              controller: _name,
              autofocus: widget.initial.name.isEmpty,
              maxLength: 30,
              decoration: InputDecoration(labelText: l.groupName, hintText: l.groupNameHint),
            ),
            SectionTitle('${l.players} (${_players.length})',
                trailing: TextButton.icon(
                  onPressed: _players.length >= GameConfig.maxPlayers
                      ? null
                      : () => setState(() => _players.add(TextEditingController())),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: Text(l.addPlayer),
                )),
            for (var i = 0; i < _players.length; i++)
              Padding(
                key: ObjectKey(_players[i]),
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  ListenableBuilder(
                    listenable: _players[i],
                    builder: (context, _) => PlayerAvatar(index: i, name: _players[i].text),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _players[i],
                      maxLength: 20,
                      decoration: InputDecoration(
                          labelText: l.playerName, hintText: l.playerN(i + 1), counterText: '', isDense: true),
                    ),
                  ),
                  IconButton(
                    tooltip: l.removePlayer,
                    onPressed: _players.length <= GameConfig.minPlayers
                        ? null
                        : () => setState(() => _players.removeAt(i).dispose()),
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                ]),
              ),
          ]),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        icon: const Icon(Icons.save_rounded),
        label: Text(l.save),
      ),
    );
  }
}
