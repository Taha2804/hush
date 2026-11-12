import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_config.freezed.dart';
part 'game_config.g.dart';

enum GameMode { classic, hint, fakeWord }

enum TieRule { revote, impostersWin }

enum VoteStyle { simple, private }

enum SeatingMode { seatingFromStarter, fullyShuffled }

/// How directly the Hint-mode imposter's hint points at the secret word.
/// Easy uses level-3 (recognizable) hints, Hard uses level-1 (subtle) hints.
enum HintDifficulty {
  easy(3),
  medium(2),
  hard(1);

  const HintDifficulty(this.level);
  final int level;
}

/// How close the Fake Word imposter's word is to the secret word.
/// Easy = noticeably different (level 1), Hard = very close (level 3).
/// Independent of [HintDifficulty].
enum ImposterDifficulty {
  easy(1),
  medium(2),
  hard(3);

  const ImposterDifficulty(this.level);
  final int level;
}

/// Which secret words may be dealt, by how well-known they are.
/// [mixed] balances easy, medium and hard words.
enum WordDifficultyFilter { mixed, easy, medium, hard }

/// Everything chosen on the Setup screen plus gameplay-relevant settings.
@freezed
abstract class GameConfig with _$GameConfig {
  const GameConfig._();

  const factory GameConfig({
    @Default(<String>['Player 1', 'Player 2', 'Player 3', 'Player 4'])
    List<String> players,
    @Default(1) int imposterCount,
    @Default(GameMode.hint) GameMode mode,
    @Default(<String>[]) List<String> categories,
    @Default(true) bool randomMix,
    @Default(180) int discussionSeconds,
    @Default(1) int clueRounds,
    @Default(HintDifficulty.medium) HintDifficulty hintDifficulty,
    @Default(ImposterDifficulty.medium) ImposterDifficulty imposterDifficulty,
    @Default(WordDifficultyFilter.mixed) WordDifficultyFilter wordDifficulty,
    /// Includes the 18+ After Dark category (needs a confirmed adult; never
    /// part of Random Mix unless this is on).
    @Default(false) bool adultContent,
    @Default(false) bool speedRound,
    @Default(15) int speedSeconds,
    @Default(false) bool maybeNobody,
    @Default(0.10) double maybeNobodyChance,
    @Default(TieRule.revote) TieRule tieRule,
    @Default(VoteStyle.simple) VoteStyle voteStyle,
    @Default(SeatingMode.seatingFromStarter) SeatingMode seating,
    @Default(false) bool avoidSameImposter,
    @Default(true) bool lastChance,
    @Default(true) bool scoreboard,
    // ---- Fun extras ----
    /// With 2+ imposters, each imposter's card names their partners.
    @Default(false) bool impostersKnowEachOther,
    /// The first speaker is always a crew member (easier for new groups).
    @Default(false) bool crewStarts,
    /// Each round gets a random "twist" rule for how clues are given.
    @Default(false) bool roundTwists,
  }) = _GameConfig;

  /// Number of different round twists (see l10n `twistN` strings).
  static const twistCount = 8;

  factory GameConfig.fromJson(Map<String, dynamic> json) =>
      _$GameConfigFromJson(json);

  static const minPlayers = 3;
  static const maxPlayers = 20;

  static int maxImpostersFor(int players) {
    final m = (players - 1) ~/ 2;
    return m < 1 ? 1 : m;
  }

  int get maxImposters => maxImpostersFor(players.length);
}
