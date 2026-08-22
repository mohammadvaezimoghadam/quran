// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quran_reader_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QuranReaderState {

 bool get isLoading; List<AyahEntity> get ayahs; String? get errorMessage;
/// Create a copy of QuranReaderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuranReaderStateCopyWith<QuranReaderState> get copyWith => _$QuranReaderStateCopyWithImpl<QuranReaderState>(this as QuranReaderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuranReaderState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.ayahs, ayahs)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(ayahs),errorMessage);

@override
String toString() {
  return 'QuranReaderState(isLoading: $isLoading, ayahs: $ayahs, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $QuranReaderStateCopyWith<$Res>  {
  factory $QuranReaderStateCopyWith(QuranReaderState value, $Res Function(QuranReaderState) _then) = _$QuranReaderStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<AyahEntity> ayahs, String? errorMessage
});




}
/// @nodoc
class _$QuranReaderStateCopyWithImpl<$Res>
    implements $QuranReaderStateCopyWith<$Res> {
  _$QuranReaderStateCopyWithImpl(this._self, this._then);

  final QuranReaderState _self;
  final $Res Function(QuranReaderState) _then;

/// Create a copy of QuranReaderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? ayahs = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,ayahs: null == ayahs ? _self.ayahs : ayahs // ignore: cast_nullable_to_non_nullable
as List<AyahEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [QuranReaderState].
extension QuranReaderStatePatterns on QuranReaderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuranReaderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuranReaderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuranReaderState value)  $default,){
final _that = this;
switch (_that) {
case _QuranReaderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuranReaderState value)?  $default,){
final _that = this;
switch (_that) {
case _QuranReaderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  List<AyahEntity> ayahs,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuranReaderState() when $default != null:
return $default(_that.isLoading,_that.ayahs,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  List<AyahEntity> ayahs,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _QuranReaderState():
return $default(_that.isLoading,_that.ayahs,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  List<AyahEntity> ayahs,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _QuranReaderState() when $default != null:
return $default(_that.isLoading,_that.ayahs,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _QuranReaderState implements QuranReaderState {
  const _QuranReaderState({this.isLoading = true, final  List<AyahEntity> ayahs = const [], this.errorMessage}): _ayahs = ayahs;
  

@override@JsonKey() final  bool isLoading;
 final  List<AyahEntity> _ayahs;
@override@JsonKey() List<AyahEntity> get ayahs {
  if (_ayahs is EqualUnmodifiableListView) return _ayahs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ayahs);
}

@override final  String? errorMessage;

/// Create a copy of QuranReaderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuranReaderStateCopyWith<_QuranReaderState> get copyWith => __$QuranReaderStateCopyWithImpl<_QuranReaderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuranReaderState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._ayahs, _ayahs)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_ayahs),errorMessage);

@override
String toString() {
  return 'QuranReaderState(isLoading: $isLoading, ayahs: $ayahs, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$QuranReaderStateCopyWith<$Res> implements $QuranReaderStateCopyWith<$Res> {
  factory _$QuranReaderStateCopyWith(_QuranReaderState value, $Res Function(_QuranReaderState) _then) = __$QuranReaderStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<AyahEntity> ayahs, String? errorMessage
});




}
/// @nodoc
class __$QuranReaderStateCopyWithImpl<$Res>
    implements _$QuranReaderStateCopyWith<$Res> {
  __$QuranReaderStateCopyWithImpl(this._self, this._then);

  final _QuranReaderState _self;
  final $Res Function(_QuranReaderState) _then;

/// Create a copy of QuranReaderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? ayahs = null,Object? errorMessage = freezed,}) {
  return _then(_QuranReaderState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,ayahs: null == ayahs ? _self._ayahs : ayahs // ignore: cast_nullable_to_non_nullable
as List<AyahEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
