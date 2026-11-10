import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/domain/game_engine.dart';
import 'package:hushbug/domain/models/game_config.dart';
import 'package:hushbug/domain/random_service.dart';
import 'package:hushbug/domain/vote_resolver.dart';

void main() {
  final engine = GameEngine(RandomService(Random(42)));
  const five = GameConfig(players: ['A', 'B', 'C', 'D', 'E']);

  RoundState start(GameConfig c, {String? fake}) => engine.startRound(
      config: c, word: 'Pizza', category: 'Food', hint: 'Italian dish', fakeWord: fake);

  RoundState toVote(RoundState s) {
    for (var i = 0; i < s.playerCount; i++) {
      s = engine.nextReveal(engine.markRevealed(s));
    }
    expect(s.phase, GamePhase.clue);
    while (s.phase == GamePhase.clue) {
      s = engine.nextClue(s);
    }
    expect(s.phase, GamePhase.discussion);
    return engine.startVote(s);
  }

  test('crew starts: first speaker is never an imposter', () {
    const c = GameConfig(players: ['A', 'B', 'C', 'D', 'E', 'F', 'G'], imposterCount: 3, crewStarts: true);
    for (var i = 0; i < 300; i++) {
      final s = start(c);
      expect(s.imposters.contains(s.starter), isFalse);
      expect(s.turnOrder.first, s.starter);
    }
  });

  test('imposter teammates see each other (not crew, not in fake-word mode)', () {
    const c = GameConfig(players: ['A', 'B', 'C', 'D', 'E', 'F', 'G'], imposterCount: 2, impostersKnowEachOther: true);
    final s = start(c);
    final [a, b] = s.imposters;
    expect(engine.cardFor(s, a).partners, [b]);
    expect(engine.cardFor(s, b).partners, [a]);
    final crew = List.generate(7, (i) => i).firstWhere((i) => !s.imposters.contains(i));
    expect(engine.cardFor(s, crew).partners, isEmpty);
    final off = start(c.copyWith(impostersKnowEachOther: false));
    expect(engine.cardFor(off, off.imposters.first).partners, isEmpty);
  });

  test('round twists: a twist is drawn only when enabled, and it is in range', () {
    expect(start(five).twist, isNull);
    final seen = <int>{};
    for (var i = 0; i < 200; i++) {
      final t = start(five.copyWith(roundTwists: true)).twist!;
      expect(t, inInclusiveRange(0, GameConfig.twistCount - 1));
      seen.add(t);
    }
    expect(seen.length, GameConfig.twistCount);
  });

  test('reveal requires seeing the card before next', () {
    final s = start(five);
    expect(engine.nextReveal(s).revealIndex, 0);
    expect(engine.nextReveal(engine.markRevealed(s)).revealIndex, 1);
  });

  test('clue rounds = 2 doubles the steps', () {
    var s = start(five.copyWith(clueRounds: 2));
    for (var i = 0; i < 5; i++) {
      s = engine.nextReveal(engine.markRevealed(s));
    }
    var steps = 0;
    while (s.phase == GamePhase.clue) {
      s = engine.nextClue(s);
      steps++;
    }
    expect(steps, 10);
  });

  test('cards per mode', () {
    final classic = start(five.copyWith(mode: GameMode.classic));
    final imp = classic.imposters.single;
    final crew = (imp + 1) % 5;
    expect(engine.cardFor(classic, imp).showsImposter, isTrue);
    expect(engine.cardFor(classic, imp).hint, isNull);
    expect(engine.cardFor(classic, crew).word, 'Pizza');

    final hint = start(five.copyWith(mode: GameMode.hint));
    expect(engine.cardFor(hint, hint.imposters.single).hint, 'Italian dish');

    final fake = start(five.copyWith(mode: GameMode.fakeWord), fake: 'Pasta');
    final fc = engine.cardFor(fake, fake.imposters.single);
    expect(fc.showsImposter, isFalse);
    expect(fc.word, 'Pasta');

    final noFake = start(five.copyWith(mode: GameMode.fakeWord));
    expect(noFake.effectiveMode, GameMode.hint);
  });

  test('single imposter: catching them -> last chance, wrong guess -> crew', () {
    var s = toVote(start(five));
    s = engine.chooseTarget(s, s.imposters.single);
    expect(s.phase, GamePhase.lastChance);
    s = engine.submitLastChance(s, 'Burger');
    expect(s.winner, Winner.crew);
  });

  test('last chance correct guess steals the win (plural tolerant)', () {
    var s = toVote(start(five));
    s = engine.chooseTarget(s, s.imposters.single);
    s = engine.submitLastChance(s, 'pizzas');
    expect(s.winner, Winner.imposters);
    expect(s.reason, WinReason.lastChanceSteal);
  });

  test('single imposter: wrong vote -> imposter wins', () {
    var s = toVote(start(five.copyWith(lastChance: false)));
    final crew = s.alive.firstWhere((p) => !s.imposters.contains(p));
    s = engine.chooseTarget(s, crew);
    expect(s.winner, Winner.imposters);
  });

  test('multiple imposters: elimination rounds until caught or outnumbered', () {
    const seven = GameConfig(
        players: ['A', 'B', 'C', 'D', 'E', 'F', 'G'], imposterCount: 2, lastChance: false);
    var s = toVote(start(seven));
    // Vote out one imposter -> continue.
    s = engine.chooseTarget(s, s.imposters.first);
    expect(s.phase, GamePhase.discussion);
    s = engine.startVote(s);
    s = engine.chooseTarget(s, s.imposters.last);
    expect(s.winner, Winner.crew);

    // Outnumbered path: 5 players 2 imposters, vote out crew -> 2 imp vs 2 crew.
    const fiveTwo = GameConfig(players: ['A', 'B', 'C', 'D', 'E'], imposterCount: 2);
    var t = toVote(start(fiveTwo));
    final crew = t.alive.firstWhere((p) => !t.imposters.contains(p));
    t = engine.chooseTarget(t, crew);
    expect(t.winner, Winner.imposters);
    expect(t.reason, WinReason.impostersOutnumber);
  });

  test('tie rule: imposters win', () {
    var s = toVote(start(five.copyWith(tieRule: TieRule.impostersWin)));
    s = engine.declareTie(s, [0, 1]);
    expect(s.winner, Winner.imposters);
  });

  test('tie rule: revote restricts candidates, persistent tie ends game', () {
    var s = toVote(start(five.copyWith(voteStyle: VoteStyle.private)));
    // Private ballots: 5 voters, 2-2-1 split -> tie between 0 and 1.
    for (final t in [0, 0, 1, 1, 2]) {
      s = engine.castBallot(s, t);
    }
    expect(s.phase, GamePhase.vote);
    expect(s.candidates, [0, 1]);
    expect(s.revotes, 1);
    s = engine.declareTie(s, [0, 1]);
    s = engine.declareTie(s, [0, 1]);
    expect(s.phase, GamePhase.result);
    expect(s.reason, WinReason.tie);
  });

  test('chaos round: "No imposter" vote wins for crew, any other loses', () {
    final chaos = five.copyWith(maybeNobody: true, maybeNobodyChance: 1.0);
    var s = toVote(start(chaos));
    expect(s.noImposter, isTrue);
    expect(engine.chooseTarget(s, noImposterVote).winner, Winner.crew);
    expect(engine.chooseTarget(s, 2).winner, Winner.nobody);

    var r = toVote(start(five.copyWith(maybeNobody: true, maybeNobodyChance: 0)));
    r = engine.chooseTarget(r, noImposterVote);
    expect(r.winner, Winner.imposters);
  });

  test('vote resolver', () {
    const v = VoteResolver();
    expect(v.resolve({}), isA<NoVotes>());
    expect((v.resolve({0: 2, 1: 2, 2: 1}) as VoteDecided).target, 2);
    expect((v.resolve({0: 1, 1: 2}) as VoteTie).targets, [1, 2]);
  });

  test('scores', () {
    var s = toVote(start(five.copyWith(lastChance: false)));
    s = engine.chooseTarget(s, s.imposters.single);
    final delta = engine.scoreDelta(s);
    expect(delta.length, 4);
    expect(delta.values.every((v) => v == 1), isTrue);
  });

  test('max imposters rule', () {
    expect(GameConfig.maxImpostersFor(3), 1);
    expect(GameConfig.maxImpostersFor(4), 1);
    expect(GameConfig.maxImpostersFor(5), 2);
    expect(GameConfig.maxImpostersFor(20), 9);
  });
}
