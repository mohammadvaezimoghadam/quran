// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prayer_times_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PrayerTimesEntity {

 CityEntity get city; DateTime get date; String get shamsiDate; String get hijriDate; DateTime get fajr; DateTime get sunrise; DateTime get dhuhr; DateTime get asr; DateTime get sunset; DateTime get maghrib; DateTime get isha; DateTime get midnight;
/// Create a copy of PrayerTimesEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrayerTimesEntityCopyWith<PrayerTimesEntity> get copyWith => _$PrayerTimesEntityCopyWithImpl<PrayerTimesEntity>(this as PrayerTimesEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrayerTimesEntity&&(identical(other.city, city) || other.city == city)&&(identical(other.date, date) || other.date == date)&&(identical(other.shamsiDate, shamsiDate) || other.shamsiDate == shamsiDate)&&(identical(other.hijriDate, hijriDate) || other.hijriDate == hijriDate)&&(identical(other.fajr, fajr) || other.fajr == fajr)&&(identical(other.sunrise, sunrise) || other.sunrise == sunrise)&&(identical(other.dhuhr, dhuhr) || other.dhuhr == dhuhr)&&(identical(other.asr, asr) || other.asr == asr)&&(identical(other.sunset, sunset) || other.sunset == sunset)&&(identical(other.maghrib, maghrib) || other.maghrib == maghrib)&&(identical(other.isha, isha) || other.isha == isha)&&(identical(other.midnight, midnight) || other.midnight == midnight));
}


@override
int get hashCode => Object.hash(runtimeType,city,date,shamsiDate,hijriDate,fajr,sunrise,dhuhr,asr,sunset,maghrib,isha,midnight);

@override
String toString() {
  return 'PrayerTimesEntity(city: $city, date: $date, shamsiDate: $shamsiDate, hijriDate: $hijriDate, fajr: $fajr, sunrise: $sunrise, dhuhr: $dhuhr, asr: $asr, sunset: $sunset, maghrib: $maghrib, isha: $isha, midnight: $midnight)';
}


}

/// @nodoc
abstract mixin class $PrayerTimesEntityCopyWith<$Res>  {
  factory $PrayerTimesEntityCopyWith(PrayerTimesEntity value, $Res Function(PrayerTimesEntity) _then) = _$PrayerTimesEntityCopyWithImpl;
@useResult
$Res call({
 CityEntity city, DateTime date, String shamsiDate, String hijriDate, DateTime fajr, DateTime sunrise, DateTime dhuhr, DateTime asr, DateTime sunset, DateTime maghrib, DateTime isha, DateTime midnight
});


$CityEntityCopyWith<$Res> get city;

}
/// @nodoc
class _$PrayerTimesEntityCopyWithImpl<$Res>
    implements $PrayerTimesEntityCopyWith<$Res> {
  _$PrayerTimesEntityCopyWithImpl(this._self, this._then);

  final PrayerTimesEntity _self;
  final $Res Function(PrayerTimesEntity) _then;

/// Create a copy of PrayerTimesEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? city = null,Object? date = null,Object? shamsiDate = null,Object? hijriDate = null,Object? fajr = null,Object? sunrise = null,Object? dhuhr = null,Object? asr = null,Object? sunset = null,Object? maghrib = null,Object? isha = null,Object? midnight = null,}) {
  return _then(_self.copyWith(
city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as CityEntity,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,shamsiDate: null == shamsiDate ? _self.shamsiDate : shamsiDate // ignore: cast_nullable_to_non_nullable
as String,hijriDate: null == hijriDate ? _self.hijriDate : hijriDate // ignore: cast_nullable_to_non_nullable
as String,fajr: null == fajr ? _self.fajr : fajr // ignore: cast_nullable_to_non_nullable
as DateTime,sunrise: null == sunrise ? _self.sunrise : sunrise // ignore: cast_nullable_to_non_nullable
as DateTime,dhuhr: null == dhuhr ? _self.dhuhr : dhuhr // ignore: cast_nullable_to_non_nullable
as DateTime,asr: null == asr ? _self.asr : asr // ignore: cast_nullable_to_non_nullable
as DateTime,sunset: null == sunset ? _self.sunset : sunset // ignore: cast_nullable_to_non_nullable
as DateTime,maghrib: null == maghrib ? _self.maghrib : maghrib // ignore: cast_nullable_to_non_nullable
as DateTime,isha: null == isha ? _self.isha : isha // ignore: cast_nullable_to_non_nullable
as DateTime,midnight: null == midnight ? _self.midnight : midnight // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of PrayerTimesEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CityEntityCopyWith<$Res> get city {
  
  return $CityEntityCopyWith<$Res>(_self.city, (value) {
    return _then(_self.copyWith(city: value));
  });
}
}


/// Adds pattern-matching-related methods to [PrayerTimesEntity].
extension PrayerTimesEntityPatterns on PrayerTimesEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrayerTimesEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrayerTimesEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrayerTimesEntity value)  $default,){
final _that = this;
switch (_that) {
case _PrayerTimesEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrayerTimesEntity value)?  $default,){
final _that = this;
switch (_that) {
case _PrayerTimesEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CityEntity city,  DateTime date,  String shamsiDate,  String hijriDate,  DateTime fajr,  DateTime sunrise,  DateTime dhuhr,  DateTime asr,  DateTime sunset,  DateTime maghrib,  DateTime isha,  DateTime midnight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrayerTimesEntity() when $default != null:
return $default(_that.city,_that.date,_that.shamsiDate,_that.hijriDate,_that.fajr,_that.sunrise,_that.dhuhr,_that.asr,_that.sunset,_that.maghrib,_that.isha,_that.midnight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CityEntity city,  DateTime date,  String shamsiDate,  String hijriDate,  DateTime fajr,  DateTime sunrise,  DateTime dhuhr,  DateTime asr,  DateTime sunset,  DateTime maghrib,  DateTime isha,  DateTime midnight)  $default,) {final _that = this;
switch (_that) {
case _PrayerTimesEntity():
return $default(_that.city,_that.date,_that.shamsiDate,_that.hijriDate,_that.fajr,_that.sunrise,_that.dhuhr,_that.asr,_that.sunset,_that.maghrib,_that.isha,_that.midnight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CityEntity city,  DateTime date,  String shamsiDate,  String hijriDate,  DateTime fajr,  DateTime sunrise,  DateTime dhuhr,  DateTime asr,  DateTime sunset,  DateTime maghrib,  DateTime isha,  DateTime midnight)?  $default,) {final _that = this;
switch (_that) {
case _PrayerTimesEntity() when $default != null:
return $default(_that.city,_that.date,_that.shamsiDate,_that.hijriDate,_that.fajr,_that.sunrise,_that.dhuhr,_that.asr,_that.sunset,_that.maghrib,_that.isha,_that.midnight);case _:
  return null;

}
}

}

/// @nodoc


class _PrayerTimesEntity implements PrayerTimesEntity {
  const _PrayerTimesEntity({required this.city, required this.date, required this.shamsiDate, required this.hijriDate, required this.fajr, required this.sunrise, required this.dhuhr, required this.asr, required this.sunset, required this.maghrib, required this.isha, required this.midnight});
  

@override final  CityEntity city;
@override final  DateTime date;
@override final  String shamsiDate;
@override final  String hijriDate;
@override final  DateTime fajr;
@override final  DateTime sunrise;
@override final  DateTime dhuhr;
@override final  DateTime asr;
@override final  DateTime sunset;
@override final  DateTime maghrib;
@override final  DateTime isha;
@override final  DateTime midnight;

/// Create a copy of PrayerTimesEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrayerTimesEntityCopyWith<_PrayerTimesEntity> get copyWith => __$PrayerTimesEntityCopyWithImpl<_PrayerTimesEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrayerTimesEntity&&(identical(other.city, city) || other.city == city)&&(identical(other.date, date) || other.date == date)&&(identical(other.shamsiDate, shamsiDate) || other.shamsiDate == shamsiDate)&&(identical(other.hijriDate, hijriDate) || other.hijriDate == hijriDate)&&(identical(other.fajr, fajr) || other.fajr == fajr)&&(identical(other.sunrise, sunrise) || other.sunrise == sunrise)&&(identical(other.dhuhr, dhuhr) || other.dhuhr == dhuhr)&&(identical(other.asr, asr) || other.asr == asr)&&(identical(other.sunset, sunset) || other.sunset == sunset)&&(identical(other.maghrib, maghrib) || other.maghrib == maghrib)&&(identical(other.isha, isha) || other.isha == isha)&&(identical(other.midnight, midnight) || other.midnight == midnight));
}


@override
int get hashCode => Object.hash(runtimeType,city,date,shamsiDate,hijriDate,fajr,sunrise,dhuhr,asr,sunset,maghrib,isha,midnight);

@override
String toString() {
  return 'PrayerTimesEntity(city: $city, date: $date, shamsiDate: $shamsiDate, hijriDate: $hijriDate, fajr: $fajr, sunrise: $sunrise, dhuhr: $dhuhr, asr: $asr, sunset: $sunset, maghrib: $maghrib, isha: $isha, midnight: $midnight)';
}


}

/// @nodoc
abstract mixin class _$PrayerTimesEntityCopyWith<$Res> implements $PrayerTimesEntityCopyWith<$Res> {
  factory _$PrayerTimesEntityCopyWith(_PrayerTimesEntity value, $Res Function(_PrayerTimesEntity) _then) = __$PrayerTimesEntityCopyWithImpl;
@override @useResult
$Res call({
 CityEntity city, DateTime date, String shamsiDate, String hijriDate, DateTime fajr, DateTime sunrise, DateTime dhuhr, DateTime asr, DateTime sunset, DateTime maghrib, DateTime isha, DateTime midnight
});


@override $CityEntityCopyWith<$Res> get city;

}
/// @nodoc
class __$PrayerTimesEntityCopyWithImpl<$Res>
    implements _$PrayerTimesEntityCopyWith<$Res> {
  __$PrayerTimesEntityCopyWithImpl(this._self, this._then);

  final _PrayerTimesEntity _self;
  final $Res Function(_PrayerTimesEntity) _then;

/// Create a copy of PrayerTimesEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? city = null,Object? date = null,Object? shamsiDate = null,Object? hijriDate = null,Object? fajr = null,Object? sunrise = null,Object? dhuhr = null,Object? asr = null,Object? sunset = null,Object? maghrib = null,Object? isha = null,Object? midnight = null,}) {
  return _then(_PrayerTimesEntity(
city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as CityEntity,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,shamsiDate: null == shamsiDate ? _self.shamsiDate : shamsiDate // ignore: cast_nullable_to_non_nullable
as String,hijriDate: null == hijriDate ? _self.hijriDate : hijriDate // ignore: cast_nullable_to_non_nullable
as String,fajr: null == fajr ? _self.fajr : fajr // ignore: cast_nullable_to_non_nullable
as DateTime,sunrise: null == sunrise ? _self.sunrise : sunrise // ignore: cast_nullable_to_non_nullable
as DateTime,dhuhr: null == dhuhr ? _self.dhuhr : dhuhr // ignore: cast_nullable_to_non_nullable
as DateTime,asr: null == asr ? _self.asr : asr // ignore: cast_nullable_to_non_nullable
as DateTime,sunset: null == sunset ? _self.sunset : sunset // ignore: cast_nullable_to_non_nullable
as DateTime,maghrib: null == maghrib ? _self.maghrib : maghrib // ignore: cast_nullable_to_non_nullable
as DateTime,isha: null == isha ? _self.isha : isha // ignore: cast_nullable_to_non_nullable
as DateTime,midnight: null == midnight ? _self.midnight : midnight // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of PrayerTimesEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CityEntityCopyWith<$Res> get city {
  
  return $CityEntityCopyWith<$Res>(_self.city, (value) {
    return _then(_self.copyWith(city: value));
  });
}
}

// dart format on
