import 'blocklist.dart';
import 'models/word_entry.dart';
import 'text_utils.dart';

/// Word filter: 3-16 chars, 1-2 tokens, alphabetic (single space or hyphen
/// between tokens), no disambiguation/list/year pages, not blocked.
String? rejectWord(String word, {Blocklist? blocklist}) {
  final w = word.trim();
  if (w.length < 3 || w.length > 16) return 'length';
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

  // Proper nouns / brands: any capitalised token after the first one.
  for (var i = 1; i < rawTokens.length; i++) {
    if (RegExp(r'^[A-Z]').hasMatch(rawTokens[i])) return 'proper-noun';
  }
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
  final base = rejectWord(fake, blocklist: blocklist);
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
  CleanedEntry(this.entry, this.rejectedHints, this.rejectedFakes);
  final WordEntry entry;
  final Map<String, String> rejectedHints;
  final Map<String, String> rejectedFakes;
}

/// Applies all hint/fake rules to [e]. Invalid hints and fakes are dropped;
/// duplicates removed.
CleanedEntry cleanEntry(
  WordEntry e, {
  Set<String> synonyms = const {},
  Blocklist? blocklist,
}) {
  final rejectedHints = <String, String>{};
  final rejectedFakes = <String, String>{};
  final seenHints = <String>{};
  final hints = <Hint>[];
  for (final h in e.hints) {
    final reason = (h.level < 1 || h.level > 3)
        ? 'bad-level'
        : rejectHint(e.word, h.text, synonyms: synonyms, blocklist: blocklist);
    if (reason != null) {
      rejectedHints[h.text] = reason;
    } else if (seenHints.add(normalize(h.text))) {
      hints.add(Hint(text: h.text.trim(), level: h.level));
    } else {
      rejectedHints[h.text] = 'duplicate';
    }
  }
  final seenFakes = <String>{};
  final fakes = <String>[];
  for (final f in e.fakeWords) {
    final reason = rejectFake(e.word, f, synonyms: synonyms, blocklist: blocklist);
    if (reason != null) {
      rejectedFakes[f] = reason;
    } else if (seenFakes.add(normalize(f))) {
      fakes.add(f.trim());
    } else {
      rejectedFakes[f] = 'duplicate';
    }
  }
  return CleanedEntry(
    e.copyWith(hints: hints, fakeWords: fakes),
    rejectedHints,
    rejectedFakes,
  );
}

/// Minimum number of valid hints for a word to be playable when hints are
/// required (Online and Offline sources).
const minValidHints = 3;
