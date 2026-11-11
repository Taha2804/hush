// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameConfig _$GameConfigFromJson(Map<String, dynamic> json) => _GameConfig(
  players:
      (json['players'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>['Player 1', 'Player 2', 'Player 3', 'Player 4'],
  imposterCount: (json['imposterCount'] as num?)?.toInt() ?? 1,
  mode: $enumDecodeNullable(_$GameModeEnumMap, json['mode']) ?? GameMode.hint,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  randomMix: json['randomMix'] as bool? ?? true,
  discussionSeconds: (json['discussionSeconds'] as num?)?.toInt() ?? 180,
  clueRounds: (json['clueRounds'] as num?)?.toInt() ?? 1,
  hintDifficulty:
      $enumDecodeNullable(_$HintDifficultyEnumMap, json['hintDifficulty']) ??
      HintDifficulty.medium,
  speedRound: json['speedRound'] as bool? ?? false,
  speedSeconds: (json['speedSeconds'] as num?)?.toInt() ?? 15,
  maybeNobody: json['maybeNobody'] as bool? ?? false,
  maybeNobodyChance: (json['maybeNobodyChance'] as num?)?.toDouble() ?? 0.10,
  tieRule:
      $enumDecodeNullable(_$TieRuleEnumMap, json['tieRule']) ?? TieRule.revote,
  voteStyle:
      $enumDecodeNullable(_$VoteStyleEnumMap, json['voteStyle']) ??
      VoteStyle.simple,
  seating:
      $enumDecodeNullable(_$SeatingModeEnumMap, json['seating']) ??
      SeatingMode.seatingFromStarter,
  avoidSameImposter: json['avoidSameImposter'] as bool? ?? false,
  lastChance: json['lastChance'] as bool? ?? true,
  scoreboard: json['scoreboard'] as bool? ?? true,
  impostersKnowEachOther: json['impostersKnowEachOther'] as bool? ?? false,
  crewStarts: json['crewStarts'] as bool? ?? false,
  roundTwists: json['roundTwists'] as bool? ?? false,
);

Map<String, dynamic> _$GameConfigToJson(_GameConfig instance) =>
    <String, dynamic>{
      'players': instance.players,
      'imposterCount': instance.imposterCount,
      'mode': _$GameModeEnumMap[instance.mode]!,
      'categories': instance.categories,
      'randomMix': instance.randomMix,
      'discussionSeconds': instance.discussionSeconds,
      'clueRounds': instance.clueRounds,
      'hintDifficulty': _$HintDifficultyEnumMap[instance.hintDifficulty]!,
      'speedRound': instance.speedRound,
      'speedSeconds': instance.speedSeconds,
      'maybeNobody': instance.maybeNobody,
      'maybeNobodyChance': instance.maybeNobodyChance,
      'tieRule': _$TieRuleEnumMap[instance.tieRule]!,
      'voteStyle': _$VoteStyleEnumMap[instance.voteStyle]!,
      'seating': _$SeatingModeEnumMap[instance.seating]!,
      'avoidSameImposter': instance.avoidSameImposter,
      'lastChance': instance.lastChance,
      'scoreboard': instance.scoreboard,
      'impostersKnowEachOther': instance.impostersKnowEachOther,
      'crewStarts': instance.crewStarts,
      'roundTwists': instance.roundTwists,
    };

const _$GameModeEnumMap = {
  GameMode.classic: 'classic',
  GameMode.hint: 'hint',
  GameMode.fakeWord: 'fakeWord',
};

const _$HintDifficultyEnumMap = {
  HintDifficulty.easy: 'easy',
  HintDifficulty.medium: 'medium',
  HintDifficulty.hard: 'hard',
};

const _$TieRuleEnumMap = {
  TieRule.revote: 'revote',
  TieRule.impostersWin: 'impostersWin',
};

const _$VoteStyleEnumMap = {
  VoteStyle.simple: 'simple',
  VoteStyle.private: 'private',
};

const _$SeatingModeEnumMap = {
  SeatingMode.seatingFromStarter: 'seatingFromStarter',
  SeatingMode.fullyShuffled: 'fullyShuffled',
};
