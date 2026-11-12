import 'blocklist.dart';
import 'models/word_entry.dart';
import 'text_utils.dart';
import 'validators.dart';
import 'word_rules.dart';

/// Requirements for bundled Offline Packs (format v2).
const minWordsPerPack = 60;
const minHintsPerTier = 6;
const maxHintsPerTier = 10;
const minImpostersPerTier = 2;

/// Pack tier names -> hint level (how direct) / imposter level (how close).
const hintTierLevel = {'easy': 3, 'medium': 2, 'hard': 1};
const imposterTierLevel = {'easy': 1, 'medium': 2, 'hard': 3};

class PackIssue {
  PackIssue(this.pack, this.word, this.message, {this.warning = false});
  final String pack;
  final String word;
  final String message;
  final bool warning;

  @override
  String toString() => '${warning ? 'WARN ' : 'ERROR'} [$pack] $word: $message';
}

/// Metadata of a bundled category pack.
class PackMeta {
  const PackMeta({
    required this.id,
    required this.name,
    this.description = '',
    this.icon = 'category',
    this.isAdult = false,
    this.count = 0,
    this.difficulty = const {},
  });
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isAdult;
  final int count;

  /// Word counts per difficulty (`easy`/`medium`/`hard`).
  final Map<String, int> difficulty;

  factory PackMeta.fromJson(Map<String, dynamic> j) => PackMeta(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String? ?? '',
        icon: j['icon'] as String? ?? 'category',
        isAdult: j['is_adult'] as bool? ?? false,
        count: (j['count'] as num?)?.toInt() ?? 0,
        difficulty: {
          for (final e in ((j['difficulty'] as Map?) ?? const {}).entries)
            e.key as String: (e.value as num).toInt(),
        },
      );
}

WordDifficulty _difficulty(Object? v) => switch (v) {
      'easy' => WordDifficulty.easy,
      'hard' => WordDifficulty.hard,
      _ => WordDifficulty.medium,
    };

/// Parses a pack JSON object into entries, validating the schema strictly.
///
/// v2 words: {word, sub, diff, desc, tags, hints:{easy,medium,hard},
/// imposters:{easy,medium,hard}}. Legacy v1 words (hints as a list of
/// {text, level}, fakes as a list) are still read for imported packs.
List<WordEntry> parsePack(Map<String, dynamic> json, List<PackIssue> issues) {
  final id = json['id'];
  final name = json['name'];
  final words = json['words'];
  final packId = id is String ? id : '?';
  final adult = json['is_adult'] == true;
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
    if (word is! String) {
      issues.add(PackIssue(packId, '?', '"word" must be a string'));
      continue;
    }
    final hints = <Hint>[];
    final imposters = <ImposterWord>[];
    final rawHints = w['hints'];
    final rawImps = w['imposters'] ?? w['fakes'];
    if (rawHints is Map) {
      hintTierLevel.forEach((tier, level) {
        for (final h in (rawHints[tier] as List? ?? const [])) {
          if (h is String) hints.add(Hint(text: h, level: level));
        }
      });
    } else if (rawHints is List) {
      for (final h in rawHints) {
        if (h is Map && h['text'] is String && h['level'] is int) {
          hints.add(Hint(text: h['text'] as String, level: h['level'] as int));
        } else {
          issues.add(PackIssue(packId, word, 'malformed hint $h'));
        }
      }
    } else {
      issues.add(PackIssue(packId, word, '"hints" missing'));
    }
    if (rawImps is Map) {
      imposterTierLevel.forEach((tier, level) {
        for (final f in (rawImps[tier] as List? ?? const [])) {
          if (f is String) imposters.add(ImposterWord(text: f, level: level));
        }
      });
    } else if (rawImps is List) {
      for (final f in rawImps) {
        if (f is String) imposters.add(ImposterWord(text: f));
      }
    }
    final desc = (w['desc'] ?? w['description']);
    out.add(WordEntry(
      id: 'offline:$packId:${slugify(word)}',
      category: packId,
      word: word,
      subcategory: w['sub'] as String?,
      difficulty: _difficulty(w['diff']),
      tags: [for (final t in (w['tags'] as List? ?? const [])) if (t is String) t],
      isAdult: adult,
      hints: hints,
      imposters: imposters,
      description: desc is String && desc.trim().isNotEmpty ? desc.trim() : null,
      source: 'offline',
    ));
  }
  return out;
}

/// Validates one pack's entries against the v2 rules. Returns the issues.
List<PackIssue> validatePack(String packId, List<WordEntry> entries, Blocklist bl) {
  final issues = <PackIssue>[];
  if (entries.length < minWordsPerPack) {
    issues.add(PackIssue(packId, '-', 'only ${entries.length} words (need $minWordsPerPack+)'));
  }
  final seen = <String>{};
  for (final e in entries) {
    final ebl = bl.forEntry(e);
    final wr = rejectWord(e.word, blocklist: ebl);
    if (wr != null) issues.add(PackIssue(packId, e.word, 'word rejected: $wr'));
    if (!seen.add(normalize(e.word))) {
      issues.add(PackIssue(packId, e.word, 'duplicate word in pack'));
    }
    // Legacy v1 words (not yet rewritten, so no description) only warn about
    // tier sizes and the missing description; the game falls back to the
    // nearest tier. Everything else is checked strictly.
    final legacy = e.description == null;
    for (var lvl = 1; lvl <= 3; lvl++) {
      final c = e.hints.where((h) => h.level == lvl).length;
      if (c < minHintsPerTier || c > maxHintsPerTier) {
        issues.add(PackIssue(packId, e.word, 'hint level $lvl has $c hints (need $minHintsPerTier-$maxHintsPerTier)',
            warning: legacy));
      }
      final f = e.imposters.where((i) => i.level == lvl).length;
      if (f < minImpostersPerTier) {
        issues.add(PackIssue(packId, e.word, 'imposter level $lvl has $f words (need $minImpostersPerTier+)',
            warning: legacy));
      }
    }
    final hintSeen = <String>{};
    for (final h in e.hints) {
      final r = rejectHint(e.word, h.text, blocklist: ebl);
      if (r != null) issues.add(PackIssue(packId, e.word, 'hint "${h.text}" rejected: $r'));
      if (!hintSeen.add(normalize(h.text))) {
        issues.add(PackIssue(packId, e.word, 'duplicate hint "${h.text}"'));
      }
    }
    final dr = rejectDescription(e.word, e.description, hints: e.hints.map((h) => h.text));
    if (dr != null) issues.add(PackIssue(packId, e.word, 'description rejected: $dr', warning: legacy));
    final fakeSeen = <String>{};
    for (final f in e.imposters) {
      final r = rejectFake(e.word, f.text, blocklist: ebl) ?? imposterConflict(e, f.text);
      if (r != null) issues.add(PackIssue(packId, e.word, 'imposter "${f.text}" rejected: $r'));
      if (!fakeSeen.add(normalize(f.text))) {
        issues.add(PackIssue(packId, e.word, 'duplicate imposter "${f.text}"'));
      }
    }
  }
  return issues;
}

/// Cross-pack duplicate words (the build dedupes, so these are errors).
List<PackIssue> crossPackDuplicates(Map<String, List<WordEntry>> packs) {
  final owner = <String, String>{};
  final issues = <PackIssue>[];
  packs.forEach((pack, entries) {
    for (final e in entries) {
      final k = normalize(e.word);
      final prev = owner[k];
      if (prev != null && prev != pack) {
        issues.add(PackIssue(pack, e.word, 'also in pack "$prev"'));
      } else {
        owner[k] = pack;
      }
    }
  });
  return issues;
}
