import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/domain/game_engine.dart';
import 'package:hushbug/domain/models/game_config.dart';
import 'package:hushbug/domain/random_service.dart';

import 'helpers/stats.dart';

void main() {
  const rounds = 24000;

  test('chi-square helper sanity', () {
    // Known critical value: df=4, x=18.467 -> p ~= 0.001
    expect(chiSquarePValue(18.467, 4), closeTo(0.001, 0.0001));
    expect(chiSquarePValue(0, 3), 1.0);
  });

  for (final n in [3, 5, 10, 20]) {
    group('n=$n players', () {
      late List<RoleDraw> draws;

      setUpAll(() {
        final engine = GameEngine(RandomService(Random(1000 + n)));
        draws = [
          for (var i = 0; i < rounds; i++)
            engine.drawRoles(players: n, imposterCount: 1),
        ];
      });

      test('imposter distribution is uniform (chi-square p > 0.001)', () {
        final counts = List<int>.filled(n, 0);
        for (final d in draws) {
          counts[d.imposters.single]++;
        }
        final p = chiSquarePValue(
            chiSquare(counts, List.filled(n, rounds / n)), n - 1);
        expect(p, greaterThan(0.001), reason: 'counts=$counts');
      });

      test('starter distribution is uniform (chi-square p > 0.001)', () {
        final counts = List<int>.filled(n, 0);
        for (final d in draws) {
          counts[d.starter]++;
        }
        final p = chiSquarePValue(
            chiSquare(counts, List.filled(n, rounds / n)), n - 1);
        expect(p, greaterThan(0.001), reason: 'counts=$counts');
      });

      test('P(imposter starts) ~= 1/n', () {
        final hits = draws.where((d) => d.imposters.single == d.starter).length;
        final pHat = hits / rounds;
        final expected = 1 / n;
        final sd = sqrt(expected * (1 - expected) / rounds);
        expect((pHat - expected).abs(), lessThan(4 * sd),
            reason: 'pHat=$pHat expected=$expected');
      });

      test('starter is independent of imposter (contingency test)', () {
        final table = List.generate(n, (_) => List<int>.filled(n, 0));
        for (final d in draws) {
          table[d.imposters.single][d.starter]++;
        }
        final r = independence(table);
        expect(r.p, greaterThan(0.001), reason: 'stat=${r.stat} df=${r.df}');
      });

      test('starter is independent of previous starter and previous imposter', () {
        final prevStarter = List.generate(n, (_) => List<int>.filled(n, 0));
        final prevImp = List.generate(n, (_) => List<int>.filled(n, 0));
        final impImp = List.generate(n, (_) => List<int>.filled(n, 0));
        for (var i = 1; i < draws.length; i++) {
          prevStarter[draws[i - 1].starter][draws[i].starter]++;
          prevImp[draws[i - 1].imposters.single][draws[i].starter]++;
          impImp[draws[i - 1].imposters.single][draws[i].imposters.single]++;
        }
        expect(independence(prevStarter).p, greaterThan(0.001));
        expect(independence(prevImp).p, greaterThan(0.001));
        expect(independence(impImp).p, greaterThan(0.001));
      });
    });
  }

  test('same imposter twice in a row is possible by default (true randomness)', () {
    final engine = GameEngine(RandomService(Random(7)));
    var repeats = 0;
    var prev = -1;
    for (var i = 0; i < 3000; i++) {
      final d = engine.drawRoles(players: 4, imposterCount: 1);
      if (d.imposters.single == prev) repeats++;
      prev = d.imposters.single;
    }
    // Expected ~ 3000/4 = 750
    expect(repeats, inInclusiveRange(600, 900));
  });

  test('avoidSame never repeats the previous imposter', () {
    final engine = GameEngine(RandomService(Random(8)));
    var prev = <int>[];
    for (var i = 0; i < 2000; i++) {
      final d = engine.drawRoles(
          players: 5, imposterCount: 1, avoidSame: true, previousImposters: prev);
      expect(d.imposters.any(prev.contains), isFalse);
      prev = d.imposters;
    }
  });

  test('multiple imposters: each player equally likely to be an imposter', () {
    final engine = GameEngine(RandomService(Random(9)));
    const n = 10, k = 3;
    final counts = List<int>.filled(n, 0);
    for (var i = 0; i < rounds; i++) {
      final d = engine.drawRoles(players: n, imposterCount: k);
      expect(d.imposters.toSet().length, k);
      for (final p in d.imposters) {
        counts[p]++;
      }
    }
    final p = chiSquarePValue(
        chiSquare(counts, List.filled(n, rounds * k / n)), n - 1);
    expect(p, greaterThan(0.001));
  });

  test('turn order: seating from starter and fully shuffled are permutations', () {
    final engine = GameEngine(RandomService(Random(10)));
    for (final mode in SeatingMode.values) {
      for (var i = 0; i < 200; i++) {
        final d = engine.drawRoles(players: 7, imposterCount: 2, seating: mode);
        expect(d.turnOrder.first, d.starter);
        expect(d.turnOrder.toSet(), {0, 1, 2, 3, 4, 5, 6});
      }
    }
  });

  test('maybe-nobody chance is respected', () {
    final engine = GameEngine(RandomService(Random(11)));
    const cfg = GameConfig(maybeNobody: true, maybeNobodyChance: 0.1);
    var nobody = 0;
    for (var i = 0; i < 10000; i++) {
      final s = engine.startRound(config: cfg, word: 'Apple', category: 'Fruits');
      if (s.noImposter) nobody++;
    }
    expect(nobody / 10000, closeTo(0.1, 0.015));
  });
}
