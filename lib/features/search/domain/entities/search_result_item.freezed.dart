// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_result_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchResultItem {

 SearchResultKind get kind; int get surahNumber; String get surahName; String get englishName; int? get numberOfAyahs; String? get revelationType; int? get ayahNumber; String? get arabicText; String? get translationText; int? get pageNumber; int? get juzNumber; bool get matchedInTranslation;
/// Create a copy of SearchResultItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResultItemCopyWith<SearchResultItem> get copyWith => _$SearchResultItemCopyWithImpl<SearchResultItem>(this as SearchResultItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResultItem&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.surahNumber, surahNumber) || other.surahNumber == surahNumber)&&(identical(other.surahName, surahName) || other.surahName == surahName)&&(identical(other.englishName, englishName) || other.englishName == englishName)&&(identical(other.numberOfAyahs, numberOfAyahs) || other.numberOfAyahs == numberOfAyahs)&&(identical(other.revelationType, revelationType) || other.revelationType == revelationType)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.arabicText, arabicText) || other.arabicText == arabicText)&&(identical(other.translationText, translationText) || other.translationText == translationText)&&(identical(other.pageNumber, pageNumber) || other.pageNumber == pageNumber)&&(identical(other.juzNumber, juzNumber) || other.juzNumber == juzNumber)&&(identical(other.matchedInTranslation, matchedInTranslation) || other.matchedInTranslation == matchedInTranslation));
}


@override
int get hashCode => Object.hash(runtimeType,kind,surahNumber,surahName,englishName,numberOfAyahs,revelationType,ayahNumber,arabicText,translationText,pageNumber,juzNumber,matchedInTranslation);

@override
String toString() {
  return 'SearchResultItem(kind: $kind, surahNumber: $surahNumber, surahName: $surahName, englishName: $englishName, numberOfAyahs: $numberOfAyahs, revelationType: $revelationType, ayahNumber: $ayahNumber, arabicText: $arabicText, translationText: $translationText, pageNumber: $pageNumber, juzNumber: $juzNumber, matchedInTranslation: $matchedInTranslation)';
}


}

/// @nodoc
abstract mixin class $SearchResultItemCopyWith<$Res>  {
  factory $SearchResultItemCopyWith(SearchResultItem value, $Res Function(SearchResultItem) _then) = _$SearchResultItemCopyWithImpl;
@useResult
$Res call({
 SearchResultKind kind, int surahNumber, String surahName, String englishName, int? numberOfAyahs, String? revelationType, int? ayahNumber, String? arabicText, String? translationText, int? pageNumber, int? juzNumber, bool matchedInTranslation
});




}
/// @nodoc
class _$SearchResultItemCopyWithImpl<$Res>
    implements $SearchResultItemCopyWith<$Res> {
  _$SearchResultItemCopyWithImpl(this._self, this._then);

  final SearchResultItem _self;
  final $Res Function(SearchResultItem) _then;

/// Create a copy of SearchResultItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? surahNumber = null,Object? surahName = null,Object? englishName = null,Object? numberOfAyahs = freezed,Object? revelationType = freezed,Object? ayahNumber = freezed,Object? arabicText = freezed,Object? translationText = freezed,Object? pageNumber = freezed,Object? juzNumber = freezed,Object? matchedInTranslation = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SearchResultKind,surahNumber: null == surahNumber ? _self.surahNumber : surahNumber // ignore: cast_nullable_to_non_nullable
as int,surahName: null == surahName ? _self.surahName : surahName // ignore: cast_nullable_to_non_nullable
as String,englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,numberOfAyahs: freezed == numberOfAyahs ? _self.numberOfAyahs : numberOfAyahs // ignore: cast_nullable_to_non_nullable
as int?,revelationType: freezed == revelationType ? _self.revelationType : revelationType // ignore: cast_nullable_to_non_nullable
as String?,ayahNumber: freezed == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int?,arabicText: freezed == arabicText ? _self.arabicText : arabicText // ignore: cast_nullable_to_non_nullable
as String?,translationText: freezed == translationText ? _self.translationText : translationText // ignore: cast_nullable_to_non_nullable
as String?,pageNumber: freezed == pageNumber ? _self.pageNumber : pageNumber // ignore: cast_nullable_to_non_nullable
as int?,juzNumber: freezed == juzNumber ? _self.juzNumber : juzNumber // ignore: cast_nullable_to_non_nullable
as int?,matchedInTranslation: null == matchedInTranslation ? _self.matchedInTranslation : matchedInTranslation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchResultItem].
extension SearchResultItemPatterns on SearchResultItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResultItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResultItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResultItem value)  $default,){
final _that = this;
switch (_that) {
case _SearchResultItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResultItem value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResultItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SearchResultKind kind,  int surahNumber,  String surahName,  String englishName,  int? numberOfAyahs,  String? revelationType,  int? ayahNumber,  String? arabicText,  String? translationText,  int? pageNumber,  int? juzNumber,  bool matchedInTranslation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResultItem() when $default != null:
return $default(_that.kind,_that.surahNumber,_that.surahName,_that.englishName,_that.numberOfAyahs,_that.revelationType,_that.ayahNumber,_that.arabicText,_that.translationText,_that.pageNumber,_that.juzNumber,_that.matchedInTranslation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SearchResultKind kind,  int surahNumber,  String surahName,  String englishName,  int? numberOfAyahs,  String? revelationType,  int? ayahNumber,  String? arabicText,  String? translationText,  int? pageNumber,  int? juzNumber,  bool matchedInTranslation)  $default,) {final _that = this;
switch (_that) {
case _SearchResultItem():
return $default(_that.kind,_that.surahNumber,_that.surahName,_that.englishName,_that.numberOfAyahs,_that.revelationType,_that.ayahNumber,_that.arabicText,_that.translationText,_that.pageNumber,_that.juzNumber,_that.matchedInTranslation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SearchResultKind kind,  int surahNumber,  String surahName,  String englishName,  int? numberOfAyahs,  String? revelationType,  int? ayahNumber,  String? arabicText,  String? translationText,  int? pageNumber,  int? juzNumber,  bool matchedInTranslation)?  $default,) {final _that = this;
switch (_that) {
case _SearchResultItem() when $default != null:
return $default(_that.kind,_that.surahNumber,_that.surahName,_that.englishName,_that.numberOfAyahs,_that.revelationType,_that.ayahNumber,_that.arabicText,_that.translationText,_that.pageNumber,_that.juzNumber,_that.matchedInTranslation);case _:
  return null;

}
}

}

/// @nodoc


class _SearchResultItem extends SearchResultItem {
  const _SearchResultItem({required this.kind, required this.surahNumber, required this.surahName, required this.englishName, this.numberOfAyahs, this.revelationType, this.ayahNumber, this.arabicText, this.translationText, this.pageNumber, this.juzNumber, this.matchedInTranslation = false}): super._();
  

@override final  SearchResultKind kind;
@override final  int surahNumber;
@override final  String surahName;
@override final  String englishName;
@override final  int? numberOfAyahs;
@override final  String? revelationType;
@override final  int? ayahNumber;
@override final  String? arabicText;
@override final  String? translationText;
@override final  int? pageNumber;
@override final  int? juzNumber;
@override@JsonKey() final  bool matchedInTranslation;

/// Create a copy of SearchResultItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResultItemCopyWith<_SearchResultItem> get copyWith => __$SearchResultItemCopyWithImpl<_SearchResultItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResultItem&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.surahNumber, surahNumber) || other.surahNumber == surahNumber)&&(identical(other.surahName, surahName) || other.surahName == surahName)&&(identical(other.englishName, englishName) || other.englishName == englishName)&&(identical(other.numberOfAyahs, numberOfAyahs) || other.numberOfAyahs == numberOfAyahs)&&(identical(other.revelationType, revelationType) || other.revelationType == revelationType)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.arabicText, arabicText) || other.arabicText == arabicText)&&(identical(other.translationText, translationText) || other.translationText == translationText)&&(identical(other.pageNumber, pageNumber) || other.pageNumber == pageNumber)&&(identical(other.juzNumber, juzNumber) || other.juzNumber == juzNumber)&&(identical(other.matchedInTranslation, matchedInTranslation) || other.matchedInTranslation == matchedInTranslation));
}


@override
int get hashCode => Object.hash(runtimeType,kind,surahNumber,surahName,englishName,numberOfAyahs,revelationType,ayahNumber,arabicText,translationText,pageNumber,juzNumber,matchedInTranslation);

@override
String toString() {
  return 'SearchResultItem(kind: $kind, surahNumber: $surahNumber, surahName: $surahName, englishName: $englishName, numberOfAyahs: $numberOfAyahs, revelationType: $revelationType, ayahNumber: $ayahNumber, arabicText: $arabicText, translationText: $translationText, pageNumber: $pageNumber, juzNumber: $juzNumber, matchedInTranslation: $matchedInTranslation)';
}


}

/// @nodoc
abstract mixin class _$SearchResultItemCopyWith<$Res> implements $SearchResultItemCopyWith<$Res> {
  factory _$SearchResultItemCopyWith(_SearchResultItem value, $Res Function(_SearchResultItem) _then) = __$SearchResultItemCopyWithImpl;
@override @useResult
$Res call({
 SearchResultKind kind, int surahNumber, String surahName, String englishName, int? numberOfAyahs, String? revelationType, int? ayahNumber, String? arabicText, String? translationText, int? pageNumber, int? juzNumber, bool matchedInTranslation
});




}
/// @nodoc
class __$SearchResultItemCopyWithImpl<$Res>
    implements _$SearchResultItemCopyWith<$Res> {
  __$SearchResultItemCopyWithImpl(this._self, this._then);

  final _SearchResultItem _self;
  final $Res Function(_SearchResultItem) _then;

/// Create a copy of SearchResultItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? surahNumber = null,Object? surahName = null,Object? englishName = null,Object? numberOfAyahs = freezed,Object? revelationType = freezed,Object? ayahNumber = freezed,Object? arabicText = freezed,Object? translationText = freezed,Object? pageNumber = freezed,Object? juzNumber = freezed,Object? matchedInTranslation = null,}) {
  return _then(_SearchResultItem(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SearchResultKind,surahNumber: null == surahNumber ? _self.surahNumber : surahNumber // ignore: cast_nullable_to_non_nullable
as int,surahName: null == surahName ? _self.surahName : surahName // ignore: cast_nullable_to_non_nullable
as String,englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,numberOfAyahs: freezed == numberOfAyahs ? _self.numberOfAyahs : numberOfAyahs // ignore: cast_nullable_to_non_nullable
as int?,revelationType: freezed == revelationType ? _self.revelationType : revelationType // ignore: cast_nullable_to_non_nullable
as String?,ayahNumber: freezed == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int?,arabicText: freezed == arabicText ? _self.arabicText : arabicText // ignore: cast_nullable_to_non_nullable
as String?,translationText: freezed == translationText ? _self.translationText : translationText // ignore: cast_nullable_to_non_nullable
as String?,pageNumber: freezed == pageNumber ? _self.pageNumber : pageNumber // ignore: cast_nullable_to_non_nullable
as int?,juzNumber: freezed == juzNumber ? _self.juzNumber : juzNumber // ignore: cast_nullable_to_non_nullable
as int?,matchedInTranslation: null == matchedInTranslation ? _self.matchedInTranslation : matchedInTranslation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
