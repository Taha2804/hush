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

_WordEntry _$WordEntryFromJson(Map<String, dynamic> json) => _WordEntry(
  id: json['id'] as String,
  category: json['category'] as String,
  word: json['word'] as String,
  hints:
      (json['hints'] as List<dynamic>?)
          ?.map((e) => Hint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Hint>[],
  fakeWords:
      (json['fakeWords'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  description: json['description'] as String?,
  source: json['source'] as String,
);

Map<String, dynamic> _$WordEntryToJson(_WordEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'word': instance.word,
      'hints': instance.hints.map((e) => e.toJson()).toList(),
      'fakeWords': instance.fakeWords,
      'description': instance.description,
      'source': instance.source,
    };
