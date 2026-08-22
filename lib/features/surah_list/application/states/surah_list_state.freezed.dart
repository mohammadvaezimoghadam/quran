// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'surah_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SurahListState {

 bool get isLoading; List<SurahEntity> get surahs; String get searchQuery; String? get errorMessage;
/// Create a copy of SurahListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SurahListStateCopyWith<SurahListState> get copyWith => _$SurahListStateCopyWithImpl<SurahListState>(this as SurahListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SurahListState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.surahs, surahs)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(surahs),searchQuery,errorMessage);

@override
String toString() {
  return 'SurahListState(isLoading: $isLoading, surahs: $surahs, searchQuery: $searchQuery, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $SurahListStateCopyWith<$Res>  {
  factory $SurahListStateCopyWith(SurahListState value, $Res Function(SurahListState) _then) = _$SurahListStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<SurahEntity> surahs, String searchQuery, String? errorMessage
});




}
/// @nodoc
class _$SurahListStateCopyWithImpl<$Res>
    implements $SurahListStateCopyWith<$Res> {
  _$SurahListStateCopyWithImpl(this._self, this._then);

  final SurahListState _self;
  final $Res Function(SurahListState) _then;

/// Create a copy of SurahListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? surahs = null,Object? searchQuery = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,surahs: null == surahs ? _self.surahs : surahs // ignore: cast_nullable_to_non_nullable
as List<SurahEntity>,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SurahListState].
extension SurahListStatePatterns on SurahListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SurahListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SurahListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SurahListState value)  $default,){
final _that = this;
switch (_that) {
case _SurahListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SurahListState value)?  $default,){
final _that = this;
switch (_that) {
case _SurahListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  List<SurahEntity> surahs,  String searchQuery,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SurahListState() when $default != null:
return $default(_that.isLoading,_that.surahs,_that.searchQuery,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  List<SurahEntity> surahs,  String searchQuery,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _SurahListState():
return $default(_that.isLoading,_that.surahs,_that.searchQuery,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  List<SurahEntity> surahs,  String searchQuery,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SurahListState() when $default != null:
return $default(_that.isLoading,_that.surahs,_that.searchQuery,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _SurahListState extends SurahListState {
  const _SurahListState({this.isLoading = true, final  List<SurahEntity> surahs = const [], this.searchQuery = '', this.errorMessage}): _surahs = surahs,super._();
  

@override@JsonKey() final  bool isLoading;
 final  List<SurahEntity> _surahs;
@override@JsonKey() List<SurahEntity> get surahs {
  if (_surahs is EqualUnmodifiableListView) return _surahs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_surahs);
}

@override@JsonKey() final  String searchQuery;
@override final  String? errorMessage;

/// Create a copy of SurahListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SurahListStateCopyWith<_SurahListState> get copyWith => __$SurahListStateCopyWithImpl<_SurahListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SurahListState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._surahs, _surahs)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_surahs),searchQuery,errorMessage);

@override
String toString() {
  return 'SurahListState(isLoading: $isLoading, surahs: $surahs, searchQuery: $searchQuery, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$SurahListStateCopyWith<$Res> implements $SurahListStateCopyWith<$Res> {
  factory _$SurahListStateCopyWith(_SurahListState value, $Res Function(_SurahListState) _then) = __$SurahListStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<SurahEntity> surahs, String searchQuery, String? errorMessage
});




}
/// @nodoc
class __$SurahListStateCopyWithImpl<$Res>
    implements _$SurahListStateCopyWith<$Res> {
  __$SurahListStateCopyWithImpl(this._self, this._then);

  final _SurahListState _self;
  final $Res Function(_SurahListState) _then;

/// Create a copy of SurahListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? surahs = null,Object? searchQuery = null,Object? errorMessage = freezed,}) {
  return _then(_SurahListState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,surahs: null == surahs ? _self._surahs : surahs // ignore: cast_nullable_to_non_nullable
as List<SurahEntity>,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
