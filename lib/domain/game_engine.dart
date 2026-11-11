import 'models/game_config.dart';
import 'random_service.dart';
import 'text_utils.dart';
import 'vote_resolver.dart';

enum GamePhase { reveal, clue, discussion, vote, lastChance, result }

enum Winner { crew, imposters, nobody }

enum WinReason {
  allImpostersCaught,
  wrongPlayerVoted,
  impostersOutnumber,
  tie,
  correctlyNoImposter,
  missedNoImposter,
  votedWhenNoImposter,
  lastChanceSteal,
}

/// What a single player sees on their secret card.
class RoleCard {
  const RoleCard({required this.showsImposter, this.word, this.hint, this.partners = const []});

  /// Fellow imposters this player knows about (teammates option).
  final List<int> partners;

  /// True when the card says "IMPOSTER" (Classic / Hint modes).
  final bool showsImposter;

  /// The word shown (real word for crew, fake word in Fake Word mode).
  final String? word;

  /// Hint for the imposter (Hint mode only).
  final String? hint;
}

/// Immutable state of one round. Players are referred to by index.
class RoundState {
  const RoundState({
    required this.config,
    required this.phase,
    required this.word,
    required this.category,
    required this.imposters,
    required this.starter,
    required this.turnOrder,
    this.hint,
    this.fakeWord,
    this.description,
    this.effectiveMode = GameMode.classic,
    this.revealIndex = 0,
    this.revealSeen = false,
    this.clueStep = 0,
    this.eliminated = const [],
    this.caught = const [],
    this.voteCandidates,
    this.ballots = const {},
    this.voterStep = 0,
    this.revotes = 0,
    this.lastEliminated,
    this.lastEliminatedWasImposter,
    this.winner,
    this.reason,
    this.lastChanceGuess,
    this.twist,
  });

  /// Index of this round's twist rule, or null when twists are off.
  final int? twist;

  final GameConfig config;
  final GamePhase phase;
  final String word;
  final String category;
  final String? hint;
  final String? fakeWord;

  /// Short description shown with the word to players who get the real word.
  final String? description;
  final GameMode effectiveMode;

  /// Imposter player indices; empty means "nobody" (chaos round).
  final List<int> imposters;
  final int starter;
  final List<int> turnOrder;

  final int revealIndex;
  final bool revealSeen;
  final int clueStep;

  final List<int> eliminated;
  final List<int> caught;

  /// Players that may be voted for (null = all alive players).
  final List<int>? voteCandidates;
  final Map<int, int> ballots;
  final int voterStep;
  final int revotes;

  final int? lastEliminated;
  final bool? lastEliminatedWasImposter;

  final Winner? winner;
  final WinReason? reason;
  final String? lastChanceGuess;

  List<String> get players => config.players;
  int get playerCount => config.players.length;
  bool get noImposter => imposters.isEmpty;

  List<int> get alive =>
      [for (var i = 0; i < playerCount; i++) if (!eliminated.contains(i)) i];

  List<int> get candidates => voteCandidates ?? alive;

  int get totalClueSteps => turnOrder.length * config.clueRounds;
  int get currentCluePlayer => turnOrder[clueStep % turnOrder.length];
  int get currentClueRound => clueStep ~/ turnOrder.length + 1;

  int get remainingImposters => imposters.where((i) => !eliminated.contains(i)).length;
  int get remainingCrew => alive.length - remainingImposters;

  /// Voters in private voting: alive players, in seating order.
  List<int> get voters => alive;

  RoundState copyWith({
    GamePhase? phase,
    int? revealIndex,
    bool? revealSeen,
    int? clueStep,
    List<int>? eliminated,
    List<int>? caught,
    List<int>? Function()? voteCandidates,
    Map<int, int>? ballots,
    int? voterStep,
    int? revotes,
    int? Function()? lastEliminated,
    bool? Function()? lastEliminatedWasImposter,
    Winner? winner,
    WinReason? reason,
    String? lastChanceGuess,
  }) =>
      RoundState(
        config: config,
        phase: phase ?? this.phase,
        word: word,
        category: category,
        hint: hint,
        fakeWord: fakeWord,
        description: description,
        effectiveMode: effectiveMode,
        imposters: imposters,
        starter: starter,
        turnOrder: turnOrder,
        revealIndex: revealIndex ?? this.revealIndex,
        revealSeen: revealSeen ?? this.revealSeen,
        clueStep: clueStep ?? this.clueStep,
        eliminated: eliminated ?? this.eliminated,
        caught: caught ?? this.caught,
        voteCandidates: voteCandidates != null ? voteCandidates() : this.voteCandidates,
        ballots: ballots ?? this.ballots,
        voterStep: voterStep ?? this.voterStep,
        revotes: revotes ?? this.revotes,
        lastEliminated: lastEliminated != null ? lastEliminated() : this.lastEliminated,
        lastEliminatedWasImposter: lastEliminatedWasImposter != null
            ? lastEliminatedWasImposter()
            : this.lastEliminatedWasImposter,
        winner: winner ?? this.winner,
        reason: reason ?? this.reason,
        lastChanceGuess: lastChanceGuess ?? this.lastChanceGuess,
        twist: twist,
      );
}

/// Result of the role draw, exposed separately for statistical testing.
class RoleDraw {
  const RoleDraw(this.imposters, this.starter, this.turnOrder);
  final List<int> imposters;
  final int starter;
  final List<int> turnOrder;
}

/// Pure-Dart game state machine. No Flutter imports.
class GameEngine {
  GameEngine(this.random, {this.resolver = const VoteResolver()});

  final RandomService random;
  final VoteResolver resolver;

  /// Max number of revotes before a persisting tie goes to the imposters.
  static const maxRevotes = 2;

  /// R2 + R4: draws imposters uniformly at random (independent of seating,
  /// names and word), then — in a separate draw that never looks at roles —
  /// the starting player uniformly from all players.
  RoleDraw drawRoles({
    required int players,
    required int imposterCount,
    bool noImposter = false,
    bool avoidSame = false,
    List<int> previousImposters = const [],
    SeatingMode seating = SeatingMode.seatingFromStarter,
    bool crewStarts = false,
  }) {
    final all = [for (var i = 0; i < players; i++) i];
    List<int> imposters;
    if (noImposter) {
      imposters = const [];
    } else {
      var pool = all;
      if (avoidSame && previousImposters.isNotEmpty) {
        final reduced = all.where((i) => !previousImposters.contains(i)).toList();
        if (reduced.length >= imposterCount) pool = reduced;
      }
      imposters = random.sample(pool, imposterCount)..sort();
    }
    // Separate draw AFTER roles; does not read `imposters` — unless the
    // opt-in "crew starts" rule is on, which deliberately picks the starter
    // uniformly from the crew.
    final crew = all.where((i) => !imposters.contains(i)).toList();
    final starter = crewStarts && imposters.isNotEmpty && crew.isNotEmpty
        ? crew[random.nextInt(crew.length)]
        : random.nextInt(players);
    final List<int> order;
    if (seating == SeatingMode.seatingFromStarter) {
      order = [for (var k = 0; k < players; k++) (starter + k) % players];
    } else {
      final rest = all.where((i) => i != starter).toList();
      random.shuffleInPlace(rest);
      order = [starter, ...rest];
    }
    return RoleDraw(List.unmodifiable(imposters), starter, List.unmodifiable(order));
  }

  RoundState startRound({
    required GameConfig config,
    required String word,
    required String category,
    String? hint,
    String? fakeWord,
    String? description,
    List<int> previousImposters = const [],
  }) {
    final n = config.players.length;
    if (n < GameConfig.minPlayers || n > GameConfig.maxPlayers) {
      throw ArgumentError('Player count $n out of range');
    }
    final k = config.imposterCount.clamp(1, config.maxImposters);
    final noImposter = config.maybeNobody && random.chance(config.maybeNobodyChance);
    final draw = drawRoles(
      players: n,
      imposterCount: k,
      noImposter: noImposter,
      avoidSame: config.avoidSameImposter,
      previousImposters: previousImposters,
      seating: config.seating,
      crewStarts: config.crewStarts,
    );
    final twist = config.roundTwists ? random.nextInt(GameConfig.twistCount) : null;
    var mode = config.mode;
    if (mode == GameMode.fakeWord && (fakeWord == null || fakeWord.isEmpty)) {
      mode = GameMode.hint; // no fake available -> graceful fallback
    }
    return RoundState(
      config: config,
      phase: GamePhase.reveal,
      word: word,
      category: category,
      hint: hint,
      fakeWord: mode == GameMode.fakeWord ? fakeWord : null,
      description: description,
      effectiveMode: mode,
      imposters: draw.imposters,
      starter: draw.starter,
      turnOrder: draw.turnOrder,
      twist: twist,
    );
  }

  RoleCard cardFor(RoundState s, int player) {
    final isImp = s.imposters.contains(player);
    if (!isImp) return RoleCard(showsImposter: false, word: s.word);
    // Fake Word imposters don't know they are imposters, so no partners.
    final partners = s.config.impostersKnowEachOther
        ? [for (final i in s.imposters) if (i != player) i]
        : const <int>[];
    switch (s.effectiveMode) {
      case GameMode.classic:
        return RoleCard(showsImposter: true, partners: partners);
      case GameMode.hint:
        return RoleCard(showsImposter: true, hint: s.hint ?? s.category, partners: partners);
      case GameMode.fakeWord:
        return RoleCard(showsImposter: false, word: s.fakeWord);
    }
  }

  // ---- Reveal ----
  RoundState markRevealed(RoundState s) =>
      s.phase == GamePhase.reveal ? s.copyWith(revealSeen: true) : s;

  RoundState nextReveal(RoundState s) {
    if (s.phase != GamePhase.reveal || !s.revealSeen) return s;
    if (s.revealIndex + 1 >= s.playerCount) {
      return s.copyWith(phase: GamePhase.clue, clueStep: 0, revealSeen: false);
    }
    return s.copyWith(revealIndex: s.revealIndex + 1, revealSeen: false);
  }

  // ---- Clues ----
  RoundState nextClue(RoundState s) {
    if (s.phase != GamePhase.clue) return s;
    if (s.clueStep + 1 >= s.totalClueSteps) return s.copyWith(phase: GamePhase.discussion);
    return s.copyWith(clueStep: s.clueStep + 1);
  }

  RoundState skipToDiscussion(RoundState s) => s.copyWith(phase: GamePhase.discussion);

  RoundState startVote(RoundState s) => s.copyWith(
        phase: GamePhase.vote,
        ballots: const {},
        voterStep: 0,
      );

  // ---- Voting ----
  /// Simple mode: the group taps the most-voted player (or [noImposterVote]).
  RoundState chooseTarget(RoundState s, int target) {
    if (s.phase != GamePhase.vote) return s;
    return _applyDecision(s, target);
  }

  /// Simple mode: the group reports a tie.
  RoundState declareTie(RoundState s, List<int> tied) {
    if (s.phase != GamePhase.vote) return s;
    return _applyTie(s, tied);
  }

  /// Private mode: the current voter casts a ballot.
  RoundState castBallot(RoundState s, int target) {
    if (s.phase != GamePhase.vote) return s;
    final voters = s.voters;
    final voter = voters[s.voterStep];
    final ballots = {...s.ballots, voter: target};
    if (s.voterStep + 1 < voters.length) {
      return s.copyWith(ballots: ballots, voterStep: s.voterStep + 1);
    }
    final outcome = resolver.resolve(ballots);
    final cleared = s.copyWith(ballots: ballots);
    return switch (outcome) {
      VoteDecided(:final target) => _applyDecision(cleared, target),
      VoteTie(:final targets) => _applyTie(cleared, targets),
      NoVotes() => cleared,
    };
  }

  RoundState _applyTie(RoundState s, List<int> tied) {
    if (s.config.tieRule == TieRule.impostersWin || s.revotes >= maxRevotes) {
      return _finish(s, s.noImposter ? Winner.nobody : Winner.imposters, WinReason.tie);
    }
    final cands = tied.where((t) => t != noImposterVote).toList();
    return s.copyWith(
      phase: GamePhase.vote,
      ballots: const {},
      voterStep: 0,
      revotes: s.revotes + 1,
      voteCandidates: () => cands.length >= 2 ? cands : null,
    );
  }

  RoundState _applyDecision(RoundState s, int target) {
    if (target == noImposterVote) {
      return s.noImposter
          ? _finish(s, Winner.crew, WinReason.correctlyNoImposter)
          : _finish(s, Winner.imposters, WinReason.missedNoImposter);
    }
    if (s.noImposter) {
      return _finish(
        s.copyWith(lastEliminated: () => target, lastEliminatedWasImposter: () => false),
        Winner.nobody,
        WinReason.votedWhenNoImposter,
      );
    }
    final isImp = s.imposters.contains(target);
    final eliminated = [...s.eliminated, target];
    var next = s.copyWith(
      eliminated: eliminated,
      caught: isImp ? [...s.caught, target] : s.caught,
      lastEliminated: () => target,
      lastEliminatedWasImposter: () => isImp,
      voteCandidates: () => null,
      ballots: const {},
      voterStep: 0,
      revotes: 0,
    );
    if (isImp) {
      if (next.remainingImposters == 0) {
        if (s.config.lastChance) return next.copyWith(phase: GamePhase.lastChance);
        return _finish(next, Winner.crew, WinReason.allImpostersCaught);
      }
      if (next.remainingImposters >= next.remainingCrew) {
        return _finish(next, Winner.imposters, WinReason.impostersOutnumber);
      }
      return next.copyWith(phase: GamePhase.discussion);
    }
    // Crew member voted out.
    if (s.imposters.length == 1) {
      return _finish(next, Winner.imposters, WinReason.wrongPlayerVoted);
    }
    if (next.remainingImposters >= next.remainingCrew) {
      return _finish(next, Winner.imposters, WinReason.impostersOutnumber);
    }
    return next.copyWith(phase: GamePhase.discussion);
  }

  /// True if [guess] matches the secret word (case/plural-insensitive).
  bool guessMatches(RoundState s, String guess) {
    final g = normalize(guess);
    if (g.isEmpty) return false;
    final w = normalize(s.word);
    return g == w || stem(g.replaceAll(' ', '')) == stem(w.replaceAll(' ', ''));
  }

  /// Last chance: imposters guess the word. [accepted] overrides the
  /// automatic comparison (the group may accept a close guess).
  RoundState submitLastChance(RoundState s, String guess, {bool? accepted}) {
    if (s.phase != GamePhase.lastChance) return s;
    final ok = accepted ?? guessMatches(s, guess);
    final withGuess = s.copyWith(lastChanceGuess: guess);
    return ok
        ? _finish(withGuess, Winner.imposters, WinReason.lastChanceSteal)
        : _finish(withGuess, Winner.crew, WinReason.allImpostersCaught);
  }

  RoundState _finish(RoundState s, Winner w, WinReason r) =>
      s.copyWith(phase: GamePhase.result, winner: w, reason: r);

  /// Points per player name for a finished round.
  /// Crew win: +1 each crew member. Imposter win: +2 each imposter.
  /// Correct "No imposter": +1 everyone. Nobody: no points.
  Map<String, int> scoreDelta(RoundState s) {
    final out = <String, int>{};
    if (s.winner == null) return out;
    for (var i = 0; i < s.playerCount; i++) {
      final isImp = s.imposters.contains(i);
      final pts = switch (s.winner!) {
        Winner.crew => isImp ? 0 : 1,
        Winner.imposters => isImp ? 2 : 0,
        Winner.nobody => 0,
      };
      if (pts > 0) out[s.players[i]] = pts;
    }
    return out;
  }
}

/// Builds a word's description from its hint lines, broad to specific,
/// for example "Wild animal • Big cat • Lives in a pride".
String? describeWord(Iterable<({String text, int level})> hints) {
  final sorted = hints.toList()..sort((a, b) => a.level.compareTo(b.level));
  final seen = <String>{};
  final parts = [
    for (final h in sorted)
      if (h.text.trim().isNotEmpty && seen.add(h.text.trim().toLowerCase())) h.text.trim(),
  ];
  return parts.isEmpty ? null : parts.join(' • ');
}
