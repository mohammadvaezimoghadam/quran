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

/// Unique identifier for the translation (e.g., 'fa.makarem', 'fas-alimaleki')
 String get id;/// Display name of the translation (e.g., 'مکارم شیرازی')
 String get name;/// Name of the translator
 String get translatorName;/// ISO Language code (e.g., 'fa', 'en')
 String get languageCode;/// The direct API URL to download the JSON from
 String get sourceUrl;/// Whether this translation is currently downloaded and available in Hive
 bool get isDownloaded;/// Whether this is the default pre-loaded translation
 bool get isDefault;
/// Create a copy of TranslationEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationEntityCopyWith<TranslationEntity> get copyWith => _$TranslationEntityCopyWithImpl<TranslationEntity>(this as TranslationEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.translatorName, translatorName) || other.translatorName == translatorName)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.isDownloaded, isDownloaded) || other.isDownloaded == isDownloaded)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,translatorName,languageCode,sourceUrl,isDownloaded,isDefault);

@override
String toString() {
  return 'TranslationEntity(id: $id, name: $name, translatorName: $translatorName, languageCode: $languageCode, sourceUrl: $sourceUrl, isDownloaded: $isDownloaded, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $TranslationEntityCopyWith<$Res>  {
  factory $TranslationEntityCopyWith(TranslationEntity value, $Res Function(TranslationEntity) _then) = _$TranslationEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String translatorName, String languageCode, String sourceUrl, bool isDownloaded, bool isDefault
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? translatorName = null,Object? languageCode = null,Object? sourceUrl = null,Object? isDownloaded = null,Object? isDefault = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,translatorName: null == translatorName ? _self.translatorName : translatorName // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,isDownloaded: null == isDownloaded ? _self.isDownloaded : isDownloaded // ignore: cast_nullable_to_non_nullable
as bool,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String translatorName,  String languageCode,  String sourceUrl,  bool isDownloaded,  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationEntity() when $default != null:
return $default(_that.id,_that.name,_that.translatorName,_that.languageCode,_that.sourceUrl,_that.isDownloaded,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String translatorName,  String languageCode,  String sourceUrl,  bool isDownloaded,  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _TranslationEntity():
return $default(_that.id,_that.name,_that.translatorName,_that.languageCode,_that.sourceUrl,_that.isDownloaded,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String translatorName,  String languageCode,  String sourceUrl,  bool isDownloaded,  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _TranslationEntity() when $default != null:
return $default(_that.id,_that.name,_that.translatorName,_that.languageCode,_that.sourceUrl,_that.isDownloaded,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc


class _TranslationEntity implements TranslationEntity {
  const _TranslationEntity({required this.id, required this.name, required this.translatorName, required this.languageCode, required this.sourceUrl, this.isDownloaded = false, this.isDefault = false});
  

/// Unique identifier for the translation (e.g., 'fa.makarem', 'fas-alimaleki')
@override final  String id;
/// Display name of the translation (e.g., 'مکارم شیرازی')
@override final  String name;
/// Name of the translator
@override final  String translatorName;
/// ISO Language code (e.g., 'fa', 'en')
@override final  String languageCode;
/// The direct API URL to download the JSON from
@override final  String sourceUrl;
/// Whether this translation is currently downloaded and available in Hive
@override@JsonKey() final  bool isDownloaded;
/// Whether this is the default pre-loaded translation
@override@JsonKey() final  bool isDefault;

/// Create a copy of TranslationEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationEntityCopyWith<_TranslationEntity> get copyWith => __$TranslationEntityCopyWithImpl<_TranslationEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.translatorName, translatorName) || other.translatorName == translatorName)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.isDownloaded, isDownloaded) || other.isDownloaded == isDownloaded)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,translatorName,languageCode,sourceUrl,isDownloaded,isDefault);

@override
String toString() {
  return 'TranslationEntity(id: $id, name: $name, translatorName: $translatorName, languageCode: $languageCode, sourceUrl: $sourceUrl, isDownloaded: $isDownloaded, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$TranslationEntityCopyWith<$Res> implements $TranslationEntityCopyWith<$Res> {
  factory _$TranslationEntityCopyWith(_TranslationEntity value, $Res Function(_TranslationEntity) _then) = __$TranslationEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String translatorName, String languageCode, String sourceUrl, bool isDownloaded, bool isDefault
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? translatorName = null,Object? languageCode = null,Object? sourceUrl = null,Object? isDownloaded = null,Object? isDefault = null,}) {
  return _then(_TranslationEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,translatorName: null == translatorName ? _self.translatorName : translatorName // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,isDownloaded: null == isDownloaded ? _self.isDownloaded : isDownloaded // ignore: cast_nullable_to_non_nullable
as bool,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
