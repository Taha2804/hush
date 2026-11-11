import 'dart:math' as math;

import '../../../domain/blocklist.dart';
import '../../../domain/models/word_entry.dart';
import '../../../domain/text_utils.dart';
import '../../../domain/validators.dart';
import 'category_config.dart';
import 'json_fetcher.dart';

/// A candidate word found online, ranked by familiarity.
class Candidate {
  Candidate(this.word, this.score, {this.description});
  final String word;
  double score;
  String? description;

  Map<String, dynamic> toJson() => {'word': word, 'score': score, 'description': description};
  factory Candidate.fromJson(Map<String, dynamic> j) => Candidate(
      j['word'] as String, (j['score'] as num).toDouble(),
      description: j['description'] as String?);
}

final _wiki = Uri.parse('https://en.wikipedia.org/w/api.php');

/// Cleans a Wikipedia/Wikidata title into a playable word, or null.
String? cleanTitle(String title, Blocklist bl) {
  var t = title.replaceAll(RegExp(r'\s*\(.*?\)\s*'), ' ').replaceAll('_', ' ').trim();
  if (t.contains(',') || t.contains(':')) return null;
  if (RegExp(r'^(list|lists|outline|index|history|glossary) of ', caseSensitive: false)
      .hasMatch(t)) {
    return null;
  }
  if (RegExp(r'\d').hasMatch(t)) return null;
  t = t[0].toUpperCase() + t.substring(1);
  if (rejectWord(t, blocklist: bl) != null) return null;
  return t;
}

/// Finds and ranks candidate words for a category (Wikipedia + Wikidata).
class CandidateFinder {
  CandidateFinder(this.fetcher, this.blocklist);
  final JsonFetcher fetcher;
  final Blocklist blocklist;

  Future<List<Candidate>> find(OnlineCategory cfg, {int limit = 120}) async {
    final byKey = <String, Candidate>{};
    void add(String rawTitle, double views, String? desc) {
      final w = cleanTitle(rawTitle, blocklist);
      if (w == null) return;
      final k = normalize(w);
      final existing = byKey[k];
      if (existing == null) {
        byKey[k] = Candidate(w, views, description: desc);
      } else {
        existing.score += views;
        existing.description ??= desc;
      }
    }

    Future<void> safe(Future<void> Function() f) async {
      try {
        await f();
      } catch (_) {/* one failing source must not break the rest */}
    }

    final jobs = <Future<void>>[
      for (final page in cfg.listPages)
        safe(() async {
          final data = await fetcher.getJson(_wiki.replace(queryParameters: {
            'action': 'query', 'format': 'json', 'formatversion': '2',
            'generator': 'links', 'titles': page, 'gplnamespace': '0', 'gpllimit': '500',
            'prop': 'pageviews|description', 'pvipdays': '60', 'redirects': '1',
          }));
          _readPages(data, add);
        }),
      for (final cat in cfg.wikipediaCategories)
        safe(() async {
          final data = await fetcher.getJson(_wiki.replace(queryParameters: {
            'action': 'query', 'format': 'json', 'formatversion': '2',
            'generator': 'categorymembers', 'gcmtitle': 'Category:$cat', 'gcmtype': 'page',
            'gcmnamespace': '0', 'gcmlimit': '200',
            'prop': 'pageviews|description', 'pvipdays': '60',
          }));
          _readPages(data, add);
        }),
      if (cfg.wikidataClasses.isNotEmpty)
        safe(() async {
          final values = cfg.wikidataClasses.map((q) => 'wd:$q').join(' ');
          final sparql = 'SELECT ?itemLabel ?links WHERE { VALUES ?cls { $values } '
              '{ ?item wdt:P279 ?cls } UNION { ?item wdt:P31 ?cls } '
              '?item wikibase:sitelinks ?links . FILTER(?links >= 15) '
              'SERVICE wikibase:label { bd:serviceParam wikibase:language "en". } } '
              'ORDER BY DESC(?links) LIMIT 200';
          final data = await fetcher.getJson(
              Uri.https('query.wikidata.org', '/sparql', {'format': 'json', 'query': sparql}),
              headers: {'Accept': 'application/sparql-results+json'});
          for (final b in (data['results']?['bindings'] as List? ?? const [])) {
            final label = b['itemLabel']?['value'] as String?;
            final links = double.tryParse('${b['links']?['value']}') ?? 0;
            if (label != null && !RegExp(r'^Q\d+$').hasMatch(label)) {
              // Sitelinks are a familiarity proxy, scaled to pageview range.
              add(label, links * 400, null);
            }
          }
        }),
    ];
    await Future.wait(jobs);
    final list = byKey.values.toList()..sort((a, b) => b.score.compareTo(a.score));
    return list.take(limit).toList();
  }

  void _readPages(dynamic data, void Function(String, double, String?) add) {
    final pages = data?['query']?['pages'] as List? ?? const [];
    for (final p in pages) {
      if (p is! Map || p['missing'] == true) continue;
      final title = p['title'] as String?;
      if (title == null) continue;
      var views = 0.0;
      final pv = p['pageviews'];
      if (pv is Map) {
        for (final v in pv.values) {
          if (v is num) views += v.toDouble();
        }
      }
      add(title, views, p['description'] as String?);
    }
  }
}

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _stripArticle(String s) =>
    s.replaceFirst(RegExp(r'^(a|an|the|some)\s+', caseSensitive: false), '').trim();

/// Turns a word into a validated hint pool + fake-word pool using the
/// Wikipedia summary, ConceptNet and Datamuse. Pure apart from [fetcher].
class Enricher {
  Enricher(this.fetcher, this.blocklist);
  final JsonFetcher fetcher;
  final Blocklist blocklist;

  Future<dynamic> _try(Uri uri) async {
    try {
      return await fetcher.getJson(uri);
    } catch (_) {
      return null;
    }
  }

  /// [siblings] are other candidates of the same category (same parent
  /// class/category) used as fake-word candidates.
  Future<WordEntry?> enrich({
    required String word,
    required String category,
    required String id,
    String? description,
    List<String> siblings = const [],
    int seed = 0,
  }) async {
    final term = normalize(word).replaceAll(' ', '_');
    final results = await Future.wait([
      description == null
          ? _try(Uri.https('en.wikipedia.org', '/api/rest_v1/page/summary/${Uri.encodeComponent(word.replaceAll(' ', '_'))}'))
          : Future.value({'description': description}),
      _try(Uri.https('api.conceptnet.io', '/query', {'node': '/c/en/$term', 'other': '/c/en', 'limit': '200'})),
      _try(Uri.https('api.datamuse.com', '/words', {'rel_trg': word, 'max': '25'})),
      _try(Uri.https('api.datamuse.com', '/words', {'ml': word, 'max': '40'})),
      _try(Uri.https('api.datamuse.com', '/words', {'rel_syn': word, 'max': '25'})),
    ]);
    final summary = results[0];
    final cn = results[1];
    final trg = results[2];
    final ml = results[3];
    final syn = results[4];

    final synonyms = <String>{
      for (final s in (syn as List? ?? const [])) (s['word'] as String).toLowerCase(),
    };
    final related = <String>{};
    final hints = <({String text, int level, double weight})>[];
    void hint(String text, int level, double w) => hints.add((text: _cap(text.trim()), level: level, weight: w));

    // Level 1: vague, category-level (Wikipedia short description, IsA).
    final desc = (summary is Map ? summary['description'] as String? : null) ?? description;
    if (desc != null && desc.isNotEmpty) {
      final toks = _stripArticle(desc).split(RegExp(r'\s+'));
      hint(toks.take(math.min(4, toks.length)).join(' '), 1, 10);
    }

    for (final e in (cn is Map ? (cn['edges'] as List? ?? const []) : const [])) {
      if (e is! Map) continue;
      final rel = (e['rel']?['label'] ?? '') as String;
      final start = e['start'] as Map?;
      final end = e['end'] as Map?;
      if (start == null || end == null) continue;
      if (start['language'] != 'en' || end['language'] != 'en') continue;
      final w = (e['weight'] as num?)?.toDouble() ?? 1;
      final startIsWord = normalize(start['label'] as String? ?? '') == normalize(word);
      final other = _stripArticle((startIsWord ? end['label'] : start['label']) as String? ?? '');
      if (other.isEmpty) continue;
      final otherWords = other.split(' ').length;
      switch (rel) {
        case 'Synonym':
          synonyms.add(other.toLowerCase());
        case 'IsA' when startIsWord && otherWords <= 3:
          hint('Kind of $other', 1, w);
        case 'PartOf' when startIsWord && otherWords <= 3:
          hint('Part of $other', 2, w);
        case 'AtLocation' when startIsWord && otherWords <= 3:
          hint('Found in $other', 2, w);
        case 'UsedFor' when startIsWord && otherWords <= 3:
          hint('Used for $other', 2, w);
        case 'HasProperty' when startIsWord && otherWords <= 4:
          hint(other, 3, w);
        case 'CapableOf' when startIsWord && otherWords <= 3:
          hint('Can $other', 3, w);
        case 'HasA' when startIsWord && otherWords <= 3:
          hint('Has $other', 3, w);
        case 'MadeOf' when startIsWord && otherWords <= 3:
          hint('Made of $other', 3, w);
        case 'RelatedTo' || 'SimilarTo':
          if (otherWords <= 2) {
            related.add(other.toLowerCase());
            if (otherWords == 1) hint('Linked to $other', 2, w * 0.5);
          }
      }
    }

    var rank = 5.0;
    for (final t in (trg as List? ?? const [])) {
      final x = t['word'] as String?;
      if (x == null || x.contains(' ')) continue;
      hint('Goes with $x', 3, rank);
      rank *= 0.9;
    }
    for (final m in (ml as List? ?? const [])) {
      final x = (m['word'] as String?)?.toLowerCase();
      if (x != null) related.add(x);
    }

    // Validate & pick a balanced pool (prefer 2+ per level, max 8 total).
    hints.sort((a, b) => b.weight.compareTo(a.weight));
    final seen = <String>{};
    final byLevel = <int, List<Hint>>{1: [], 2: [], 3: []};
    for (final h in hints) {
      if (rejectHint(word, h.text, synonyms: synonyms, blocklist: blocklist) != null) continue;
      if (!seen.add(normalize(h.text))) continue;
      if (byLevel[h.level]!.length < 3) byLevel[h.level]!.add(Hint(text: h.text, level: h.level));
    }
    final pool = [...byLevel[1]!, ...byLevel[2]!, ...byLevel[3]!];
    if (pool.length < minValidHints) return null;

    // Fakes: siblings sharing the category that are also semantically
    // related; topped up with the most familiar siblings.
    final fakes = <String>[];
    bool okFake(String f) =>
        rejectFake(word, f, synonyms: synonyms, blocklist: blocklist) == null &&
        !fakes.map(normalize).contains(normalize(f));
    for (final s in siblings) {
      if (fakes.length >= 4) break;
      if (related.contains(normalize(s)) && okFake(s)) fakes.add(s);
    }
    if (fakes.length < 3) {
      final rnd = math.Random(seed);
      final rest = siblings.take(30).toList()..shuffle(rnd);
      for (final s in rest) {
        if (fakes.length >= 3) break;
        if (okFake(s)) fakes.add(s);
      }
    }

    return WordEntry(
      id: id,
      category: category,
      word: word,
      hints: pool,
      fakeWords: fakes,
      description: (summary?['description'] as String?)?.trim().isNotEmpty == true ? (summary!['description'] as String).trim() : null,
      source: 'online',
    );
  }

  /// Hints-only enrichment for a single custom word (My Words editor).
  Future<WordEntry?> enrichSingle(String word, String category) =>
      enrich(word: word, category: category, id: 'tmp:${slugify(word)}');
}

/// Searches Wikipedia for a custom topic and returns candidate words.
class TopicSearch {
  TopicSearch(this.fetcher, this.blocklist);
  final JsonFetcher fetcher;
  final Blocklist blocklist;

  Future<List<String>> search(String topic, {int limit = 60}) async {
    if (blocklist.isBlocked(topic)) return const [];
    final cats = <String>[];
    final pages = <String>[];
    try {
      final s = await fetcher.getJson(_wiki.replace(queryParameters: {
        'action': 'query', 'format': 'json', 'formatversion': '2', 'list': 'search',
        'srsearch': topic, 'srnamespace': '14', 'srlimit': '3',
      }));
      for (final r in (s['query']?['search'] as List? ?? const [])) {
        cats.add((r['title'] as String).replaceFirst('Category:', ''));
      }
    } catch (_) {}
    try {
      final s = await fetcher.getJson(_wiki.replace(queryParameters: {
        'action': 'query', 'format': 'json', 'formatversion': '2', 'list': 'search',
        'srsearch': 'intitle:"list of" $topic', 'srlimit': '2',
      }));
      for (final r in (s['query']?['search'] as List? ?? const [])) {
        pages.add(r['title'] as String);
      }
    } catch (_) {}
    final found = await CandidateFinder(fetcher, blocklist).find(
      OnlineCategory(listPages: pages, wikipediaCategories: cats),
      limit: limit,
    );
    return [for (final c in found) c.word];
  }
}
