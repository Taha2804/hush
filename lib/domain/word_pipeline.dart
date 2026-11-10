import 'blocklist.dart';
import 'models/word_entry.dart';
import 'random_service.dart';
import 'rotation_selector.dart';
import 'shuffle_bag.dart';
import 'state_store.dart';
import 'text_utils.dart';
import 'validators.dart';

/// What the round needs from the pipeline.
class DealtWord {
  DealtWord({
    required this.entry,
    required this.category,
    this.hint,
    this.fakeWord,
  });

  final WordEntry entry;
  final String category;

  /// Hint text for the imposter (falls back to the category name).
  final String? hint;

  /// Fake word (Fake Word mode only).
  final String? fakeWord;
}

/// Shared pipeline applied to every source's output: word filter, blocklist,
/// hint/fake validation, then fair dealing with a persistent shuffle bag,
/// global recent-history and hint/fake rotation.
class WordPipeline {
  WordPipeline({
    required this.store,
    required this.random,
    Blocklist? blocklist,
  }) : blocklist = blocklist ?? Blocklist.empty;

  final GameStateStore store;
  final RandomService random;
  final Blocklist blocklist;

  /// Filters and validates raw entries. When [requireHints] is true, words
  /// with fewer than [minValidHints] valid hints are discarded.
  List<WordEntry> clean(Iterable<WordEntry> raw, {required bool requireHints}) {
    final out = <WordEntry>[];
    final seen = <String>{};
    for (final e in raw) {
      if (rejectWord(e.word, blocklist: blocklist) != null) continue;
      final key = '${e.category}|${normalize(e.word)}';
      if (!seen.add(key)) continue;
      final cleaned = cleanEntry(e, blocklist: blocklist).entry;
      if (requireHints && cleaned.hints.length < minValidHints) continue;
      out.add(cleaned);
    }
    return out;
  }

  /// Deals one word from [pools] (category -> entries).
  ///
  /// With several categories, the category is picked by weighted random,
  /// weights favouring categories with more unused words in their bag.
  /// [eligible] can exclude entries (e.g. words without fakes in Fake Word
  /// mode); returns null if nothing eligible exists.
  Future<DealtWord?> deal({
    required String sourceId,
    required Map<String, List<WordEntry>> pools,
    required int hintLevel,
    bool wantFake = false,
    bool Function(WordEntry e)? eligible,
  }) async {
    final categories = <String, List<WordEntry>>{};
    pools.forEach((cat, list) {
      final ok = eligible == null ? list : list.where(eligible).toList();
      if (ok.isNotEmpty) categories[cat] = ok;
    });
    if (categories.isEmpty) return null;

    final bags = <String, ShuffleBagState>{};
    final weights = <double>[];
    final names = categories.keys.toList();
    for (final cat in names) {
      final st = await store.loadBag(sourceId, cat);
      final bag = ShuffleBag(st, random)
        ..sync(categories[cat]!.map((e) => e.id).toSet());
      bags[cat] = st;
      final unused = bag.remainingCount == 0 ? categories[cat]!.length : bag.remainingCount;
      weights.add(unused.toDouble());
    }
    final category = names[random.pickWeightedIndex(weights)];
    final entries = categories[category]!;
    final byId = {for (final e in entries) e.id: e};

    final history = await store.loadHistory();
    final recent = history.toSet();
    final bag = ShuffleBag(bags[category]!, random);
    final id = bag.deal(byId.keys.toSet(),
        avoid: (id) => recent.contains(normalize(byId[id]!.word)))!;
    await store.saveBag(sourceId, category, bag.state);

    final entry = byId[id]!;
    history.remove(normalize(entry.word));
    history.add(normalize(entry.word));
    await store.saveHistory(history);

    String? hint;
    if (entry.hints.isNotEmpty) {
      final usage = await store.loadHintUsage(entry.id);
      final selector = HintSelector(random);
      hint = selector.select(entry, hintLevel, usage)?.text;
      // Easy gives the imposter two clear clues so it feels clearly easier
      // than Medium/Hard (which give one).
      if (hint != null && hintLevel >= 3 && entry.hints.length > 1) {
        var second = selector.select(entry, hintLevel, usage)?.text;
        if (second == null || second == hint) second = selector.select(entry, hintLevel - 1, usage)?.text;
        if (second != null && second != hint) hint = '$hint · $second';
      }
      await store.saveHintUsage(entry.id, usage);
    }
    hint ??= entry.category;

    String? fake;
    if (wantFake && entry.fakeWords.isNotEmpty) {
      final usage = await store.loadFakeUsage(entry.id);
      fake = FakeWordSelector(random).select(entry, usage);
      await store.saveFakeUsage(entry.id, usage);
    }
    return DealtWord(entry: entry, category: category, hint: hint, fakeWord: fake);
  }
}
