import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/data/db/app_db.dart';
import 'package:hushbug/data/sources/my_words_source.dart';
import 'package:hushbug/domain/models/word_entry.dart';
import 'package:hushbug/domain/random_service.dart';
import 'package:hushbug/domain/state_store.dart';
import 'package:hushbug/domain/word_pipeline.dart';

void main() {
  late AppDb db;
  late MyWordsSource src;
  setUp(() {
    db = AppDb(NativeDatabase.memory());
    src = MyWordsSource(db);
  });
  tearDown(() => db.close());

  test('create, add, bulk paste, export, import round-trip', () async {
    final id = await src.createPack('Party');
    await src.upsertWord(id, MyWord(word: 'Pizza', hints: const [Hint(text: 'Italian dish', level: 1)], fakes: const ['Pasta']));
    final n = await src.addMany(id, ['Taco', '', ' Sushi ', 'Taco']);
    expect(n, 3);
    final words = await src.wordsOf(id);
    expect(words.map((w) => w.word), ['Pizza', 'Sushi', 'Taco']); // dedupe by text
    expect(words.firstWhere((w) => w.word == 'Taco').needsHints, isTrue);

    final json = await src.exportJson(id);
    final parsed = MyWordsSource.parseImport(json);
    expect(parsed.name, 'Party');
    expect(parsed.words.length, 3);
    expect(parsed.words.firstWhere((w) => w.word == 'Pizza').hints.single.text, 'Italian dish');

    expect(await src.isAvailable(), isTrue);
    expect(await src.categories(), ['my$id']);
    final entries = await src.fetchWords('my$id', 99);
    expect(entries.first.category, 'Party');

    await src.renamePack(id, 'Food night');
    expect((await src.packs()).single.name, 'Food night');
    await src.deletePack(id);
    expect(await src.packs(), isEmpty);
    expect(await src.isAvailable(), isFalse);
  });

  test('CSV import with quotes and optional columns', () {
    final r = MyWordsSource.parseImport('word,hints,fakes\nPizza,"Italian dish|Comes in slices",Pasta|Burger\nTaco\n');
    expect(r.words.length, 2);
    expect(r.words.first.hints.length, 2);
    expect(r.words.first.fakes, ['Pasta', 'Burger']);
    expect(r.words.last.word, 'Taco');
  });

  test('words without hints give the imposter no hint (v2: no category fallback)', () async {
    final id = await src.createPack('Mine');
    await src.addMany(id, ['Kettle', 'Toaster', 'Blender']);
    final pipeline = WordPipeline(store: GameStateStore(InMemoryKeyValueStore()), random: RandomService(Random(1)));
    final entries = pipeline.clean(await src.fetchWords('my$id', 99), requireHints: false);
    expect(entries.length, 3);
    final dealt = await pipeline.deal(sourceId: 'mywords', pools: {'my$id': entries}, hintLevel: 2);
    expect(dealt!.hint, isNull);
    // Fake Word mode skips words without fakes.
    final none = await pipeline.deal(
        sourceId: 'mywords', pools: {'my$id': entries}, hintLevel: 2, wantFake: true, eligible: (e) => e.hasFakes);
    expect(none, isNull);
  });
}
