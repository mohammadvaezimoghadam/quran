// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prayer_times_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PrayerTimesState {

 bool get isLoading; CityEntity? get selectedCity; List<CityEntity> get cities; PrayerTimesEntity? get prayerTimes; DateTime? get selectedDate; int get hijriAdjustment; String? get errorMessage;
/// Create a copy of PrayerTimesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrayerTimesStateCopyWith<PrayerTimesState> get copyWith => _$PrayerTimesStateCopyWithImpl<PrayerTimesState>(this as PrayerTimesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrayerTimesState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.selectedCity, selectedCity) || other.selectedCity == selectedCity)&&const DeepCollectionEquality().equals(other.cities, cities)&&(identical(other.prayerTimes, prayerTimes) || other.prayerTimes == prayerTimes)&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&(identical(other.hijriAdjustment, hijriAdjustment) || other.hijriAdjustment == hijriAdjustment)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,selectedCity,const DeepCollectionEquality().hash(cities),prayerTimes,selectedDate,hijriAdjustment,errorMessage);

@override
String toString() {
  return 'PrayerTimesState(isLoading: $isLoading, selectedCity: $selectedCity, cities: $cities, prayerTimes: $prayerTimes, selectedDate: $selectedDate, hijriAdjustment: $hijriAdjustment, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $PrayerTimesStateCopyWith<$Res>  {
  factory $PrayerTimesStateCopyWith(PrayerTimesState value, $Res Function(PrayerTimesState) _then) = _$PrayerTimesStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, CityEntity? selectedCity, List<CityEntity> cities, PrayerTimesEntity? prayerTimes, DateTime? selectedDate, int hijriAdjustment, String? errorMessage
});


$CityEntityCopyWith<$Res>? get selectedCity;$PrayerTimesEntityCopyWith<$Res>? get prayerTimes;

}
/// @nodoc
class _$PrayerTimesStateCopyWithImpl<$Res>
    implements $PrayerTimesStateCopyWith<$Res> {
  _$PrayerTimesStateCopyWithImpl(this._self, this._then);

  final PrayerTimesState _self;
  final $Res Function(PrayerTimesState) _then;

/// Create a copy of PrayerTimesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? selectedCity = freezed,Object? cities = null,Object? prayerTimes = freezed,Object? selectedDate = freezed,Object? hijriAdjustment = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedCity: freezed == selectedCity ? _self.selectedCity : selectedCity // ignore: cast_nullable_to_non_nullable
as CityEntity?,cities: null == cities ? _self.cities : cities // ignore: cast_nullable_to_non_nullable
as List<CityEntity>,prayerTimes: freezed == prayerTimes ? _self.prayerTimes : prayerTimes // ignore: cast_nullable_to_non_nullable
as PrayerTimesEntity?,selectedDate: freezed == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,hijriAdjustment: null == hijriAdjustment ? _self.hijriAdjustment : hijriAdjustment // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PrayerTimesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CityEntityCopyWith<$Res>? get selectedCity {
    if (_self.selectedCity == null) {
    return null;
  }

  return $CityEntityCopyWith<$Res>(_self.selectedCity!, (value) {
    return _then(_self.copyWith(selectedCity: value));
  });
}/// Create a copy of PrayerTimesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrayerTimesEntityCopyWith<$Res>? get prayerTimes {
    if (_self.prayerTimes == null) {
    return null;
  }

  return $PrayerTimesEntityCopyWith<$Res>(_self.prayerTimes!, (value) {
    return _then(_self.copyWith(prayerTimes: value));
  });
}
}


/// Adds pattern-matching-related methods to [PrayerTimesState].
extension PrayerTimesStatePatterns on PrayerTimesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrayerTimesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrayerTimesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrayerTimesState value)  $default,){
final _that = this;
switch (_that) {
case _PrayerTimesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrayerTimesState value)?  $default,){
final _that = this;
switch (_that) {
case _PrayerTimesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  CityEntity? selectedCity,  List<CityEntity> cities,  PrayerTimesEntity? prayerTimes,  DateTime? selectedDate,  int hijriAdjustment,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrayerTimesState() when $default != null:
return $default(_that.isLoading,_that.selectedCity,_that.cities,_that.prayerTimes,_that.selectedDate,_that.hijriAdjustment,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  CityEntity? selectedCity,  List<CityEntity> cities,  PrayerTimesEntity? prayerTimes,  DateTime? selectedDate,  int hijriAdjustment,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _PrayerTimesState():
return $default(_that.isLoading,_that.selectedCity,_that.cities,_that.prayerTimes,_that.selectedDate,_that.hijriAdjustment,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  CityEntity? selectedCity,  List<CityEntity> cities,  PrayerTimesEntity? prayerTimes,  DateTime? selectedDate,  int hijriAdjustment,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _PrayerTimesState() when $default != null:
return $default(_that.isLoading,_that.selectedCity,_that.cities,_that.prayerTimes,_that.selectedDate,_that.hijriAdjustment,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _PrayerTimesState implements PrayerTimesState {
  const _PrayerTimesState({this.isLoading = true, this.selectedCity, final  List<CityEntity> cities = const [], this.prayerTimes, this.selectedDate, this.hijriAdjustment = 0, this.errorMessage}): _cities = cities;
  

@override@JsonKey() final  bool isLoading;
@override final  CityEntity? selectedCity;
 final  List<CityEntity> _cities;
@override@JsonKey() List<CityEntity> get cities {
  if (_cities is EqualUnmodifiableListView) return _cities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cities);
}

@override final  PrayerTimesEntity? prayerTimes;
@override final  DateTime? selectedDate;
@override@JsonKey() final  int hijriAdjustment;
@override final  String? errorMessage;

/// Create a copy of PrayerTimesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrayerTimesStateCopyWith<_PrayerTimesState> get copyWith => __$PrayerTimesStateCopyWithImpl<_PrayerTimesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrayerTimesState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.selectedCity, selectedCity) || other.selectedCity == selectedCity)&&const DeepCollectionEquality().equals(other._cities, _cities)&&(identical(other.prayerTimes, prayerTimes) || other.prayerTimes == prayerTimes)&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&(identical(other.hijriAdjustment, hijriAdjustment) || other.hijriAdjustment == hijriAdjustment)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,selectedCity,const DeepCollectionEquality().hash(_cities),prayerTimes,selectedDate,hijriAdjustment,errorMessage);

@override
String toString() {
  return 'PrayerTimesState(isLoading: $isLoading, selectedCity: $selectedCity, cities: $cities, prayerTimes: $prayerTimes, selectedDate: $selectedDate, hijriAdjustment: $hijriAdjustment, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$PrayerTimesStateCopyWith<$Res> implements $PrayerTimesStateCopyWith<$Res> {
  factory _$PrayerTimesStateCopyWith(_PrayerTimesState value, $Res Function(_PrayerTimesState) _then) = __$PrayerTimesStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, CityEntity? selectedCity, List<CityEntity> cities, PrayerTimesEntity? prayerTimes, DateTime? selectedDate, int hijriAdjustment, String? errorMessage
});


@override $CityEntityCopyWith<$Res>? get selectedCity;@override $PrayerTimesEntityCopyWith<$Res>? get prayerTimes;

}
/// @nodoc
class __$PrayerTimesStateCopyWithImpl<$Res>
    implements _$PrayerTimesStateCopyWith<$Res> {
  __$PrayerTimesStateCopyWithImpl(this._self, this._then);

  final _PrayerTimesState _self;
  final $Res Function(_PrayerTimesState) _then;

/// Create a copy of PrayerTimesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? selectedCity = freezed,Object? cities = null,Object? prayerTimes = freezed,Object? selectedDate = freezed,Object? hijriAdjustment = null,Object? errorMessage = freezed,}) {
  return _then(_PrayerTimesState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedCity: freezed == selectedCity ? _self.selectedCity : selectedCity // ignore: cast_nullable_to_non_nullable
as CityEntity?,cities: null == cities ? _self._cities : cities // ignore: cast_nullable_to_non_nullable
as List<CityEntity>,prayerTimes: freezed == prayerTimes ? _self.prayerTimes : prayerTimes // ignore: cast_nullable_to_non_nullable
as PrayerTimesEntity?,selectedDate: freezed == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,hijriAdjustment: null == hijriAdjustment ? _self.hijriAdjustment : hijriAdjustment // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PrayerTimesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CityEntityCopyWith<$Res>? get selectedCity {
    if (_self.selectedCity == null) {
    return null;
  }

  return $CityEntityCopyWith<$Res>(_self.selectedCity!, (value) {
    return _then(_self.copyWith(selectedCity: value));
  });
}/// Create a copy of PrayerTimesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrayerTimesEntityCopyWith<$Res>? get prayerTimes {
    if (_self.prayerTimes == null) {
    return null;
  }

  return $PrayerTimesEntityCopyWith<$Res>(_self.prayerTimes!, (value) {
    return _then(_self.copyWith(prayerTimes: value));
  });
}
}

// dart format on
