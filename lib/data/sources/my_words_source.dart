import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/models/word_entry.dart';
import '../../domain/text_utils.dart';
import '../../domain/word_source.dart';
import '../db/app_db.dart';

/// A personal word with optional hints/fakes (editor model).
class MyWord {
  MyWord({this.id, required this.word, this.hints = const [], this.fakes = const []});
  final int? id;
  final String word;
  final List<Hint> hints;
  final List<String> fakes;

  bool get needsHints => hints.length < 3;

  Map<String, dynamic> toJson() => {
        'word': word,
        'hints': [for (final h in hints) h.toJson()],
        'fakes': fakes,
      };

  static MyWord fromJson(Map<String, dynamic> j) => MyWord(
        word: (j['word'] as String).trim(),
        hints: [
          for (final h in (j['hints'] as List? ?? const []))
            if (h is Map) Hint.fromJson(Map<String, dynamic>.from(h))
            else if (h is String) Hint(text: h, level: 2),
        ],
        fakes: [for (final f in (j['fakes'] as List? ?? const [])) f.toString()],
      );
}

class MyPack {
  MyPack(this.id, this.name, this.wordCount);
  final int id;
  final String name;
  final int wordCount;
}

/// Source 3: personal packs stored locally in the drift DB.
class MyWordsSource extends WordSource {
  MyWordsSource(this.db);
  final AppDb db;

  static const sourceId = 'mywords';
  static String categoryId(int packId) => 'my$packId';
  static int? packIdOf(String category) =>
      category.startsWith('my') ? int.tryParse(category.substring(2)) : null;

  @override
  String get id => sourceId;
  @override
  String get name => 'My Words';
  @override
  bool get requiresInternet => false;
  @override
  bool get requiresHints => false;

  @override
  Future<bool> isAvailable() async =>
      (await packs()).any((p) => p.wordCount > 0);

  @override
  Future<String?> unavailableReason() async =>
      (await isAvailable()) ? null : 'no_packs';

  Future<List<MyPack>> packs() async {
    final count = db.customWords.id.count();
    final q = db.select(db.customPacks).join([
      leftOuterJoin(db.customWords, db.customWords.packId.equalsExp(db.customPacks.id)),
    ])
      ..addColumns([count])
      ..groupBy([db.customPacks.id])
      ..orderBy([OrderingTerm.asc(db.customPacks.name)]);
    final rows = await q.get();
    return [
      for (final r in rows)
        MyPack(r.readTable(db.customPacks).id, r.readTable(db.customPacks).name,
            r.read(count) ?? 0),
    ];
  }

  @override
  Future<List<String>> categories() async =>
      [for (final p in await packs()) if (p.wordCount > 0) categoryId(p.id)];

  Future<String> categoryName(String category) async {
    final id = packIdOf(category);
    if (id == null) return category;
    final row = await (db.select(db.customPacks)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row?.name ?? category;
  }

  @override
  Future<List<WordEntry>> fetchWords(String category, int count) async {
    final packId = packIdOf(category);
    if (packId == null) return const [];
    final name = await categoryName(category);
    final words = await wordsOf(packId);
    return [
      for (final w in words)
        WordEntry(
          id: 'my:$packId:${slugify(w.word)}',
          category: name,
          word: w.word,
          hints: w.hints,
          fakeWords: w.fakes,
          source: sourceId,
        ),
    ];
  }

  // ---- Editor operations ----
  Future<int> createPack(String name) => db
      .into(db.customPacks)
      .insert(CustomPacksCompanion.insert(name: name.trim(), createdAt: DateTime.now().millisecondsSinceEpoch));

  Future<void> renamePack(int id, String name) =>
      (db.update(db.customPacks)..where((t) => t.id.equals(id)))
          .write(CustomPacksCompanion(name: Value(name.trim())));

  Future<void> deletePack(int id) async {
    await (db.delete(db.customWords)..where((t) => t.packId.equals(id))).go();
    await (db.delete(db.customPacks)..where((t) => t.id.equals(id))).go();
  }

  Future<List<MyWord>> wordsOf(int packId) async {
    final rows = await (db.select(db.customWords)
          ..where((t) => t.packId.equals(packId))
          ..orderBy([(t) => OrderingTerm.asc(t.word)]))
        .get();
    return [
      for (final r in rows)
        MyWord(
          id: r.id,
          word: r.word,
          hints: [
            for (final h in jsonDecode(r.hintsJson) as List)
              Hint.fromJson(Map<String, dynamic>.from(h as Map)),
          ],
          fakes: List<String>.from(jsonDecode(r.fakesJson) as List),
        ),
    ];
  }

  /// Adds or updates a word (matched by normalized text within the pack).
  Future<void> upsertWord(int packId, MyWord w) async {
    final existing = await wordsOf(packId);
    final match = existing.where((e) => normalize(e.word) == normalize(w.word));
    final hints = jsonEncode([for (final h in w.hints) h.toJson()]);
    final fakes = jsonEncode(w.fakes);
    if (w.id != null || match.isNotEmpty) {
      final id = w.id ?? match.first.id!;
      await (db.update(db.customWords)..where((t) => t.id.equals(id))).write(
          CustomWordsCompanion(word: Value(w.word.trim()), hintsJson: Value(hints), fakesJson: Value(fakes)));
    } else {
      await db.into(db.customWords).insert(CustomWordsCompanion.insert(
          packId: packId, word: w.word.trim(), hintsJson: Value(hints), fakesJson: Value(fakes)));
    }
  }

  Future<void> deleteWord(int wordId) =>
      (db.delete(db.customWords)..where((t) => t.id.equals(wordId))).go();

  /// Empties a pack but keeps it.
  Future<void> clearPack(int packId) =>
      (db.delete(db.customWords)..where((t) => t.packId.equals(packId))).go();

  /// Removes every custom pack and word.
  Future<void> deleteAllPacks() async {
    await db.delete(db.customWords).go();
    await db.delete(db.customPacks).go();
  }

  /// Bulk paste: one word per line; returns how many were added.
  Future<int> addMany(int packId, Iterable<String> words) async {
    var n = 0;
    for (final w in words) {
      final t = w.trim();
      if (t.isEmpty) continue;
      await upsertWord(packId, MyWord(word: t));
      n++;
    }
    return n;
  }

  Future<String> exportJson(int packId) async {
    final row = await (db.select(db.customPacks)..where((t) => t.id.equals(packId))).getSingle();
    final words = await wordsOf(packId);
    return const JsonEncoder.withIndent('  ').convert({
      'format': 'hushbug-pack',
      'version': 1,
      'name': row.name,
      'words': [for (final w in words) w.toJson()],
    });
  }

  /// Parses JSON (hushbug-pack or a plain list of strings/objects) or CSV
  /// (`word,hint1|hint2,fake1|fake2`; header optional).
  static ({String? name, List<MyWord> words}) parseImport(String text) {
    final trimmed = text.trimLeft();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      final data = jsonDecode(trimmed);
      final list = data is Map ? (data['words'] as List? ?? const []) : data as List;
      return (
        name: data is Map ? data['name'] as String? : null,
        words: [
          for (final item in list)
            if (item is String) MyWord(word: item)
            else if (item is Map) MyWord.fromJson(Map<String, dynamic>.from(item)),
        ],
      );
    }
    final words = <MyWord>[];
    for (final line in const LineSplitter().convert(text)) {
      if (line.trim().isEmpty) continue;
      final cols = _csvSplit(line);
      final w = cols.first.trim();
      if (w.isEmpty || normalize(w) == 'word') continue;
      final hints = cols.length > 1
          ? [for (final h in cols[1].split('|')) if (h.trim().isNotEmpty) Hint(text: h.trim(), level: 2)]
          : <Hint>[];
      final fakes = cols.length > 2
          ? [for (final f in cols[2].split('|')) if (f.trim().isNotEmpty) f.trim()]
          : <String>[];
      words.add(MyWord(word: w, hints: hints, fakes: fakes));
    }
    return (name: null, words: words);
  }

  static List<String> _csvSplit(String line) {
    final out = <String>[];
    final sb = StringBuffer();
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') {
        if (quoted && i + 1 < line.length && line[i + 1] == '"') {
          sb.write('"');
          i++;
        } else {
          quoted = !quoted;
        }
      } else if (c == ',' && !quoted) {
        out.add(sb.toString());
        sb.clear();
      } else {
        sb.write(c);
      }
    }
    out.add(sb.toString());
    return out;
  }
}
