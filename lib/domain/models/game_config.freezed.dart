// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameConfig {

 List<String> get players; int get imposterCount; GameMode get mode; List<String> get categories; bool get randomMix; int get discussionSeconds; int get clueRounds; HintDifficulty get hintDifficulty; ImposterDifficulty get imposterDifficulty; WordDifficultyFilter get wordDifficulty;/// Includes the 18+ After Dark category (needs a confirmed adult; never
/// part of Random Mix unless this is on).
 bool get adultContent; bool get speedRound; int get speedSeconds; bool get maybeNobody; double get maybeNobodyChance; TieRule get tieRule; VoteStyle get voteStyle; SeatingMode get seating; bool get avoidSameImposter; bool get lastChance; bool get scoreboard;/// With 2+ imposters, each imposter's card names their partners.
 bool get impostersKnowEachOther;/// The first speaker is always a crew member (easier for new groups).
 bool get crewStarts;/// Each round gets a random "twist" rule for how clues are given.
 bool get roundTwists;
/// Create a copy of GameConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameConfigCopyWith<GameConfig> get copyWith => _$GameConfigCopyWithImpl<GameConfig>(this as GameConfig, _$identity);

  /// Serializes this GameConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GameConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameConfig&&const DeepCollectionEquality().equals(other.players, _this.players)&&(identical(other.imposterCount, _this.imposterCount) || other.imposterCount == _this.imposterCount)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&(identical(other.randomMix, _this.randomMix) || other.randomMix == _this.randomMix)&&(identical(other.discussionSeconds, _this.discussionSeconds) || other.discussionSeconds == _this.discussionSeconds)&&(identical(other.clueRounds, _this.clueRounds) || other.clueRounds == _this.clueRounds)&&(identical(other.hintDifficulty, _this.hintDifficulty) || other.hintDifficulty == _this.hintDifficulty)&&(identical(other.imposterDifficulty, _this.imposterDifficulty) || other.imposterDifficulty == _this.imposterDifficulty)&&(identical(other.wordDifficulty, _this.wordDifficulty) || other.wordDifficulty == _this.wordDifficulty)&&(identical(other.adultContent, _this.adultContent) || other.adultContent == _this.adultContent)&&(identical(other.speedRound, _this.speedRound) || other.speedRound == _this.speedRound)&&(identical(other.speedSeconds, _this.speedSeconds) || other.speedSeconds == _this.speedSeconds)&&(identical(other.maybeNobody, _this.maybeNobody) || other.maybeNobody == _this.maybeNobody)&&(identical(other.maybeNobodyChance, _this.maybeNobodyChance) || other.maybeNobodyChance == _this.maybeNobodyChance)&&(identical(other.tieRule, _this.tieRule) || other.tieRule == _this.tieRule)&&(identical(other.voteStyle, _this.voteStyle) || other.voteStyle == _this.voteStyle)&&(identical(other.seating, _this.seating) || other.seating == _this.seating)&&(identical(other.avoidSameImposter, _this.avoidSameImposter) || other.avoidSameImposter == _this.avoidSameImposter)&&(identical(other.lastChance, _this.lastChance) || other.lastChance == _this.lastChance)&&(identical(other.scoreboard, _this.scoreboard) || other.scoreboard == _this.scoreboard)&&(identical(other.impostersKnowEachOther, _this.impostersKnowEachOther) || other.impostersKnowEachOther == _this.impostersKnowEachOther)&&(identical(other.crewStarts, _this.crewStarts) || other.crewStarts == _this.crewStarts)&&(identical(other.roundTwists, _this.roundTwists) || other.roundTwists == _this.roundTwists));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GameConfig;
  return Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_this.players),_this.imposterCount,_this.mode,const DeepCollectionEquality().hash(_this.categories),_this.randomMix,_this.discussionSeconds,_this.clueRounds,_this.hintDifficulty,_this.imposterDifficulty,_this.wordDifficulty,_this.adultContent,_this.speedRound,_this.speedSeconds,_this.maybeNobody,_this.maybeNobodyChance,_this.tieRule,_this.voteStyle,_this.seating,_this.avoidSameImposter,_this.lastChance,_this.scoreboard,_this.impostersKnowEachOther,_this.crewStarts,_this.roundTwists]);
}

@override
String toString() {
  final _this = this as GameConfig;
  return 'GameConfig(players: ${_this.players}, imposterCount: ${_this.imposterCount}, mode: ${_this.mode}, categories: ${_this.categories}, randomMix: ${_this.randomMix}, discussionSeconds: ${_this.discussionSeconds}, clueRounds: ${_this.clueRounds}, hintDifficulty: ${_this.hintDifficulty}, imposterDifficulty: ${_this.imposterDifficulty}, wordDifficulty: ${_this.wordDifficulty}, adultContent: ${_this.adultContent}, speedRound: ${_this.speedRound}, speedSeconds: ${_this.speedSeconds}, maybeNobody: ${_this.maybeNobody}, maybeNobodyChance: ${_this.maybeNobodyChance}, tieRule: ${_this.tieRule}, voteStyle: ${_this.voteStyle}, seating: ${_this.seating}, avoidSameImposter: ${_this.avoidSameImposter}, lastChance: ${_this.lastChance}, scoreboard: ${_this.scoreboard}, impostersKnowEachOther: ${_this.impostersKnowEachOther}, crewStarts: ${_this.crewStarts}, roundTwists: ${_this.roundTwists})';
}


}

/// @nodoc
abstract mixin class $GameConfigCopyWith<$Res>  {
  factory $GameConfigCopyWith(GameConfig value, $Res Function(GameConfig) _then) = _$GameConfigCopyWithImpl;
@useResult
$Res call({
 List<String> players, int imposterCount, GameMode mode, List<String> categories, bool randomMix, int discussionSeconds, int clueRounds, HintDifficulty hintDifficulty, ImposterDifficulty imposterDifficulty, WordDifficultyFilter wordDifficulty, bool adultContent, bool speedRound, int speedSeconds, bool maybeNobody, double maybeNobodyChance, TieRule tieRule, VoteStyle voteStyle, SeatingMode seating, bool avoidSameImposter, bool lastChance, bool scoreboard, bool impostersKnowEachOther, bool crewStarts, bool roundTwists
});




}
/// @nodoc
class _$GameConfigCopyWithImpl<$Res>
    implements $GameConfigCopyWith<$Res> {
  _$GameConfigCopyWithImpl(this._self, this._then);

  final GameConfig _self;
  final $Res Function(GameConfig) _then;

/// Create a copy of GameConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? players = null,Object? imposterCount = null,Object? mode = null,Object? categories = null,Object? randomMix = null,Object? discussionSeconds = null,Object? clueRounds = null,Object? hintDifficulty = null,Object? imposterDifficulty = null,Object? wordDifficulty = null,Object? adultContent = null,Object? speedRound = null,Object? speedSeconds = null,Object? maybeNobody = null,Object? maybeNobodyChance = null,Object? tieRule = null,Object? voteStyle = null,Object? seating = null,Object? avoidSameImposter = null,Object? lastChance = null,Object? scoreboard = null,Object? impostersKnowEachOther = null,Object? crewStarts = null,Object? roundTwists = null,}) {
  return _then(GameConfig(
players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<String>,imposterCount: null == imposterCount ? _self.imposterCount : imposterCount // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,randomMix: null == randomMix ? _self.randomMix : randomMix // ignore: cast_nullable_to_non_nullable
as bool,discussionSeconds: null == discussionSeconds ? _self.discussionSeconds : discussionSeconds // ignore: cast_nullable_to_non_nullable
as int,clueRounds: null == clueRounds ? _self.clueRounds : clueRounds // ignore: cast_nullable_to_non_nullable
as int,hintDifficulty: null == hintDifficulty ? _self.hintDifficulty : hintDifficulty // ignore: cast_nullable_to_non_nullable
as HintDifficulty,imposterDifficulty: null == imposterDifficulty ? _self.imposterDifficulty : imposterDifficulty // ignore: cast_nullable_to_non_nullable
as ImposterDifficulty,wordDifficulty: null == wordDifficulty ? _self.wordDifficulty : wordDifficulty // ignore: cast_nullable_to_non_nullable
as WordDifficultyFilter,adultContent: null == adultContent ? _self.adultContent : adultContent // ignore: cast_nullable_to_non_nullable
as bool,speedRound: null == speedRound ? _self.speedRound : speedRound // ignore: cast_nullable_to_non_nullable
as bool,speedSeconds: null == speedSeconds ? _self.speedSeconds : speedSeconds // ignore: cast_nullable_to_non_nullable
as int,maybeNobody: null == maybeNobody ? _self.maybeNobody : maybeNobody // ignore: cast_nullable_to_non_nullable
as bool,maybeNobodyChance: null == maybeNobodyChance ? _self.maybeNobodyChance : maybeNobodyChance // ignore: cast_nullable_to_non_nullable
as double,tieRule: null == tieRule ? _self.tieRule : tieRule // ignore: cast_nullable_to_non_nullable
as TieRule,voteStyle: null == voteStyle ? _self.voteStyle : voteStyle // ignore: cast_nullable_to_non_nullable
as VoteStyle,seating: null == seating ? _self.seating : seating // ignore: cast_nullable_to_non_nullable
as SeatingMode,avoidSameImposter: null == avoidSameImposter ? _self.avoidSameImposter : avoidSameImposter // ignore: cast_nullable_to_non_nullable
as bool,lastChance: null == lastChance ? _self.lastChance : lastChance // ignore: cast_nullable_to_non_nullable
as bool,scoreboard: null == scoreboard ? _self.scoreboard : scoreboard // ignore: cast_nullable_to_non_nullable
as bool,impostersKnowEachOther: null == impostersKnowEachOther ? _self.impostersKnowEachOther : impostersKnowEachOther // ignore: cast_nullable_to_non_nullable
as bool,crewStarts: null == crewStarts ? _self.crewStarts : crewStarts // ignore: cast_nullable_to_non_nullable
as bool,roundTwists: null == roundTwists ? _self.roundTwists : roundTwists // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GameConfig].
extension GameConfigPatterns on GameConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameConfig value)  $default,){
final _that = this;
switch (_that) {
case _GameConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameConfig value)?  $default,){
final _that = this;
switch (_that) {
case _GameConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> players,  int imposterCount,  GameMode mode,  List<String> categories,  bool randomMix,  int discussionSeconds,  int clueRounds,  HintDifficulty hintDifficulty,  ImposterDifficulty imposterDifficulty,  WordDifficultyFilter wordDifficulty,  bool adultContent,  bool speedRound,  int speedSeconds,  bool maybeNobody,  double maybeNobodyChance,  TieRule tieRule,  VoteStyle voteStyle,  SeatingMode seating,  bool avoidSameImposter,  bool lastChance,  bool scoreboard,  bool impostersKnowEachOther,  bool crewStarts,  bool roundTwists)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameConfig() when $default != null:
return $default(_that.players,_that.imposterCount,_that.mode,_that.categories,_that.randomMix,_that.discussionSeconds,_that.clueRounds,_that.hintDifficulty,_that.imposterDifficulty,_that.wordDifficulty,_that.adultContent,_that.speedRound,_that.speedSeconds,_that.maybeNobody,_that.maybeNobodyChance,_that.tieRule,_that.voteStyle,_that.seating,_that.avoidSameImposter,_that.lastChance,_that.scoreboard,_that.impostersKnowEachOther,_that.crewStarts,_that.roundTwists);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> players,  int imposterCount,  GameMode mode,  List<String> categories,  bool randomMix,  int discussionSeconds,  int clueRounds,  HintDifficulty hintDifficulty,  ImposterDifficulty imposterDifficulty,  WordDifficultyFilter wordDifficulty,  bool adultContent,  bool speedRound,  int speedSeconds,  bool maybeNobody,  double maybeNobodyChance,  TieRule tieRule,  VoteStyle voteStyle,  SeatingMode seating,  bool avoidSameImposter,  bool lastChance,  bool scoreboard,  bool impostersKnowEachOther,  bool crewStarts,  bool roundTwists)  $default,) {final _that = this;
switch (_that) {
case _GameConfig():
return $default(_that.players,_that.imposterCount,_that.mode,_that.categories,_that.randomMix,_that.discussionSeconds,_that.clueRounds,_that.hintDifficulty,_that.imposterDifficulty,_that.wordDifficulty,_that.adultContent,_that.speedRound,_that.speedSeconds,_that.maybeNobody,_that.maybeNobodyChance,_that.tieRule,_that.voteStyle,_that.seating,_that.avoidSameImposter,_that.lastChance,_that.scoreboard,_that.impostersKnowEachOther,_that.crewStarts,_that.roundTwists);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> players,  int imposterCount,  GameMode mode,  List<String> categories,  bool randomMix,  int discussionSeconds,  int clueRounds,  HintDifficulty hintDifficulty,  ImposterDifficulty imposterDifficulty,  WordDifficultyFilter wordDifficulty,  bool adultContent,  bool speedRound,  int speedSeconds,  bool maybeNobody,  double maybeNobodyChance,  TieRule tieRule,  VoteStyle voteStyle,  SeatingMode seating,  bool avoidSameImposter,  bool lastChance,  bool scoreboard,  bool impostersKnowEachOther,  bool crewStarts,  bool roundTwists)?  $default,) {final _that = this;
switch (_that) {
case _GameConfig() when $default != null:
return $default(_that.players,_that.imposterCount,_that.mode,_that.categories,_that.randomMix,_that.discussionSeconds,_that.clueRounds,_that.hintDifficulty,_that.imposterDifficulty,_that.wordDifficulty,_that.adultContent,_that.speedRound,_that.speedSeconds,_that.maybeNobody,_that.maybeNobodyChance,_that.tieRule,_that.voteStyle,_that.seating,_that.avoidSameImposter,_that.lastChance,_that.scoreboard,_that.impostersKnowEachOther,_that.crewStarts,_that.roundTwists);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameConfig extends GameConfig {
  const _GameConfig({ List<String> players = const <String>['Player 1', 'Player 2', 'Player 3', 'Player 4'], this.imposterCount = 1, this.mode = GameMode.hint,  List<String> categories = const <String>[], this.randomMix = true, this.discussionSeconds = 180, this.clueRounds = 1, this.hintDifficulty = HintDifficulty.medium, this.imposterDifficulty = ImposterDifficulty.medium, this.wordDifficulty = WordDifficultyFilter.mixed, this.adultContent = false, this.speedRound = false, this.speedSeconds = 15, this.maybeNobody = false, this.maybeNobodyChance = 0.10, this.tieRule = TieRule.revote, this.voteStyle = VoteStyle.simple, this.seating = SeatingMode.seatingFromStarter, this.avoidSameImposter = false, this.lastChance = true, this.scoreboard = true, this.impostersKnowEachOther = false, this.crewStarts = false, this.roundTwists = false}): _players = players,_categories = categories,super._();
  factory _GameConfig.fromJson(Map<String, dynamic> json) => _$GameConfigFromJson(json);

 final  List<String> _players;
@override@JsonKey() List<String> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}

@override@JsonKey() final  int imposterCount;
@override@JsonKey() final  GameMode mode;
 final  List<String> _categories;
@override@JsonKey() List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override@JsonKey() final  bool randomMix;
@override@JsonKey() final  int discussionSeconds;
@override@JsonKey() final  int clueRounds;
@override@JsonKey() final  HintDifficulty hintDifficulty;
@override@JsonKey() final  ImposterDifficulty imposterDifficulty;
@override@JsonKey() final  WordDifficultyFilter wordDifficulty;
/// Includes the 18+ After Dark category (needs a confirmed adult; never
/// part of Random Mix unless this is on).
@override@JsonKey() final  bool adultContent;
@override@JsonKey() final  bool speedRound;
@override@JsonKey() final  int speedSeconds;
@override@JsonKey() final  bool maybeNobody;
@override@JsonKey() final  double maybeNobodyChance;
@override@JsonKey() final  TieRule tieRule;
@override@JsonKey() final  VoteStyle voteStyle;
@override@JsonKey() final  SeatingMode seating;
@override@JsonKey() final  bool avoidSameImposter;
@override@JsonKey() final  bool lastChance;
@override@JsonKey() final  bool scoreboard;
/// With 2+ imposters, each imposter's card names their partners.
@override@JsonKey() final  bool impostersKnowEachOther;
/// The first speaker is always a crew member (easier for new groups).
@override@JsonKey() final  bool crewStarts;
/// Each round gets a random "twist" rule for how clues are given.
@override@JsonKey() final  bool roundTwists;

/// Create a copy of GameConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameConfigCopyWith<_GameConfig> get copyWith => __$GameConfigCopyWithImpl<_GameConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameConfig&&const DeepCollectionEquality().equals(other.players, _players)&&(identical(other.imposterCount, imposterCount) || other.imposterCount == imposterCount)&&(identical(other.mode, mode) || other.mode == mode)&&const DeepCollectionEquality().equals(other.categories, _categories)&&(identical(other.randomMix, randomMix) || other.randomMix == randomMix)&&(identical(other.discussionSeconds, discussionSeconds) || other.discussionSeconds == discussionSeconds)&&(identical(other.clueRounds, clueRounds) || other.clueRounds == clueRounds)&&(identical(other.hintDifficulty, hintDifficulty) || other.hintDifficulty == hintDifficulty)&&(identical(other.imposterDifficulty, imposterDifficulty) || other.imposterDifficulty == imposterDifficulty)&&(identical(other.wordDifficulty, wordDifficulty) || other.wordDifficulty == wordDifficulty)&&(identical(other.adultContent, adultContent) || other.adultContent == adultContent)&&(identical(other.speedRound, speedRound) || other.speedRound == speedRound)&&(identical(other.speedSeconds, speedSeconds) || other.speedSeconds == speedSeconds)&&(identical(other.maybeNobody, maybeNobody) || other.maybeNobody == maybeNobody)&&(identical(other.maybeNobodyChance, maybeNobodyChance) || other.maybeNobodyChance == maybeNobodyChance)&&(identical(other.tieRule, tieRule) || other.tieRule == tieRule)&&(identical(other.voteStyle, voteStyle) || other.voteStyle == voteStyle)&&(identical(other.seating, seating) || other.seating == seating)&&(identical(other.avoidSameImposter, avoidSameImposter) || other.avoidSameImposter == avoidSameImposter)&&(identical(other.lastChance, lastChance) || other.lastChance == lastChance)&&(identical(other.scoreboard, scoreboard) || other.scoreboard == scoreboard)&&(identical(other.impostersKnowEachOther, impostersKnowEachOther) || other.impostersKnowEachOther == impostersKnowEachOther)&&(identical(other.crewStarts, crewStarts) || other.crewStarts == crewStarts)&&(identical(other.roundTwists, roundTwists) || other.roundTwists == roundTwists));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_players),imposterCount,mode,const DeepCollectionEquality().hash(_categories),randomMix,discussionSeconds,clueRounds,hintDifficulty,imposterDifficulty,wordDifficulty,adultContent,speedRound,speedSeconds,maybeNobody,maybeNobodyChance,tieRule,voteStyle,seating,avoidSameImposter,lastChance,scoreboard,impostersKnowEachOther,crewStarts,roundTwists]);
}

@override
String toString() {
    return 'GameConfig(players: $players, imposterCount: $imposterCount, mode: $mode, categories: $categories, randomMix: $randomMix, discussionSeconds: $discussionSeconds, clueRounds: $clueRounds, hintDifficulty: $hintDifficulty, imposterDifficulty: $imposterDifficulty, wordDifficulty: $wordDifficulty, adultContent: $adultContent, speedRound: $speedRound, speedSeconds: $speedSeconds, maybeNobody: $maybeNobody, maybeNobodyChance: $maybeNobodyChance, tieRule: $tieRule, voteStyle: $voteStyle, seating: $seating, avoidSameImposter: $avoidSameImposter, lastChance: $lastChance, scoreboard: $scoreboard, impostersKnowEachOther: $impostersKnowEachOther, crewStarts: $crewStarts, roundTwists: $roundTwists)';
}


}

/// @nodoc
abstract mixin class _$GameConfigCopyWith<$Res> implements $GameConfigCopyWith<$Res> {
  factory _$GameConfigCopyWith(_GameConfig value, $Res Function(_GameConfig) _then) = __$GameConfigCopyWithImpl;
@override @useResult
$Res call({
 List<String> players, int imposterCount, GameMode mode, List<String> categories, bool randomMix, int discussionSeconds, int clueRounds, HintDifficulty hintDifficulty, ImposterDifficulty imposterDifficulty, WordDifficultyFilter wordDifficulty, bool adultContent, bool speedRound, int speedSeconds, bool maybeNobody, double maybeNobodyChance, TieRule tieRule, VoteStyle voteStyle, SeatingMode seating, bool avoidSameImposter, bool lastChance, bool scoreboard, bool impostersKnowEachOther, bool crewStarts, bool roundTwists
});




}
/// @nodoc
class __$GameConfigCopyWithImpl<$Res>
    implements _$GameConfigCopyWith<$Res> {
  __$GameConfigCopyWithImpl(this._self, this._then);

  final _GameConfig _self;
  final $Res Function(_GameConfig) _then;

/// Create a copy of GameConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? players = null,Object? imposterCount = null,Object? mode = null,Object? categories = null,Object? randomMix = null,Object? discussionSeconds = null,Object? clueRounds = null,Object? hintDifficulty = null,Object? imposterDifficulty = null,Object? wordDifficulty = null,Object? adultContent = null,Object? speedRound = null,Object? speedSeconds = null,Object? maybeNobody = null,Object? maybeNobodyChance = null,Object? tieRule = null,Object? voteStyle = null,Object? seating = null,Object? avoidSameImposter = null,Object? lastChance = null,Object? scoreboard = null,Object? impostersKnowEachOther = null,Object? crewStarts = null,Object? roundTwists = null,}) {
  return _then(_GameConfig(
players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<String>,imposterCount: null == imposterCount ? _self.imposterCount : imposterCount // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,randomMix: null == randomMix ? _self.randomMix : randomMix // ignore: cast_nullable_to_non_nullable
as bool,discussionSeconds: null == discussionSeconds ? _self.discussionSeconds : discussionSeconds // ignore: cast_nullable_to_non_nullable
as int,clueRounds: null == clueRounds ? _self.clueRounds : clueRounds // ignore: cast_nullable_to_non_nullable
as int,hintDifficulty: null == hintDifficulty ? _self.hintDifficulty : hintDifficulty // ignore: cast_nullable_to_non_nullable
as HintDifficulty,imposterDifficulty: null == imposterDifficulty ? _self.imposterDifficulty : imposterDifficulty // ignore: cast_nullable_to_non_nullable
as ImposterDifficulty,wordDifficulty: null == wordDifficulty ? _self.wordDifficulty : wordDifficulty // ignore: cast_nullable_to_non_nullable
as WordDifficultyFilter,adultContent: null == adultContent ? _self.adultContent : adultContent // ignore: cast_nullable_to_non_nullable
as bool,speedRound: null == speedRound ? _self.speedRound : speedRound // ignore: cast_nullable_to_non_nullable
as bool,speedSeconds: null == speedSeconds ? _self.speedSeconds : speedSeconds // ignore: cast_nullable_to_non_nullable
as int,maybeNobody: null == maybeNobody ? _self.maybeNobody : maybeNobody // ignore: cast_nullable_to_non_nullable
as bool,maybeNobodyChance: null == maybeNobodyChance ? _self.maybeNobodyChance : maybeNobodyChance // ignore: cast_nullable_to_non_nullable
as double,tieRule: null == tieRule ? _self.tieRule : tieRule // ignore: cast_nullable_to_non_nullable
as TieRule,voteStyle: null == voteStyle ? _self.voteStyle : voteStyle // ignore: cast_nullable_to_non_nullable
as VoteStyle,seating: null == seating ? _self.seating : seating // ignore: cast_nullable_to_non_nullable
as SeatingMode,avoidSameImposter: null == avoidSameImposter ? _self.avoidSameImposter : avoidSameImposter // ignore: cast_nullable_to_non_nullable
as bool,lastChance: null == lastChance ? _self.lastChance : lastChance // ignore: cast_nullable_to_non_nullable
as bool,scoreboard: null == scoreboard ? _self.scoreboard : scoreboard // ignore: cast_nullable_to_non_nullable
as bool,impostersKnowEachOther: null == impostersKnowEachOther ? _self.impostersKnowEachOther : impostersKnowEachOther // ignore: cast_nullable_to_non_nullable
as bool,crewStarts: null == crewStarts ? _self.crewStarts : crewStarts // ignore: cast_nullable_to_non_nullable
as bool,roundTwists: null == roundTwists ? _self.roundTwists : roundTwists // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
