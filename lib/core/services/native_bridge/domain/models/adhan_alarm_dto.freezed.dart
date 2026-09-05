// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adhan_alarm_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdhanAlarmDto {

/// Unique identifier for the alarm (e.g., hash of date and prayer type)
 int get id;/// The name of the prayer in Persian (e.g., 'صبح', 'ظهر')
 String get prayerName;/// The exact time the alarm should fire, in milliseconds since epoch
 int get epochMillis;/// The asset identifier for the moezzin's audio file (e.g., 'ghalvash') (Fallback)
 String get moezzinAsset;/// The absolute local file path of the downloaded moezzin mp3
 String? get moezzinFilePath; int get volumeLevel; bool get vibrate; bool get playInSilentMode; bool get ascendingVolume; bool get wakeScreen;
/// Create a copy of AdhanAlarmDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdhanAlarmDtoCopyWith<AdhanAlarmDto> get copyWith => _$AdhanAlarmDtoCopyWithImpl<AdhanAlarmDto>(this as AdhanAlarmDto, _$identity);

  /// Serializes this AdhanAlarmDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdhanAlarmDto&&(identical(other.id, id) || other.id == id)&&(identical(other.prayerName, prayerName) || other.prayerName == prayerName)&&(identical(other.epochMillis, epochMillis) || other.epochMillis == epochMillis)&&(identical(other.moezzinAsset, moezzinAsset) || other.moezzinAsset == moezzinAsset)&&(identical(other.moezzinFilePath, moezzinFilePath) || other.moezzinFilePath == moezzinFilePath)&&(identical(other.volumeLevel, volumeLevel) || other.volumeLevel == volumeLevel)&&(identical(other.vibrate, vibrate) || other.vibrate == vibrate)&&(identical(other.playInSilentMode, playInSilentMode) || other.playInSilentMode == playInSilentMode)&&(identical(other.ascendingVolume, ascendingVolume) || other.ascendingVolume == ascendingVolume)&&(identical(other.wakeScreen, wakeScreen) || other.wakeScreen == wakeScreen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,prayerName,epochMillis,moezzinAsset,moezzinFilePath,volumeLevel,vibrate,playInSilentMode,ascendingVolume,wakeScreen);

@override
String toString() {
  return 'AdhanAlarmDto(id: $id, prayerName: $prayerName, epochMillis: $epochMillis, moezzinAsset: $moezzinAsset, moezzinFilePath: $moezzinFilePath, volumeLevel: $volumeLevel, vibrate: $vibrate, playInSilentMode: $playInSilentMode, ascendingVolume: $ascendingVolume, wakeScreen: $wakeScreen)';
}


}

/// @nodoc
abstract mixin class $AdhanAlarmDtoCopyWith<$Res>  {
  factory $AdhanAlarmDtoCopyWith(AdhanAlarmDto value, $Res Function(AdhanAlarmDto) _then) = _$AdhanAlarmDtoCopyWithImpl;
@useResult
$Res call({
 int id, String prayerName, int epochMillis, String moezzinAsset, String? moezzinFilePath, int volumeLevel, bool vibrate, bool playInSilentMode, bool ascendingVolume, bool wakeScreen
});




}
/// @nodoc
class _$AdhanAlarmDtoCopyWithImpl<$Res>
    implements $AdhanAlarmDtoCopyWith<$Res> {
  _$AdhanAlarmDtoCopyWithImpl(this._self, this._then);

  final AdhanAlarmDto _self;
  final $Res Function(AdhanAlarmDto) _then;

/// Create a copy of AdhanAlarmDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? prayerName = null,Object? epochMillis = null,Object? moezzinAsset = null,Object? moezzinFilePath = freezed,Object? volumeLevel = null,Object? vibrate = null,Object? playInSilentMode = null,Object? ascendingVolume = null,Object? wakeScreen = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,prayerName: null == prayerName ? _self.prayerName : prayerName // ignore: cast_nullable_to_non_nullable
as String,epochMillis: null == epochMillis ? _self.epochMillis : epochMillis // ignore: cast_nullable_to_non_nullable
as int,moezzinAsset: null == moezzinAsset ? _self.moezzinAsset : moezzinAsset // ignore: cast_nullable_to_non_nullable
as String,moezzinFilePath: freezed == moezzinFilePath ? _self.moezzinFilePath : moezzinFilePath // ignore: cast_nullable_to_non_nullable
as String?,volumeLevel: null == volumeLevel ? _self.volumeLevel : volumeLevel // ignore: cast_nullable_to_non_nullable
as int,vibrate: null == vibrate ? _self.vibrate : vibrate // ignore: cast_nullable_to_non_nullable
as bool,playInSilentMode: null == playInSilentMode ? _self.playInSilentMode : playInSilentMode // ignore: cast_nullable_to_non_nullable
as bool,ascendingVolume: null == ascendingVolume ? _self.ascendingVolume : ascendingVolume // ignore: cast_nullable_to_non_nullable
as bool,wakeScreen: null == wakeScreen ? _self.wakeScreen : wakeScreen // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AdhanAlarmDto].
extension AdhanAlarmDtoPatterns on AdhanAlarmDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdhanAlarmDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdhanAlarmDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdhanAlarmDto value)  $default,){
final _that = this;
switch (_that) {
case _AdhanAlarmDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdhanAlarmDto value)?  $default,){
final _that = this;
switch (_that) {
case _AdhanAlarmDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String prayerName,  int epochMillis,  String moezzinAsset,  String? moezzinFilePath,  int volumeLevel,  bool vibrate,  bool playInSilentMode,  bool ascendingVolume,  bool wakeScreen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdhanAlarmDto() when $default != null:
return $default(_that.id,_that.prayerName,_that.epochMillis,_that.moezzinAsset,_that.moezzinFilePath,_that.volumeLevel,_that.vibrate,_that.playInSilentMode,_that.ascendingVolume,_that.wakeScreen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String prayerName,  int epochMillis,  String moezzinAsset,  String? moezzinFilePath,  int volumeLevel,  bool vibrate,  bool playInSilentMode,  bool ascendingVolume,  bool wakeScreen)  $default,) {final _that = this;
switch (_that) {
case _AdhanAlarmDto():
return $default(_that.id,_that.prayerName,_that.epochMillis,_that.moezzinAsset,_that.moezzinFilePath,_that.volumeLevel,_that.vibrate,_that.playInSilentMode,_that.ascendingVolume,_that.wakeScreen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String prayerName,  int epochMillis,  String moezzinAsset,  String? moezzinFilePath,  int volumeLevel,  bool vibrate,  bool playInSilentMode,  bool ascendingVolume,  bool wakeScreen)?  $default,) {final _that = this;
switch (_that) {
case _AdhanAlarmDto() when $default != null:
return $default(_that.id,_that.prayerName,_that.epochMillis,_that.moezzinAsset,_that.moezzinFilePath,_that.volumeLevel,_that.vibrate,_that.playInSilentMode,_that.ascendingVolume,_that.wakeScreen);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdhanAlarmDto extends AdhanAlarmDto {
  const _AdhanAlarmDto({required this.id, required this.prayerName, required this.epochMillis, required this.moezzinAsset, this.moezzinFilePath, this.volumeLevel = 100, this.vibrate = true, this.playInSilentMode = true, this.ascendingVolume = false, this.wakeScreen = true}): super._();
  factory _AdhanAlarmDto.fromJson(Map<String, dynamic> json) => _$AdhanAlarmDtoFromJson(json);

/// Unique identifier for the alarm (e.g., hash of date and prayer type)
@override final  int id;
/// The name of the prayer in Persian (e.g., 'صبح', 'ظهر')
@override final  String prayerName;
/// The exact time the alarm should fire, in milliseconds since epoch
@override final  int epochMillis;
/// The asset identifier for the moezzin's audio file (e.g., 'ghalvash') (Fallback)
@override final  String moezzinAsset;
/// The absolute local file path of the downloaded moezzin mp3
@override final  String? moezzinFilePath;
@override@JsonKey() final  int volumeLevel;
@override@JsonKey() final  bool vibrate;
@override@JsonKey() final  bool playInSilentMode;
@override@JsonKey() final  bool ascendingVolume;
@override@JsonKey() final  bool wakeScreen;

/// Create a copy of AdhanAlarmDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdhanAlarmDtoCopyWith<_AdhanAlarmDto> get copyWith => __$AdhanAlarmDtoCopyWithImpl<_AdhanAlarmDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdhanAlarmDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdhanAlarmDto&&(identical(other.id, id) || other.id == id)&&(identical(other.prayerName, prayerName) || other.prayerName == prayerName)&&(identical(other.epochMillis, epochMillis) || other.epochMillis == epochMillis)&&(identical(other.moezzinAsset, moezzinAsset) || other.moezzinAsset == moezzinAsset)&&(identical(other.moezzinFilePath, moezzinFilePath) || other.moezzinFilePath == moezzinFilePath)&&(identical(other.volumeLevel, volumeLevel) || other.volumeLevel == volumeLevel)&&(identical(other.vibrate, vibrate) || other.vibrate == vibrate)&&(identical(other.playInSilentMode, playInSilentMode) || other.playInSilentMode == playInSilentMode)&&(identical(other.ascendingVolume, ascendingVolume) || other.ascendingVolume == ascendingVolume)&&(identical(other.wakeScreen, wakeScreen) || other.wakeScreen == wakeScreen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,prayerName,epochMillis,moezzinAsset,moezzinFilePath,volumeLevel,vibrate,playInSilentMode,ascendingVolume,wakeScreen);

@override
String toString() {
  return 'AdhanAlarmDto(id: $id, prayerName: $prayerName, epochMillis: $epochMillis, moezzinAsset: $moezzinAsset, moezzinFilePath: $moezzinFilePath, volumeLevel: $volumeLevel, vibrate: $vibrate, playInSilentMode: $playInSilentMode, ascendingVolume: $ascendingVolume, wakeScreen: $wakeScreen)';
}


}

/// @nodoc
abstract mixin class _$AdhanAlarmDtoCopyWith<$Res> implements $AdhanAlarmDtoCopyWith<$Res> {
  factory _$AdhanAlarmDtoCopyWith(_AdhanAlarmDto value, $Res Function(_AdhanAlarmDto) _then) = __$AdhanAlarmDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String prayerName, int epochMillis, String moezzinAsset, String? moezzinFilePath, int volumeLevel, bool vibrate, bool playInSilentMode, bool ascendingVolume, bool wakeScreen
});




}
/// @nodoc
class __$AdhanAlarmDtoCopyWithImpl<$Res>
    implements _$AdhanAlarmDtoCopyWith<$Res> {
  __$AdhanAlarmDtoCopyWithImpl(this._self, this._then);

  final _AdhanAlarmDto _self;
  final $Res Function(_AdhanAlarmDto) _then;

/// Create a copy of AdhanAlarmDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? prayerName = null,Object? epochMillis = null,Object? moezzinAsset = null,Object? moezzinFilePath = freezed,Object? volumeLevel = null,Object? vibrate = null,Object? playInSilentMode = null,Object? ascendingVolume = null,Object? wakeScreen = null,}) {
  return _then(_AdhanAlarmDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,prayerName: null == prayerName ? _self.prayerName : prayerName // ignore: cast_nullable_to_non_nullable
as String,epochMillis: null == epochMillis ? _self.epochMillis : epochMillis // ignore: cast_nullable_to_non_nullable
as int,moezzinAsset: null == moezzinAsset ? _self.moezzinAsset : moezzinAsset // ignore: cast_nullable_to_non_nullable
as String,moezzinFilePath: freezed == moezzinFilePath ? _self.moezzinFilePath : moezzinFilePath // ignore: cast_nullable_to_non_nullable
as String?,volumeLevel: null == volumeLevel ? _self.volumeLevel : volumeLevel // ignore: cast_nullable_to_non_nullable
as int,vibrate: null == vibrate ? _self.vibrate : vibrate // ignore: cast_nullable_to_non_nullable
as bool,playInSilentMode: null == playInSilentMode ? _self.playInSilentMode : playInSilentMode // ignore: cast_nullable_to_non_nullable
as bool,ascendingVolume: null == ascendingVolume ? _self.ascendingVolume : ascendingVolume // ignore: cast_nullable_to_non_nullable
as bool,wakeScreen: null == wakeScreen ? _self.wakeScreen : wakeScreen // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
