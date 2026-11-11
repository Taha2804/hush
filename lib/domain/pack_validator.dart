import 'blocklist.dart';
import 'models/word_entry.dart';
import 'text_utils.dart';
import 'validators.dart';

/// Requirements for bundled Offline Packs.
const minWordsPerPack = 150;
const hintsPerWord = 6;
const hintsPerLevel = 2;
const minFakesPerWord = 3;

class PackIssue {
  PackIssue(this.pack, this.word, this.message, {this.warning = false});
  final String pack;
  final String word;
  final String message;
  final bool warning;

  @override
  String toString() => '${warning ? 'WARN ' : 'ERROR'} [$pack] $word: $message';
}

/// Parses a pack JSON object into entries, validating the schema strictly.
List<WordEntry> parsePack(Map<String, dynamic> json, List<PackIssue> issues) {
  final id = json['id'];
  final name = json['name'];
  final words = json['words'];
  final packId = id is String ? id : '?';
  if (id is! String || id.isEmpty) issues.add(PackIssue(packId, '-', 'missing "id"'));
  if (name is! String || name.isEmpty) issues.add(PackIssue(packId, '-', 'missing "name"'));
  if (words is! List) {
    issues.add(PackIssue(packId, '-', '"words" must be a list'));
    return const [];
  }
  final out = <WordEntry>[];
  for (final w in words) {
    if (w is! Map) {
      issues.add(PackIssue(packId, '?', 'word entry is not an object'));
      continue;
    }
    final word = w['word'];
    final hints = w['hints'];
    final fakes = w['fakes'];
    if (word is! String) {
      issues.add(PackIssue(packId, '?', '"word" must be a string'));
      continue;
    }
    if (hints is! List || fakes is! List) {
      issues.add(PackIssue(packId, word, '"hints" and "fakes" must be lists'));
      continue;
    }
    final parsedHints = <Hint>[];
    for (final h in hints) {
      if (h is Map && h['text'] is String && h['level'] is int) {
        parsedHints.add(Hint(text: h['text'] as String, level: h['level'] as int));
      } else {
        issues.add(PackIssue(packId, word, 'malformed hint $h'));
      }
    }
    out.add(WordEntry(
      id: 'offline:$packId:${slugify(word)}',
      category: packId,
      word: word,
      hints: parsedHints,
      fakeWords: [for (final f in fakes) if (f is String) f],
      description: w['description'] is String && (w['description'] as String).trim().isNotEmpty ? (w['description'] as String).trim() : null,
      source: 'offline',
    ));
  }
  return out;
}

/// Validates one pack's entries. Returns the issues found.
List<PackIssue> validatePack(String packId, List<WordEntry> entries, Blocklist bl) {
  final issues = <PackIssue>[];
  if (entries.length < minWordsPerPack) {
    issues.add(PackIssue(packId, '-',
        'only ${entries.length} words (need $minWordsPerPack+)'));
  }
  final seen = <String>{};
  for (final e in entries) {
    final wr = rejectWord(e.word, blocklist: bl);
    if (wr != null) issues.add(PackIssue(packId, e.word, 'word rejected: $wr'));
    if (!seen.add(normalize(e.word))) {
      issues.add(PackIssue(packId, e.word, 'duplicate word in pack'));
    }
    if (e.hints.length != hintsPerWord) {
      issues.add(PackIssue(packId, e.word, 'has ${e.hints.length} hints (need $hintsPerWord)'));
    }
    for (var lvl = 1; lvl <= 3; lvl++) {
      final c = e.hints.where((h) => h.level == lvl).length;
      if (c != hintsPerLevel) {
        issues.add(PackIssue(packId, e.word, 'level $lvl has $c hints (need $hintsPerLevel)'));
      }
    }
    final hintSeen = <String>{};
    for (final h in e.hints) {
      final r = rejectHint(e.word, h.text, blocklist: bl);
      if (r != null) issues.add(PackIssue(packId, e.word, 'hint "${h.text}" rejected: $r'));
      if (!hintSeen.add(normalize(h.text))) {
        issues.add(PackIssue(packId, e.word, 'duplicate hint "${h.text}"'));
      }
    }
    if (e.fakeWords.length < minFakesPerWord) {
      issues.add(PackIssue(packId, e.word, 'has ${e.fakeWords.length} fakes (need $minFakesPerWord+)'));
    }
    final fakeSeen = <String>{};
    for (final f in e.fakeWords) {
      final r = rejectFake(e.word, f, blocklist: bl);
      if (r != null) issues.add(PackIssue(packId, e.word, 'fake "$f" rejected: $r'));
      if (!fakeSeen.add(normalize(f))) {
        issues.add(PackIssue(packId, e.word, 'duplicate fake "$f"'));
      }
    }
  }
  return issues;
}

/// Cross-pack duplicate words are reported as warnings.
List<PackIssue> crossPackDuplicates(Map<String, List<WordEntry>> packs) {
  final owner = <String, String>{};
  final issues = <PackIssue>[];
  packs.forEach((pack, entries) {
    for (final e in entries) {
      final k = normalize(e.word);
      final prev = owner[k];
      if (prev != null && prev != pack) {
        issues.add(PackIssue(pack, e.word, 'also in pack "$prev"', warning: true));
      } else {
        owner[k] = pack;
      }
    }
  });
  return issues;
}
