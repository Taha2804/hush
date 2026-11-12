// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Hint _$HintFromJson(Map<String, dynamic> json) =>
    _Hint(text: json['text'] as String, level: (json['level'] as num).toInt());

Map<String, dynamic> _$HintToJson(_Hint instance) => <String, dynamic>{
  'text': instance.text,
  'level': instance.level,
};

_ImposterWord _$ImposterWordFromJson(Map<String, dynamic> json) =>
    _ImposterWord(
      text: json['text'] as String,
      level: (json['level'] as num?)?.toInt() ?? 2,
    );

Map<String, dynamic> _$ImposterWordToJson(_ImposterWord instance) =>
    <String, dynamic>{'text': instance.text, 'level': instance.level};

_WordEntry _$WordEntryFromJson(Map<String, dynamic> json) => _WordEntry(
  id: json['id'] as String,
  category: json['category'] as String,
  word: json['word'] as String,
  subcategory: json['subcategory'] as String?,
  difficulty:
      $enumDecodeNullable(_$WordDifficultyEnumMap, json['difficulty']) ??
      WordDifficulty.medium,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  isAdult: json['isAdult'] as bool? ?? false,
  hints:
      (json['hints'] as List<dynamic>?)
          ?.map((e) => Hint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Hint>[],
  imposters:
      (json['imposters'] as List<dynamic>?)
          ?.map((e) => ImposterWord.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ImposterWord>[],
  description: json['description'] as String?,
  source: json['source'] as String,
);

Map<String, dynamic> _$WordEntryToJson(_WordEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'word': instance.word,
      'subcategory': instance.subcategory,
      'difficulty': _$WordDifficultyEnumMap[instance.difficulty]!,
      'tags': instance.tags,
      'isAdult': instance.isAdult,
      'hints': instance.hints.map((e) => e.toJson()).toList(),
      'imposters': instance.imposters.map((e) => e.toJson()).toList(),
      'description': instance.description,
      'source': instance.source,
    };

const _$WordDifficultyEnumMap = {
  WordDifficulty.easy: 'easy',
  WordDifficulty.medium: 'medium',
  WordDifficulty.hard: 'hard',
};
