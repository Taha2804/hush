import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/domain/random_service.dart';
import 'package:hushbug/domain/shuffle_bag.dart';

void main() {
  Set<String> pool(int n) => {for (var i = 0; i < n; i++) 'w$i'};

  test('no repeats until the bag is exhausted', () {
    final p = pool(50);
    final bag = ShuffleBag(ShuffleBagState(), RandomService(Random(1)));
    for (var cycle = 0; cycle < 5; cycle++) {
      final seen = <String>{};
      for (var i = 0; i < 50; i++) {
        final w = bag.deal(p)!;
        expect(seen.add(w), isTrue, reason: 'repeat of $w in cycle $cycle');
      }
      expect(seen, p);
    }
  });

  test('reshuffle boundary: last 10 dealt never in next first 10', () {
    for (var seed = 0; seed < 200; seed++) {
      final p = pool(40);
      final bag = ShuffleBag(ShuffleBagState(), RandomService(Random(seed)));
      final dealt = <String>[];
      for (var i = 0; i < 40 * 4; i++) {
        dealt.add(bag.deal(p)!);
      }
      for (var b = 40; b < dealt.length; b += 40) {
        final tail = dealt.sublist(b - 10, b).toSet();
        final head = dealt.sublist(b, b + 10).toSet();
        expect(tail.intersection(head), isEmpty, reason: 'seed=$seed boundary=$b');
      }
    }
  });

  test('pool growth: new words are dealt in the current cycle, no repeats', () {
    final bag = ShuffleBag(ShuffleBagState(), RandomService(Random(3)));
    final p = pool(20);
    final seen = <String>{};
    for (var i = 0; i < 10; i++) {
      seen.add(bag.deal(p)!);
    }
    final grown = {...p, for (var i = 100; i < 110; i++) 'w$i'};
    for (var i = 0; i < 20; i++) {
      expect(seen.add(bag.deal(grown)!), isTrue);
    }
    expect(seen, grown);
  });

  test('avoid predicate skips history words while others remain', () {
    final bag = ShuffleBag(ShuffleBagState(), RandomService(Random(4)));
    final p = pool(10);
    final avoid = {'w0', 'w1', 'w2'};
    final first7 = [for (var i = 0; i < 7; i++) bag.deal(p, avoid: avoid.contains)!];
    expect(first7.toSet().intersection(avoid), isEmpty);
    // Only avoided words remain: they are served now (pool exhausted).
    final last3 = [for (var i = 0; i < 3; i++) bag.deal(p, avoid: avoid.contains)!];
    expect(last3.toSet(), avoid);
  });

  test('state round-trips through JSON', () {
    final bag = ShuffleBag(ShuffleBagState(), RandomService(Random(5)));
    final p = pool(15);
    for (var i = 0; i < 6; i++) {
      bag.deal(p);
    }
    final copy = ShuffleBagState.fromJson(bag.state.toJson());
    expect(copy.remaining, bag.state.remaining);
    expect(copy.dealt, bag.state.dealt);
    expect(copy.recent, bag.state.recent);
  });
}
