import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/sources/my_words_source.dart';
import '../../domain/models/word_entry.dart';
import '../../domain/validators.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import '../widgets/visuals.dart';

final myPacksProvider = FutureProvider.autoDispose<List<MyPack>>((ref) => ref.watch(myWordsSourceProvider).packs());
final packWordsProvider =
    FutureProvider.autoDispose.family<List<MyWord>, int>((ref, id) => ref.watch(myWordsSourceProvider).wordsOf(id));

Future<String?> _askText(BuildContext context, String title, {String initial = '', String? label, bool multiline = false}) {
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: c,
          autofocus: true,
          minLines: multiline ? 6 : 1,
          maxLines: multiline ? 12 : 1,
          decoration: InputDecoration(labelText: label),
          onSubmitted: multiline ? null : (v) => Navigator.pop(ctx, v),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.cancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: Text(context.l10n.save)),
      ],
    ),
  );
}

/// Deletes a pack (after confirmation) and forgets it in the category picker.
Future<bool> _deletePackFlow(BuildContext context, WidgetRef ref, int packId, String name) async {
  final l = context.l10n;
  if (!await confirmDialog(context, title: '${l.deletePack}: $name', body: l.deletePackConfirm, action: l.delete)) {
    return false;
  }
  await ref.read(myWordsSourceProvider).deletePack(packId);
  ref.read(settingsProvider.notifier).update((s) {
    final sel = s.selectedCategories['mywords'];
    if (sel == null) return s;
    return s.copyWith(selectedCategories: {
      ...s.selectedCategories,
      'mywords': [for (final c in sel) if (c != 'my$packId') c],
    });
  });
  ref.invalidate(myPacksProvider);
  if (context.mounted) toast(context, l.packDeleted);
  return true;
}

class MyWordsScreen extends ConsumerWidget {
  const MyWordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final packs = ref.watch(myPacksProvider);
    final src = ref.read(myWordsSourceProvider);

    Future<void> create() async {
      final name = await _askText(context, l.newPack, label: l.packName);
      if (name == null || name.trim().isEmpty) return;
      final id = await src.createPack(name);
      ref.invalidate(myPacksProvider);
      if (context.mounted) context.push('/mywords/$id');
    }

    Future<void> import() async {
      final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['json', 'csv', 'txt']);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final parsed = MyWordsSource.parseImport(utf8.decode(bytes, allowMalformed: true));
      final id = await src.createPack(parsed.name ?? file.name.split('.').first);
      for (final w in parsed.words) {
        if (rejectWord(w.word, blocklist: ref.read(blocklistProvider)) == 'blocklist') continue;
        await src.upsertWord(id, w);
      }
      ref.invalidate(myPacksProvider);
      if (context.mounted) toast(context, l.imported(parsed.words.length));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.myWords),
        actions: [
          IconButton(tooltip: l.importFile, onPressed: import, icon: const Icon(Icons.file_open_rounded)),
          IconButton(tooltip: l.customTopic, onPressed: () => context.push('/topic'), icon: const Icon(Icons.travel_explore_rounded)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: create,
        icon: const Icon(Icons.add_rounded),
        label: Text(l.newPack),
      ),
      body: packs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? Center(
                child: Body(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Mascot(size: 100, mood: MascotMood.sad),
                    const SizedBox(height: 12),
                    Text(l.noPacksYet, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/topic'),
                      icon: const Icon(Icons.travel_explore_rounded),
                      label: Text(l.customTopic),
                    ),
                  ]),
                ),
              )
            : ListView(padding: const EdgeInsets.only(bottom: 96, top: 8), children: [
                Body(
                  child: Column(children: [
                    for (final p in list) ...[
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.folder_rounded),
                          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(l.wordsCount(p.wordCount)),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                              tooltip: l.deletePack,
                              icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                              onPressed: () => _deletePackFlow(context, ref, p.id, p.name),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ]),
                          onTap: () => context.push('/mywords/${p.id}'),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ]),
                ),
              ]),
      ),
    );
  }
}

class PackEditorScreen extends ConsumerStatefulWidget {
  const PackEditorScreen({super.key, required this.packId});
  final int packId;

  @override
  ConsumerState<PackEditorScreen> createState() => _PackEditorScreenState();
}

class _PackEditorScreenState extends ConsumerState<PackEditorScreen> {
  bool _busy = false;

  MyWordsSource get _src => ref.read(myWordsSourceProvider);

  void _refresh() {
    ref.invalidate(packWordsProvider(widget.packId));
    ref.invalidate(myPacksProvider);
  }

  Future<String> _packName() async {
    final packs = await _src.packs();
    return packs.firstWhere((p) => p.id == widget.packId, orElse: () => MyPack(widget.packId, '', 0)).name;
  }

  Future<void> _editWord([MyWord? existing]) async {
    final result = await showDialog<MyWord>(
      context: context,
      builder: (c) => _WordDialog(existing: existing, packName: _packName),
    );
    if (result == null) return;
    await _src.upsertWord(widget.packId, result);
    _refresh();
  }

  Future<void> _bulk() async {
    final l = context.l10n;
    final text = await _askText(context, l.bulkPaste, label: l.bulkPasteHint, multiline: true);
    if (text == null) return;
    final bl = ref.read(blocklistProvider);
    final words = text.split(RegExp(r'\r?\n')).where((w) => w.trim().isNotEmpty && !bl.isBlocked(w));
    final n = await _src.addMany(widget.packId, words);
    _refresh();
    if (mounted) toast(context, l.addedWords(n));
  }

  Future<void> _enrichAll() async {
    final l = context.l10n;
    final online = ref.read(onlineSourceProvider);
    if (!await online.isAvailable()) {
      if (mounted) toast(context, l.reasonNoInternet);
      return;
    }
    setState(() => _busy = true);
    final name = await _packName();
    final words = await _src.wordsOf(widget.packId);
    for (final w in words.where((w) => w.needsHints)) {
      final e = await online.enrichCustomWord(w.word, name);
      if (e != null) {
        await _src.upsertWord(widget.packId,
            MyWord(id: w.id, word: w.word, hints: e.hints, fakes: w.fakes.isNotEmpty ? w.fakes : e.fakeWords));
      }
    }
    if (!mounted) return;
    setState(() => _busy = false);
    _refresh();
  }

  Future<void> _export() async {
    final l = context.l10n;
    final json = await _src.exportJson(widget.packId);
    final name = (await _packName()).replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
    final bytes = Uint8List.fromList(utf8.encode(json));
    // file_picker writes the bytes itself on every platform.
    final uri = await FilePicker.saveFile(
      dialogTitle: l.exportJson,
      fileName: '${name.isEmpty ? 'pack' : name}.json',
      mimeType: 'application/json',
      bytes: bytes,
    );
    if (uri != null && mounted) toast(context, l.exported);
  }

  Future<void> _rename() async {
    final l = context.l10n;
    final current = await _packName();
    if (!mounted) return;
    final name = await _askText(context, l.rename, initial: current, label: l.packName);
    if (name == null || name.trim().isEmpty) return;
    await _src.renamePack(widget.packId, name);
    _refresh();
    setState(() {});
  }

  Future<void> _delete() async {
    final name = await _packName();
    if (!mounted) return;
    final deleted = await _deletePackFlow(context, ref, widget.packId, name);
    if (deleted && mounted) context.pop();
  }

  Future<void> _clearAll() async {
    final l = context.l10n;
    if (!await confirmDialog(context, title: l.deleteAllWords, body: l.clearPackConfirm, action: l.delete)) return;
    await _src.clearPack(widget.packId);
    _refresh();
  }

  Future<void> _removeWord(MyWord w) async {
    final l = context.l10n;
    await _src.deleteWord(w.id!);
    _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(l.wordRemoved(w.word)),
        action: SnackBarAction(
          label: l.undo,
          onPressed: () async {
            await _src.upsertWord(widget.packId, MyWord(word: w.word, hints: w.hints, fakes: w.fakes));
            _refresh();
          },
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final words = ref.watch(packWordsProvider(widget.packId));
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(future: _packName(), builder: (c, s) => Text(s.data ?? '')),
        actions: [
          IconButton(tooltip: l.autoEnrich, onPressed: _busy ? null : _enrichAll, icon: const Icon(Icons.auto_fix_high_rounded)),
          PopupMenuButton<String>(
            onSelected: (v) => switch (v) {
              'bulk' => _bulk(),
              'export' => _export(),
              'rename' => _rename(),
              'clear' => _clearAll(),
              'delete' => _delete(),
              _ => null,
            },
            itemBuilder: (c) => [
              PopupMenuItem(value: 'bulk', child: ListTile(leading: const Icon(Icons.content_paste_rounded), title: Text(l.bulkPaste))),
              PopupMenuItem(value: 'export', child: ListTile(leading: const Icon(Icons.download_rounded), title: Text(l.exportJson))),
              PopupMenuItem(value: 'rename', child: ListTile(leading: const Icon(Icons.edit_rounded), title: Text(l.rename))),
              PopupMenuItem(value: 'clear', child: ListTile(leading: const Icon(Icons.clear_all_rounded), title: Text(l.deleteAllWords))),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_forever_rounded, color: cs.error),
                  title: Text(l.deletePack, style: TextStyle(color: cs.error)),
                ),
              ),
            ],
          ),
        ],
        bottom: _busy ? const PreferredSize(preferredSize: Size.fromHeight(4), child: LinearProgressIndicator()) : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editWord(),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.addWord),
      ),
      body: words.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? Center(child: Text(l.noWordsYet))
            : ListView(padding: const EdgeInsets.only(bottom: 96, top: 8), children: [
                Body(
                  child: Card(
                    child: Column(children: [
                      for (final w in list)
                        ListTile(
                          title: Text(w.word),
                          subtitle: w.hints.isEmpty ? null : Text(w.hints.map((h) => h.text).join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis),
                          onTap: () => _editWord(w),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (w.needsHints)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: cs.errorContainer, borderRadius: BorderRadius.circular(8)),
                                child: Text(l.needsHints, style: TextStyle(color: cs.onErrorContainer, fontSize: 12)),
                              ),
                            IconButton(
                              tooltip: l.removeWord,
                              onPressed: () => _removeWord(w),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ]),
                        ),
                    ]),
                  ),
                ),
              ]),
      ),
    );
  }
}

class _WordDialog extends ConsumerStatefulWidget {
  const _WordDialog({this.existing, required this.packName});
  final MyWord? existing;
  final Future<String> Function() packName;

  @override
  ConsumerState<_WordDialog> createState() => _WordDialogState();
}

class _WordDialogState extends ConsumerState<_WordDialog> {
  late final _word = TextEditingController(text: widget.existing?.word ?? '');
  late final _hints = TextEditingController(text: widget.existing?.hints.map((h) => h.text).join('\n') ?? '');
  late final _fakes = TextEditingController(text: widget.existing?.fakes.join('\n') ?? '');
  late List<Hint> _levels = widget.existing?.hints ?? const [];
  bool _enriching = false;

  @override
  void dispose() {
    _word.dispose();
    _hints.dispose();
    _fakes.dispose();
    super.dispose();
  }

  Future<void> _enrich() async {
    final l = context.l10n;
    final online = ref.read(onlineSourceProvider);
    if (_word.text.trim().isEmpty) return;
    setState(() => _enriching = true);
    final ok = await online.isAvailable();
    final e = ok ? await online.enrichCustomWord(_word.text.trim(), await widget.packName()) : null;
    if (!mounted) return;
    setState(() => _enriching = false);
    if (e == null) {
      toast(context, ok ? l.enrichFailed : l.reasonNoInternet);
      return;
    }
    _levels = e.hints;
    _hints.text = e.hints.map((h) => h.text).join('\n');
    if (_fakes.text.trim().isEmpty) _fakes.text = e.fakeWords.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.existing == null ? l.addWord : l.editWord),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _word, autofocus: true, decoration: InputDecoration(labelText: l.word)),
            const SizedBox(height: 12),
            TextField(controller: _hints, minLines: 3, maxLines: 6, decoration: InputDecoration(labelText: l.hintsOptional)),
            const SizedBox(height: 12),
            TextField(controller: _fakes, minLines: 2, maxLines: 4, decoration: InputDecoration(labelText: l.fakesOptional)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _enriching ? null : _enrich,
                icon: _enriching
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_fix_high_rounded),
                label: Text(_enriching ? l.enriching : l.autoEnrich),
              ),
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            final word = _word.text.trim();
            if (word.isEmpty) return;
            final lines = _hints.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            // Keep levels from enrichment where the text is unchanged;
            // user-typed hints default to level 2 (medium).
            final hints = [
              for (final t in lines)
                Hint(text: t, level: _levels.firstWhere((h) => h.text == t, orElse: () => Hint(text: t, level: 2)).level),
            ];
            final fakes = _fakes.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            Navigator.pop(context, MyWord(id: widget.existing?.id, word: word, hints: hints, fakes: fakes));
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}

class TopicSearchScreen extends ConsumerStatefulWidget {
  const TopicSearchScreen({super.key});

  @override
  ConsumerState<TopicSearchScreen> createState() => _TopicSearchScreenState();
}

class _TopicSearchScreenState extends ConsumerState<TopicSearchScreen> {
  final _topic = TextEditingController();
  final _add = TextEditingController();
  List<String>? _results;
  final _removed = <String>{};
  bool _loading = false;

  @override
  void dispose() {
    _topic.dispose();
    _add.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final l = context.l10n;
    final q = _topic.text.trim();
    if (q.isEmpty) return;
    final online = ref.read(onlineSourceProvider);
    setState(() => _loading = true);
    if (!await online.isAvailable()) {
      if (mounted) {
        setState(() => _loading = false);
        toast(context, l.reasonNoInternet);
      }
      return;
    }
    final words = await online.searchTopic(q);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _results = words;
      _removed.clear();
    });
  }

  Future<void> _save() async {
    final l = context.l10n;
    final words = [...?_results?.where((w) => !_removed.contains(w))];
    if (words.isEmpty) return;
    final src = ref.read(myWordsSourceProvider);
    final id = await src.createPack(_topic.text.trim());
    await src.addMany(id, words);
    ref.invalidate(myPacksProvider);
    if (!mounted) return;
    toast(context, l.addedWords(words.length));
    context.pushReplacement('/mywords/$id');
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: HushbugColors.scaffoldGradient,
        ),
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
                      'Create Custom Topic',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // Search Box Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1433),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF3B2E63), width: 1.2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: HushbugColors.neonPurpleLight, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _topic,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: 'e.g. Space Exploration, Anime...',
                            hintStyle: TextStyle(color: HushbugColors.textMuted, fontSize: 14),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => _search(),
                        ),
                      ),
                      if (_topic.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: HushbugColors.textSubtext),
                          onPressed: () {
                            _topic.clear();
                            setState(() => _results = null);
                          },
                        ),
                      IconButton(
                        tooltip: 'Search',
                        onPressed: _loading ? null : _search,
                        icon: _loading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: HushbugColors.accentYellow))
                            : const Icon(Icons.arrow_forward_rounded, color: HushbugColors.accentYellow, size: 22),
                      ),
                    ],
                  ),
                ),
              ),

              // Live Discovery Status Badge
              if (results != null && !_loading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x2E10B981),
                          border: Border.all(color: const Color(0x6610B981)),
                        ),
                        child: const Icon(Icons.check_rounded, color: Color(0xFF34D399), size: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Found ${results.length} words from Wikipedia',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Content Split: Checklist on Left + Researcher Mascot on Right
              Expanded(
                child: Stack(
                  children: [
                    // Researcher Mascot on the bottom right
                    const Positioned(
                      right: -10,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Mascot(
                          size: 190,
                          mood: MascotMood.researcher,
                        ),
                      ),
                    ),

                    // Words Checklist on Left / Center
                    if (_loading)
                      Center(
                        child: CircularProgressIndicator(color: HushbugColors.neonPurpleLight),
                      )
                    else if (results != null && results.isNotEmpty)
                      ListView.builder(
                        padding: const EdgeInsets.only(left: 20, right: 140, top: 8, bottom: 80),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final word = results[index];
                          final isChecked = !_removed.contains(word);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isChecked) {
                                      _removed.add(word);
                                    } else {
                                      _removed.remove(word);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isChecked
                                        ? const Color(0xFF1B1535).withValues(alpha: 0.95)
                                        : const Color(0xFF17122E).withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isChecked ? const Color(0xFF544085) : const Color(0xFF2C204D),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(7),
                                          gradient: isChecked
                                              ? const LinearGradient(
                                                  colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
                                                )
                                              : null,
                                          border: Border.all(
                                            color: isChecked ? const Color(0xFFC084FC) : const Color(0xFF544085),
                                            width: 1.8,
                                          ),
                                        ),
                                        child: isChecked
                                            ? const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 14))
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          word,
                                          style: TextStyle(
                                            color: isChecked ? Colors.white : HushbugColors.textMuted,
                                            fontWeight: isChecked ? FontWeight.w800 : FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.travel_explore_rounded, size: 54, color: HushbugColors.neonPurpleLight.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              const Text(
                                'Search any topic to auto-discover words',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: HushbugColors.textSubtext, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Sticky Bottom CTA: Save as My Pack
              if (results != null && results.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: TactileButton(
                    onPressed: _save,
                    style: TactileButtonStyle.neonPurple,
                    height: 54,
                    icon: const Icon(Icons.file_download_rounded, color: Colors.white, size: 24),
                    child: const Text('Save as My Pack'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
