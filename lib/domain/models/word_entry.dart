import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_entry.freezed.dart';
part 'word_entry.g.dart';

/// A single hint for a secret word.
/// Level 1 = vague / category-level, 2 = medium association, 3 = specific.
@freezed
abstract class Hint with _$Hint {
  const factory Hint({required String text, required int level}) = _Hint;

  factory Hint.fromJson(Map<String, dynamic> json) => _$HintFromJson(json);
}

/// A playable word with its hint pool and fake-word pool.
@freezed
abstract class WordEntry with _$WordEntry {
  const WordEntry._();

  const factory WordEntry({
    required String id,
    required String category,
    required String word,
    @Default(<Hint>[]) List<Hint> hints,
    @Default(<String>[]) List<String> fakeWords,
    required String source,
  }) = _WordEntry;

  factory WordEntry.fromJson(Map<String, dynamic> json) =>
      _$WordEntryFromJson(json);

  bool get hasHints => hints.isNotEmpty;
  bool get hasFakes => fakeWords.isNotEmpty;
}
