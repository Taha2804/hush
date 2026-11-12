import 'blocklist.dart';
import 'models/game_config.dart';
import 'models/word_entry.dart';
import 'random_service.dart';
import 'rotation_selector.dart';
import 'shuffle_bag.dart';
import 'state_store.dart';
import 'text_utils.dart';
import 'validators.dart';
import 'word_rules.dart';

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

  /// Hint text for the Hint-mode imposter (null if the word has no hints).
  final String? hint;

  /// Imposter word (Fake Word mode only). Guaranteed not to appear in the
  /// secret word, its description or any of its hints.
  final String? fakeWord;
}

/// Shared pipeline applied to every source's output.
///
/// Loading: word filter, blocklist, then per-field validation via
/// [cleanEntry] (bad hints, bad descriptions and any imposter word that
/// collides with the word/description/hints are removed).
///
/// Dealing ([deal]):
/// 1. eligibility: enabled category, valid record, and for Fake Word mode at
///    least one conflict-free imposter word;
/// 2. category: a persistent category shuffle bag, so every selected
///    category gets an equal share (Random Mix is not dominated by big packs);
/// 3. word difficulty: the chosen filter, or for Mixed a per-category
///    difficulty bag so easy/medium/hard words alternate evenly;
/// 4. word: the category's persistent shuffle bag, skipping recently played
///    words (global history across sessions);
/// 5. hint: rotation inside the Hint Difficulty tier (nearest tier if empty);
/// 6. imposter word: rotation inside the Imposter Difficulty tier (nearest
///    tier if empty), re-checked for conflicts right before it is handed out.
///    If no safe imposter word exists, another secret word is chosen.
class WordPipeline {
  WordPipeline({
    required this.store,
    required this.random,
    Blocklist? blocklist,
  }) : blocklist = blocklist ?? Blocklist.empty;

  final GameStateStore store;
  final RandomService random;
  final Blocklist blocklist;

  static const _catBag = '__categories__';

  /// Filters and validates raw entries.
  ///
  /// [requireHints]: drop words with fewer than [minValidHints] valid hints.
  /// Curated (offline) and online words must also have a valid description;
  /// online descriptions are short encyclopedia lines, so they are checked
  /// with [DescriptionRules.lenient]. Custom words (My Words) may have none.
  List<WordEntry> clean(
    Iterable<WordEntry> raw, {
    required bool requireHints,
  }) {
    final out = <WordEntry>[];
    final seen = <String>{};
    for (final e in raw) {
      if (rejectWord(e.word, blocklist: blocklist.forEntry(e)) != null) continue;
      final key = '${e.category}|${normalize(e.word)}';
      if (!seen.add(key)) continue;
      final custom = e.source == 'mywords';
      final rules = e.source == 'online' ? const DescriptionRules.lenient() : const DescriptionRules();
      final cleaned = cleanEntry(e, blocklist: blocklist, descriptionRules: rules).entry;
      if (requireHints && cleaned.hints.length < minValidHints) continue;
      if (!custom && cleaned.description == null) continue;
      out.add(cleaned);
    }
    return out;
  }

  /// Imposter words of [e] that are safe to hand out (no conflicts).
  static List<ImposterWord> safeImposters(WordEntry e) =>
      [for (final i in e.imposters) if (imposterConflict(e, i.text) == null) i];

  /// Deals one word from [pools] (category -> entries). Returns null if
  /// nothing eligible exists.
  Future<DealtWord?> deal({
    required String sourceId,
    required Map<String, List<WordEntry>> pools,
    required int hintLevel,
    int imposterLevel = 2,
    WordDifficultyFilter wordDifficulty = WordDifficultyFilter.mixed,
    bool wantFake = false,
    bool Function(WordEntry e)? eligible,
  }) async {
    final categories = <String, List<WordEntry>>{};
    pools.forEach((cat, list) {
      final ok = list.where((e) {
        if (eligible != null && !eligible(e)) return false;
        if (wantFake && safeImposters(e).isEmpty) return false;
        return true;
      }).toList();
      if (ok.isNotEmpty) categories[cat] = ok;
    });
    if (categories.isEmpty) return null;

    // 2. Category: equal share per category via a persistent bag.
    final catState = await store.loadBag(sourceId, _catBag);
    final catBag = ShuffleBag(catState, random);
    final category = catBag.deal(categories.keys.toSet())!;
    await store.saveBag(sourceId, _catBag, catState);
    var entries = categories[category]!;

    // 3. Word difficulty.
    final want = switch (wordDifficulty) {
      WordDifficultyFilter.easy => WordDifficulty.easy,
      WordDifficultyFilter.medium => WordDifficulty.medium,
      WordDifficultyFilter.hard => WordDifficulty.hard,
      WordDifficultyFilter.mixed => null,
    };
    if (want != null) {
      final f = entries.where((e) => e.difficulty == want).toList();
      if (f.isNotEmpty) entries = f; // missing tier never blocks the game
    } else {
      final tiers = {for (final e in entries) e.difficulty.name};
      if (tiers.length > 1) {
        final key = '$_catBag:diff:$category';
        final st = await store.loadBag(sourceId, key);
        final tier = ShuffleBag(st, random).deal(tiers)!;
        await store.saveBag(sourceId, key, st);
        entries = entries.where((e) => e.difficulty.name == tier).toList();
      }
    }

    // 4. Word: per-category bag over the WHOLE category (so the bag keeps
    // its cycle across difficulty changes), restricted to the chosen tier.
    final allIds = {for (final e in categories[category]!) e.id};
    final byId = {for (final e in entries) e.id: e};
    final history = await store.loadHistory();
    final recent = history.toSet();
    final bagState = await store.loadBag(sourceId, category);
    final bag = ShuffleBag(bagState, random)..sync(allIds);
    String? id;
    // Take the first remaining id of the wanted tier that isn't recent.
    bool usable(String x) => byId.containsKey(x);
    final candidates = bagState.remaining.where(usable).toList();
    if (candidates.isEmpty) {
      // Tier exhausted in this cycle: start a fresh cycle for the category.
      bagState.remaining.clear();
      bagState.dealt.clear();
      bag.sync(allIds);
    }
    final pick = bagState.remaining.where(usable).toList();
    id = pick.firstWhere((x) => !recent.contains(normalize(byId[x]!.word)),
        orElse: () => pick.isNotEmpty ? pick.first : byId.keys.first);
    bagState.remaining.remove(id);
    bagState.dealt.add(id);
    bagState.recent.add(id);
    while (bagState.recent.length > ShuffleBag.boundaryWindow) {
      bagState.recent.removeAt(0);
    }
    await store.saveBag(sourceId, category, bagState);

    final entry = byId[id]!;
    history.remove(normalize(entry.word));
    history.add(normalize(entry.word));
    await store.saveHistory(history);

    // 5. Hint for the Hint-mode imposter.
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

    // 6. Imposter word, never one that collides with the crew's information.
    String? fake;
    if (wantFake) {
      final safe = entry.copyWith(imposters: safeImposters(entry));
      final usage = await store.loadFakeUsage(entry.id);
      fake = FakeWordSelector(random).select(safe, usage, level: imposterLevel);
      await store.saveFakeUsage(entry.id, usage);
      if (fake == null || imposterConflict(entry, fake) != null) return null;
    }
    return DealtWord(entry: entry, category: category, hint: hint, fakeWord: fake);
  }
}
