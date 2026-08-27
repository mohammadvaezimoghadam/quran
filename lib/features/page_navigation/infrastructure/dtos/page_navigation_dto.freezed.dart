// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_navigation_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PageNavigationDto {

@JsonKey(name: 'surah_id') int get surahId;@JsonKey(name: 'surah_name') String get surahName;@JsonKey(name: 'ayah_number') int get ayahNumber;
/// Create a copy of PageNavigationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PageNavigationDtoCopyWith<PageNavigationDto> get copyWith => _$PageNavigationDtoCopyWithImpl<PageNavigationDto>(this as PageNavigationDto, _$identity);

  /// Serializes this PageNavigationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PageNavigationDto&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.surahName, surahName) || other.surahName == surahName)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,surahId,surahName,ayahNumber);

@override
String toString() {
  return 'PageNavigationDto(surahId: $surahId, surahName: $surahName, ayahNumber: $ayahNumber)';
}


}

/// @nodoc
abstract mixin class $PageNavigationDtoCopyWith<$Res>  {
  factory $PageNavigationDtoCopyWith(PageNavigationDto value, $Res Function(PageNavigationDto) _then) = _$PageNavigationDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'surah_id') int surahId,@JsonKey(name: 'surah_name') String surahName,@JsonKey(name: 'ayah_number') int ayahNumber
});




}
/// @nodoc
class _$PageNavigationDtoCopyWithImpl<$Res>
    implements $PageNavigationDtoCopyWith<$Res> {
  _$PageNavigationDtoCopyWithImpl(this._self, this._then);

  final PageNavigationDto _self;
  final $Res Function(PageNavigationDto) _then;

/// Create a copy of PageNavigationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? surahId = null,Object? surahName = null,Object? ayahNumber = null,}) {
  return _then(_self.copyWith(
surahId: null == surahId ? _self.surahId : surahId // ignore: cast_nullable_to_non_nullable
as int,surahName: null == surahName ? _self.surahName : surahName // ignore: cast_nullable_to_non_nullable
as String,ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PageNavigationDto].
extension PageNavigationDtoPatterns on PageNavigationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PageNavigationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PageNavigationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PageNavigationDto value)  $default,){
final _that = this;
switch (_that) {
case _PageNavigationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PageNavigationDto value)?  $default,){
final _that = this;
switch (_that) {
case _PageNavigationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'surah_id')  int surahId, @JsonKey(name: 'surah_name')  String surahName, @JsonKey(name: 'ayah_number')  int ayahNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PageNavigationDto() when $default != null:
return $default(_that.surahId,_that.surahName,_that.ayahNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'surah_id')  int surahId, @JsonKey(name: 'surah_name')  String surahName, @JsonKey(name: 'ayah_number')  int ayahNumber)  $default,) {final _that = this;
switch (_that) {
case _PageNavigationDto():
return $default(_that.surahId,_that.surahName,_that.ayahNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'surah_id')  int surahId, @JsonKey(name: 'surah_name')  String surahName, @JsonKey(name: 'ayah_number')  int ayahNumber)?  $default,) {final _that = this;
switch (_that) {
case _PageNavigationDto() when $default != null:
return $default(_that.surahId,_that.surahName,_that.ayahNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PageNavigationDto implements PageNavigationDto {
  const _PageNavigationDto({@JsonKey(name: 'surah_id') required this.surahId, @JsonKey(name: 'surah_name') required this.surahName, @JsonKey(name: 'ayah_number') required this.ayahNumber});
  factory _PageNavigationDto.fromJson(Map<String, dynamic> json) => _$PageNavigationDtoFromJson(json);

@override@JsonKey(name: 'surah_id') final  int surahId;
@override@JsonKey(name: 'surah_name') final  String surahName;
@override@JsonKey(name: 'ayah_number') final  int ayahNumber;

/// Create a copy of PageNavigationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PageNavigationDtoCopyWith<_PageNavigationDto> get copyWith => __$PageNavigationDtoCopyWithImpl<_PageNavigationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PageNavigationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PageNavigationDto&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.surahName, surahName) || other.surahName == surahName)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,surahId,surahName,ayahNumber);

@override
String toString() {
  return 'PageNavigationDto(surahId: $surahId, surahName: $surahName, ayahNumber: $ayahNumber)';
}


}

/// @nodoc
abstract mixin class _$PageNavigationDtoCopyWith<$Res> implements $PageNavigationDtoCopyWith<$Res> {
  factory _$PageNavigationDtoCopyWith(_PageNavigationDto value, $Res Function(_PageNavigationDto) _then) = __$PageNavigationDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'surah_id') int surahId,@JsonKey(name: 'surah_name') String surahName,@JsonKey(name: 'ayah_number') int ayahNumber
});




}
/// @nodoc
class __$PageNavigationDtoCopyWithImpl<$Res>
    implements _$PageNavigationDtoCopyWith<$Res> {
  __$PageNavigationDtoCopyWithImpl(this._self, this._then);

  final _PageNavigationDto _self;
  final $Res Function(_PageNavigationDto) _then;

/// Create a copy of PageNavigationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? surahId = null,Object? surahName = null,Object? ayahNumber = null,}) {
  return _then(_PageNavigationDto(
surahId: null == surahId ? _self.surahId : surahId // ignore: cast_nullable_to_non_nullable
as int,surahName: null == surahName ? _self.surahName : surahName // ignore: cast_nullable_to_non_nullable
as String,ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
