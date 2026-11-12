import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/data/db/app_db.dart';
import 'package:hushbug/data/sources/online/category_config.dart';
import 'package:hushbug/data/sources/online/json_fetcher.dart';
import 'package:hushbug/data/sources/online/online_pipeline.dart';
import 'package:hushbug/data/sources/online/online_source.dart';
import 'package:hushbug/domain/blocklist.dart';
import 'package:hushbug/domain/text_utils.dart';
import 'package:hushbug/domain/validators.dart';

import 'fixtures/online_fixtures.dart';

void main() {
  final bl = Blocklist(blocked: ['beer']);
  const fruitCfg = OnlineCategory(listPages: ['List of culinary fruits'], wikidataClasses: ['Q1364']);

  test('cleanTitle filters meta pages, disambiguation, years', () {
    expect(cleanTitle('Apple (fruit)', bl), 'Apple');
    expect(cleanTitle('List of culinary fruits', bl), isNull);
    expect(cleanTitle('Durian 2026 season', bl), isNull);
    expect(cleanTitle('Beer', bl), isNull);
    expect(cleanTitle('ice cream', bl), 'Ice cream');
  });

  test('CandidateFinder merges Wikipedia + Wikidata and ranks by familiarity', () async {
    final f = FixtureFetcher(fruitFixtures());
    final found = await CandidateFinder(f, bl).find(fruitCfg);
    final words = found.map((c) => c.word).toList();
    expect(words.first, 'Apple'); // highest pageviews + sitelinks
    expect(words, containsAll(['Banana', 'Mango', 'Cherry', 'Kiwifruit']));
    expect(words, isNot(contains('List of culinary fruits')));
    expect(words.where((w) => w.startsWith('Q')), isEmpty);
    // Every request carries the descriptive User-Agent in production; here
    // we assert pageviews were requested for familiarity ranking.
    expect(f.requested.any((u) => u.queryParameters['prop']?.contains('pageviews') ?? false), isTrue);
  });

  test('Enricher builds a validated multi-level hint pool and sibling fakes', () async {
    final f = FixtureFetcher(fruitFixtures());
    final e = await Enricher(f, bl).enrich(
      word: 'Apple',
      category: 'fruits_vegetables',
      id: 'online:fruits_vegetables:apple',
      siblings: ['Banana', 'Pear', 'Peach', 'Cherry', 'Apples', 'Pineapple', 'Mango'],
    );
    expect(e, isNotNull);
    final hints = e!.hints;
    expect(hints.length, greaterThanOrEqualTo(minValidHints));
    for (final h in hints) {
      expect(rejectHint('Apple', h.text, synonyms: {'pome'}), isNull, reason: h.text);
      expect(h.text.split(' ').length, lessThanOrEqualTo(4));
    }
    expect(hints.map((h) => h.level).toSet(), containsAll([1, 2, 3]));
    // Never leaks the word, its plural or a synonym.
    expect(hints.any((h) => normalize(h.text).contains('apple')), isFalse);
    expect(hints.any((h) => normalize(h.text).contains('pome')), isFalse);
    // Fakes: siblings, related ones first, never plural/substring/synonym.
    expect(e.fakeWords.length, greaterThanOrEqualTo(3));
    expect(e.fakeWords, contains('Peach'));
    expect(e.fakeWords, isNot(contains('Apples')));
    expect(e.fakeWords, isNot(contains('Pineapple')));
  });

  test('Enricher returns null (word discarded) when < 3 valid hints', () async {
    final f = FixtureFetcher({
      'page/summary/Zzyzx': {'description': 'Zzyzx'},
    });
    final e = await Enricher(f, bl).enrich(word: 'Zzyzx', category: 'x', id: 'x');
    expect(e, isNull);
  });

  group('OnlineSearchSource with drift cache', () {
    late AppDb db;
    setUp(() => db = AppDb(NativeDatabase.memory()));
    tearDown(() => db.close());

    OnlineSearchSource make(JsonFetcher f) => OnlineSearchSource(
          db: db,
          blocklistText: 'beer',
          brandsText: '',
          fetcher: f,
          useIsolate: false,
          tuning: const OnlineTuning(enrichAhead: 2),
        );

    test('prefetches candidates, lazily enriches, then serves from cache offline', () async {
      final online = make(FixtureFetcher(fruitFixtures()));
      expect(await online.isAvailable(), isTrue);
      final words = await online.fetchWords('fruits_vegetables', 50);
      // Only Apple has full fixtures, so only Apple survives enrichment.
      expect(words.map((w) => w.word), contains('Apple'));
      final rows = await db.select(db.cachedWords).get();
      expect(rows.length, greaterThan(3)); // candidates cached for later
      final apple = words.firstWhere((w) => w.word == 'Apple');
      expect(jsonEncode(apple.hints), isNotEmpty);

      // A second instance with no network still serves the cached words.
      final offline = make(FixtureFetcher({}));
      expect(await offline.isAvailable(), isFalse);
      final cached = await offline.cachedWords('fruits_vegetables');
      expect(cached.map((w) => w.word), contains('Apple'));
    });

    test('negative cache: a failing category is not re-queried immediately', () async {
      final f = FixtureFetcher({});
      final online = make(f);
      await online.ensureReady('fruits_vegetables');
      final first = f.requested.length;
      expect(first, greaterThan(0));
      final neg = await db.select(db.negativeCache).get();
      expect(neg.map((n) => n.key), contains('cand:fruits_vegetables'));
      await online.clearCache();
      expect(await online.cacheSize(), 0);
    });

    test('TTL: entries older than 30 days are ignored', () async {
      var now = DateTime(2026, 1, 1);
      final online = OnlineSearchSource(
        db: db,
        blocklistText: '',
        brandsText: '',
        fetcher: FixtureFetcher(fruitFixtures()),
        useIsolate: false,
        clock: () => now,
      );
      await online.fetchWords('fruits_vegetables', 10);
      expect(await online.cachedWords('fruits_vegetables'), isNotEmpty);
      now = now.add(const Duration(days: 31));
      expect(await online.cachedWords('fruits_vegetables'), isEmpty);
    });
  });
}
