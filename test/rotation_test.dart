import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/domain/models/word_entry.dart';
import 'package:hushbug/domain/random_service.dart';
import 'package:hushbug/domain/rotation_selector.dart';

const entry = WordEntry(
  id: 't:pizza',
  category: 'Food',
  word: 'Pizza',
  source: 'test',
  hints: [
    Hint(text: 'Italian dish', level: 1),
    Hint(text: 'Baked food', level: 1),
    Hint(text: 'Shared at parties', level: 2),
    Hint(text: 'Delivered hot', level: 2),
    Hint(text: 'Comes in slices', level: 3),
    Hint(text: 'Topped with cheese', level: 3),
  ],
  fakeWords: ['Pasta', 'Burger', 'Calzone', 'Lasagna'],
);

void main() {
  for (final level in [1, 2, 3]) {
    test('word served 20x at level $level: stays at that level, rotates, no back-to-back', () {
      for (var seed = 0; seed < 50; seed++) {
        final sel = HintSelector(RandomService(Random(seed)));
        final usage = RotationUsage();
        final shown = <String>[];
        for (var i = 0; i < 20; i++) {
          shown.add(sel.select(entry, level, usage)!.text);
        }
        // Difficulty never drifts into another level's hints.
        expect(shown.every((t) => entry.hints.firstWhere((h) => h.text == t).level == level), isTrue,
            reason: 'seed=$seed');
        // Both hints of the level are used before any repeat.
        for (var c = 0; c + 2 <= 20; c += 2) {
          expect(shown.sublist(c, c + 2).toSet().length, 2, reason: 'seed=$seed');
        }
        for (var i = 1; i < shown.length; i++) {
          expect(shown[i], isNot(shown[i - 1]), reason: 'seed=$seed i=$i');
        }
      }
    });
  }

  test('playing other difficulties does not leak hints between levels', () {
    final sel = HintSelector(RandomService(Random(1)));
    final usage = RotationUsage();
    for (var i = 0; i < 10; i++) {
      expect(sel.select(entry, 3, usage)!.level, 3);
      expect(sel.select(entry, 1, usage)!.level, 1);
    }
  });

  test('falls back to the nearest existing level only when the word has none', () {
    const onlyVague = WordEntry(id: 't:x', category: 'Food', word: 'X', source: 'test', hints: [
      Hint(text: 'Vague one', level: 1),
      Hint(text: 'Vague two', level: 1),
      Hint(text: 'Medium one', level: 2),
    ]);
    final sel = HintSelector(RandomService(Random(3)));
    final usage = RotationUsage();
    for (var i = 0; i < 6; i++) {
      expect(sel.select(onlyVague, 3, usage)!.level, 2);
    }
  });

  test('fake words rotate, never the same twice in a row', () {
    for (var seed = 0; seed < 50; seed++) {
      final sel = FakeWordSelector(RandomService(Random(seed)));
      final usage = RotationUsage();
      final shown = [for (var i = 0; i < 20; i++) sel.select(entry, usage)!];
      expect(shown.sublist(0, 4).toSet().length, 4);
      for (var i = 1; i < shown.length; i++) {
        expect(shown[i], isNot(shown[i - 1]));
      }
    }
  });

  test('usage survives JSON round-trip (persistence of rotation state)', () {
    final rnd = RandomService(Random(2));
    final usage = RotationUsage();
    final first = HintSelector(rnd).select(entry, 2, usage)!.text;
    final restored = RotationUsage.fromJson(usage.toJson());
    final second = HintSelector(rnd).select(entry, 2, restored)!.text;
    expect(second, isNot(first));
  });
}
