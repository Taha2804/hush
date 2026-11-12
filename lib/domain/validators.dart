import 'blocklist.dart';
import 'models/word_entry.dart';
import 'text_utils.dart';
import 'word_rules.dart';

/// Word filter: 3-16 chars, 1-2 tokens, alphabetic (single space or hyphen
/// between tokens), no disambiguation/list/year pages, not blocked.
String? rejectWord(String word, {Blocklist? blocklist, int maxLength = 16}) {
  final w = word.trim();
  if (w.length < 3 || w.length > maxLength) return 'length';
  if (!RegExp(r'^[A-Za-z]+(?:[ \-][A-Za-z]+)?$').hasMatch(w)) return 'format';
  final n = normalize(w);
  if (n.startsWith('list ') || n.contains('disambiguation')) return 'meta-page';
  if ((blocklist ?? Blocklist.empty).isBlocked(w)) return 'blocklist';
  return null;
}

final _letterClue = RegExp(
  r'\b(letters?|starts? with|begins? with|ends? with|rhymes?|spelled|spelling|'
  r'syllables?|initials?|characters? long|anagram|first letter|last letter|vowels?)\b',
  caseSensitive: false,
);

/// Words that alone carry no meaning; a hint made only of these is
/// treated as "not in the same domain".
const genericFiller = <String>{
  'thing', 'things', 'something', 'stuff', 'object', 'item', 'word', 'noun',
  'concept', 'entity', 'example', 'type', 'kind', 'sort', 'term', 'idea',
};

/// Validates a hint against the rules in the spec. Returns `null` if the
/// hint is acceptable, otherwise a short rejection reason.
String? rejectHint(
  String word,
  String hint, {
  Set<String> synonyms = const {},
  Blocklist? blocklist,
}) {
  final bl = blocklist ?? Blocklist.empty;
  final h = hint.trim();
  if (h.isEmpty) return 'empty';
  final rawTokens = h.split(RegExp(r'\s+'));
  if (rawTokens.length > 4) return 'too-long';
  if (RegExp(r'\d').hasMatch(h)) return 'letter-or-length';
  if (_letterClue.hasMatch(h)) return 'letter-or-length';

  // Contains the word, its stem/plural, or a meaningful part of it.
  final wordToks = tokens(word);
  final hintToks = tokens(h);
  if (relatedForms(word, h)) return 'contains-word';
  for (final wt in wordToks) {
    if (wt.length < 3) continue;
    for (final ht in hintToks) {
      if (stem(ht) == stem(wt)) return 'contains-word';
      if (wt.length >= 4 && ht.contains(wt)) return 'contains-word';
      if (ht.length >= 4 && wt.contains(ht)) return 'contains-word';
    }
  }

  // Synonym (whole hint, or a single-token hint equal to a synonym).
  final normSyn = synonyms.map(normalize).toSet();
  if (normSyn.contains(normalize(h))) return 'synonym';
  if (hintToks.length == 1 && normSyn.map(stem).contains(stem(hintToks.first))) {
    return 'synonym';
  }

  // Brands are not allowed as hints (the Brands category opts out via
  // Blocklist.forEntry). Proper nouns such as landmarks are fine.
  if (bl.hasBrand(h)) return 'brand';
  if (bl.isBlocked(h)) return 'blocklist';

  // Domain: must carry at least one meaningful (non-filler) token.
  final content = hintToks.where((t) => !stopwords.contains(t)).toList();
  if (content.isEmpty) return 'off-domain';
  if (content.every(genericFiller.contains)) return 'off-domain';
  return null;
}

/// Validates a fake word for Fake Word mode.
String? rejectFake(
  String word,
  String fake, {
  Set<String> synonyms = const {},
  Blocklist? blocklist,
}) {
  final base = rejectWord(fake, blocklist: blocklist, maxLength: 18);
  if (base != null) return base;
  if (normalize(word) == normalize(fake)) return 'same-word';
  if (relatedForms(word, fake)) return 'stem-or-substring';
  // A fake may share a generic head token ("Orange juice" -> "Apple juice"),
  // but must differ in at least one meaningful token.
  final wt = tokens(word).map(stem).toSet();
  final ft = tokens(fake).map(stem).toSet();
  if (ft.difference(wt).isEmpty || wt.difference(ft).isEmpty) {
    return 'stem-or-substring';
  }
  if (synonyms.map(normalize).contains(normalize(fake))) return 'synonym';
  return null;
}

/// Result of cleaning a single entry.
class CleanedEntry {
  CleanedEntry(this.entry, this.rejectedHints, this.rejectedFakes, {this.rejectedDescription});
  final WordEntry entry;
  final Map<String, String> rejectedHints;
  final Map<String, String> rejectedFakes;

  /// Why the description was removed (null if kept or absent).
  final String? rejectedDescription;
}

/// Applies all field rules to [e]:
/// - invalid / duplicate hints are dropped;
/// - invalid / duplicate imposter words are dropped, and so is any imposter
///   word that appears in the description or any hint (it would expose the
///   imposter's word to the crew, or hand a hint to the wrong player);
/// - an invalid description (hint list, too long, names the word...) is
///   removed. Descriptions are never rebuilt from hints.
CleanedEntry cleanEntry(
  WordEntry e, {
  Set<String> synonyms = const {},
  Blocklist? blocklist,
  DescriptionRules descriptionRules = const DescriptionRules(),
}) {
  final bl = (blocklist ?? Blocklist.empty).forEntry(e);
  final rejectedHints = <String, String>{};
  final rejectedFakes = <String, String>{};
  final seenHints = <String>{};
  final hints = <Hint>[];
  for (final h in e.hints) {
    final reason = (h.level < 1 || h.level > 3)
        ? 'bad-level'
        : rejectHint(e.word, h.text, synonyms: synonyms, blocklist: bl);
    if (reason != null) {
      rejectedHints[h.text] = reason;
    } else if (seenHints.add(normalize(h.text))) {
      hints.add(Hint(text: h.text.trim(), level: h.level));
    } else {
      rejectedHints[h.text] = 'duplicate';
    }
  }

  String? description = e.description?.trim();
  String? rejectedDescription;
  if (description != null && description.isNotEmpty) {
    rejectedDescription = rejectDescription(e.word, description,
        hints: hints.map((h) => h.text), rules: descriptionRules);
    if (rejectedDescription != null) description = null;
  } else {
    description = null;
  }

  final seenFakes = <String>{};
  final fakes = <ImposterWord>[];
  final probe = e.copyWith(hints: hints, description: description);
  for (final f in e.imposters) {
    final reason = (f.level < 1 || f.level > 3)
        ? 'bad-level'
        : rejectFake(e.word, f.text, synonyms: synonyms, blocklist: bl) ?? imposterConflict(probe, f.text);
    if (reason != null) {
      rejectedFakes[f.text] = reason;
    } else if (seenFakes.add(normalize(f.text))) {
      fakes.add(ImposterWord(text: f.text.trim(), level: f.level));
    } else {
      rejectedFakes[f.text] = 'duplicate';
    }
  }
  return CleanedEntry(
    e.copyWith(hints: hints, imposters: fakes, description: description),
    rejectedHints,
    rejectedFakes,
    rejectedDescription: rejectedDescription,
  );
}

/// Minimum number of valid hints for a word to be playable when hints are
/// required (Online and Offline sources).
const minValidHints = 3;
