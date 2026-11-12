import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:drift/drift.dart';

import '../../../domain/blocklist.dart';
import '../../../domain/models/word_entry.dart';
import '../../../domain/text_utils.dart';
import '../../../domain/word_source.dart';
import '../../db/app_db.dart';
import 'category_config.dart';
import 'json_fetcher.dart';
import 'online_pipeline.dart';

/// Tunables for the online cache.
class OnlineTuning {
  const OnlineTuning({
    this.prefetchTarget = 80,
    this.topUpThreshold = 20,
    this.enrichAhead = 5,
    this.ttl = const Duration(days: 30),
    this.negativeTtl = const Duration(days: 3),
    this.firstBatchTimeout = const Duration(seconds: 25),
  });
  final int prefetchTarget;
  final int topUpThreshold;
  final int enrichAhead;
  final Duration ttl;
  final Duration negativeTtl;
  final Duration firstBatchTimeout;
}

// ---------- Isolate entry points (top-level, sendable arguments) ----------

Future<List<Map<String, dynamic>>> _findInIsolate(
    (String, Map<String, List<String>>, String, String) args) async {
  final (_, cfgMap, blocked, brands) = args;
  final cfg = OnlineCategory(
    listPages: cfgMap['list']!,
    wikipediaCategories: cfgMap['cat']!,
    wikidataClasses: cfgMap['wd']!,
  );
  final bl = Blocklist.fromText(blocked: blocked, brands: brands);
  final found = await CandidateFinder(DioJsonFetcher(), bl).find(cfg);
  return [for (final c in found) c.toJson()];
}

Future<List<Map<String, dynamic>?>> _enrichInIsolate(
    (List<Map<String, dynamic>>, List<String>, String, String) args) async {
  final (items, siblings, blocked, brands) = args;
  final bl = Blocklist.fromText(blocked: blocked, brands: brands);
  final enricher = Enricher(DioJsonFetcher(), bl);
  return Future.wait([
    for (final it in items)
      enricher
          .enrich(
            word: it['word'] as String,
            category: it['category'] as String,
            id: it['id'] as String,
            description: it['description'] as String?,
            siblings: siblings,
            seed: (it['id'] as String).hashCode,
          )
          .then((e) => e?.toJson()),
  ]);
}

/// Source 1: words searched live (Wikipedia/Wikidata, ConceptNet,
/// Datamuse) and cached locally with a 30-day TTL.
class OnlineSearchSource extends WordSource {
  OnlineSearchSource({
    required this.db,
    required this.blocklistText,
    required this.brandsText,
    JsonFetcher? fetcher,
    this.useIsolate = true,
    this.tuning = const OnlineTuning(),
    DateTime Function()? clock,
  })  : fetcher = fetcher ?? DioJsonFetcher(),
        _now = clock ?? DateTime.now;

  final AppDb db;
  final String blocklistText;
  final String brandsText;
  final JsonFetcher fetcher;
  final bool useIsolate;
  final OnlineTuning tuning;
  final DateTime Function() _now;

  static const sourceId = 'online';

  late final Blocklist _bl = Blocklist.fromText(blocked: blocklistText, brands: brandsText);
  final Map<String, Future<void>> _inflight = {};
  bool? _lastAvailable;
  DateTime? _lastCheck;

  @override
  String get id => sourceId;
  @override
  String get name => 'Online Search';
  @override
  bool get requiresInternet => true;

  @override
  Future<bool> isAvailable() async {
    final now = _now();
    if (_lastCheck != null && now.difference(_lastCheck!) < const Duration(seconds: 30)) {
      return _lastAvailable!;
    }
    try {
      await fetcher
          .getJson(Uri.parse('https://en.wikipedia.org/w/api.php?action=query&meta=siteinfo&format=json'))
          .timeout(const Duration(seconds: 6));
      _lastAvailable = true;
    } catch (_) {
      _lastAvailable = false;
    }
    _lastCheck = now;
    return _lastAvailable!;
  }

  @override
  Future<String?> unavailableReason() async => (await isAvailable()) ? null : 'no_internet';

  @override
  Future<List<String>> categories() async => onlineCategories.keys.toList();

  int get _ttlCutoff => _now().subtract(tuning.ttl).millisecondsSinceEpoch;

  // ---------------- Negative cache ----------------
  Future<bool> _isNegative(String key) async {
    final row = await (db.select(db.negativeCache)..where((t) => t.key.equals(key))).getSingleOrNull();
    if (row == null) return false;
    return _now().millisecondsSinceEpoch - row.at < tuning.negativeTtl.inMilliseconds;
  }

  Future<void> _markNegative(String key) => db.into(db.negativeCache).insertOnConflictUpdate(
      NegativeCacheCompanion.insert(key: key, at: _now().millisecondsSinceEpoch));

  // ---------------- Cache queries ----------------
  Future<List<CachedWord>> _rows(String category) => (db.select(db.cachedWords)
        ..where((t) => t.category.equals(category) & t.fetchedAt.isBiggerOrEqualValue(_ttlCutoff))
        ..orderBy([(t) => OrderingTerm.desc(t.rank)]))
      .get();

  WordEntry _toEntry(CachedWord r) => WordEntry(
        id: r.id,
        category: r.category,
        word: r.word,
        hints: [
          for (final h in jsonDecode(r.hintsJson) as List) Hint.fromJson(Map<String, dynamic>.from(h as Map)),
        ],
        imposters: _imposters(r.fakesJson),
        description: _cachedDescription(r.fakesJson),
        source: sourceId,
      );

  /// `fakes_json` holds `{"v":2,"imposters":[{text,level}],"description":..}`
  /// (validated record); older caches stored a plain list of fake words.
  static List<ImposterWord> _imposters(String raw) {
    try {
      final j = jsonDecode(raw);
      if (j is List) return [for (final f in j) if (f is String) ImposterWord(text: f)];
      if (j is Map) {
        return [
          for (final f in (j['imposters'] as List? ?? const []))
            ImposterWord.fromJson(Map<String, dynamic>.from(f as Map)),
        ];
      }
    } catch (_) {}
    return const [];
  }

  static String? _cachedDescription(String raw) {
    try {
      final j = jsonDecode(raw);
      if (j is Map) return j['description'] as String?;
    } catch (_) {}
    return null;
  }

  /// Words already enriched and valid for [category] (no network).
  Future<List<WordEntry>> cachedWords(String category) async => [
        for (final r in await _rows(category))
          if (r.enriched && !r.rejected) _toEntry(r),
      ];

  Future<int> cacheSize() async {
    final c = db.cachedWords.id.count();
    final row = await (db.selectOnly(db.cachedWords)
          ..addColumns([c])
          ..where(db.cachedWords.enriched.equals(true) & db.cachedWords.rejected.equals(false)))
        .getSingle();
    return row.read(c) ?? 0;
  }

  Future<void> clearCache() async {
    await db.delete(db.cachedWords).go();
    await db.delete(db.negativeCache).go();
  }

  /// Marks a word as dealt (used to decide when to top up).
  Future<void> markUsed(String entryId) =>
      (db.update(db.cachedWords)..where((t) => t.id.equals(entryId)))
          .write(const CachedWordsCompanion(used: Value(true)));

  // ---------------- WordSource ----------------
  @override
  Future<List<WordEntry>> fetchWords(String category, int count) async {
    await ensureReady(category);
    return cachedWords(category);
  }

  /// Makes sure there are enough enriched words. Awaits the first batch
  /// (bounded by a timeout) when the cache is empty, otherwise tops up in
  /// the background without blocking.
  Future<void> ensureReady(String category) async {
    final rows = await _rows(category);
    final enrichedUnused = rows.where((r) => r.enriched && !r.rejected && !r.used).length;
    final pending = rows.where((r) => !r.enriched && !r.rejected).length;
    final unused = enrichedUnused + pending;

    final needCandidates = unused < tuning.topUpThreshold;
    final needEnrich = enrichedUnused < tuning.enrichAhead;
    if (!needCandidates && !needEnrich) return;

    final work = _serial(category, () async {
      if (needCandidates) await _prefetch(category, rows.length);
      await _enrichNext(category, tuning.enrichAhead + (enrichedUnused == 0 ? 3 : 0));
    });
    if (rows.where((r) => r.enriched && !r.rejected).length < 5) {
      try {
        await work.timeout(tuning.firstBatchTimeout);
      } catch (_) {/* fall back to whatever is cached */}
    } else {
      unawaited(work.catchError((_) {}));
    }
  }

  Future<void> _serial(String category, Future<void> Function() job) {
    final prev = _inflight[category];
    if (prev != null) return prev;
    final f = job().whenComplete(() => _inflight.remove(category));
    _inflight[category] = f;
    return f;
  }

  Future<void> _prefetch(String category, int existing) async {
    final cfg = onlineCategories[category];
    if (cfg == null) return;
    final negKey = 'cand:$category';
    if (await _isNegative(negKey) && existing > 0) return;
    List<Candidate> found;
    if (useIsolate) {
      // Copy to locals so the closure does not capture `this` (not sendable).
      final args = (
        category,
        {'list': cfg.listPages, 'cat': cfg.wikipediaCategories, 'wd': cfg.wikidataClasses},
        blocklistText,
        brandsText,
      );
      final raw = await Isolate.run(() => _findInIsolate(args));
      found = [for (final m in raw) Candidate.fromJson(m)];
    } else {
      found = await CandidateFinder(fetcher, _bl).find(cfg);
    }
    if (found.isEmpty) {
      await _markNegative(negKey);
      return;
    }
    final now = _now().millisecondsSinceEpoch;
    final known = {for (final r in await _rows(category)) normalize(r.word)};
    await db.batch((b) {
      var added = 0;
      for (final c in found) {
        if (added >= tuning.prefetchTarget) break;
        if (known.contains(normalize(c.word))) continue;
        added++;
        b.insert(
          db.cachedWords,
          CachedWordsCompanion.insert(
            id: 'online:$category:${slugify(c.word)}',
            category: category,
            word: c.word,
            rank: Value(c.score),
            fetchedAt: now,
            hintsJson: Value(jsonEncode(c.description == null ? [] : [{'desc': c.description}])),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<void> _enrichNext(String category, int n) async {
    final rows = await _rows(category);
    final todo = rows.where((r) => !r.enriched && !r.rejected).take(n).toList();
    if (todo.isEmpty) return;
    final siblings = [for (final r in rows) r.word];
    final items = [
      for (final r in todo)
        {
          'id': r.id,
          'word': r.word,
          'category': category,
          'description': _descOf(r),
        },
    ];
    List<Map<String, dynamic>?> out;
    if (useIsolate) {
      final args = (items, siblings, blocklistText, brandsText);
      out = await Isolate.run(() => _enrichInIsolate(args));
    } else {
      final enricher = Enricher(fetcher, _bl);
      out = await Future.wait([
        for (final it in items)
          enricher
              .enrich(
                word: it['word'] as String,
                category: category,
                id: it['id'] as String,
                description: it['description'],
                siblings: siblings,
                seed: (it['id'] as String).hashCode,
              )
              .then((e) => e?.toJson()),
      ]);
    }
    await db.batch((b) {
      for (var i = 0; i < todo.length; i++) {
        final e = out[i];
        b.update(
          db.cachedWords,
          e == null
              ? const CachedWordsCompanion(enriched: Value(true), rejected: Value(true))
              : CachedWordsCompanion(
                  enriched: const Value(true),
                  hintsJson: Value(jsonEncode(e['hints'])),
                  fakesJson: Value(jsonEncode({'v': 2, 'imposters': e['imposters'], 'description': e['description']})),
                ),
          where: (t) => t.id.equals(todo[i].id),
        );
      }
    });
  }

  String? _descOf(CachedWord r) {
    try {
      final l = jsonDecode(r.hintsJson) as List;
      if (l.isNotEmpty && l.first is Map && (l.first as Map).containsKey('desc')) {
        return (l.first as Map)['desc'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Splits [categories] into ones that can be served now and a few "cold"
  /// ones worth waiting for; the remaining cold categories are warmed one
  /// at a time in the background (never all at once, to respect rate limits).
  Future<List<String>> playableSubset(List<String> categories, {required List<String> Function(List<String>) shuffle}) async {
    final ready = <String>[];
    final cold = <String>[];
    for (final c in categories) {
      ((await cachedWords(c)).length >= 5 ? ready : cold).add(c);
    }
    final shuffledCold = shuffle(cold);
    final waitFor = shuffledCold.take(ready.isEmpty ? 2 : 1).toList();
    unawaited(_warmSequentially(shuffledCold.skip(waitFor.length).toList()));
    return [...ready, ...waitFor];
  }

  Future<void> _warmSequentially(List<String> cats) async {
    for (final c in cats) {
      try {
        await ensureReady(c).timeout(const Duration(minutes: 2));
      } catch (_) {}
    }
  }

  /// Re-fetches candidates for [category] (Settings > Refresh).
  Future<void> refresh(String category) async {
    await (db.delete(db.negativeCache)..where((t) => t.key.equals('cand:$category'))).go();
    await _serial(category, () async {
      await _prefetch(category, 0);
      await _enrichNext(category, tuning.enrichAhead * 2);
    });
  }

  /// Hints/fakes for a user's custom word (needs internet).
  Future<WordEntry?> enrichCustomWord(String word, String category) =>
      Enricher(fetcher, _bl).enrichSingle(word, category);

  Future<List<String>> searchTopic(String topic) => TopicSearch(fetcher, _bl).search(topic);
}

/// Read-only view over the online cache, used as the first fallback when
/// the device is offline.
class OnlineCacheSource extends WordSource {
  OnlineCacheSource(this.online);
  final OnlineSearchSource online;

  @override
  String get id => 'online_cache';
  @override
  String get name => 'Online cache';
  @override
  bool get requiresInternet => false;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<List<String>> categories() => online.categories();
  @override
  Future<List<WordEntry>> fetchWords(String category, int count) => online.cachedWords(category);
}
