import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sources/online/online_source.dart';
import '../domain/game_engine.dart';
import '../domain/models/game_config.dart';
import 'providers.dart';

class GameSession {
  const GameSession({
    this.round,
    this.loading = false,
    this.notice,
    this.error,
    this.previousImposters = const [],
    this.scored = false,
    this.lastDelta = const {},
  });

  final RoundState? round;
  final bool loading;
  final String? notice;
  final String? error;
  final List<int> previousImposters;
  final bool scored;
  final Map<String, int> lastDelta;

  GameSession copyWith({
    RoundState? Function()? round,
    bool? loading,
    String? Function()? notice,
    String? Function()? error,
    List<int>? previousImposters,
    bool? scored,
    Map<String, int>? lastDelta,
  }) =>
      GameSession(
        round: round != null ? round() : this.round,
        loading: loading ?? this.loading,
        notice: notice != null ? notice() : this.notice,
        error: error != null ? error() : this.error,
        previousImposters: previousImposters ?? this.previousImposters,
        scored: scored ?? this.scored,
        lastDelta: lastDelta ?? this.lastDelta,
      );
}

/// Orchestrates sources, pipeline and the pure [GameEngine].
class GameController extends Notifier<GameSession> {
  late GameEngine _engine;

  @override
  GameSession build() {
    _engine = GameEngine(ref.watch(randomProvider));
    return const GameSession();
  }

  GameEngine get engine => _engine;

  /// Deals a word and starts a round with the saved config.
  Future<bool> startRound() async {
    final settings = ref.read(settingsProvider);
    final sourceId = ref.read(currentSourceProvider) ?? 'offline';
    final registry = ref.read(registryProvider);
    final config = settings.game;
    state = state.copyWith(loading: true, error: () => null, notice: () => null);
    try {
      var categories = config.randomMix || config.categories.isEmpty
          ? await registry.byId(sourceId).categories()
          : config.categories;
      if (categories.isEmpty) categories = await registry.offline.categories();
      if (sourceId == OnlineSearchSource.sourceId && categories.length > 1 && await registry.online.isAvailable()) {
        final rnd = ref.read(randomProvider);
        categories = await registry.online.playableSubset(categories, shuffle: (l) => rnd.shuffled(l));
      }
      final resolved = await registry.resolve(sourceId, categories);
      final wantFake = config.mode == GameMode.fakeWord;
      final pipeline = ref.read(pipelineProvider);
      final bagSource = resolved.sourceUsed == 'online_cache' ? OnlineSearchSource.sourceId : resolved.sourceUsed;
      var dealt = await pipeline.deal(
        sourceId: bagSource,
        pools: resolved.pools,
        hintLevel: config.hintDifficulty.level,
        wantFake: wantFake,
        eligible: wantFake ? (e) => e.hasFakes : null,
      );
      String? notice = resolved.notice;
      if (dealt == null && wantFake) {
        dealt = await pipeline.deal(
            sourceId: bagSource, pools: resolved.pools, hintLevel: config.hintDifficulty.level);
        notice = 'fake_fallback';
      }
      if (dealt == null) {
        state = state.copyWith(loading: false, error: () => 'no_words');
        return false;
      }
      if (resolved.sourceUsed == OnlineSearchSource.sourceId) {
        await registry.online.markUsed(dealt.entry.id);
        // Keep the pool topped up in the background for upcoming rounds.
        registry.online.ensureReady(dealt.entry.category);
      }
      final categoryName = dealt.entry.source == 'mywords'
          ? dealt.entry.category
          : await registry.categoryName(resolved.sourceUsed == 'online' ? 'offline' : resolved.sourceUsed,
              dealt.category);
      final round = _engine.startRound(
        config: config,
        word: dealt.entry.word,
        category: categoryName,
        hint: dealt.entry.hints.isEmpty ? categoryName : dealt.hint,
        fakeWord: dealt.fakeWord,
        description: describeWord(dealt.entry.hints.map((h) => (text: h.text, level: h.level))),
        previousImposters: state.previousImposters,
      );
      if (wantFake && round.effectiveMode != GameMode.fakeWord) notice = 'fake_fallback';
      state = GameSession(
        round: round,
        notice: notice,
        previousImposters: round.imposters,
      );
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: () => e.toString());
      return false;
    }
  }

  void _set(RoundState next) {
    var s = state.copyWith(round: () => next);
    if (next.phase == GamePhase.result && !state.scored) {
      final delta = _engine.scoreDelta(next);
      final settings = ref.read(settingsProvider);
      if (settings.game.scoreboard) {
        final scores = {...settings.scores};
        for (final p in next.players) {
          scores.putIfAbsent(p, () => 0);
        }
        delta.forEach((k, v) => scores[k] = (scores[k] ?? 0) + v);
        ref.read(settingsProvider.notifier).update((st) => st.copyWith(scores: scores));
      }
      s = s.copyWith(scored: true, lastDelta: delta);
    }
    state = s;
  }

  RoundState? get _r => state.round;

  void markRevealed() => _r == null ? null : _set(_engine.markRevealed(_r!));
  void nextReveal() => _r == null ? null : _set(_engine.nextReveal(_r!));
  void nextClue() => _r == null ? null : _set(_engine.nextClue(_r!));
  void skipToDiscussion() => _r == null ? null : _set(_engine.skipToDiscussion(_r!));
  void startVote() => _r == null ? null : _set(_engine.startVote(_r!));
  void chooseTarget(int t) => _r == null ? null : _set(_engine.chooseTarget(_r!, t));
  void declareTie(List<int> tied) => _r == null ? null : _set(_engine.declareTie(_r!, tied));
  void castBallot(int t) => _r == null ? null : _set(_engine.castBallot(_r!, t));
  void submitGuess(String g, {bool? accepted}) =>
      _r == null ? null : _set(_engine.submitLastChance(_r!, g, accepted: accepted));

  void endGame() => state = GameSession(previousImposters: state.previousImposters);

  void clearNotice() => state = state.copyWith(notice: () => null);
}

final gameProvider = NotifierProvider<GameController, GameSession>(GameController.new);
