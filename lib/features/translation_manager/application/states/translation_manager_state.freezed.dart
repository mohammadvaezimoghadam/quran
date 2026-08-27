// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translation_manager_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TranslationManagerState {

/// List of all available translations (merged from catalog and Hive)
 List<TranslationEntity> get translations;/// The ID of the currently active/selected translation
 String? get activeTranslationId;/// Map of translation IDs to their download progress (0.0 to 1.0).
/// If an ID is in this map, it is currently downloading.
 Map<String, double> get downloadProgress;/// General error message to display in UI if something fails
 String? get errorMessage;
/// Create a copy of TranslationManagerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationManagerStateCopyWith<TranslationManagerState> get copyWith => _$TranslationManagerStateCopyWithImpl<TranslationManagerState>(this as TranslationManagerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationManagerState&&const DeepCollectionEquality().equals(other.translations, translations)&&(identical(other.activeTranslationId, activeTranslationId) || other.activeTranslationId == activeTranslationId)&&const DeepCollectionEquality().equals(other.downloadProgress, downloadProgress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(translations),activeTranslationId,const DeepCollectionEquality().hash(downloadProgress),errorMessage);

@override
String toString() {
  return 'TranslationManagerState(translations: $translations, activeTranslationId: $activeTranslationId, downloadProgress: $downloadProgress, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $TranslationManagerStateCopyWith<$Res>  {
  factory $TranslationManagerStateCopyWith(TranslationManagerState value, $Res Function(TranslationManagerState) _then) = _$TranslationManagerStateCopyWithImpl;
@useResult
$Res call({
 List<TranslationEntity> translations, String? activeTranslationId, Map<String, double> downloadProgress, String? errorMessage
});




}
/// @nodoc
class _$TranslationManagerStateCopyWithImpl<$Res>
    implements $TranslationManagerStateCopyWith<$Res> {
  _$TranslationManagerStateCopyWithImpl(this._self, this._then);

  final TranslationManagerState _self;
  final $Res Function(TranslationManagerState) _then;

/// Create a copy of TranslationManagerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? translations = null,Object? activeTranslationId = freezed,Object? downloadProgress = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as List<TranslationEntity>,activeTranslationId: freezed == activeTranslationId ? _self.activeTranslationId : activeTranslationId // ignore: cast_nullable_to_non_nullable
as String?,downloadProgress: null == downloadProgress ? _self.downloadProgress : downloadProgress // ignore: cast_nullable_to_non_nullable
as Map<String, double>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslationManagerState].
extension TranslationManagerStatePatterns on TranslationManagerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslationManagerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslationManagerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslationManagerState value)  $default,){
final _that = this;
switch (_that) {
case _TranslationManagerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslationManagerState value)?  $default,){
final _that = this;
switch (_that) {
case _TranslationManagerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TranslationEntity> translations,  String? activeTranslationId,  Map<String, double> downloadProgress,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationManagerState() when $default != null:
return $default(_that.translations,_that.activeTranslationId,_that.downloadProgress,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TranslationEntity> translations,  String? activeTranslationId,  Map<String, double> downloadProgress,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _TranslationManagerState():
return $default(_that.translations,_that.activeTranslationId,_that.downloadProgress,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TranslationEntity> translations,  String? activeTranslationId,  Map<String, double> downloadProgress,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _TranslationManagerState() when $default != null:
return $default(_that.translations,_that.activeTranslationId,_that.downloadProgress,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _TranslationManagerState implements TranslationManagerState {
  const _TranslationManagerState({final  List<TranslationEntity> translations = const [], this.activeTranslationId, final  Map<String, double> downloadProgress = const {}, this.errorMessage}): _translations = translations,_downloadProgress = downloadProgress;
  

/// List of all available translations (merged from catalog and Hive)
 final  List<TranslationEntity> _translations;
/// List of all available translations (merged from catalog and Hive)
@override@JsonKey() List<TranslationEntity> get translations {
  if (_translations is EqualUnmodifiableListView) return _translations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_translations);
}

/// The ID of the currently active/selected translation
@override final  String? activeTranslationId;
/// Map of translation IDs to their download progress (0.0 to 1.0).
/// If an ID is in this map, it is currently downloading.
 final  Map<String, double> _downloadProgress;
/// Map of translation IDs to their download progress (0.0 to 1.0).
/// If an ID is in this map, it is currently downloading.
@override@JsonKey() Map<String, double> get downloadProgress {
  if (_downloadProgress is EqualUnmodifiableMapView) return _downloadProgress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_downloadProgress);
}

/// General error message to display in UI if something fails
@override final  String? errorMessage;

/// Create a copy of TranslationManagerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationManagerStateCopyWith<_TranslationManagerState> get copyWith => __$TranslationManagerStateCopyWithImpl<_TranslationManagerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationManagerState&&const DeepCollectionEquality().equals(other._translations, _translations)&&(identical(other.activeTranslationId, activeTranslationId) || other.activeTranslationId == activeTranslationId)&&const DeepCollectionEquality().equals(other._downloadProgress, _downloadProgress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_translations),activeTranslationId,const DeepCollectionEquality().hash(_downloadProgress),errorMessage);

@override
String toString() {
  return 'TranslationManagerState(translations: $translations, activeTranslationId: $activeTranslationId, downloadProgress: $downloadProgress, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$TranslationManagerStateCopyWith<$Res> implements $TranslationManagerStateCopyWith<$Res> {
  factory _$TranslationManagerStateCopyWith(_TranslationManagerState value, $Res Function(_TranslationManagerState) _then) = __$TranslationManagerStateCopyWithImpl;
@override @useResult
$Res call({
 List<TranslationEntity> translations, String? activeTranslationId, Map<String, double> downloadProgress, String? errorMessage
});




}
/// @nodoc
class __$TranslationManagerStateCopyWithImpl<$Res>
    implements _$TranslationManagerStateCopyWith<$Res> {
  __$TranslationManagerStateCopyWithImpl(this._self, this._then);

  final _TranslationManagerState _self;
  final $Res Function(_TranslationManagerState) _then;

/// Create a copy of TranslationManagerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? translations = null,Object? activeTranslationId = freezed,Object? downloadProgress = null,Object? errorMessage = freezed,}) {
  return _then(_TranslationManagerState(
translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as List<TranslationEntity>,activeTranslationId: freezed == activeTranslationId ? _self.activeTranslationId : activeTranslationId // ignore: cast_nullable_to_non_nullable
as String?,downloadProgress: null == downloadProgress ? _self._downloadProgress : downloadProgress // ignore: cast_nullable_to_non_nullable
as Map<String, double>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
