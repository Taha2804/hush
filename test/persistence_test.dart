import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/data/db/app_db.dart';
import 'package:hushbug/domain/models/word_entry.dart';
import 'package:hushbug/domain/random_service.dart';
import 'package:hushbug/domain/state_store.dart';
import 'package:hushbug/domain/word_pipeline.dart';

List<WordEntry> makePool(int n) => [
      for (var i = 0; i < n; i++)
        WordEntry(
          id: 'off:food:w$i',
          category: 'Food',
          word: 'Word${String.fromCharCode(97 + i % 26)}${String.fromCharCode(97 + i ~/ 26)}',
          source: 'offline',
          hints: const [
            Hint(text: 'Vague clue', level: 1),
            Hint(text: 'Other vague', level: 1),
            Hint(text: 'Medium clue', level: 2),
            Hint(text: 'Another medium', level: 2),
            Hint(text: 'Specific clue', level: 3),
            Hint(text: 'Another specific', level: 3),
          ],
          fakeWords: const ['Alpha', 'Bravo', 'Charlie'],
        ),
    ];

void main() {
  test('hint difficulty: Easy = two specific hints, Medium/Hard = one hint of their level', () async {
    final db = AppDb(NativeDatabase.memory());
    addTearDown(db.close);
    final pipeline = WordPipeline(store: GameStateStore(DriftKeyValueStore(db)), random: RandomService(Random(5)));
    final pool = makePool(5);
    for (var round = 0; round < 15; round++) {
      final easy = await pipeline.deal(sourceId: 's', pools: {'Food': pool}, hintLevel: 3);
      expect(easy!.hint!.split(' · ').toSet(), {'Specific clue', 'Another specific'});
      final medium = await pipeline.deal(sourceId: 's', pools: {'Food': pool}, hintLevel: 2);
      expect(['Medium clue', 'Another medium'], contains(medium!.hint));
      final hard = await pipeline.deal(sourceId: 's', pools: {'Food': pool}, hintLevel: 1);
      expect(['Vague clue', 'Other vague'], contains(hard!.hint));
    }
  });

  test('bag, history and hint usage survive an app restart', () async {
    final dir = await Directory.systemTemp.createTemp('hushbug_test');
    final file = File('${dir.path}/state.sqlite');
    final pool = makePool(30);

    // --- Session 1 ---
    var db = AppDb(NativeDatabase(file));
    var pipeline = WordPipeline(
      store: GameStateStore(DriftKeyValueStore(db)),
      random: RandomService(Random(1)),
    );
    final served = <String>[];
    final hintsForFirst = <String>[];
    for (var i = 0; i < 12; i++) {
      final d = await pipeline.deal(
          sourceId: 'offline', pools: {'Food': pool}, hintLevel: 2, wantFake: true);
      served.add(d!.entry.id);
    }
    // Serve a specific word's hint twice via direct rotation to record usage.
    final firstEntry = pool.firstWhere((e) => e.id == served.first);
    hintsForFirst.add((await GameStateStore(DriftKeyValueStore(db))
            .loadHintUsage(firstEntry.id))
        .last
        .toString());
    await db.close();

    // --- Session 2 (restart: new DB connection, new random seed) ---
    db = AppDb(NativeDatabase(file));
    final store = GameStateStore(DriftKeyValueStore(db));
    pipeline = WordPipeline(store: store, random: RandomService(Random(999)));

    final history = await store.loadHistory();
    expect(history.length, 12);

    final usage = await store.loadHintUsage(firstEntry.id);
    expect(usage.shown, isNotEmpty);
    expect(usage.last.toString(), hintsForFirst.single);

    final bag = await store.loadBag('offline', 'Food');
    expect(bag.dealt.length, 12);
    expect(bag.remaining.length, 18);

    // The remaining 18 deals of the cycle never repeat the first 12.
    for (var i = 0; i < 18; i++) {
      final d = await pipeline.deal(
          sourceId: 'offline', pools: {'Food': pool}, hintLevel: 2);
      expect(served.contains(d!.entry.id), isFalse);
      served.add(d.entry.id);
    }
    expect(served.toSet().length, 30);
    await db.close();
    await dir.delete(recursive: true);
  });

  test('pipeline never serves a recent-history word while others exist', () async {
    final store = GameStateStore(InMemoryKeyValueStore());
    final pipeline = WordPipeline(store: store, random: RandomService(Random(3)));
    final pool = makePool(30);
    await store.saveHistory([for (final e in pool.take(10)) e.word.toLowerCase()]);
    for (var i = 0; i < 20; i++) {
      final d = await pipeline.deal(sourceId: 's', pools: {'Food': pool}, hintLevel: 2);
      expect(pool.take(10).map((e) => e.id).contains(d!.entry.id), isFalse);
    }
  });

  test('random mix favours categories with more unused words', () async {
    final store = GameStateStore(InMemoryKeyValueStore());
    final pipeline = WordPipeline(store: store, random: RandomService(Random(4)));
    final big = makePool(90);
    final small = [
      for (final e in makePool(10)) e.copyWith(id: e.id.replaceFirst('food', 'tiny'), category: 'Tiny'),
    ];
    var bigCount = 0;
    for (var i = 0; i < 10; i++) {
      final d = await pipeline.deal(
          sourceId: 's', pools: {'Food': big, 'Tiny': small}, hintLevel: 2);
      if (d!.category == 'Food') bigCount++;
    }
    expect(bigCount, greaterThanOrEqualTo(6));
  });
}
