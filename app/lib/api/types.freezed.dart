// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InitConfig {

 String get dataDir; String get appVersion; bool get proxyEnabled;
/// Create a copy of InitConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InitConfigCopyWith<InitConfig> get copyWith => _$InitConfigCopyWithImpl<InitConfig>(this as InitConfig, _$identity);

  /// Serializes this InitConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InitConfig&&(identical(other.dataDir, dataDir) || other.dataDir == dataDir)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.proxyEnabled, proxyEnabled) || other.proxyEnabled == proxyEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dataDir,appVersion,proxyEnabled);

@override
String toString() {
  return 'InitConfig(dataDir: $dataDir, appVersion: $appVersion, proxyEnabled: $proxyEnabled)';
}


}

/// @nodoc
abstract mixin class $InitConfigCopyWith<$Res>  {
  factory $InitConfigCopyWith(InitConfig value, $Res Function(InitConfig) _then) = _$InitConfigCopyWithImpl;
@useResult
$Res call({
 String dataDir, String appVersion, bool proxyEnabled
});




}
/// @nodoc
class _$InitConfigCopyWithImpl<$Res>
    implements $InitConfigCopyWith<$Res> {
  _$InitConfigCopyWithImpl(this._self, this._then);

  final InitConfig _self;
  final $Res Function(InitConfig) _then;

/// Create a copy of InitConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dataDir = null,Object? appVersion = null,Object? proxyEnabled = null,}) {
  return _then(_self.copyWith(
dataDir: null == dataDir ? _self.dataDir : dataDir // ignore: cast_nullable_to_non_nullable
as String,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,proxyEnabled: null == proxyEnabled ? _self.proxyEnabled : proxyEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [InitConfig].
extension InitConfigPatterns on InitConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InitConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InitConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InitConfig value)  $default,){
final _that = this;
switch (_that) {
case _InitConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InitConfig value)?  $default,){
final _that = this;
switch (_that) {
case _InitConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dataDir,  String appVersion,  bool proxyEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InitConfig() when $default != null:
return $default(_that.dataDir,_that.appVersion,_that.proxyEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dataDir,  String appVersion,  bool proxyEnabled)  $default,) {final _that = this;
switch (_that) {
case _InitConfig():
return $default(_that.dataDir,_that.appVersion,_that.proxyEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dataDir,  String appVersion,  bool proxyEnabled)?  $default,) {final _that = this;
switch (_that) {
case _InitConfig() when $default != null:
return $default(_that.dataDir,_that.appVersion,_that.proxyEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InitConfig implements InitConfig {
  const _InitConfig({required this.dataDir, required this.appVersion, this.proxyEnabled = true});
  factory _InitConfig.fromJson(Map<String, dynamic> json) => _$InitConfigFromJson(json);

@override final  String dataDir;
@override final  String appVersion;
@override@JsonKey() final  bool proxyEnabled;

/// Create a copy of InitConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InitConfigCopyWith<_InitConfig> get copyWith => __$InitConfigCopyWithImpl<_InitConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InitConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InitConfig&&(identical(other.dataDir, dataDir) || other.dataDir == dataDir)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.proxyEnabled, proxyEnabled) || other.proxyEnabled == proxyEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dataDir,appVersion,proxyEnabled);

@override
String toString() {
  return 'InitConfig(dataDir: $dataDir, appVersion: $appVersion, proxyEnabled: $proxyEnabled)';
}


}

/// @nodoc
abstract mixin class _$InitConfigCopyWith<$Res> implements $InitConfigCopyWith<$Res> {
  factory _$InitConfigCopyWith(_InitConfig value, $Res Function(_InitConfig) _then) = __$InitConfigCopyWithImpl;
@override @useResult
$Res call({
 String dataDir, String appVersion, bool proxyEnabled
});




}
/// @nodoc
class __$InitConfigCopyWithImpl<$Res>
    implements _$InitConfigCopyWith<$Res> {
  __$InitConfigCopyWithImpl(this._self, this._then);

  final _InitConfig _self;
  final $Res Function(_InitConfig) _then;

/// Create a copy of InitConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dataDir = null,Object? appVersion = null,Object? proxyEnabled = null,}) {
  return _then(_InitConfig(
dataDir: null == dataDir ? _self.dataDir : dataDir // ignore: cast_nullable_to_non_nullable
as String,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,proxyEnabled: null == proxyEnabled ? _self.proxyEnabled : proxyEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$InitResult {

 String get dbPath; int? get proxyPort; String get coreVersion; String get contractVersion;
/// Create a copy of InitResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InitResultCopyWith<InitResult> get copyWith => _$InitResultCopyWithImpl<InitResult>(this as InitResult, _$identity);

  /// Serializes this InitResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InitResult&&(identical(other.dbPath, dbPath) || other.dbPath == dbPath)&&(identical(other.proxyPort, proxyPort) || other.proxyPort == proxyPort)&&(identical(other.coreVersion, coreVersion) || other.coreVersion == coreVersion)&&(identical(other.contractVersion, contractVersion) || other.contractVersion == contractVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dbPath,proxyPort,coreVersion,contractVersion);

@override
String toString() {
  return 'InitResult(dbPath: $dbPath, proxyPort: $proxyPort, coreVersion: $coreVersion, contractVersion: $contractVersion)';
}


}

/// @nodoc
abstract mixin class $InitResultCopyWith<$Res>  {
  factory $InitResultCopyWith(InitResult value, $Res Function(InitResult) _then) = _$InitResultCopyWithImpl;
@useResult
$Res call({
 String dbPath, int? proxyPort, String coreVersion, String contractVersion
});




}
/// @nodoc
class _$InitResultCopyWithImpl<$Res>
    implements $InitResultCopyWith<$Res> {
  _$InitResultCopyWithImpl(this._self, this._then);

  final InitResult _self;
  final $Res Function(InitResult) _then;

/// Create a copy of InitResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dbPath = null,Object? proxyPort = freezed,Object? coreVersion = null,Object? contractVersion = null,}) {
  return _then(_self.copyWith(
dbPath: null == dbPath ? _self.dbPath : dbPath // ignore: cast_nullable_to_non_nullable
as String,proxyPort: freezed == proxyPort ? _self.proxyPort : proxyPort // ignore: cast_nullable_to_non_nullable
as int?,coreVersion: null == coreVersion ? _self.coreVersion : coreVersion // ignore: cast_nullable_to_non_nullable
as String,contractVersion: null == contractVersion ? _self.contractVersion : contractVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [InitResult].
extension InitResultPatterns on InitResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InitResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InitResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InitResult value)  $default,){
final _that = this;
switch (_that) {
case _InitResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InitResult value)?  $default,){
final _that = this;
switch (_that) {
case _InitResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dbPath,  int? proxyPort,  String coreVersion,  String contractVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InitResult() when $default != null:
return $default(_that.dbPath,_that.proxyPort,_that.coreVersion,_that.contractVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dbPath,  int? proxyPort,  String coreVersion,  String contractVersion)  $default,) {final _that = this;
switch (_that) {
case _InitResult():
return $default(_that.dbPath,_that.proxyPort,_that.coreVersion,_that.contractVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dbPath,  int? proxyPort,  String coreVersion,  String contractVersion)?  $default,) {final _that = this;
switch (_that) {
case _InitResult() when $default != null:
return $default(_that.dbPath,_that.proxyPort,_that.coreVersion,_that.contractVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InitResult implements InitResult {
  const _InitResult({required this.dbPath, this.proxyPort, required this.coreVersion, required this.contractVersion});
  factory _InitResult.fromJson(Map<String, dynamic> json) => _$InitResultFromJson(json);

@override final  String dbPath;
@override final  int? proxyPort;
@override final  String coreVersion;
@override final  String contractVersion;

/// Create a copy of InitResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InitResultCopyWith<_InitResult> get copyWith => __$InitResultCopyWithImpl<_InitResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InitResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InitResult&&(identical(other.dbPath, dbPath) || other.dbPath == dbPath)&&(identical(other.proxyPort, proxyPort) || other.proxyPort == proxyPort)&&(identical(other.coreVersion, coreVersion) || other.coreVersion == coreVersion)&&(identical(other.contractVersion, contractVersion) || other.contractVersion == contractVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dbPath,proxyPort,coreVersion,contractVersion);

@override
String toString() {
  return 'InitResult(dbPath: $dbPath, proxyPort: $proxyPort, coreVersion: $coreVersion, contractVersion: $contractVersion)';
}


}

/// @nodoc
abstract mixin class _$InitResultCopyWith<$Res> implements $InitResultCopyWith<$Res> {
  factory _$InitResultCopyWith(_InitResult value, $Res Function(_InitResult) _then) = __$InitResultCopyWithImpl;
@override @useResult
$Res call({
 String dbPath, int? proxyPort, String coreVersion, String contractVersion
});




}
/// @nodoc
class __$InitResultCopyWithImpl<$Res>
    implements _$InitResultCopyWith<$Res> {
  __$InitResultCopyWithImpl(this._self, this._then);

  final _InitResult _self;
  final $Res Function(_InitResult) _then;

/// Create a copy of InitResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dbPath = null,Object? proxyPort = freezed,Object? coreVersion = null,Object? contractVersion = null,}) {
  return _then(_InitResult(
dbPath: null == dbPath ? _self.dbPath : dbPath // ignore: cast_nullable_to_non_nullable
as String,proxyPort: freezed == proxyPort ? _self.proxyPort : proxyPort // ignore: cast_nullable_to_non_nullable
as int?,coreVersion: null == coreVersion ? _self.coreVersion : coreVersion // ignore: cast_nullable_to_non_nullable
as String,contractVersion: null == contractVersion ? _self.contractVersion : contractVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ContentRef {

 String get source; String get contentId; ContentKind get kind;
/// Create a copy of ContentRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentRefCopyWith<ContentRef> get copyWith => _$ContentRefCopyWithImpl<ContentRef>(this as ContentRef, _$identity);

  /// Serializes this ContentRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentRef&&(identical(other.source, source) || other.source == source)&&(identical(other.contentId, contentId) || other.contentId == contentId)&&(identical(other.kind, kind) || other.kind == kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,source,contentId,kind);

@override
String toString() {
  return 'ContentRef(source: $source, contentId: $contentId, kind: $kind)';
}


}

/// @nodoc
abstract mixin class $ContentRefCopyWith<$Res>  {
  factory $ContentRefCopyWith(ContentRef value, $Res Function(ContentRef) _then) = _$ContentRefCopyWithImpl;
@useResult
$Res call({
 String source, String contentId, ContentKind kind
});




}
/// @nodoc
class _$ContentRefCopyWithImpl<$Res>
    implements $ContentRefCopyWith<$Res> {
  _$ContentRefCopyWithImpl(this._self, this._then);

  final ContentRef _self;
  final $Res Function(ContentRef) _then;

/// Create a copy of ContentRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = null,Object? contentId = null,Object? kind = null,}) {
  return _then(_self.copyWith(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,contentId: null == contentId ? _self.contentId : contentId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ContentKind,
  ));
}

}


/// Adds pattern-matching-related methods to [ContentRef].
extension ContentRefPatterns on ContentRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentRef value)  $default,){
final _that = this;
switch (_that) {
case _ContentRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentRef value)?  $default,){
final _that = this;
switch (_that) {
case _ContentRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String source,  String contentId,  ContentKind kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentRef() when $default != null:
return $default(_that.source,_that.contentId,_that.kind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String source,  String contentId,  ContentKind kind)  $default,) {final _that = this;
switch (_that) {
case _ContentRef():
return $default(_that.source,_that.contentId,_that.kind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String source,  String contentId,  ContentKind kind)?  $default,) {final _that = this;
switch (_that) {
case _ContentRef() when $default != null:
return $default(_that.source,_that.contentId,_that.kind);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentRef implements ContentRef {
  const _ContentRef({required this.source, required this.contentId, required this.kind});
  factory _ContentRef.fromJson(Map<String, dynamic> json) => _$ContentRefFromJson(json);

@override final  String source;
@override final  String contentId;
@override final  ContentKind kind;

/// Create a copy of ContentRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentRefCopyWith<_ContentRef> get copyWith => __$ContentRefCopyWithImpl<_ContentRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentRef&&(identical(other.source, source) || other.source == source)&&(identical(other.contentId, contentId) || other.contentId == contentId)&&(identical(other.kind, kind) || other.kind == kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,source,contentId,kind);

@override
String toString() {
  return 'ContentRef(source: $source, contentId: $contentId, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$ContentRefCopyWith<$Res> implements $ContentRefCopyWith<$Res> {
  factory _$ContentRefCopyWith(_ContentRef value, $Res Function(_ContentRef) _then) = __$ContentRefCopyWithImpl;
@override @useResult
$Res call({
 String source, String contentId, ContentKind kind
});




}
/// @nodoc
class __$ContentRefCopyWithImpl<$Res>
    implements _$ContentRefCopyWith<$Res> {
  __$ContentRefCopyWithImpl(this._self, this._then);

  final _ContentRef _self;
  final $Res Function(_ContentRef) _then;

/// Create a copy of ContentRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = null,Object? contentId = null,Object? kind = null,}) {
  return _then(_ContentRef(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,contentId: null == contentId ? _self.contentId : contentId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ContentKind,
  ));
}


}


/// @nodoc
mixin _$SearchResult {

 ContentRef get content; String get title; int? get year; String? get posterUrl; List<String> get qualityBadges;
/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResultCopyWith<SearchResult> get copyWith => _$SearchResultCopyWithImpl<SearchResult>(this as SearchResult, _$identity);

  /// Serializes this SearchResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResult&&(identical(other.content, content) || other.content == content)&&(identical(other.title, title) || other.title == title)&&(identical(other.year, year) || other.year == year)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&const DeepCollectionEquality().equals(other.qualityBadges, qualityBadges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,title,year,posterUrl,const DeepCollectionEquality().hash(qualityBadges));

@override
String toString() {
  return 'SearchResult(content: $content, title: $title, year: $year, posterUrl: $posterUrl, qualityBadges: $qualityBadges)';
}


}

/// @nodoc
abstract mixin class $SearchResultCopyWith<$Res>  {
  factory $SearchResultCopyWith(SearchResult value, $Res Function(SearchResult) _then) = _$SearchResultCopyWithImpl;
@useResult
$Res call({
 ContentRef content, String title, int? year, String? posterUrl, List<String> qualityBadges
});


$ContentRefCopyWith<$Res> get content;

}
/// @nodoc
class _$SearchResultCopyWithImpl<$Res>
    implements $SearchResultCopyWith<$Res> {
  _$SearchResultCopyWithImpl(this._self, this._then);

  final SearchResult _self;
  final $Res Function(SearchResult) _then;

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,Object? title = null,Object? year = freezed,Object? posterUrl = freezed,Object? qualityBadges = null,}) {
  return _then(_self.copyWith(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as ContentRef,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,qualityBadges: null == qualityBadges ? _self.qualityBadges : qualityBadges // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentRefCopyWith<$Res> get content {
  
  return $ContentRefCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}
}


/// Adds pattern-matching-related methods to [SearchResult].
extension SearchResultPatterns on SearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResult value)  $default,){
final _that = this;
switch (_that) {
case _SearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContentRef content,  String title,  int? year,  String? posterUrl,  List<String> qualityBadges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
return $default(_that.content,_that.title,_that.year,_that.posterUrl,_that.qualityBadges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContentRef content,  String title,  int? year,  String? posterUrl,  List<String> qualityBadges)  $default,) {final _that = this;
switch (_that) {
case _SearchResult():
return $default(_that.content,_that.title,_that.year,_that.posterUrl,_that.qualityBadges);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContentRef content,  String title,  int? year,  String? posterUrl,  List<String> qualityBadges)?  $default,) {final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
return $default(_that.content,_that.title,_that.year,_that.posterUrl,_that.qualityBadges);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchResult implements SearchResult {
  const _SearchResult({required this.content, required this.title, this.year, this.posterUrl, final  List<String> qualityBadges = const []}): _qualityBadges = qualityBadges;
  factory _SearchResult.fromJson(Map<String, dynamic> json) => _$SearchResultFromJson(json);

@override final  ContentRef content;
@override final  String title;
@override final  int? year;
@override final  String? posterUrl;
 final  List<String> _qualityBadges;
@override@JsonKey() List<String> get qualityBadges {
  if (_qualityBadges is EqualUnmodifiableListView) return _qualityBadges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_qualityBadges);
}


/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResultCopyWith<_SearchResult> get copyWith => __$SearchResultCopyWithImpl<_SearchResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResult&&(identical(other.content, content) || other.content == content)&&(identical(other.title, title) || other.title == title)&&(identical(other.year, year) || other.year == year)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&const DeepCollectionEquality().equals(other._qualityBadges, _qualityBadges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,title,year,posterUrl,const DeepCollectionEquality().hash(_qualityBadges));

@override
String toString() {
  return 'SearchResult(content: $content, title: $title, year: $year, posterUrl: $posterUrl, qualityBadges: $qualityBadges)';
}


}

/// @nodoc
abstract mixin class _$SearchResultCopyWith<$Res> implements $SearchResultCopyWith<$Res> {
  factory _$SearchResultCopyWith(_SearchResult value, $Res Function(_SearchResult) _then) = __$SearchResultCopyWithImpl;
@override @useResult
$Res call({
 ContentRef content, String title, int? year, String? posterUrl, List<String> qualityBadges
});


@override $ContentRefCopyWith<$Res> get content;

}
/// @nodoc
class __$SearchResultCopyWithImpl<$Res>
    implements _$SearchResultCopyWith<$Res> {
  __$SearchResultCopyWithImpl(this._self, this._then);

  final _SearchResult _self;
  final $Res Function(_SearchResult) _then;

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,Object? title = null,Object? year = freezed,Object? posterUrl = freezed,Object? qualityBadges = null,}) {
  return _then(_SearchResult(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as ContentRef,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,qualityBadges: null == qualityBadges ? _self._qualityBadges : qualityBadges // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentRefCopyWith<$Res> get content {
  
  return $ContentRefCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}
}


/// @nodoc
mixin _$SearchPage {

 List<SearchResult> get results; bool get hasMore; bool get partial;
/// Create a copy of SearchPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchPageCopyWith<SearchPage> get copyWith => _$SearchPageCopyWithImpl<SearchPage>(this as SearchPage, _$identity);

  /// Serializes this SearchPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchPage&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.partial, partial) || other.partial == partial));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(results),hasMore,partial);

@override
String toString() {
  return 'SearchPage(results: $results, hasMore: $hasMore, partial: $partial)';
}


}

/// @nodoc
abstract mixin class $SearchPageCopyWith<$Res>  {
  factory $SearchPageCopyWith(SearchPage value, $Res Function(SearchPage) _then) = _$SearchPageCopyWithImpl;
@useResult
$Res call({
 List<SearchResult> results, bool hasMore, bool partial
});




}
/// @nodoc
class _$SearchPageCopyWithImpl<$Res>
    implements $SearchPageCopyWith<$Res> {
  _$SearchPageCopyWithImpl(this._self, this._then);

  final SearchPage _self;
  final $Res Function(SearchPage) _then;

/// Create a copy of SearchPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? results = null,Object? hasMore = null,Object? partial = null,}) {
  return _then(_self.copyWith(
results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<SearchResult>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,partial: null == partial ? _self.partial : partial // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchPage].
extension SearchPagePatterns on SearchPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchPage value)  $default,){
final _that = this;
switch (_that) {
case _SearchPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchPage value)?  $default,){
final _that = this;
switch (_that) {
case _SearchPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SearchResult> results,  bool hasMore,  bool partial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchPage() when $default != null:
return $default(_that.results,_that.hasMore,_that.partial);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SearchResult> results,  bool hasMore,  bool partial)  $default,) {final _that = this;
switch (_that) {
case _SearchPage():
return $default(_that.results,_that.hasMore,_that.partial);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SearchResult> results,  bool hasMore,  bool partial)?  $default,) {final _that = this;
switch (_that) {
case _SearchPage() when $default != null:
return $default(_that.results,_that.hasMore,_that.partial);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchPage implements SearchPage {
  const _SearchPage({required final  List<SearchResult> results, this.hasMore = false, this.partial = false}): _results = results;
  factory _SearchPage.fromJson(Map<String, dynamic> json) => _$SearchPageFromJson(json);

 final  List<SearchResult> _results;
@override List<SearchResult> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  bool partial;

/// Create a copy of SearchPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchPageCopyWith<_SearchPage> get copyWith => __$SearchPageCopyWithImpl<_SearchPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchPage&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.partial, partial) || other.partial == partial));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results),hasMore,partial);

@override
String toString() {
  return 'SearchPage(results: $results, hasMore: $hasMore, partial: $partial)';
}


}

/// @nodoc
abstract mixin class _$SearchPageCopyWith<$Res> implements $SearchPageCopyWith<$Res> {
  factory _$SearchPageCopyWith(_SearchPage value, $Res Function(_SearchPage) _then) = __$SearchPageCopyWithImpl;
@override @useResult
$Res call({
 List<SearchResult> results, bool hasMore, bool partial
});




}
/// @nodoc
class __$SearchPageCopyWithImpl<$Res>
    implements _$SearchPageCopyWith<$Res> {
  __$SearchPageCopyWithImpl(this._self, this._then);

  final _SearchPage _self;
  final $Res Function(_SearchPage) _then;

/// Create a copy of SearchPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? results = null,Object? hasMore = null,Object? partial = null,}) {
  return _then(_SearchPage(
results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<SearchResult>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,partial: null == partial ? _self.partial : partial // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Episode {

 ContentRef get content; int get season; int get episode; String get title; String? get description; String? get thumbnailUrl; int? get durationSeconds;
/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EpisodeCopyWith<Episode> get copyWith => _$EpisodeCopyWithImpl<Episode>(this as Episode, _$identity);

  /// Serializes this Episode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Episode&&(identical(other.content, content) || other.content == content)&&(identical(other.season, season) || other.season == season)&&(identical(other.episode, episode) || other.episode == episode)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,season,episode,title,description,thumbnailUrl,durationSeconds);

@override
String toString() {
  return 'Episode(content: $content, season: $season, episode: $episode, title: $title, description: $description, thumbnailUrl: $thumbnailUrl, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class $EpisodeCopyWith<$Res>  {
  factory $EpisodeCopyWith(Episode value, $Res Function(Episode) _then) = _$EpisodeCopyWithImpl;
@useResult
$Res call({
 ContentRef content, int season, int episode, String title, String? description, String? thumbnailUrl, int? durationSeconds
});


$ContentRefCopyWith<$Res> get content;

}
/// @nodoc
class _$EpisodeCopyWithImpl<$Res>
    implements $EpisodeCopyWith<$Res> {
  _$EpisodeCopyWithImpl(this._self, this._then);

  final Episode _self;
  final $Res Function(Episode) _then;

/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,Object? season = null,Object? episode = null,Object? title = null,Object? description = freezed,Object? thumbnailUrl = freezed,Object? durationSeconds = freezed,}) {
  return _then(_self.copyWith(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as ContentRef,season: null == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as int,episode: null == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentRefCopyWith<$Res> get content {
  
  return $ContentRefCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}
}


/// Adds pattern-matching-related methods to [Episode].
extension EpisodePatterns on Episode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Episode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Episode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Episode value)  $default,){
final _that = this;
switch (_that) {
case _Episode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Episode value)?  $default,){
final _that = this;
switch (_that) {
case _Episode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContentRef content,  int season,  int episode,  String title,  String? description,  String? thumbnailUrl,  int? durationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Episode() when $default != null:
return $default(_that.content,_that.season,_that.episode,_that.title,_that.description,_that.thumbnailUrl,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContentRef content,  int season,  int episode,  String title,  String? description,  String? thumbnailUrl,  int? durationSeconds)  $default,) {final _that = this;
switch (_that) {
case _Episode():
return $default(_that.content,_that.season,_that.episode,_that.title,_that.description,_that.thumbnailUrl,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContentRef content,  int season,  int episode,  String title,  String? description,  String? thumbnailUrl,  int? durationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _Episode() when $default != null:
return $default(_that.content,_that.season,_that.episode,_that.title,_that.description,_that.thumbnailUrl,_that.durationSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Episode implements Episode {
  const _Episode({required this.content, required this.season, required this.episode, required this.title, this.description, this.thumbnailUrl, this.durationSeconds});
  factory _Episode.fromJson(Map<String, dynamic> json) => _$EpisodeFromJson(json);

@override final  ContentRef content;
@override final  int season;
@override final  int episode;
@override final  String title;
@override final  String? description;
@override final  String? thumbnailUrl;
@override final  int? durationSeconds;

/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EpisodeCopyWith<_Episode> get copyWith => __$EpisodeCopyWithImpl<_Episode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EpisodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Episode&&(identical(other.content, content) || other.content == content)&&(identical(other.season, season) || other.season == season)&&(identical(other.episode, episode) || other.episode == episode)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,season,episode,title,description,thumbnailUrl,durationSeconds);

@override
String toString() {
  return 'Episode(content: $content, season: $season, episode: $episode, title: $title, description: $description, thumbnailUrl: $thumbnailUrl, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class _$EpisodeCopyWith<$Res> implements $EpisodeCopyWith<$Res> {
  factory _$EpisodeCopyWith(_Episode value, $Res Function(_Episode) _then) = __$EpisodeCopyWithImpl;
@override @useResult
$Res call({
 ContentRef content, int season, int episode, String title, String? description, String? thumbnailUrl, int? durationSeconds
});


@override $ContentRefCopyWith<$Res> get content;

}
/// @nodoc
class __$EpisodeCopyWithImpl<$Res>
    implements _$EpisodeCopyWith<$Res> {
  __$EpisodeCopyWithImpl(this._self, this._then);

  final _Episode _self;
  final $Res Function(_Episode) _then;

/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,Object? season = null,Object? episode = null,Object? title = null,Object? description = freezed,Object? thumbnailUrl = freezed,Object? durationSeconds = freezed,}) {
  return _then(_Episode(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as ContentRef,season: null == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as int,episode: null == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentRefCopyWith<$Res> get content {
  
  return $ContentRefCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}
}


/// @nodoc
mixin _$Details {

 ContentRef get content; String get title; String? get description; int? get year; String? get posterUrl; String? get backdropUrl; String? get rating; List<String>? get genres; int? get durationSeconds; List<Episode> get episodes;
/// Create a copy of Details
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetailsCopyWith<Details> get copyWith => _$DetailsCopyWithImpl<Details>(this as Details, _$identity);

  /// Serializes this Details to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Details&&(identical(other.content, content) || other.content == content)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.year, year) || other.year == year)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.backdropUrl, backdropUrl) || other.backdropUrl == backdropUrl)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&const DeepCollectionEquality().equals(other.episodes, episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,title,description,year,posterUrl,backdropUrl,rating,const DeepCollectionEquality().hash(genres),durationSeconds,const DeepCollectionEquality().hash(episodes));

@override
String toString() {
  return 'Details(content: $content, title: $title, description: $description, year: $year, posterUrl: $posterUrl, backdropUrl: $backdropUrl, rating: $rating, genres: $genres, durationSeconds: $durationSeconds, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class $DetailsCopyWith<$Res>  {
  factory $DetailsCopyWith(Details value, $Res Function(Details) _then) = _$DetailsCopyWithImpl;
@useResult
$Res call({
 ContentRef content, String title, String? description, int? year, String? posterUrl, String? backdropUrl, String? rating, List<String>? genres, int? durationSeconds, List<Episode> episodes
});


$ContentRefCopyWith<$Res> get content;

}
/// @nodoc
class _$DetailsCopyWithImpl<$Res>
    implements $DetailsCopyWith<$Res> {
  _$DetailsCopyWithImpl(this._self, this._then);

  final Details _self;
  final $Res Function(Details) _then;

/// Create a copy of Details
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,Object? title = null,Object? description = freezed,Object? year = freezed,Object? posterUrl = freezed,Object? backdropUrl = freezed,Object? rating = freezed,Object? genres = freezed,Object? durationSeconds = freezed,Object? episodes = null,}) {
  return _then(_self.copyWith(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as ContentRef,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,backdropUrl: freezed == backdropUrl ? _self.backdropUrl : backdropUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as String?,genres: freezed == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,episodes: null == episodes ? _self.episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<Episode>,
  ));
}
/// Create a copy of Details
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentRefCopyWith<$Res> get content {
  
  return $ContentRefCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}
}


/// Adds pattern-matching-related methods to [Details].
extension DetailsPatterns on Details {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Details value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Details() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Details value)  $default,){
final _that = this;
switch (_that) {
case _Details():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Details value)?  $default,){
final _that = this;
switch (_that) {
case _Details() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContentRef content,  String title,  String? description,  int? year,  String? posterUrl,  String? backdropUrl,  String? rating,  List<String>? genres,  int? durationSeconds,  List<Episode> episodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Details() when $default != null:
return $default(_that.content,_that.title,_that.description,_that.year,_that.posterUrl,_that.backdropUrl,_that.rating,_that.genres,_that.durationSeconds,_that.episodes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContentRef content,  String title,  String? description,  int? year,  String? posterUrl,  String? backdropUrl,  String? rating,  List<String>? genres,  int? durationSeconds,  List<Episode> episodes)  $default,) {final _that = this;
switch (_that) {
case _Details():
return $default(_that.content,_that.title,_that.description,_that.year,_that.posterUrl,_that.backdropUrl,_that.rating,_that.genres,_that.durationSeconds,_that.episodes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContentRef content,  String title,  String? description,  int? year,  String? posterUrl,  String? backdropUrl,  String? rating,  List<String>? genres,  int? durationSeconds,  List<Episode> episodes)?  $default,) {final _that = this;
switch (_that) {
case _Details() when $default != null:
return $default(_that.content,_that.title,_that.description,_that.year,_that.posterUrl,_that.backdropUrl,_that.rating,_that.genres,_that.durationSeconds,_that.episodes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Details implements Details {
  const _Details({required this.content, required this.title, this.description, this.year, this.posterUrl, this.backdropUrl, this.rating, final  List<String>? genres, this.durationSeconds, final  List<Episode> episodes = const []}): _genres = genres,_episodes = episodes;
  factory _Details.fromJson(Map<String, dynamic> json) => _$DetailsFromJson(json);

@override final  ContentRef content;
@override final  String title;
@override final  String? description;
@override final  int? year;
@override final  String? posterUrl;
@override final  String? backdropUrl;
@override final  String? rating;
 final  List<String>? _genres;
@override List<String>? get genres {
  final value = _genres;
  if (value == null) return null;
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int? durationSeconds;
 final  List<Episode> _episodes;
@override@JsonKey() List<Episode> get episodes {
  if (_episodes is EqualUnmodifiableListView) return _episodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_episodes);
}


/// Create a copy of Details
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetailsCopyWith<_Details> get copyWith => __$DetailsCopyWithImpl<_Details>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Details&&(identical(other.content, content) || other.content == content)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.year, year) || other.year == year)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.backdropUrl, backdropUrl) || other.backdropUrl == backdropUrl)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&const DeepCollectionEquality().equals(other._episodes, _episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,title,description,year,posterUrl,backdropUrl,rating,const DeepCollectionEquality().hash(_genres),durationSeconds,const DeepCollectionEquality().hash(_episodes));

@override
String toString() {
  return 'Details(content: $content, title: $title, description: $description, year: $year, posterUrl: $posterUrl, backdropUrl: $backdropUrl, rating: $rating, genres: $genres, durationSeconds: $durationSeconds, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class _$DetailsCopyWith<$Res> implements $DetailsCopyWith<$Res> {
  factory _$DetailsCopyWith(_Details value, $Res Function(_Details) _then) = __$DetailsCopyWithImpl;
@override @useResult
$Res call({
 ContentRef content, String title, String? description, int? year, String? posterUrl, String? backdropUrl, String? rating, List<String>? genres, int? durationSeconds, List<Episode> episodes
});


@override $ContentRefCopyWith<$Res> get content;

}
/// @nodoc
class __$DetailsCopyWithImpl<$Res>
    implements _$DetailsCopyWith<$Res> {
  __$DetailsCopyWithImpl(this._self, this._then);

  final _Details _self;
  final $Res Function(_Details) _then;

/// Create a copy of Details
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,Object? title = null,Object? description = freezed,Object? year = freezed,Object? posterUrl = freezed,Object? backdropUrl = freezed,Object? rating = freezed,Object? genres = freezed,Object? durationSeconds = freezed,Object? episodes = null,}) {
  return _then(_Details(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as ContentRef,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,backdropUrl: freezed == backdropUrl ? _self.backdropUrl : backdropUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as String?,genres: freezed == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,episodes: null == episodes ? _self._episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<Episode>,
  ));
}

/// Create a copy of Details
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentRefCopyWith<$Res> get content {
  
  return $ContentRefCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}
}


/// @nodoc
mixin _$Variant {

 String get id; String get label; int? get width; int? get height; int? get bitrateKbps;
/// Create a copy of Variant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VariantCopyWith<Variant> get copyWith => _$VariantCopyWithImpl<Variant>(this as Variant, _$identity);

  /// Serializes this Variant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Variant&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.bitrateKbps, bitrateKbps) || other.bitrateKbps == bitrateKbps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,width,height,bitrateKbps);

@override
String toString() {
  return 'Variant(id: $id, label: $label, width: $width, height: $height, bitrateKbps: $bitrateKbps)';
}


}

/// @nodoc
abstract mixin class $VariantCopyWith<$Res>  {
  factory $VariantCopyWith(Variant value, $Res Function(Variant) _then) = _$VariantCopyWithImpl;
@useResult
$Res call({
 String id, String label, int? width, int? height, int? bitrateKbps
});




}
/// @nodoc
class _$VariantCopyWithImpl<$Res>
    implements $VariantCopyWith<$Res> {
  _$VariantCopyWithImpl(this._self, this._then);

  final Variant _self;
  final $Res Function(Variant) _then;

/// Create a copy of Variant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? width = freezed,Object? height = freezed,Object? bitrateKbps = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,bitrateKbps: freezed == bitrateKbps ? _self.bitrateKbps : bitrateKbps // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Variant].
extension VariantPatterns on Variant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Variant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Variant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Variant value)  $default,){
final _that = this;
switch (_that) {
case _Variant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Variant value)?  $default,){
final _that = this;
switch (_that) {
case _Variant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  int? width,  int? height,  int? bitrateKbps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Variant() when $default != null:
return $default(_that.id,_that.label,_that.width,_that.height,_that.bitrateKbps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  int? width,  int? height,  int? bitrateKbps)  $default,) {final _that = this;
switch (_that) {
case _Variant():
return $default(_that.id,_that.label,_that.width,_that.height,_that.bitrateKbps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  int? width,  int? height,  int? bitrateKbps)?  $default,) {final _that = this;
switch (_that) {
case _Variant() when $default != null:
return $default(_that.id,_that.label,_that.width,_that.height,_that.bitrateKbps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Variant implements Variant {
  const _Variant({required this.id, required this.label, this.width, this.height, this.bitrateKbps});
  factory _Variant.fromJson(Map<String, dynamic> json) => _$VariantFromJson(json);

@override final  String id;
@override final  String label;
@override final  int? width;
@override final  int? height;
@override final  int? bitrateKbps;

/// Create a copy of Variant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VariantCopyWith<_Variant> get copyWith => __$VariantCopyWithImpl<_Variant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VariantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Variant&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.bitrateKbps, bitrateKbps) || other.bitrateKbps == bitrateKbps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,width,height,bitrateKbps);

@override
String toString() {
  return 'Variant(id: $id, label: $label, width: $width, height: $height, bitrateKbps: $bitrateKbps)';
}


}

/// @nodoc
abstract mixin class _$VariantCopyWith<$Res> implements $VariantCopyWith<$Res> {
  factory _$VariantCopyWith(_Variant value, $Res Function(_Variant) _then) = __$VariantCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, int? width, int? height, int? bitrateKbps
});




}
/// @nodoc
class __$VariantCopyWithImpl<$Res>
    implements _$VariantCopyWith<$Res> {
  __$VariantCopyWithImpl(this._self, this._then);

  final _Variant _self;
  final $Res Function(_Variant) _then;

/// Create a copy of Variant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? width = freezed,Object? height = freezed,Object? bitrateKbps = freezed,}) {
  return _then(_Variant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,bitrateKbps: freezed == bitrateKbps ? _self.bitrateKbps : bitrateKbps // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ResolvedStream {

 String get url; Map<String, String> get headers; StreamKind get kind; List<Variant> get variants; String? get selectedVariant; String? get filenameHint; int? get sizeBytes;
/// Create a copy of ResolvedStream
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedStreamCopyWith<ResolvedStream> get copyWith => _$ResolvedStreamCopyWithImpl<ResolvedStream>(this as ResolvedStream, _$identity);

  /// Serializes this ResolvedStream to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedStream&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.headers, headers)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.variants, variants)&&(identical(other.selectedVariant, selectedVariant) || other.selectedVariant == selectedVariant)&&(identical(other.filenameHint, filenameHint) || other.filenameHint == filenameHint)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,const DeepCollectionEquality().hash(headers),kind,const DeepCollectionEquality().hash(variants),selectedVariant,filenameHint,sizeBytes);

@override
String toString() {
  return 'ResolvedStream(url: $url, headers: $headers, kind: $kind, variants: $variants, selectedVariant: $selectedVariant, filenameHint: $filenameHint, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class $ResolvedStreamCopyWith<$Res>  {
  factory $ResolvedStreamCopyWith(ResolvedStream value, $Res Function(ResolvedStream) _then) = _$ResolvedStreamCopyWithImpl;
@useResult
$Res call({
 String url, Map<String, String> headers, StreamKind kind, List<Variant> variants, String? selectedVariant, String? filenameHint, int? sizeBytes
});




}
/// @nodoc
class _$ResolvedStreamCopyWithImpl<$Res>
    implements $ResolvedStreamCopyWith<$Res> {
  _$ResolvedStreamCopyWithImpl(this._self, this._then);

  final ResolvedStream _self;
  final $Res Function(ResolvedStream) _then;

/// Create a copy of ResolvedStream
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? headers = null,Object? kind = null,Object? variants = null,Object? selectedVariant = freezed,Object? filenameHint = freezed,Object? sizeBytes = freezed,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as StreamKind,variants: null == variants ? _self.variants : variants // ignore: cast_nullable_to_non_nullable
as List<Variant>,selectedVariant: freezed == selectedVariant ? _self.selectedVariant : selectedVariant // ignore: cast_nullable_to_non_nullable
as String?,filenameHint: freezed == filenameHint ? _self.filenameHint : filenameHint // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolvedStream].
extension ResolvedStreamPatterns on ResolvedStream {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolvedStream value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolvedStream() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolvedStream value)  $default,){
final _that = this;
switch (_that) {
case _ResolvedStream():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolvedStream value)?  $default,){
final _that = this;
switch (_that) {
case _ResolvedStream() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  Map<String, String> headers,  StreamKind kind,  List<Variant> variants,  String? selectedVariant,  String? filenameHint,  int? sizeBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedStream() when $default != null:
return $default(_that.url,_that.headers,_that.kind,_that.variants,_that.selectedVariant,_that.filenameHint,_that.sizeBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  Map<String, String> headers,  StreamKind kind,  List<Variant> variants,  String? selectedVariant,  String? filenameHint,  int? sizeBytes)  $default,) {final _that = this;
switch (_that) {
case _ResolvedStream():
return $default(_that.url,_that.headers,_that.kind,_that.variants,_that.selectedVariant,_that.filenameHint,_that.sizeBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  Map<String, String> headers,  StreamKind kind,  List<Variant> variants,  String? selectedVariant,  String? filenameHint,  int? sizeBytes)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedStream() when $default != null:
return $default(_that.url,_that.headers,_that.kind,_that.variants,_that.selectedVariant,_that.filenameHint,_that.sizeBytes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResolvedStream implements ResolvedStream {
  const _ResolvedStream({required this.url, final  Map<String, String> headers = const {}, required this.kind, final  List<Variant> variants = const [], this.selectedVariant, this.filenameHint, this.sizeBytes}): _headers = headers,_variants = variants;
  factory _ResolvedStream.fromJson(Map<String, dynamic> json) => _$ResolvedStreamFromJson(json);

@override final  String url;
 final  Map<String, String> _headers;
@override@JsonKey() Map<String, String> get headers {
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_headers);
}

@override final  StreamKind kind;
 final  List<Variant> _variants;
@override@JsonKey() List<Variant> get variants {
  if (_variants is EqualUnmodifiableListView) return _variants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_variants);
}

@override final  String? selectedVariant;
@override final  String? filenameHint;
@override final  int? sizeBytes;

/// Create a copy of ResolvedStream
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedStreamCopyWith<_ResolvedStream> get copyWith => __$ResolvedStreamCopyWithImpl<_ResolvedStream>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResolvedStreamToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedStream&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._headers, _headers)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other._variants, _variants)&&(identical(other.selectedVariant, selectedVariant) || other.selectedVariant == selectedVariant)&&(identical(other.filenameHint, filenameHint) || other.filenameHint == filenameHint)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,const DeepCollectionEquality().hash(_headers),kind,const DeepCollectionEquality().hash(_variants),selectedVariant,filenameHint,sizeBytes);

@override
String toString() {
  return 'ResolvedStream(url: $url, headers: $headers, kind: $kind, variants: $variants, selectedVariant: $selectedVariant, filenameHint: $filenameHint, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class _$ResolvedStreamCopyWith<$Res> implements $ResolvedStreamCopyWith<$Res> {
  factory _$ResolvedStreamCopyWith(_ResolvedStream value, $Res Function(_ResolvedStream) _then) = __$ResolvedStreamCopyWithImpl;
@override @useResult
$Res call({
 String url, Map<String, String> headers, StreamKind kind, List<Variant> variants, String? selectedVariant, String? filenameHint, int? sizeBytes
});




}
/// @nodoc
class __$ResolvedStreamCopyWithImpl<$Res>
    implements _$ResolvedStreamCopyWith<$Res> {
  __$ResolvedStreamCopyWithImpl(this._self, this._then);

  final _ResolvedStream _self;
  final $Res Function(_ResolvedStream) _then;

/// Create a copy of ResolvedStream
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? headers = null,Object? kind = null,Object? variants = null,Object? selectedVariant = freezed,Object? filenameHint = freezed,Object? sizeBytes = freezed,}) {
  return _then(_ResolvedStream(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as StreamKind,variants: null == variants ? _self._variants : variants // ignore: cast_nullable_to_non_nullable
as List<Variant>,selectedVariant: freezed == selectedVariant ? _self.selectedVariant : selectedVariant // ignore: cast_nullable_to_non_nullable
as String?,filenameHint: freezed == filenameHint ? _self.filenameHint : filenameHint // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$SourceInfo {

 String get id; String get name; bool get enabled; SourceStatus get status;
/// Create a copy of SourceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SourceInfoCopyWith<SourceInfo> get copyWith => _$SourceInfoCopyWithImpl<SourceInfo>(this as SourceInfo, _$identity);

  /// Serializes this SourceInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SourceInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,enabled,status);

@override
String toString() {
  return 'SourceInfo(id: $id, name: $name, enabled: $enabled, status: $status)';
}


}

/// @nodoc
abstract mixin class $SourceInfoCopyWith<$Res>  {
  factory $SourceInfoCopyWith(SourceInfo value, $Res Function(SourceInfo) _then) = _$SourceInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool enabled, SourceStatus status
});




}
/// @nodoc
class _$SourceInfoCopyWithImpl<$Res>
    implements $SourceInfoCopyWith<$Res> {
  _$SourceInfoCopyWithImpl(this._self, this._then);

  final SourceInfo _self;
  final $Res Function(SourceInfo) _then;

/// Create a copy of SourceInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? enabled = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SourceStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [SourceInfo].
extension SourceInfoPatterns on SourceInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SourceInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SourceInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SourceInfo value)  $default,){
final _that = this;
switch (_that) {
case _SourceInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SourceInfo value)?  $default,){
final _that = this;
switch (_that) {
case _SourceInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  bool enabled,  SourceStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SourceInfo() when $default != null:
return $default(_that.id,_that.name,_that.enabled,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  bool enabled,  SourceStatus status)  $default,) {final _that = this;
switch (_that) {
case _SourceInfo():
return $default(_that.id,_that.name,_that.enabled,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  bool enabled,  SourceStatus status)?  $default,) {final _that = this;
switch (_that) {
case _SourceInfo() when $default != null:
return $default(_that.id,_that.name,_that.enabled,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SourceInfo implements SourceInfo {
  const _SourceInfo({required this.id, required this.name, required this.enabled, this.status = SourceStatus.healthy});
  factory _SourceInfo.fromJson(Map<String, dynamic> json) => _$SourceInfoFromJson(json);

@override final  String id;
@override final  String name;
@override final  bool enabled;
@override@JsonKey() final  SourceStatus status;

/// Create a copy of SourceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SourceInfoCopyWith<_SourceInfo> get copyWith => __$SourceInfoCopyWithImpl<_SourceInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SourceInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SourceInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,enabled,status);

@override
String toString() {
  return 'SourceInfo(id: $id, name: $name, enabled: $enabled, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SourceInfoCopyWith<$Res> implements $SourceInfoCopyWith<$Res> {
  factory _$SourceInfoCopyWith(_SourceInfo value, $Res Function(_SourceInfo) _then) = __$SourceInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool enabled, SourceStatus status
});




}
/// @nodoc
class __$SourceInfoCopyWithImpl<$Res>
    implements _$SourceInfoCopyWith<$Res> {
  __$SourceInfoCopyWithImpl(this._self, this._then);

  final _SourceInfo _self;
  final $Res Function(_SourceInfo) _then;

/// Create a copy of SourceInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? enabled = null,Object? status = null,}) {
  return _then(_SourceInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SourceStatus,
  ));
}


}


/// @nodoc
mixin _$DownloadJob {

 String get id; String get title; String? get variant; JobKind get kind; String get destPath; JobStatus get status; int get bytesDone; int? get totalBytes; int get segmentsDone; int? get totalSegments; String? get errorMsg; int get createdAt;
/// Create a copy of DownloadJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadJobCopyWith<DownloadJob> get copyWith => _$DownloadJobCopyWithImpl<DownloadJob>(this as DownloadJob, _$identity);

  /// Serializes this DownloadJob to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadJob&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.destPath, destPath) || other.destPath == destPath)&&(identical(other.status, status) || other.status == status)&&(identical(other.bytesDone, bytesDone) || other.bytesDone == bytesDone)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.segmentsDone, segmentsDone) || other.segmentsDone == segmentsDone)&&(identical(other.totalSegments, totalSegments) || other.totalSegments == totalSegments)&&(identical(other.errorMsg, errorMsg) || other.errorMsg == errorMsg)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,variant,kind,destPath,status,bytesDone,totalBytes,segmentsDone,totalSegments,errorMsg,createdAt);

@override
String toString() {
  return 'DownloadJob(id: $id, title: $title, variant: $variant, kind: $kind, destPath: $destPath, status: $status, bytesDone: $bytesDone, totalBytes: $totalBytes, segmentsDone: $segmentsDone, totalSegments: $totalSegments, errorMsg: $errorMsg, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DownloadJobCopyWith<$Res>  {
  factory $DownloadJobCopyWith(DownloadJob value, $Res Function(DownloadJob) _then) = _$DownloadJobCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? variant, JobKind kind, String destPath, JobStatus status, int bytesDone, int? totalBytes, int segmentsDone, int? totalSegments, String? errorMsg, int createdAt
});




}
/// @nodoc
class _$DownloadJobCopyWithImpl<$Res>
    implements $DownloadJobCopyWith<$Res> {
  _$DownloadJobCopyWithImpl(this._self, this._then);

  final DownloadJob _self;
  final $Res Function(DownloadJob) _then;

/// Create a copy of DownloadJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? variant = freezed,Object? kind = null,Object? destPath = null,Object? status = null,Object? bytesDone = null,Object? totalBytes = freezed,Object? segmentsDone = null,Object? totalSegments = freezed,Object? errorMsg = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as JobKind,destPath: null == destPath ? _self.destPath : destPath // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,bytesDone: null == bytesDone ? _self.bytesDone : bytesDone // ignore: cast_nullable_to_non_nullable
as int,totalBytes: freezed == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int?,segmentsDone: null == segmentsDone ? _self.segmentsDone : segmentsDone // ignore: cast_nullable_to_non_nullable
as int,totalSegments: freezed == totalSegments ? _self.totalSegments : totalSegments // ignore: cast_nullable_to_non_nullable
as int?,errorMsg: freezed == errorMsg ? _self.errorMsg : errorMsg // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DownloadJob].
extension DownloadJobPatterns on DownloadJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadJob value)  $default,){
final _that = this;
switch (_that) {
case _DownloadJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadJob value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? variant,  JobKind kind,  String destPath,  JobStatus status,  int bytesDone,  int? totalBytes,  int segmentsDone,  int? totalSegments,  String? errorMsg,  int createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadJob() when $default != null:
return $default(_that.id,_that.title,_that.variant,_that.kind,_that.destPath,_that.status,_that.bytesDone,_that.totalBytes,_that.segmentsDone,_that.totalSegments,_that.errorMsg,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? variant,  JobKind kind,  String destPath,  JobStatus status,  int bytesDone,  int? totalBytes,  int segmentsDone,  int? totalSegments,  String? errorMsg,  int createdAt)  $default,) {final _that = this;
switch (_that) {
case _DownloadJob():
return $default(_that.id,_that.title,_that.variant,_that.kind,_that.destPath,_that.status,_that.bytesDone,_that.totalBytes,_that.segmentsDone,_that.totalSegments,_that.errorMsg,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? variant,  JobKind kind,  String destPath,  JobStatus status,  int bytesDone,  int? totalBytes,  int segmentsDone,  int? totalSegments,  String? errorMsg,  int createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DownloadJob() when $default != null:
return $default(_that.id,_that.title,_that.variant,_that.kind,_that.destPath,_that.status,_that.bytesDone,_that.totalBytes,_that.segmentsDone,_that.totalSegments,_that.errorMsg,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DownloadJob implements DownloadJob {
  const _DownloadJob({required this.id, required this.title, this.variant, required this.kind, required this.destPath, required this.status, this.bytesDone = 0, this.totalBytes, this.segmentsDone = 0, this.totalSegments, this.errorMsg, required this.createdAt});
  factory _DownloadJob.fromJson(Map<String, dynamic> json) => _$DownloadJobFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? variant;
@override final  JobKind kind;
@override final  String destPath;
@override final  JobStatus status;
@override@JsonKey() final  int bytesDone;
@override final  int? totalBytes;
@override@JsonKey() final  int segmentsDone;
@override final  int? totalSegments;
@override final  String? errorMsg;
@override final  int createdAt;

/// Create a copy of DownloadJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadJobCopyWith<_DownloadJob> get copyWith => __$DownloadJobCopyWithImpl<_DownloadJob>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DownloadJobToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadJob&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.destPath, destPath) || other.destPath == destPath)&&(identical(other.status, status) || other.status == status)&&(identical(other.bytesDone, bytesDone) || other.bytesDone == bytesDone)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.segmentsDone, segmentsDone) || other.segmentsDone == segmentsDone)&&(identical(other.totalSegments, totalSegments) || other.totalSegments == totalSegments)&&(identical(other.errorMsg, errorMsg) || other.errorMsg == errorMsg)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,variant,kind,destPath,status,bytesDone,totalBytes,segmentsDone,totalSegments,errorMsg,createdAt);

@override
String toString() {
  return 'DownloadJob(id: $id, title: $title, variant: $variant, kind: $kind, destPath: $destPath, status: $status, bytesDone: $bytesDone, totalBytes: $totalBytes, segmentsDone: $segmentsDone, totalSegments: $totalSegments, errorMsg: $errorMsg, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DownloadJobCopyWith<$Res> implements $DownloadJobCopyWith<$Res> {
  factory _$DownloadJobCopyWith(_DownloadJob value, $Res Function(_DownloadJob) _then) = __$DownloadJobCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? variant, JobKind kind, String destPath, JobStatus status, int bytesDone, int? totalBytes, int segmentsDone, int? totalSegments, String? errorMsg, int createdAt
});




}
/// @nodoc
class __$DownloadJobCopyWithImpl<$Res>
    implements _$DownloadJobCopyWith<$Res> {
  __$DownloadJobCopyWithImpl(this._self, this._then);

  final _DownloadJob _self;
  final $Res Function(_DownloadJob) _then;

/// Create a copy of DownloadJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? variant = freezed,Object? kind = null,Object? destPath = null,Object? status = null,Object? bytesDone = null,Object? totalBytes = freezed,Object? segmentsDone = null,Object? totalSegments = freezed,Object? errorMsg = freezed,Object? createdAt = null,}) {
  return _then(_DownloadJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as JobKind,destPath: null == destPath ? _self.destPath : destPath // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,bytesDone: null == bytesDone ? _self.bytesDone : bytesDone // ignore: cast_nullable_to_non_nullable
as int,totalBytes: freezed == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int?,segmentsDone: null == segmentsDone ? _self.segmentsDone : segmentsDone // ignore: cast_nullable_to_non_nullable
as int,totalSegments: freezed == totalSegments ? _self.totalSegments : totalSegments // ignore: cast_nullable_to_non_nullable
as int?,errorMsg: freezed == errorMsg ? _self.errorMsg : errorMsg // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$HistoryEntry {

 String get id; String? get sourceId; String? get contentId; String? get localPath; String get title; String? get posterUrl; String? get variant; int get positionSeconds; int? get durationSeconds; int get lastWatched; int get playCount; bool get completed;
/// Create a copy of HistoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryEntryCopyWith<HistoryEntry> get copyWith => _$HistoryEntryCopyWithImpl<HistoryEntry>(this as HistoryEntry, _$identity);

  /// Serializes this HistoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.contentId, contentId) || other.contentId == contentId)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.title, title) || other.title == title)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.positionSeconds, positionSeconds) || other.positionSeconds == positionSeconds)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.lastWatched, lastWatched) || other.lastWatched == lastWatched)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceId,contentId,localPath,title,posterUrl,variant,positionSeconds,durationSeconds,lastWatched,playCount,completed);

@override
String toString() {
  return 'HistoryEntry(id: $id, sourceId: $sourceId, contentId: $contentId, localPath: $localPath, title: $title, posterUrl: $posterUrl, variant: $variant, positionSeconds: $positionSeconds, durationSeconds: $durationSeconds, lastWatched: $lastWatched, playCount: $playCount, completed: $completed)';
}


}

/// @nodoc
abstract mixin class $HistoryEntryCopyWith<$Res>  {
  factory $HistoryEntryCopyWith(HistoryEntry value, $Res Function(HistoryEntry) _then) = _$HistoryEntryCopyWithImpl;
@useResult
$Res call({
 String id, String? sourceId, String? contentId, String? localPath, String title, String? posterUrl, String? variant, int positionSeconds, int? durationSeconds, int lastWatched, int playCount, bool completed
});




}
/// @nodoc
class _$HistoryEntryCopyWithImpl<$Res>
    implements $HistoryEntryCopyWith<$Res> {
  _$HistoryEntryCopyWithImpl(this._self, this._then);

  final HistoryEntry _self;
  final $Res Function(HistoryEntry) _then;

/// Create a copy of HistoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sourceId = freezed,Object? contentId = freezed,Object? localPath = freezed,Object? title = null,Object? posterUrl = freezed,Object? variant = freezed,Object? positionSeconds = null,Object? durationSeconds = freezed,Object? lastWatched = null,Object? playCount = null,Object? completed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceId: freezed == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String?,contentId: freezed == contentId ? _self.contentId : contentId // ignore: cast_nullable_to_non_nullable
as String?,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,positionSeconds: null == positionSeconds ? _self.positionSeconds : positionSeconds // ignore: cast_nullable_to_non_nullable
as int,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,lastWatched: null == lastWatched ? _self.lastWatched : lastWatched // ignore: cast_nullable_to_non_nullable
as int,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoryEntry].
extension HistoryEntryPatterns on HistoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _HistoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _HistoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? sourceId,  String? contentId,  String? localPath,  String title,  String? posterUrl,  String? variant,  int positionSeconds,  int? durationSeconds,  int lastWatched,  int playCount,  bool completed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoryEntry() when $default != null:
return $default(_that.id,_that.sourceId,_that.contentId,_that.localPath,_that.title,_that.posterUrl,_that.variant,_that.positionSeconds,_that.durationSeconds,_that.lastWatched,_that.playCount,_that.completed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? sourceId,  String? contentId,  String? localPath,  String title,  String? posterUrl,  String? variant,  int positionSeconds,  int? durationSeconds,  int lastWatched,  int playCount,  bool completed)  $default,) {final _that = this;
switch (_that) {
case _HistoryEntry():
return $default(_that.id,_that.sourceId,_that.contentId,_that.localPath,_that.title,_that.posterUrl,_that.variant,_that.positionSeconds,_that.durationSeconds,_that.lastWatched,_that.playCount,_that.completed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? sourceId,  String? contentId,  String? localPath,  String title,  String? posterUrl,  String? variant,  int positionSeconds,  int? durationSeconds,  int lastWatched,  int playCount,  bool completed)?  $default,) {final _that = this;
switch (_that) {
case _HistoryEntry() when $default != null:
return $default(_that.id,_that.sourceId,_that.contentId,_that.localPath,_that.title,_that.posterUrl,_that.variant,_that.positionSeconds,_that.durationSeconds,_that.lastWatched,_that.playCount,_that.completed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HistoryEntry implements HistoryEntry {
  const _HistoryEntry({required this.id, this.sourceId, this.contentId, this.localPath, required this.title, this.posterUrl, this.variant, this.positionSeconds = 0, this.durationSeconds, required this.lastWatched, this.playCount = 0, this.completed = false});
  factory _HistoryEntry.fromJson(Map<String, dynamic> json) => _$HistoryEntryFromJson(json);

@override final  String id;
@override final  String? sourceId;
@override final  String? contentId;
@override final  String? localPath;
@override final  String title;
@override final  String? posterUrl;
@override final  String? variant;
@override@JsonKey() final  int positionSeconds;
@override final  int? durationSeconds;
@override final  int lastWatched;
@override@JsonKey() final  int playCount;
@override@JsonKey() final  bool completed;

/// Create a copy of HistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryEntryCopyWith<_HistoryEntry> get copyWith => __$HistoryEntryCopyWithImpl<_HistoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.contentId, contentId) || other.contentId == contentId)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.title, title) || other.title == title)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.positionSeconds, positionSeconds) || other.positionSeconds == positionSeconds)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.lastWatched, lastWatched) || other.lastWatched == lastWatched)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceId,contentId,localPath,title,posterUrl,variant,positionSeconds,durationSeconds,lastWatched,playCount,completed);

@override
String toString() {
  return 'HistoryEntry(id: $id, sourceId: $sourceId, contentId: $contentId, localPath: $localPath, title: $title, posterUrl: $posterUrl, variant: $variant, positionSeconds: $positionSeconds, durationSeconds: $durationSeconds, lastWatched: $lastWatched, playCount: $playCount, completed: $completed)';
}


}

/// @nodoc
abstract mixin class _$HistoryEntryCopyWith<$Res> implements $HistoryEntryCopyWith<$Res> {
  factory _$HistoryEntryCopyWith(_HistoryEntry value, $Res Function(_HistoryEntry) _then) = __$HistoryEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String? sourceId, String? contentId, String? localPath, String title, String? posterUrl, String? variant, int positionSeconds, int? durationSeconds, int lastWatched, int playCount, bool completed
});




}
/// @nodoc
class __$HistoryEntryCopyWithImpl<$Res>
    implements _$HistoryEntryCopyWith<$Res> {
  __$HistoryEntryCopyWithImpl(this._self, this._then);

  final _HistoryEntry _self;
  final $Res Function(_HistoryEntry) _then;

/// Create a copy of HistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sourceId = freezed,Object? contentId = freezed,Object? localPath = freezed,Object? title = null,Object? posterUrl = freezed,Object? variant = freezed,Object? positionSeconds = null,Object? durationSeconds = freezed,Object? lastWatched = null,Object? playCount = null,Object? completed = null,}) {
  return _then(_HistoryEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceId: freezed == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String?,contentId: freezed == contentId ? _self.contentId : contentId // ignore: cast_nullable_to_non_nullable
as String?,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,positionSeconds: null == positionSeconds ? _self.positionSeconds : positionSeconds // ignore: cast_nullable_to_non_nullable
as int,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,lastWatched: null == lastWatched ? _self.lastWatched : lastWatched // ignore: cast_nullable_to_non_nullable
as int,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$LibraryLocation {

 String get id; String get path; String get kind; String? get label; int get addedAt;
/// Create a copy of LibraryLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryLocationCopyWith<LibraryLocation> get copyWith => _$LibraryLocationCopyWithImpl<LibraryLocation>(this as LibraryLocation, _$identity);

  /// Serializes this LibraryLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.label, label) || other.label == label)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,path,kind,label,addedAt);

@override
String toString() {
  return 'LibraryLocation(id: $id, path: $path, kind: $kind, label: $label, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class $LibraryLocationCopyWith<$Res>  {
  factory $LibraryLocationCopyWith(LibraryLocation value, $Res Function(LibraryLocation) _then) = _$LibraryLocationCopyWithImpl;
@useResult
$Res call({
 String id, String path, String kind, String? label, int addedAt
});




}
/// @nodoc
class _$LibraryLocationCopyWithImpl<$Res>
    implements $LibraryLocationCopyWith<$Res> {
  _$LibraryLocationCopyWithImpl(this._self, this._then);

  final LibraryLocation _self;
  final $Res Function(LibraryLocation) _then;

/// Create a copy of LibraryLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? path = null,Object? kind = null,Object? label = freezed,Object? addedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LibraryLocation].
extension LibraryLocationPatterns on LibraryLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LibraryLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LibraryLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LibraryLocation value)  $default,){
final _that = this;
switch (_that) {
case _LibraryLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LibraryLocation value)?  $default,){
final _that = this;
switch (_that) {
case _LibraryLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String path,  String kind,  String? label,  int addedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LibraryLocation() when $default != null:
return $default(_that.id,_that.path,_that.kind,_that.label,_that.addedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String path,  String kind,  String? label,  int addedAt)  $default,) {final _that = this;
switch (_that) {
case _LibraryLocation():
return $default(_that.id,_that.path,_that.kind,_that.label,_that.addedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String path,  String kind,  String? label,  int addedAt)?  $default,) {final _that = this;
switch (_that) {
case _LibraryLocation() when $default != null:
return $default(_that.id,_that.path,_that.kind,_that.label,_that.addedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LibraryLocation implements LibraryLocation {
  const _LibraryLocation({required this.id, required this.path, required this.kind, this.label, required this.addedAt});
  factory _LibraryLocation.fromJson(Map<String, dynamic> json) => _$LibraryLocationFromJson(json);

@override final  String id;
@override final  String path;
@override final  String kind;
@override final  String? label;
@override final  int addedAt;

/// Create a copy of LibraryLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LibraryLocationCopyWith<_LibraryLocation> get copyWith => __$LibraryLocationCopyWithImpl<_LibraryLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LibraryLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LibraryLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.label, label) || other.label == label)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,path,kind,label,addedAt);

@override
String toString() {
  return 'LibraryLocation(id: $id, path: $path, kind: $kind, label: $label, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class _$LibraryLocationCopyWith<$Res> implements $LibraryLocationCopyWith<$Res> {
  factory _$LibraryLocationCopyWith(_LibraryLocation value, $Res Function(_LibraryLocation) _then) = __$LibraryLocationCopyWithImpl;
@override @useResult
$Res call({
 String id, String path, String kind, String? label, int addedAt
});




}
/// @nodoc
class __$LibraryLocationCopyWithImpl<$Res>
    implements _$LibraryLocationCopyWith<$Res> {
  __$LibraryLocationCopyWithImpl(this._self, this._then);

  final _LibraryLocation _self;
  final $Res Function(_LibraryLocation) _then;

/// Create a copy of LibraryLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? path = null,Object? kind = null,Object? label = freezed,Object? addedAt = null,}) {
  return _then(_LibraryLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MediaEntry {

 String get name; String get path; bool get isDir; int? get sizeBytes; bool get exists;
/// Create a copy of MediaEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaEntryCopyWith<MediaEntry> get copyWith => _$MediaEntryCopyWithImpl<MediaEntry>(this as MediaEntry, _$identity);

  /// Serializes this MediaEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaEntry&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.isDir, isDir) || other.isDir == isDir)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.exists, exists) || other.exists == exists));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,path,isDir,sizeBytes,exists);

@override
String toString() {
  return 'MediaEntry(name: $name, path: $path, isDir: $isDir, sizeBytes: $sizeBytes, exists: $exists)';
}


}

/// @nodoc
abstract mixin class $MediaEntryCopyWith<$Res>  {
  factory $MediaEntryCopyWith(MediaEntry value, $Res Function(MediaEntry) _then) = _$MediaEntryCopyWithImpl;
@useResult
$Res call({
 String name, String path, bool isDir, int? sizeBytes, bool exists
});




}
/// @nodoc
class _$MediaEntryCopyWithImpl<$Res>
    implements $MediaEntryCopyWith<$Res> {
  _$MediaEntryCopyWithImpl(this._self, this._then);

  final MediaEntry _self;
  final $Res Function(MediaEntry) _then;

/// Create a copy of MediaEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? path = null,Object? isDir = null,Object? sizeBytes = freezed,Object? exists = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,exists: null == exists ? _self.exists : exists // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaEntry].
extension MediaEntryPatterns on MediaEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaEntry value)  $default,){
final _that = this;
switch (_that) {
case _MediaEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MediaEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String path,  bool isDir,  int? sizeBytes,  bool exists)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaEntry() when $default != null:
return $default(_that.name,_that.path,_that.isDir,_that.sizeBytes,_that.exists);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String path,  bool isDir,  int? sizeBytes,  bool exists)  $default,) {final _that = this;
switch (_that) {
case _MediaEntry():
return $default(_that.name,_that.path,_that.isDir,_that.sizeBytes,_that.exists);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String path,  bool isDir,  int? sizeBytes,  bool exists)?  $default,) {final _that = this;
switch (_that) {
case _MediaEntry() when $default != null:
return $default(_that.name,_that.path,_that.isDir,_that.sizeBytes,_that.exists);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaEntry implements MediaEntry {
  const _MediaEntry({required this.name, required this.path, required this.isDir, this.sizeBytes, this.exists = true});
  factory _MediaEntry.fromJson(Map<String, dynamic> json) => _$MediaEntryFromJson(json);

@override final  String name;
@override final  String path;
@override final  bool isDir;
@override final  int? sizeBytes;
@override@JsonKey() final  bool exists;

/// Create a copy of MediaEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaEntryCopyWith<_MediaEntry> get copyWith => __$MediaEntryCopyWithImpl<_MediaEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaEntry&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.isDir, isDir) || other.isDir == isDir)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.exists, exists) || other.exists == exists));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,path,isDir,sizeBytes,exists);

@override
String toString() {
  return 'MediaEntry(name: $name, path: $path, isDir: $isDir, sizeBytes: $sizeBytes, exists: $exists)';
}


}

/// @nodoc
abstract mixin class _$MediaEntryCopyWith<$Res> implements $MediaEntryCopyWith<$Res> {
  factory _$MediaEntryCopyWith(_MediaEntry value, $Res Function(_MediaEntry) _then) = __$MediaEntryCopyWithImpl;
@override @useResult
$Res call({
 String name, String path, bool isDir, int? sizeBytes, bool exists
});




}
/// @nodoc
class __$MediaEntryCopyWithImpl<$Res>
    implements _$MediaEntryCopyWith<$Res> {
  __$MediaEntryCopyWithImpl(this._self, this._then);

  final _MediaEntry _self;
  final $Res Function(_MediaEntry) _then;

/// Create a copy of MediaEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? path = null,Object? isDir = null,Object? sizeBytes = freezed,Object? exists = null,}) {
  return _then(_MediaEntry(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,exists: null == exists ? _self.exists : exists // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
