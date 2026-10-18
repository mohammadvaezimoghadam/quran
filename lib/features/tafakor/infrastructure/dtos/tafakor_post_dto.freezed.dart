// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tafakor_post_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TafakorPostDto {

 int get id;@JsonKey(name: 'topic') int get topicId;@JsonKey(name: 'author') int get authorId;@JsonKey(name: 'author_phone') String get authorPhone;@JsonKey(name: 'author_name') String get authorName;@JsonKey(name: 'author_avatar') String? get authorAvatar; String get content;@JsonKey(name: 'media_type') String? get mediaType;@JsonKey(name: 'media_file') String? get mediaFile;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;@JsonKey(name: 'reactions_summary') Map<String, int> get reactionsSummary;@JsonKey(name: 'user_reaction') String? get userReaction;@JsonKey(name: 'comments_count') int get commentsCount;@JsonKey(name: 'published_platforms') List<String> get publishedPlatforms;
/// Create a copy of TafakorPostDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TafakorPostDtoCopyWith<TafakorPostDto> get copyWith => _$TafakorPostDtoCopyWithImpl<TafakorPostDto>(this as TafakorPostDto, _$identity);

  /// Serializes this TafakorPostDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TafakorPostDto&&(identical(other.id, id) || other.id == id)&&(identical(other.topicId, topicId) || other.topicId == topicId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorPhone, authorPhone) || other.authorPhone == authorPhone)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorAvatar, authorAvatar) || other.authorAvatar == authorAvatar)&&(identical(other.content, content) || other.content == content)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.mediaFile, mediaFile) || other.mediaFile == mediaFile)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.reactionsSummary, reactionsSummary)&&(identical(other.userReaction, userReaction) || other.userReaction == userReaction)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&const DeepCollectionEquality().equals(other.publishedPlatforms, publishedPlatforms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,topicId,authorId,authorPhone,authorName,authorAvatar,content,mediaType,mediaFile,createdAt,updatedAt,const DeepCollectionEquality().hash(reactionsSummary),userReaction,commentsCount,const DeepCollectionEquality().hash(publishedPlatforms));

@override
String toString() {
  return 'TafakorPostDto(id: $id, topicId: $topicId, authorId: $authorId, authorPhone: $authorPhone, authorName: $authorName, authorAvatar: $authorAvatar, content: $content, mediaType: $mediaType, mediaFile: $mediaFile, createdAt: $createdAt, updatedAt: $updatedAt, reactionsSummary: $reactionsSummary, userReaction: $userReaction, commentsCount: $commentsCount, publishedPlatforms: $publishedPlatforms)';
}


}

/// @nodoc
abstract mixin class $TafakorPostDtoCopyWith<$Res>  {
  factory $TafakorPostDtoCopyWith(TafakorPostDto value, $Res Function(TafakorPostDto) _then) = _$TafakorPostDtoCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'topic') int topicId,@JsonKey(name: 'author') int authorId,@JsonKey(name: 'author_phone') String authorPhone,@JsonKey(name: 'author_name') String authorName,@JsonKey(name: 'author_avatar') String? authorAvatar, String content,@JsonKey(name: 'media_type') String? mediaType,@JsonKey(name: 'media_file') String? mediaFile,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt,@JsonKey(name: 'reactions_summary') Map<String, int> reactionsSummary,@JsonKey(name: 'user_reaction') String? userReaction,@JsonKey(name: 'comments_count') int commentsCount,@JsonKey(name: 'published_platforms') List<String> publishedPlatforms
});




}
/// @nodoc
class _$TafakorPostDtoCopyWithImpl<$Res>
    implements $TafakorPostDtoCopyWith<$Res> {
  _$TafakorPostDtoCopyWithImpl(this._self, this._then);

  final TafakorPostDto _self;
  final $Res Function(TafakorPostDto) _then;

/// Create a copy of TafakorPostDto
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


/// Adds pattern-matching-related methods to [TafakorPostDto].
extension TafakorPostDtoPatterns on TafakorPostDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TafakorPostDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TafakorPostDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TafakorPostDto value)  $default,){
final _that = this;
switch (_that) {
case _TafakorPostDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TafakorPostDto value)?  $default,){
final _that = this;
switch (_that) {
case _TafakorPostDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'topic')  int topicId, @JsonKey(name: 'author')  int authorId, @JsonKey(name: 'author_phone')  String authorPhone, @JsonKey(name: 'author_name')  String authorName, @JsonKey(name: 'author_avatar')  String? authorAvatar,  String content, @JsonKey(name: 'media_type')  String? mediaType, @JsonKey(name: 'media_file')  String? mediaFile, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'reactions_summary')  Map<String, int> reactionsSummary, @JsonKey(name: 'user_reaction')  String? userReaction, @JsonKey(name: 'comments_count')  int commentsCount, @JsonKey(name: 'published_platforms')  List<String> publishedPlatforms)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TafakorPostDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'topic')  int topicId, @JsonKey(name: 'author')  int authorId, @JsonKey(name: 'author_phone')  String authorPhone, @JsonKey(name: 'author_name')  String authorName, @JsonKey(name: 'author_avatar')  String? authorAvatar,  String content, @JsonKey(name: 'media_type')  String? mediaType, @JsonKey(name: 'media_file')  String? mediaFile, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'reactions_summary')  Map<String, int> reactionsSummary, @JsonKey(name: 'user_reaction')  String? userReaction, @JsonKey(name: 'comments_count')  int commentsCount, @JsonKey(name: 'published_platforms')  List<String> publishedPlatforms)  $default,) {final _that = this;
switch (_that) {
case _TafakorPostDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'topic')  int topicId, @JsonKey(name: 'author')  int authorId, @JsonKey(name: 'author_phone')  String authorPhone, @JsonKey(name: 'author_name')  String authorName, @JsonKey(name: 'author_avatar')  String? authorAvatar,  String content, @JsonKey(name: 'media_type')  String? mediaType, @JsonKey(name: 'media_file')  String? mediaFile, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'reactions_summary')  Map<String, int> reactionsSummary, @JsonKey(name: 'user_reaction')  String? userReaction, @JsonKey(name: 'comments_count')  int commentsCount, @JsonKey(name: 'published_platforms')  List<String> publishedPlatforms)?  $default,) {final _that = this;
switch (_that) {
case _TafakorPostDto() when $default != null:
return $default(_that.id,_that.topicId,_that.authorId,_that.authorPhone,_that.authorName,_that.authorAvatar,_that.content,_that.mediaType,_that.mediaFile,_that.createdAt,_that.updatedAt,_that.reactionsSummary,_that.userReaction,_that.commentsCount,_that.publishedPlatforms);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TafakorPostDto extends TafakorPostDto {
  const _TafakorPostDto({required this.id, @JsonKey(name: 'topic') required this.topicId, @JsonKey(name: 'author') required this.authorId, @JsonKey(name: 'author_phone') this.authorPhone = '', @JsonKey(name: 'author_name') this.authorName = '', @JsonKey(name: 'author_avatar') this.authorAvatar, this.content = '', @JsonKey(name: 'media_type') this.mediaType, @JsonKey(name: 'media_file') this.mediaFile, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'reactions_summary') final  Map<String, int> reactionsSummary = const {}, @JsonKey(name: 'user_reaction') this.userReaction, @JsonKey(name: 'comments_count') this.commentsCount = 0, @JsonKey(name: 'published_platforms') final  List<String> publishedPlatforms = const []}): _reactionsSummary = reactionsSummary,_publishedPlatforms = publishedPlatforms,super._();
  factory _TafakorPostDto.fromJson(Map<String, dynamic> json) => _$TafakorPostDtoFromJson(json);

@override final  int id;
@override@JsonKey(name: 'topic') final  int topicId;
@override@JsonKey(name: 'author') final  int authorId;
@override@JsonKey(name: 'author_phone') final  String authorPhone;
@override@JsonKey(name: 'author_name') final  String authorName;
@override@JsonKey(name: 'author_avatar') final  String? authorAvatar;
@override@JsonKey() final  String content;
@override@JsonKey(name: 'media_type') final  String? mediaType;
@override@JsonKey(name: 'media_file') final  String? mediaFile;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;
 final  Map<String, int> _reactionsSummary;
@override@JsonKey(name: 'reactions_summary') Map<String, int> get reactionsSummary {
  if (_reactionsSummary is EqualUnmodifiableMapView) return _reactionsSummary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactionsSummary);
}

@override@JsonKey(name: 'user_reaction') final  String? userReaction;
@override@JsonKey(name: 'comments_count') final  int commentsCount;
 final  List<String> _publishedPlatforms;
@override@JsonKey(name: 'published_platforms') List<String> get publishedPlatforms {
  if (_publishedPlatforms is EqualUnmodifiableListView) return _publishedPlatforms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publishedPlatforms);
}


/// Create a copy of TafakorPostDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TafakorPostDtoCopyWith<_TafakorPostDto> get copyWith => __$TafakorPostDtoCopyWithImpl<_TafakorPostDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TafakorPostDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TafakorPostDto&&(identical(other.id, id) || other.id == id)&&(identical(other.topicId, topicId) || other.topicId == topicId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorPhone, authorPhone) || other.authorPhone == authorPhone)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorAvatar, authorAvatar) || other.authorAvatar == authorAvatar)&&(identical(other.content, content) || other.content == content)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.mediaFile, mediaFile) || other.mediaFile == mediaFile)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._reactionsSummary, _reactionsSummary)&&(identical(other.userReaction, userReaction) || other.userReaction == userReaction)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&const DeepCollectionEquality().equals(other._publishedPlatforms, _publishedPlatforms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,topicId,authorId,authorPhone,authorName,authorAvatar,content,mediaType,mediaFile,createdAt,updatedAt,const DeepCollectionEquality().hash(_reactionsSummary),userReaction,commentsCount,const DeepCollectionEquality().hash(_publishedPlatforms));

@override
String toString() {
  return 'TafakorPostDto(id: $id, topicId: $topicId, authorId: $authorId, authorPhone: $authorPhone, authorName: $authorName, authorAvatar: $authorAvatar, content: $content, mediaType: $mediaType, mediaFile: $mediaFile, createdAt: $createdAt, updatedAt: $updatedAt, reactionsSummary: $reactionsSummary, userReaction: $userReaction, commentsCount: $commentsCount, publishedPlatforms: $publishedPlatforms)';
}


}

/// @nodoc
abstract mixin class _$TafakorPostDtoCopyWith<$Res> implements $TafakorPostDtoCopyWith<$Res> {
  factory _$TafakorPostDtoCopyWith(_TafakorPostDto value, $Res Function(_TafakorPostDto) _then) = __$TafakorPostDtoCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'topic') int topicId,@JsonKey(name: 'author') int authorId,@JsonKey(name: 'author_phone') String authorPhone,@JsonKey(name: 'author_name') String authorName,@JsonKey(name: 'author_avatar') String? authorAvatar, String content,@JsonKey(name: 'media_type') String? mediaType,@JsonKey(name: 'media_file') String? mediaFile,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt,@JsonKey(name: 'reactions_summary') Map<String, int> reactionsSummary,@JsonKey(name: 'user_reaction') String? userReaction,@JsonKey(name: 'comments_count') int commentsCount,@JsonKey(name: 'published_platforms') List<String> publishedPlatforms
});




}
/// @nodoc
class __$TafakorPostDtoCopyWithImpl<$Res>
    implements _$TafakorPostDtoCopyWith<$Res> {
  __$TafakorPostDtoCopyWithImpl(this._self, this._then);

  final _TafakorPostDto _self;
  final $Res Function(_TafakorPostDto) _then;

/// Create a copy of TafakorPostDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? topicId = null,Object? authorId = null,Object? authorPhone = null,Object? authorName = null,Object? authorAvatar = freezed,Object? content = null,Object? mediaType = freezed,Object? mediaFile = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? reactionsSummary = null,Object? userReaction = freezed,Object? commentsCount = null,Object? publishedPlatforms = null,}) {
  return _then(_TafakorPostDto(
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
