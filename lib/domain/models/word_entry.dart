import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_entry.freezed.dart';
part 'word_entry.g.dart';

/// How well-known a secret word is (used for word-difficulty filtering and
/// balanced Mixed selection). It never changes hints or imposter words.
enum WordDifficulty { easy, medium, hard }

/// A single hint for a secret word, given to the imposter in Hint mode.
///
/// [level] is how DIRECT the hint is: 3 = easy (recognizable association),
/// 2 = medium (indirect), 1 = hard (subtle). See `HintDifficulty.level`.
@freezed
abstract class Hint with _$Hint {
  const factory Hint({required String text, required int level}) = _Hint;

  factory Hint.fromJson(Map<String, dynamic> json) => _$HintFromJson(json);
}

/// An alternative word handed to imposters in Fake Word mode.
///
/// [level] is how CLOSE it is to the secret word: 1 = easy (same broad
/// area, noticeably different), 2 = medium (shares context), 3 = hard (very
/// close, similar function or look). See `ImposterDifficulty.level`.
@freezed
abstract class ImposterWord with _$ImposterWord {
  const factory ImposterWord({required String text, @Default(2) int level}) = _ImposterWord;

  factory ImposterWord.fromJson(Map<String, dynamic> json) => _$ImposterWordFromJson(json);
}

/// A playable word. Word, description, hints and imposter words are four
/// separate fields and are never derived from one another.
@freezed
abstract class WordEntry with _$WordEntry {
  const WordEntry._();

  const factory WordEntry({
    required String id,
    /// Category id (e.g. `animals_wildlife`, or `my12` for a custom pack).
    required String category,
    required String word,
    String? subcategory,
    @Default(WordDifficulty.medium) WordDifficulty difficulty,
    @Default(<String>[]) List<String> tags,
    @Default(false) bool isAdult,
    @Default(<Hint>[]) List<Hint> hints,
    @Default(<ImposterWord>[]) List<ImposterWord> imposters,
    /// One-sentence neutral definition shown only to players who get the
    /// real word. Never built from hints.
    String? description,
    required String source,
  }) = _WordEntry;

  factory WordEntry.fromJson(Map<String, dynamic> json) =>
      _$WordEntryFromJson(json);

  bool get hasHints => hints.isNotEmpty;
  bool get hasFakes => imposters.isNotEmpty;

  /// Imposter words as plain strings (any tier).
  List<String> get fakeWords => [for (final i in imposters) i.text];
}
