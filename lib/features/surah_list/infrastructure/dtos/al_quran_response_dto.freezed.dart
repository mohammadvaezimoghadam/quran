// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'al_quran_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlQuranResponseDto<T> {

 int get code; String get status; T get data;
/// Create a copy of AlQuranResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlQuranResponseDtoCopyWith<T, AlQuranResponseDto<T>> get copyWith => _$AlQuranResponseDtoCopyWithImpl<T, AlQuranResponseDto<T>>(this as AlQuranResponseDto<T>, _$identity);

  /// Serializes this AlQuranResponseDto to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlQuranResponseDto<T>&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,status,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'AlQuranResponseDto<$T>(code: $code, status: $status, data: $data)';
}


}

/// @nodoc
abstract mixin class $AlQuranResponseDtoCopyWith<T,$Res>  {
  factory $AlQuranResponseDtoCopyWith(AlQuranResponseDto<T> value, $Res Function(AlQuranResponseDto<T>) _then) = _$AlQuranResponseDtoCopyWithImpl;
@useResult
$Res call({
 int code, String status, T data
});




}
/// @nodoc
class _$AlQuranResponseDtoCopyWithImpl<T,$Res>
    implements $AlQuranResponseDtoCopyWith<T, $Res> {
  _$AlQuranResponseDtoCopyWithImpl(this._self, this._then);

  final AlQuranResponseDto<T> _self;
  final $Res Function(AlQuranResponseDto<T>) _then;

/// Create a copy of AlQuranResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? status = null,Object? data = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}

}


/// Adds pattern-matching-related methods to [AlQuranResponseDto].
extension AlQuranResponseDtoPatterns<T> on AlQuranResponseDto<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlQuranResponseDto<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlQuranResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlQuranResponseDto<T> value)  $default,){
final _that = this;
switch (_that) {
case _AlQuranResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlQuranResponseDto<T> value)?  $default,){
final _that = this;
switch (_that) {
case _AlQuranResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int code,  String status,  T data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlQuranResponseDto() when $default != null:
return $default(_that.code,_that.status,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int code,  String status,  T data)  $default,) {final _that = this;
switch (_that) {
case _AlQuranResponseDto():
return $default(_that.code,_that.status,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int code,  String status,  T data)?  $default,) {final _that = this;
switch (_that) {
case _AlQuranResponseDto() when $default != null:
return $default(_that.code,_that.status,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _AlQuranResponseDto<T> implements AlQuranResponseDto<T> {
  const _AlQuranResponseDto({required this.code, required this.status, required this.data});
  factory _AlQuranResponseDto.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$AlQuranResponseDtoFromJson(json,fromJsonT);

@override final  int code;
@override final  String status;
@override final  T data;

/// Create a copy of AlQuranResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlQuranResponseDtoCopyWith<T, _AlQuranResponseDto<T>> get copyWith => __$AlQuranResponseDtoCopyWithImpl<T, _AlQuranResponseDto<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$AlQuranResponseDtoToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlQuranResponseDto<T>&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,status,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'AlQuranResponseDto<$T>(code: $code, status: $status, data: $data)';
}


}

/// @nodoc
abstract mixin class _$AlQuranResponseDtoCopyWith<T,$Res> implements $AlQuranResponseDtoCopyWith<T, $Res> {
  factory _$AlQuranResponseDtoCopyWith(_AlQuranResponseDto<T> value, $Res Function(_AlQuranResponseDto<T>) _then) = __$AlQuranResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 int code, String status, T data
});




}
/// @nodoc
class __$AlQuranResponseDtoCopyWithImpl<T,$Res>
    implements _$AlQuranResponseDtoCopyWith<T, $Res> {
  __$AlQuranResponseDtoCopyWithImpl(this._self, this._then);

  final _AlQuranResponseDto<T> _self;
  final $Res Function(_AlQuranResponseDto<T>) _then;

/// Create a copy of AlQuranResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? status = null,Object? data = freezed,}) {
  return _then(_AlQuranResponseDto<T>(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

// dart format on
