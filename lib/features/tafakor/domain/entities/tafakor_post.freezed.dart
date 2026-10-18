// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tafakor_post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TafakorPost {

 int get id; int get topicId; int get authorId; String get authorPhone; String get authorName; String? get authorAvatar; String get content; String? get mediaType; String? get mediaFile; String? get createdAt; String? get updatedAt; Map<String, int> get reactionsSummary; String? get userReaction; int get commentsCount; List<String> get publishedPlatforms;
/// Create a copy of TafakorPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TafakorPostCopyWith<TafakorPost> get copyWith => _$TafakorPostCopyWithImpl<TafakorPost>(this as TafakorPost, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TafakorPost&&(identical(other.id, id) || other.id == id)&&(identical(other.topicId, topicId) || other.topicId == topicId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorPhone, authorPhone) || other.authorPhone == authorPhone)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorAvatar, authorAvatar) || other.authorAvatar == authorAvatar)&&(identical(other.content, content) || other.content == content)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.mediaFile, mediaFile) || other.mediaFile == mediaFile)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.reactionsSummary, reactionsSummary)&&(identical(other.userReaction, userReaction) || other.userReaction == userReaction)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&const DeepCollectionEquality().equals(other.publishedPlatforms, publishedPlatforms));
}


@override
int get hashCode => Object.hash(runtimeType,id,topicId,authorId,authorPhone,authorName,authorAvatar,content,mediaType,mediaFile,createdAt,updatedAt,const DeepCollectionEquality().hash(reactionsSummary),userReaction,commentsCount,const DeepCollectionEquality().hash(publishedPlatforms));

@override
String toString() {
  return 'TafakorPost(id: $id, topicId: $topicId, authorId: $authorId, authorPhone: $authorPhone, authorName: $authorName, authorAvatar: $authorAvatar, content: $content, mediaType: $mediaType, mediaFile: $mediaFile, createdAt: $createdAt, updatedAt: $updatedAt, reactionsSummary: $reactionsSummary, userReaction: $userReaction, commentsCount: $commentsCount, publishedPlatforms: $publishedPlatforms)';
}


}

/// @nodoc
abstract mixin class $TafakorPostCopyWith<$Res>  {
  factory $TafakorPostCopyWith(TafakorPost value, $Res Function(TafakorPost) _then) = _$TafakorPostCopyWithImpl;
@useResult
$Res call({
 int id, int topicId, int authorId, String authorPhone, String authorName, String? authorAvatar, String content, String? mediaType, String? mediaFile, String? createdAt, String? updatedAt, Map<String, int> reactionsSummary, String? userReaction, int commentsCount, List<String> publishedPlatforms
});




}
/// @nodoc
class _$TafakorPostCopyWithImpl<$Res>
    implements $TafakorPostCopyWith<$Res> {
  _$TafakorPostCopyWithImpl(this._self, this._then);

  final TafakorPost _self;
  final $Res Function(TafakorPost) _then;

/// Create a copy of TafakorPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? topicId = null,Object? authorId = null,Object? authorPhone = null,Object? authorName = null,Object? authorAvatar = freezed,Object? content = null,Object? mediaType = freezed,Object? mediaFile = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? reactionsSummary = null,Object? userReaction = freezed,Object? commentsCount = null,Object? publishedPlatforms = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,topicId: null == topicId ? _self.topicId : topicId // ignore: cast_nullable_to_non_nullable
as int,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as int,authorPhone: null == authorPhone ? _self.authorPhone : authorPhone // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorAvatar: freezed == authorAvatar ? _self.authorAvatar : authorAvatar // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String?,mediaFile: freezed == mediaFile ? _self.mediaFile : mediaFile // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,reactionsSummary: null == reactionsSummary ? _self.reactionsSummary : reactionsSummary // ignore: cast_nullable_to_non_nullable
as Map<String, int>,userReaction: freezed == userReaction ? _self.userReaction : userReaction // ignore: cast_nullable_to_non_nullable
as String?,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,publishedPlatforms: null == publishedPlatforms ? _self.publishedPlatforms : publishedPlatforms // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TafakorPost].
extension TafakorPostPatterns on TafakorPost {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TafakorPost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TafakorPost() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TafakorPost value)  $default,){
final _that = this;
switch (_that) {
case _TafakorPost():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TafakorPost value)?  $default,){
final _that = this;
switch (_that) {
case _TafakorPost() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int topicId,  int authorId,  String authorPhone,  String authorName,  String? authorAvatar,  String content,  String? mediaType,  String? mediaFile,  String? createdAt,  String? updatedAt,  Map<String, int> reactionsSummary,  String? userReaction,  int commentsCount,  List<String> publishedPlatforms)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TafakorPost() when $default != null:
return $default(_that.id,_that.topicId,_that.authorId,_that.authorPhone,_that.authorName,_that.authorAvatar,_that.content,_that.mediaType,_that.mediaFile,_that.createdAt,_that.updatedAt,_that.reactionsSummary,_that.userReaction,_that.commentsCount,_that.publishedPlatforms);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int topicId,  int authorId,  String authorPhone,  String authorName,  String? authorAvatar,  String content,  String? mediaType,  String? mediaFile,  String? createdAt,  String? updatedAt,  Map<String, int> reactionsSummary,  String? userReaction,  int commentsCount,  List<String> publishedPlatforms)  $default,) {final _that = this;
switch (_that) {
case _TafakorPost():
return $default(_that.id,_that.topicId,_that.authorId,_that.authorPhone,_that.authorName,_that.authorAvatar,_that.content,_that.mediaType,_that.mediaFile,_that.createdAt,_that.updatedAt,_that.reactionsSummary,_that.userReaction,_that.commentsCount,_that.publishedPlatforms);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int topicId,  int authorId,  String authorPhone,  String authorName,  String? authorAvatar,  String content,  String? mediaType,  String? mediaFile,  String? createdAt,  String? updatedAt,  Map<String, int> reactionsSummary,  String? userReaction,  int commentsCount,  List<String> publishedPlatforms)?  $default,) {final _that = this;
switch (_that) {
case _TafakorPost() when $default != null:
return $default(_that.id,_that.topicId,_that.authorId,_that.authorPhone,_that.authorName,_that.authorAvatar,_that.content,_that.mediaType,_that.mediaFile,_that.createdAt,_that.updatedAt,_that.reactionsSummary,_that.userReaction,_that.commentsCount,_that.publishedPlatforms);case _:
  return null;

}
}

}

/// @nodoc


class _TafakorPost extends TafakorPost {
  const _TafakorPost({required this.id, required this.topicId, required this.authorId, required this.authorPhone, required this.authorName, this.authorAvatar, required this.content, this.mediaType, this.mediaFile, this.createdAt, this.updatedAt, final  Map<String, int> reactionsSummary = const {}, this.userReaction, this.commentsCount = 0, final  List<String> publishedPlatforms = const []}): _reactionsSummary = reactionsSummary,_publishedPlatforms = publishedPlatforms,super._();
  

@override final  int id;
@override final  int topicId;
@override final  int authorId;
@override final  String authorPhone;
@override final  String authorName;
@override final  String? authorAvatar;
@override final  String content;
@override final  String? mediaType;
@override final  String? mediaFile;
@override final  String? createdAt;
@override final  String? updatedAt;
 final  Map<String, int> _reactionsSummary;
@override@JsonKey() Map<String, int> get reactionsSummary {
  if (_reactionsSummary is EqualUnmodifiableMapView) return _reactionsSummary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactionsSummary);
}

@override final  String? userReaction;
@override@JsonKey() final  int commentsCount;
 final  List<String> _publishedPlatforms;
@override@JsonKey() List<String> get publishedPlatforms {
  if (_publishedPlatforms is EqualUnmodifiableListView) return _publishedPlatforms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publishedPlatforms);
}


/// Create a copy of TafakorPost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TafakorPostCopyWith<_TafakorPost> get copyWith => __$TafakorPostCopyWithImpl<_TafakorPost>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TafakorPost&&(identical(other.id, id) || other.id == id)&&(identical(other.topicId, topicId) || other.topicId == topicId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorPhone, authorPhone) || other.authorPhone == authorPhone)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorAvatar, authorAvatar) || other.authorAvatar == authorAvatar)&&(identical(other.content, content) || other.content == content)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.mediaFile, mediaFile) || other.mediaFile == mediaFile)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._reactionsSummary, _reactionsSummary)&&(identical(other.userReaction, userReaction) || other.userReaction == userReaction)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&const DeepCollectionEquality().equals(other._publishedPlatforms, _publishedPlatforms));
}


@override
int get hashCode => Object.hash(runtimeType,id,topicId,authorId,authorPhone,authorName,authorAvatar,content,mediaType,mediaFile,createdAt,updatedAt,const DeepCollectionEquality().hash(_reactionsSummary),userReaction,commentsCount,const DeepCollectionEquality().hash(_publishedPlatforms));

@override
String toString() {
  return 'TafakorPost(id: $id, topicId: $topicId, authorId: $authorId, authorPhone: $authorPhone, authorName: $authorName, authorAvatar: $authorAvatar, content: $content, mediaType: $mediaType, mediaFile: $mediaFile, createdAt: $createdAt, updatedAt: $updatedAt, reactionsSummary: $reactionsSummary, userReaction: $userReaction, commentsCount: $commentsCount, publishedPlatforms: $publishedPlatforms)';
}


}

/// @nodoc
abstract mixin class _$TafakorPostCopyWith<$Res> implements $TafakorPostCopyWith<$Res> {
  factory _$TafakorPostCopyWith(_TafakorPost value, $Res Function(_TafakorPost) _then) = __$TafakorPostCopyWithImpl;
@override @useResult
$Res call({
 int id, int topicId, int authorId, String authorPhone, String authorName, String? authorAvatar, String content, String? mediaType, String? mediaFile, String? createdAt, String? updatedAt, Map<String, int> reactionsSummary, String? userReaction, int commentsCount, List<String> publishedPlatforms
});




}
/// @nodoc
class __$TafakorPostCopyWithImpl<$Res>
    implements _$TafakorPostCopyWith<$Res> {
  __$TafakorPostCopyWithImpl(this._self, this._then);

  final _TafakorPost _self;
  final $Res Function(_TafakorPost) _then;

/// Create a copy of TafakorPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? topicId = null,Object? authorId = null,Object? authorPhone = null,Object? authorName = null,Object? authorAvatar = freezed,Object? content = null,Object? mediaType = freezed,Object? mediaFile = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? reactionsSummary = null,Object? userReaction = freezed,Object? commentsCount = null,Object? publishedPlatforms = null,}) {
  return _then(_TafakorPost(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,topicId: null == topicId ? _self.topicId : topicId // ignore: cast_nullable_to_non_nullable
as int,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as int,authorPhone: null == authorPhone ? _self.authorPhone : authorPhone // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorAvatar: freezed == authorAvatar ? _self.authorAvatar : authorAvatar // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String?,mediaFile: freezed == mediaFile ? _self.mediaFile : mediaFile // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,reactionsSummary: null == reactionsSummary ? _self._reactionsSummary : reactionsSummary // ignore: cast_nullable_to_non_nullable
as Map<String, int>,userReaction: freezed == userReaction ? _self.userReaction : userReaction // ignore: cast_nullable_to_non_nullable
as String?,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,publishedPlatforms: null == publishedPlatforms ? _self._publishedPlatforms : publishedPlatforms // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
