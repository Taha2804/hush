import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_config.freezed.dart';
part 'game_config.g.dart';

enum GameMode { classic, hint, fakeWord }

enum TieRule { revote, impostersWin }

enum VoteStyle { simple, private }

enum SeatingMode { seatingFromStarter, fullyShuffled }

/// Easy shows level-3 (specific) hints, Hard shows level-1 (vague) hints.
enum HintDifficulty {
  easy(3),
  medium(2),
  hard(1);

  const HintDifficulty(this.level);
  final int level;
}

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
