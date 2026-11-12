// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Hint {

 String get text; int get level;
/// Create a copy of Hint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HintCopyWith<Hint> get copyWith => _$HintCopyWithImpl<Hint>(this as Hint, _$identity);

  /// Serializes this Hint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Hint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Hint&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.level, _this.level) || other.level == _this.level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Hint;
  return Object.hash(runtimeType,_this.text,_this.level);
}

@override
String toString() {
  final _this = this as Hint;
  return 'Hint(text: ${_this.text}, level: ${_this.level})';
}


}

/// @nodoc
abstract mixin class $HintCopyWith<$Res>  {
  factory $HintCopyWith(Hint value, $Res Function(Hint) _then) = _$HintCopyWithImpl;
@useResult
$Res call({
 String text, int level
});




}
/// @nodoc
class _$HintCopyWithImpl<$Res>
    implements $HintCopyWith<$Res> {
  _$HintCopyWithImpl(this._self, this._then);

  final Hint _self;
  final $Res Function(Hint) _then;

/// Create a copy of Hint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? level = null,}) {
  return _then(Hint(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Hint].
extension HintPatterns on Hint {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Hint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Hint() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Hint value)  $default,){
final _that = this;
switch (_that) {
case _Hint():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Hint value)?  $default,){
final _that = this;
switch (_that) {
case _Hint() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  int level)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Hint() when $default != null:
return $default(_that.text,_that.level);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  int level)  $default,) {final _that = this;
switch (_that) {
case _Hint():
return $default(_that.text,_that.level);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  int level)?  $default,) {final _that = this;
switch (_that) {
case _Hint() when $default != null:
return $default(_that.text,_that.level);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Hint implements Hint {
  const _Hint({required this.text, required this.level});
  factory _Hint.fromJson(Map<String, dynamic> json) => _$HintFromJson(json);

@override final  String text;
@override final  int level;

/// Create a copy of Hint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HintCopyWith<_Hint> get copyWith => __$HintCopyWithImpl<_Hint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HintToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Hint&&(identical(other.text, text) || other.text == text)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,level);
}

@override
String toString() {
    return 'Hint(text: $text, level: $level)';
}


}

/// @nodoc
abstract mixin class _$HintCopyWith<$Res> implements $HintCopyWith<$Res> {
  factory _$HintCopyWith(_Hint value, $Res Function(_Hint) _then) = __$HintCopyWithImpl;
@override @useResult
$Res call({
 String text, int level
});




}
/// @nodoc
class __$HintCopyWithImpl<$Res>
    implements _$HintCopyWith<$Res> {
  __$HintCopyWithImpl(this._self, this._then);

  final _Hint _self;
  final $Res Function(_Hint) _then;

/// Create a copy of Hint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? level = null,}) {
  return _then(_Hint(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ImposterWord {

 String get text; int get level;
/// Create a copy of ImposterWord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImposterWordCopyWith<ImposterWord> get copyWith => _$ImposterWordCopyWithImpl<ImposterWord>(this as ImposterWord, _$identity);

  /// Serializes this ImposterWord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ImposterWord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImposterWord&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.level, _this.level) || other.level == _this.level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ImposterWord;
  return Object.hash(runtimeType,_this.text,_this.level);
}

@override
String toString() {
  final _this = this as ImposterWord;
  return 'ImposterWord(text: ${_this.text}, level: ${_this.level})';
}


}

/// @nodoc
abstract mixin class $ImposterWordCopyWith<$Res>  {
  factory $ImposterWordCopyWith(ImposterWord value, $Res Function(ImposterWord) _then) = _$ImposterWordCopyWithImpl;
@useResult
$Res call({
 String text, int level
});




}
/// @nodoc
class _$ImposterWordCopyWithImpl<$Res>
    implements $ImposterWordCopyWith<$Res> {
  _$ImposterWordCopyWithImpl(this._self, this._then);

  final ImposterWord _self;
  final $Res Function(ImposterWord) _then;

/// Create a copy of ImposterWord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? level = null,}) {
  return _then(ImposterWord(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ImposterWord].
extension ImposterWordPatterns on ImposterWord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImposterWord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImposterWord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImposterWord value)  $default,){
final _that = this;
switch (_that) {
case _ImposterWord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImposterWord value)?  $default,){
final _that = this;
switch (_that) {
case _ImposterWord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  int level)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImposterWord() when $default != null:
return $default(_that.text,_that.level);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  int level)  $default,) {final _that = this;
switch (_that) {
case _ImposterWord():
return $default(_that.text,_that.level);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  int level)?  $default,) {final _that = this;
switch (_that) {
case _ImposterWord() when $default != null:
return $default(_that.text,_that.level);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImposterWord implements ImposterWord {
  const _ImposterWord({required this.text, this.level = 2});
  factory _ImposterWord.fromJson(Map<String, dynamic> json) => _$ImposterWordFromJson(json);

@override final  String text;
@override@JsonKey() final  int level;

/// Create a copy of ImposterWord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImposterWordCopyWith<_ImposterWord> get copyWith => __$ImposterWordCopyWithImpl<_ImposterWord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImposterWordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImposterWord&&(identical(other.text, text) || other.text == text)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,level);
}

@override
String toString() {
    return 'ImposterWord(text: $text, level: $level)';
}


}

/// @nodoc
abstract mixin class _$ImposterWordCopyWith<$Res> implements $ImposterWordCopyWith<$Res> {
  factory _$ImposterWordCopyWith(_ImposterWord value, $Res Function(_ImposterWord) _then) = __$ImposterWordCopyWithImpl;
@override @useResult
$Res call({
 String text, int level
});




}
/// @nodoc
class __$ImposterWordCopyWithImpl<$Res>
    implements _$ImposterWordCopyWith<$Res> {
  __$ImposterWordCopyWithImpl(this._self, this._then);

  final _ImposterWord _self;
  final $Res Function(_ImposterWord) _then;

/// Create a copy of ImposterWord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? level = null,}) {
  return _then(_ImposterWord(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$WordEntry {

 String get id;/// Category id (e.g. `animals_wildlife`, or `my12` for a custom pack).
 String get category; String get word; String? get subcategory; WordDifficulty get difficulty; List<String> get tags; bool get isAdult; List<Hint> get hints; List<ImposterWord> get imposters;/// One-sentence neutral definition shown only to players who get the
/// real word. Never built from hints.
 String? get description; String get source;
/// Create a copy of WordEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordEntryCopyWith<WordEntry> get copyWith => _$WordEntryCopyWithImpl<WordEntry>(this as WordEntry, _$identity);

  /// Serializes this WordEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WordEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.word, _this.word) || other.word == _this.word)&&(identical(other.subcategory, _this.subcategory) || other.subcategory == _this.subcategory)&&(identical(other.difficulty, _this.difficulty) || other.difficulty == _this.difficulty)&&const DeepCollectionEquality().equals(other.tags, _this.tags)&&(identical(other.isAdult, _this.isAdult) || other.isAdult == _this.isAdult)&&const DeepCollectionEquality().equals(other.hints, _this.hints)&&const DeepCollectionEquality().equals(other.imposters, _this.imposters)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.source, _this.source) || other.source == _this.source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WordEntry;
  return Object.hash(runtimeType,_this.id,_this.category,_this.word,_this.subcategory,_this.difficulty,const DeepCollectionEquality().hash(_this.tags),_this.isAdult,const DeepCollectionEquality().hash(_this.hints),const DeepCollectionEquality().hash(_this.imposters),_this.description,_this.source);
}

@override
String toString() {
  final _this = this as WordEntry;
  return 'WordEntry(id: ${_this.id}, category: ${_this.category}, word: ${_this.word}, subcategory: ${_this.subcategory}, difficulty: ${_this.difficulty}, tags: ${_this.tags}, isAdult: ${_this.isAdult}, hints: ${_this.hints}, imposters: ${_this.imposters}, description: ${_this.description}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $WordEntryCopyWith<$Res>  {
  factory $WordEntryCopyWith(WordEntry value, $Res Function(WordEntry) _then) = _$WordEntryCopyWithImpl;
@useResult
$Res call({
 String id, String category, String word, String? subcategory, WordDifficulty difficulty, List<String> tags, bool isAdult, List<Hint> hints, List<ImposterWord> imposters, String? description, String source
});




}
/// @nodoc
class _$WordEntryCopyWithImpl<$Res>
    implements $WordEntryCopyWith<$Res> {
  _$WordEntryCopyWithImpl(this._self, this._then);

  final WordEntry _self;
  final $Res Function(WordEntry) _then;

/// Create a copy of WordEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category = null,Object? word = null,Object? subcategory = freezed,Object? difficulty = null,Object? tags = null,Object? isAdult = null,Object? hints = null,Object? imposters = null,Object? description = freezed,Object? source = null,}) {
  return _then(WordEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,subcategory: freezed == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as WordDifficulty,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isAdult: null == isAdult ? _self.isAdult : isAdult // ignore: cast_nullable_to_non_nullable
as bool,hints: null == hints ? _self.hints : hints // ignore: cast_nullable_to_non_nullable
as List<Hint>,imposters: null == imposters ? _self.imposters : imposters // ignore: cast_nullable_to_non_nullable
as List<ImposterWord>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WordEntry].
extension WordEntryPatterns on WordEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordEntry value)  $default,){
final _that = this;
switch (_that) {
case _WordEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordEntry value)?  $default,){
final _that = this;
switch (_that) {
case _WordEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String category,  String word,  String? subcategory,  WordDifficulty difficulty,  List<String> tags,  bool isAdult,  List<Hint> hints,  List<ImposterWord> imposters,  String? description,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordEntry() when $default != null:
return $default(_that.id,_that.category,_that.word,_that.subcategory,_that.difficulty,_that.tags,_that.isAdult,_that.hints,_that.imposters,_that.description,_that.source);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String category,  String word,  String? subcategory,  WordDifficulty difficulty,  List<String> tags,  bool isAdult,  List<Hint> hints,  List<ImposterWord> imposters,  String? description,  String source)  $default,) {final _that = this;
switch (_that) {
case _WordEntry():
return $default(_that.id,_that.category,_that.word,_that.subcategory,_that.difficulty,_that.tags,_that.isAdult,_that.hints,_that.imposters,_that.description,_that.source);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String category,  String word,  String? subcategory,  WordDifficulty difficulty,  List<String> tags,  bool isAdult,  List<Hint> hints,  List<ImposterWord> imposters,  String? description,  String source)?  $default,) {final _that = this;
switch (_that) {
case _WordEntry() when $default != null:
return $default(_that.id,_that.category,_that.word,_that.subcategory,_that.difficulty,_that.tags,_that.isAdult,_that.hints,_that.imposters,_that.description,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordEntry extends WordEntry {
  const _WordEntry({required this.id, required this.category, required this.word, this.subcategory, this.difficulty = WordDifficulty.medium,  List<String> tags = const <String>[], this.isAdult = false,  List<Hint> hints = const <Hint>[],  List<ImposterWord> imposters = const <ImposterWord>[], this.description, required this.source}): _tags = tags,_hints = hints,_imposters = imposters,super._();
  factory _WordEntry.fromJson(Map<String, dynamic> json) => _$WordEntryFromJson(json);

@override final  String id;
/// Category id (e.g. `animals_wildlife`, or `my12` for a custom pack).
@override final  String category;
@override final  String word;
@override final  String? subcategory;
@override@JsonKey() final  WordDifficulty difficulty;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  bool isAdult;
 final  List<Hint> _hints;
@override@JsonKey() List<Hint> get hints {
  if (_hints is EqualUnmodifiableListView) return _hints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hints);
}

 final  List<ImposterWord> _imposters;
@override@JsonKey() List<ImposterWord> get imposters {
  if (_imposters is EqualUnmodifiableListView) return _imposters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imposters);
}

/// One-sentence neutral definition shown only to players who get the
/// real word. Never built from hints.
@override final  String? description;
@override final  String source;

/// Create a copy of WordEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordEntryCopyWith<_WordEntry> get copyWith => __$WordEntryCopyWithImpl<_WordEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.word, word) || other.word == word)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&const DeepCollectionEquality().equals(other.tags, _tags)&&(identical(other.isAdult, isAdult) || other.isAdult == isAdult)&&const DeepCollectionEquality().equals(other.hints, _hints)&&const DeepCollectionEquality().equals(other.imposters, _imposters)&&(identical(other.description, description) || other.description == description)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,category,word,subcategory,difficulty,const DeepCollectionEquality().hash(_tags),isAdult,const DeepCollectionEquality().hash(_hints),const DeepCollectionEquality().hash(_imposters),description,source);
}

@override
String toString() {
    return 'WordEntry(id: $id, category: $category, word: $word, subcategory: $subcategory, difficulty: $difficulty, tags: $tags, isAdult: $isAdult, hints: $hints, imposters: $imposters, description: $description, source: $source)';
}


}

/// @nodoc
abstract mixin class _$WordEntryCopyWith<$Res> implements $WordEntryCopyWith<$Res> {
  factory _$WordEntryCopyWith(_WordEntry value, $Res Function(_WordEntry) _then) = __$WordEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String category, String word, String? subcategory, WordDifficulty difficulty, List<String> tags, bool isAdult, List<Hint> hints, List<ImposterWord> imposters, String? description, String source
});




}
/// @nodoc
class __$WordEntryCopyWithImpl<$Res>
    implements _$WordEntryCopyWith<$Res> {
  __$WordEntryCopyWithImpl(this._self, this._then);

  final _WordEntry _self;
  final $Res Function(_WordEntry) _then;

/// Create a copy of WordEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category = null,Object? word = null,Object? subcategory = freezed,Object? difficulty = null,Object? tags = null,Object? isAdult = null,Object? hints = null,Object? imposters = null,Object? description = freezed,Object? source = null,}) {
  return _then(_WordEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,subcategory: freezed == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as WordDifficulty,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isAdult: null == isAdult ? _self.isAdult : isAdult // ignore: cast_nullable_to_non_nullable
as bool,hints: null == hints ? _self._hints : hints // ignore: cast_nullable_to_non_nullable
as List<Hint>,imposters: null == imposters ? _self._imposters : imposters // ignore: cast_nullable_to_non_nullable
as List<ImposterWord>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
