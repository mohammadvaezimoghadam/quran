// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adhan_download_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdhanDownloadState {

/// Map of moezzinId -> progress (0.0 to 1.0)
 Map<String, double> get downloadProgresses;/// Map of moezzinId -> isDownloading
 Map<String, bool> get isDownloading;/// Map of moezzinId -> error message if any
 Map<String, String> get downloadErrors;
/// Create a copy of AdhanDownloadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdhanDownloadStateCopyWith<AdhanDownloadState> get copyWith => _$AdhanDownloadStateCopyWithImpl<AdhanDownloadState>(this as AdhanDownloadState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdhanDownloadState&&const DeepCollectionEquality().equals(other.downloadProgresses, downloadProgresses)&&const DeepCollectionEquality().equals(other.isDownloading, isDownloading)&&const DeepCollectionEquality().equals(other.downloadErrors, downloadErrors));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(downloadProgresses),const DeepCollectionEquality().hash(isDownloading),const DeepCollectionEquality().hash(downloadErrors));

@override
String toString() {
  return 'AdhanDownloadState(downloadProgresses: $downloadProgresses, isDownloading: $isDownloading, downloadErrors: $downloadErrors)';
}


}

/// @nodoc
abstract mixin class $AdhanDownloadStateCopyWith<$Res>  {
  factory $AdhanDownloadStateCopyWith(AdhanDownloadState value, $Res Function(AdhanDownloadState) _then) = _$AdhanDownloadStateCopyWithImpl;
@useResult
$Res call({
 Map<String, double> downloadProgresses, Map<String, bool> isDownloading, Map<String, String> downloadErrors
});




}
/// @nodoc
class _$AdhanDownloadStateCopyWithImpl<$Res>
    implements $AdhanDownloadStateCopyWith<$Res> {
  _$AdhanDownloadStateCopyWithImpl(this._self, this._then);

  final AdhanDownloadState _self;
  final $Res Function(AdhanDownloadState) _then;

/// Create a copy of AdhanDownloadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? downloadProgresses = null,Object? isDownloading = null,Object? downloadErrors = null,}) {
  return _then(_self.copyWith(
downloadProgresses: null == downloadProgresses ? _self.downloadProgresses : downloadProgresses // ignore: cast_nullable_to_non_nullable
as Map<String, double>,isDownloading: null == isDownloading ? _self.isDownloading : isDownloading // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,downloadErrors: null == downloadErrors ? _self.downloadErrors : downloadErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AdhanDownloadState].
extension AdhanDownloadStatePatterns on AdhanDownloadState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdhanDownloadState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdhanDownloadState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdhanDownloadState value)  $default,){
final _that = this;
switch (_that) {
case _AdhanDownloadState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdhanDownloadState value)?  $default,){
final _that = this;
switch (_that) {
case _AdhanDownloadState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, double> downloadProgresses,  Map<String, bool> isDownloading,  Map<String, String> downloadErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdhanDownloadState() when $default != null:
return $default(_that.downloadProgresses,_that.isDownloading,_that.downloadErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, double> downloadProgresses,  Map<String, bool> isDownloading,  Map<String, String> downloadErrors)  $default,) {final _that = this;
switch (_that) {
case _AdhanDownloadState():
return $default(_that.downloadProgresses,_that.isDownloading,_that.downloadErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, double> downloadProgresses,  Map<String, bool> isDownloading,  Map<String, String> downloadErrors)?  $default,) {final _that = this;
switch (_that) {
case _AdhanDownloadState() when $default != null:
return $default(_that.downloadProgresses,_that.isDownloading,_that.downloadErrors);case _:
  return null;

}
}

}

/// @nodoc


class _AdhanDownloadState implements AdhanDownloadState {
  const _AdhanDownloadState({final  Map<String, double> downloadProgresses = const {}, final  Map<String, bool> isDownloading = const {}, final  Map<String, String> downloadErrors = const {}}): _downloadProgresses = downloadProgresses,_isDownloading = isDownloading,_downloadErrors = downloadErrors;
  

/// Map of moezzinId -> progress (0.0 to 1.0)
 final  Map<String, double> _downloadProgresses;
/// Map of moezzinId -> progress (0.0 to 1.0)
@override@JsonKey() Map<String, double> get downloadProgresses {
  if (_downloadProgresses is EqualUnmodifiableMapView) return _downloadProgresses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_downloadProgresses);
}

/// Map of moezzinId -> isDownloading
 final  Map<String, bool> _isDownloading;
/// Map of moezzinId -> isDownloading
@override@JsonKey() Map<String, bool> get isDownloading {
  if (_isDownloading is EqualUnmodifiableMapView) return _isDownloading;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_isDownloading);
}

/// Map of moezzinId -> error message if any
 final  Map<String, String> _downloadErrors;
/// Map of moezzinId -> error message if any
@override@JsonKey() Map<String, String> get downloadErrors {
  if (_downloadErrors is EqualUnmodifiableMapView) return _downloadErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_downloadErrors);
}


/// Create a copy of AdhanDownloadState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdhanDownloadStateCopyWith<_AdhanDownloadState> get copyWith => __$AdhanDownloadStateCopyWithImpl<_AdhanDownloadState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdhanDownloadState&&const DeepCollectionEquality().equals(other._downloadProgresses, _downloadProgresses)&&const DeepCollectionEquality().equals(other._isDownloading, _isDownloading)&&const DeepCollectionEquality().equals(other._downloadErrors, _downloadErrors));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_downloadProgresses),const DeepCollectionEquality().hash(_isDownloading),const DeepCollectionEquality().hash(_downloadErrors));

@override
String toString() {
  return 'AdhanDownloadState(downloadProgresses: $downloadProgresses, isDownloading: $isDownloading, downloadErrors: $downloadErrors)';
}


}

/// @nodoc
abstract mixin class _$AdhanDownloadStateCopyWith<$Res> implements $AdhanDownloadStateCopyWith<$Res> {
  factory _$AdhanDownloadStateCopyWith(_AdhanDownloadState value, $Res Function(_AdhanDownloadState) _then) = __$AdhanDownloadStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, double> downloadProgresses, Map<String, bool> isDownloading, Map<String, String> downloadErrors
});




}
/// @nodoc
class __$AdhanDownloadStateCopyWithImpl<$Res>
    implements _$AdhanDownloadStateCopyWith<$Res> {
  __$AdhanDownloadStateCopyWithImpl(this._self, this._then);

  final _AdhanDownloadState _self;
  final $Res Function(_AdhanDownloadState) _then;

/// Create a copy of AdhanDownloadState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? downloadProgresses = null,Object? isDownloading = null,Object? downloadErrors = null,}) {
  return _then(_AdhanDownloadState(
downloadProgresses: null == downloadProgresses ? _self._downloadProgresses : downloadProgresses // ignore: cast_nullable_to_non_nullable
as Map<String, double>,isDownloading: null == isDownloading ? _self._isDownloading : isDownloading // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,downloadErrors: null == downloadErrors ? _self._downloadErrors : downloadErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
