// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'moezzin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Moezzin {

/// Unique identifier for the moezzin
 String get id;/// Persian display name (e.g., 'راغب مصطفی غلوش')
 String get nameFa;/// Asset name prefix (e.g. 'adhan_ghalvash') 
/// Used for default bundled audio or saved filename.
 String get assetPath;/// Direct URL to download the mp3 file
 String get downloadUrl;
/// Create a copy of Moezzin
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoezzinCopyWith<Moezzin> get copyWith => _$MoezzinCopyWithImpl<Moezzin>(this as Moezzin, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Moezzin&&(identical(other.id, id) || other.id == id)&&(identical(other.nameFa, nameFa) || other.nameFa == nameFa)&&(identical(other.assetPath, assetPath) || other.assetPath == assetPath)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,nameFa,assetPath,downloadUrl);

@override
String toString() {
  return 'Moezzin(id: $id, nameFa: $nameFa, assetPath: $assetPath, downloadUrl: $downloadUrl)';
}


}

/// @nodoc
abstract mixin class $MoezzinCopyWith<$Res>  {
  factory $MoezzinCopyWith(Moezzin value, $Res Function(Moezzin) _then) = _$MoezzinCopyWithImpl;
@useResult
$Res call({
 String id, String nameFa, String assetPath, String downloadUrl
});




}
/// @nodoc
class _$MoezzinCopyWithImpl<$Res>
    implements $MoezzinCopyWith<$Res> {
  _$MoezzinCopyWithImpl(this._self, this._then);

  final Moezzin _self;
  final $Res Function(Moezzin) _then;

/// Create a copy of Moezzin
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameFa = null,Object? assetPath = null,Object? downloadUrl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameFa: null == nameFa ? _self.nameFa : nameFa // ignore: cast_nullable_to_non_nullable
as String,assetPath: null == assetPath ? _self.assetPath : assetPath // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Moezzin].
extension MoezzinPatterns on Moezzin {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Moezzin value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Moezzin() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Moezzin value)  $default,){
final _that = this;
switch (_that) {
case _Moezzin():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Moezzin value)?  $default,){
final _that = this;
switch (_that) {
case _Moezzin() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nameFa,  String assetPath,  String downloadUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Moezzin() when $default != null:
return $default(_that.id,_that.nameFa,_that.assetPath,_that.downloadUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nameFa,  String assetPath,  String downloadUrl)  $default,) {final _that = this;
switch (_that) {
case _Moezzin():
return $default(_that.id,_that.nameFa,_that.assetPath,_that.downloadUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nameFa,  String assetPath,  String downloadUrl)?  $default,) {final _that = this;
switch (_that) {
case _Moezzin() when $default != null:
return $default(_that.id,_that.nameFa,_that.assetPath,_that.downloadUrl);case _:
  return null;

}
}

}

/// @nodoc


class _Moezzin implements Moezzin {
  const _Moezzin({required this.id, required this.nameFa, required this.assetPath, required this.downloadUrl});
  

/// Unique identifier for the moezzin
@override final  String id;
/// Persian display name (e.g., 'راغب مصطفی غلوش')
@override final  String nameFa;
/// Asset name prefix (e.g. 'adhan_ghalvash') 
/// Used for default bundled audio or saved filename.
@override final  String assetPath;
/// Direct URL to download the mp3 file
@override final  String downloadUrl;

/// Create a copy of Moezzin
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoezzinCopyWith<_Moezzin> get copyWith => __$MoezzinCopyWithImpl<_Moezzin>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Moezzin&&(identical(other.id, id) || other.id == id)&&(identical(other.nameFa, nameFa) || other.nameFa == nameFa)&&(identical(other.assetPath, assetPath) || other.assetPath == assetPath)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,nameFa,assetPath,downloadUrl);

@override
String toString() {
  return 'Moezzin(id: $id, nameFa: $nameFa, assetPath: $assetPath, downloadUrl: $downloadUrl)';
}


}

/// @nodoc
abstract mixin class _$MoezzinCopyWith<$Res> implements $MoezzinCopyWith<$Res> {
  factory _$MoezzinCopyWith(_Moezzin value, $Res Function(_Moezzin) _then) = __$MoezzinCopyWithImpl;
@override @useResult
$Res call({
 String id, String nameFa, String assetPath, String downloadUrl
});




}
/// @nodoc
class __$MoezzinCopyWithImpl<$Res>
    implements _$MoezzinCopyWith<$Res> {
  __$MoezzinCopyWithImpl(this._self, this._then);

  final _Moezzin _self;
  final $Res Function(_Moezzin) _then;

/// Create a copy of Moezzin
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameFa = null,Object? assetPath = null,Object? downloadUrl = null,}) {
  return _then(_Moezzin(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameFa: null == nameFa ? _self.nameFa : nameFa // ignore: cast_nullable_to_non_nullable
as String,assetPath: null == assetPath ? _self.assetPath : assetPath // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
