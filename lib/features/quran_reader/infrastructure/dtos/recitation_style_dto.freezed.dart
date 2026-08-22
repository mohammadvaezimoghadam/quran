// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recitation_style_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecitationStyleDto {

 int get id; String get name;@JsonKey(name: 'english_name') String get englishName;
/// Create a copy of RecitationStyleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecitationStyleDtoCopyWith<RecitationStyleDto> get copyWith => _$RecitationStyleDtoCopyWithImpl<RecitationStyleDto>(this as RecitationStyleDto, _$identity);

  /// Serializes this RecitationStyleDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecitationStyleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.englishName, englishName) || other.englishName == englishName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,englishName);

@override
String toString() {
  return 'RecitationStyleDto(id: $id, name: $name, englishName: $englishName)';
}


}

/// @nodoc
abstract mixin class $RecitationStyleDtoCopyWith<$Res>  {
  factory $RecitationStyleDtoCopyWith(RecitationStyleDto value, $Res Function(RecitationStyleDto) _then) = _$RecitationStyleDtoCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'english_name') String englishName
});




}
/// @nodoc
class _$RecitationStyleDtoCopyWithImpl<$Res>
    implements $RecitationStyleDtoCopyWith<$Res> {
  _$RecitationStyleDtoCopyWithImpl(this._self, this._then);

  final RecitationStyleDto _self;
  final $Res Function(RecitationStyleDto) _then;

/// Create a copy of RecitationStyleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? englishName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RecitationStyleDto].
extension RecitationStyleDtoPatterns on RecitationStyleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecitationStyleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecitationStyleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecitationStyleDto value)  $default,){
final _that = this;
switch (_that) {
case _RecitationStyleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecitationStyleDto value)?  $default,){
final _that = this;
switch (_that) {
case _RecitationStyleDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'english_name')  String englishName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecitationStyleDto() when $default != null:
return $default(_that.id,_that.name,_that.englishName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'english_name')  String englishName)  $default,) {final _that = this;
switch (_that) {
case _RecitationStyleDto():
return $default(_that.id,_that.name,_that.englishName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'english_name')  String englishName)?  $default,) {final _that = this;
switch (_that) {
case _RecitationStyleDto() when $default != null:
return $default(_that.id,_that.name,_that.englishName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecitationStyleDto extends RecitationStyleDto {
  const _RecitationStyleDto({required this.id, required this.name, @JsonKey(name: 'english_name') required this.englishName}): super._();
  factory _RecitationStyleDto.fromJson(Map<String, dynamic> json) => _$RecitationStyleDtoFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey(name: 'english_name') final  String englishName;

/// Create a copy of RecitationStyleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecitationStyleDtoCopyWith<_RecitationStyleDto> get copyWith => __$RecitationStyleDtoCopyWithImpl<_RecitationStyleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecitationStyleDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecitationStyleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.englishName, englishName) || other.englishName == englishName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,englishName);

@override
String toString() {
  return 'RecitationStyleDto(id: $id, name: $name, englishName: $englishName)';
}


}

/// @nodoc
abstract mixin class _$RecitationStyleDtoCopyWith<$Res> implements $RecitationStyleDtoCopyWith<$Res> {
  factory _$RecitationStyleDtoCopyWith(_RecitationStyleDto value, $Res Function(_RecitationStyleDto) _then) = __$RecitationStyleDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'english_name') String englishName
});




}
/// @nodoc
class __$RecitationStyleDtoCopyWithImpl<$Res>
    implements _$RecitationStyleDtoCopyWith<$Res> {
  __$RecitationStyleDtoCopyWithImpl(this._self, this._then);

  final _RecitationStyleDto _self;
  final $Res Function(_RecitationStyleDto) _then;

/// Create a copy of RecitationStyleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? englishName = null,}) {
  return _then(_RecitationStyleDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
