// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translation_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TranslationEntity {

 int get id; String get translationId; int get ayahId; int get ayahNumber; String get text;
/// Create a copy of TranslationEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationEntityCopyWith<TranslationEntity> get copyWith => _$TranslationEntityCopyWithImpl<TranslationEntity>(this as TranslationEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.translationId, translationId) || other.translationId == translationId)&&(identical(other.ayahId, ayahId) || other.ayahId == ayahId)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,id,translationId,ayahId,ayahNumber,text);

@override
String toString() {
  return 'TranslationEntity(id: $id, translationId: $translationId, ayahId: $ayahId, ayahNumber: $ayahNumber, text: $text)';
}


}

/// @nodoc
abstract mixin class $TranslationEntityCopyWith<$Res>  {
  factory $TranslationEntityCopyWith(TranslationEntity value, $Res Function(TranslationEntity) _then) = _$TranslationEntityCopyWithImpl;
@useResult
$Res call({
 int id, String translationId, int ayahId, int ayahNumber, String text
});




}
/// @nodoc
class _$TranslationEntityCopyWithImpl<$Res>
    implements $TranslationEntityCopyWith<$Res> {
  _$TranslationEntityCopyWithImpl(this._self, this._then);

  final TranslationEntity _self;
  final $Res Function(TranslationEntity) _then;

/// Create a copy of TranslationEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? translationId = null,Object? ayahId = null,Object? ayahNumber = null,Object? text = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,translationId: null == translationId ? _self.translationId : translationId // ignore: cast_nullable_to_non_nullable
as String,ayahId: null == ayahId ? _self.ayahId : ayahId // ignore: cast_nullable_to_non_nullable
as int,ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslationEntity].
extension TranslationEntityPatterns on TranslationEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslationEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslationEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslationEntity value)  $default,){
final _that = this;
switch (_that) {
case _TranslationEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslationEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TranslationEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String translationId,  int ayahId,  int ayahNumber,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationEntity() when $default != null:
return $default(_that.id,_that.translationId,_that.ayahId,_that.ayahNumber,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String translationId,  int ayahId,  int ayahNumber,  String text)  $default,) {final _that = this;
switch (_that) {
case _TranslationEntity():
return $default(_that.id,_that.translationId,_that.ayahId,_that.ayahNumber,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String translationId,  int ayahId,  int ayahNumber,  String text)?  $default,) {final _that = this;
switch (_that) {
case _TranslationEntity() when $default != null:
return $default(_that.id,_that.translationId,_that.ayahId,_that.ayahNumber,_that.text);case _:
  return null;

}
}

}

/// @nodoc


class _TranslationEntity implements TranslationEntity {
  const _TranslationEntity({required this.id, required this.translationId, required this.ayahId, required this.ayahNumber, required this.text});
  

@override final  int id;
@override final  String translationId;
@override final  int ayahId;
@override final  int ayahNumber;
@override final  String text;

/// Create a copy of TranslationEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationEntityCopyWith<_TranslationEntity> get copyWith => __$TranslationEntityCopyWithImpl<_TranslationEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.translationId, translationId) || other.translationId == translationId)&&(identical(other.ayahId, ayahId) || other.ayahId == ayahId)&&(identical(other.ayahNumber, ayahNumber) || other.ayahNumber == ayahNumber)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,id,translationId,ayahId,ayahNumber,text);

@override
String toString() {
  return 'TranslationEntity(id: $id, translationId: $translationId, ayahId: $ayahId, ayahNumber: $ayahNumber, text: $text)';
}


}

/// @nodoc
abstract mixin class _$TranslationEntityCopyWith<$Res> implements $TranslationEntityCopyWith<$Res> {
  factory _$TranslationEntityCopyWith(_TranslationEntity value, $Res Function(_TranslationEntity) _then) = __$TranslationEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, String translationId, int ayahId, int ayahNumber, String text
});




}
/// @nodoc
class __$TranslationEntityCopyWithImpl<$Res>
    implements _$TranslationEntityCopyWith<$Res> {
  __$TranslationEntityCopyWithImpl(this._self, this._then);

  final _TranslationEntity _self;
  final $Res Function(_TranslationEntity) _then;

/// Create a copy of TranslationEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? translationId = null,Object? ayahId = null,Object? ayahNumber = null,Object? text = null,}) {
  return _then(_TranslationEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,translationId: null == translationId ? _self.translationId : translationId // ignore: cast_nullable_to_non_nullable
as String,ayahId: null == ayahId ? _self.ayahId : ayahId // ignore: cast_nullable_to_non_nullable
as int,ayahNumber: null == ayahNumber ? _self.ayahNumber : ayahNumber // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
