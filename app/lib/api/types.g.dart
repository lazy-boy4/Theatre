// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InitConfig _$InitConfigFromJson(Map<String, dynamic> json) => _InitConfig(
  dataDir: json['dataDir'] as String,
  appVersion: json['appVersion'] as String,
  proxyEnabled: json['proxyEnabled'] as bool? ?? true,
);

Map<String, dynamic> _$InitConfigToJson(_InitConfig instance) =>
    <String, dynamic>{
      'dataDir': instance.dataDir,
      'appVersion': instance.appVersion,
      'proxyEnabled': instance.proxyEnabled,
    };

_InitResult _$InitResultFromJson(Map<String, dynamic> json) => _InitResult(
  dbPath: json['dbPath'] as String,
  proxyPort: (json['proxyPort'] as num?)?.toInt(),
  coreVersion: json['coreVersion'] as String,
  contractVersion: json['contractVersion'] as String,
);

Map<String, dynamic> _$InitResultToJson(_InitResult instance) =>
    <String, dynamic>{
      'dbPath': instance.dbPath,
      'proxyPort': instance.proxyPort,
      'coreVersion': instance.coreVersion,
      'contractVersion': instance.contractVersion,
    };

_ContentRef _$ContentRefFromJson(Map<String, dynamic> json) => _ContentRef(
  source: json['source'] as String,
  contentId: json['contentId'] as String,
  kind: $enumDecode(_$ContentKindEnumMap, json['kind']),
);

Map<String, dynamic> _$ContentRefToJson(_ContentRef instance) =>
    <String, dynamic>{
      'source': instance.source,
      'contentId': instance.contentId,
      'kind': _$ContentKindEnumMap[instance.kind]!,
    };

const _$ContentKindEnumMap = {
  ContentKind.movie: 'movie',
  ContentKind.series: 'series',
  ContentKind.episode: 'episode',
};

_SearchResult _$SearchResultFromJson(Map<String, dynamic> json) =>
    _SearchResult(
      content: ContentRef.fromJson(json['content'] as Map<String, dynamic>),
      title: json['title'] as String,
      year: (json['year'] as num?)?.toInt(),
      posterUrl: json['posterUrl'] as String?,
      qualityBadges:
          (json['qualityBadges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SearchResultToJson(_SearchResult instance) =>
    <String, dynamic>{
      'content': instance.content.toJson(),
      'title': instance.title,
      'year': instance.year,
      'posterUrl': instance.posterUrl,
      'qualityBadges': instance.qualityBadges,
    };

_SearchPage _$SearchPageFromJson(Map<String, dynamic> json) => _SearchPage(
  results: (json['results'] as List<dynamic>)
      .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
      .toList(),
  hasMore: json['hasMore'] as bool? ?? false,
  partial: json['partial'] as bool? ?? false,
);

Map<String, dynamic> _$SearchPageToJson(_SearchPage instance) =>
    <String, dynamic>{
      'results': instance.results.map((e) => e.toJson()).toList(),
      'hasMore': instance.hasMore,
      'partial': instance.partial,
    };

_Episode _$EpisodeFromJson(Map<String, dynamic> json) => _Episode(
  content: ContentRef.fromJson(json['content'] as Map<String, dynamic>),
  season: (json['season'] as num).toInt(),
  episode: (json['episode'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$EpisodeToJson(_Episode instance) => <String, dynamic>{
  'content': instance.content.toJson(),
  'season': instance.season,
  'episode': instance.episode,
  'title': instance.title,
  'description': instance.description,
  'thumbnailUrl': instance.thumbnailUrl,
  'durationSeconds': instance.durationSeconds,
};

_Details _$DetailsFromJson(Map<String, dynamic> json) => _Details(
  content: ContentRef.fromJson(json['content'] as Map<String, dynamic>),
  title: json['title'] as String,
  description: json['description'] as String?,
  year: (json['year'] as num?)?.toInt(),
  posterUrl: json['posterUrl'] as String?,
  backdropUrl: json['backdropUrl'] as String?,
  rating: json['rating'] as String?,
  genres: (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
  durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
  episodes:
      (json['episodes'] as List<dynamic>?)
          ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$DetailsToJson(_Details instance) => <String, dynamic>{
  'content': instance.content.toJson(),
  'title': instance.title,
  'description': instance.description,
  'year': instance.year,
  'posterUrl': instance.posterUrl,
  'backdropUrl': instance.backdropUrl,
  'rating': instance.rating,
  'genres': instance.genres,
  'durationSeconds': instance.durationSeconds,
  'episodes': instance.episodes.map((e) => e.toJson()).toList(),
};

_Variant _$VariantFromJson(Map<String, dynamic> json) => _Variant(
  id: json['id'] as String,
  label: json['label'] as String,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  bitrateKbps: (json['bitrateKbps'] as num?)?.toInt(),
);

Map<String, dynamic> _$VariantToJson(_Variant instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'width': instance.width,
  'height': instance.height,
  'bitrateKbps': instance.bitrateKbps,
};

_ResolvedStream _$ResolvedStreamFromJson(Map<String, dynamic> json) =>
    _ResolvedStream(
      url: json['url'] as String,
      headers:
          (json['headers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      kind: $enumDecode(_$StreamKindEnumMap, json['kind']),
      variants:
          (json['variants'] as List<dynamic>?)
              ?.map((e) => Variant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      selectedVariant: json['selectedVariant'] as String?,
      filenameHint: json['filenameHint'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ResolvedStreamToJson(_ResolvedStream instance) =>
    <String, dynamic>{
      'url': instance.url,
      'headers': instance.headers,
      'kind': _$StreamKindEnumMap[instance.kind]!,
      'variants': instance.variants.map((e) => e.toJson()).toList(),
      'selectedVariant': instance.selectedVariant,
      'filenameHint': instance.filenameHint,
      'sizeBytes': instance.sizeBytes,
    };

const _$StreamKindEnumMap = {
  StreamKind.direct: 'direct',
  StreamKind.hls: 'hls',
};

_SourceInfo _$SourceInfoFromJson(Map<String, dynamic> json) => _SourceInfo(
  id: json['id'] as String,
  name: json['name'] as String,
  enabled: json['enabled'] as bool,
  status:
      $enumDecodeNullable(_$SourceStatusEnumMap, json['status']) ??
      SourceStatus.healthy,
);

Map<String, dynamic> _$SourceInfoToJson(_SourceInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'enabled': instance.enabled,
      'status': _$SourceStatusEnumMap[instance.status]!,
    };

const _$SourceStatusEnumMap = {
  SourceStatus.healthy: 'healthy',
  SourceStatus.degraded: 'degraded',
};

_DownloadJob _$DownloadJobFromJson(Map<String, dynamic> json) => _DownloadJob(
  id: json['id'] as String,
  title: json['title'] as String,
  variant: json['variant'] as String?,
  kind: $enumDecode(_$JobKindEnumMap, json['kind']),
  destPath: json['destPath'] as String,
  status: $enumDecode(_$JobStatusEnumMap, json['status']),
  bytesDone: (json['bytesDone'] as num?)?.toInt() ?? 0,
  totalBytes: (json['totalBytes'] as num?)?.toInt(),
  segmentsDone: (json['segmentsDone'] as num?)?.toInt() ?? 0,
  totalSegments: (json['totalSegments'] as num?)?.toInt(),
  errorMsg: json['errorMsg'] as String?,
  createdAt: (json['createdAt'] as num).toInt(),
);

Map<String, dynamic> _$DownloadJobToJson(_DownloadJob instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'variant': instance.variant,
      'kind': _$JobKindEnumMap[instance.kind]!,
      'destPath': instance.destPath,
      'status': _$JobStatusEnumMap[instance.status]!,
      'bytesDone': instance.bytesDone,
      'totalBytes': instance.totalBytes,
      'segmentsDone': instance.segmentsDone,
      'totalSegments': instance.totalSegments,
      'errorMsg': instance.errorMsg,
      'createdAt': instance.createdAt,
    };

const _$JobKindEnumMap = {JobKind.direct: 'direct', JobKind.hls: 'hls'};

const _$JobStatusEnumMap = {
  JobStatus.queued: 'queued',
  JobStatus.preparing: 'preparing',
  JobStatus.running: 'running',
  JobStatus.paused: 'paused',
  JobStatus.failed: 'failed',
  JobStatus.done: 'done',
  JobStatus.cancelled: 'cancelled',
};

_HistoryEntry _$HistoryEntryFromJson(Map<String, dynamic> json) =>
    _HistoryEntry(
      id: json['id'] as String,
      sourceId: json['sourceId'] as String?,
      contentId: json['contentId'] as String?,
      localPath: json['localPath'] as String?,
      title: json['title'] as String,
      posterUrl: json['posterUrl'] as String?,
      variant: json['variant'] as String?,
      positionSeconds: (json['positionSeconds'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      lastWatched: (json['lastWatched'] as num).toInt(),
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
    );

Map<String, dynamic> _$HistoryEntryToJson(_HistoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceId': instance.sourceId,
      'contentId': instance.contentId,
      'localPath': instance.localPath,
      'title': instance.title,
      'posterUrl': instance.posterUrl,
      'variant': instance.variant,
      'positionSeconds': instance.positionSeconds,
      'durationSeconds': instance.durationSeconds,
      'lastWatched': instance.lastWatched,
      'playCount': instance.playCount,
      'completed': instance.completed,
    };

_LibraryLocation _$LibraryLocationFromJson(Map<String, dynamic> json) =>
    _LibraryLocation(
      id: json['id'] as String,
      path: json['path'] as String,
      kind: json['kind'] as String,
      label: json['label'] as String?,
      addedAt: (json['addedAt'] as num).toInt(),
    );

Map<String, dynamic> _$LibraryLocationToJson(_LibraryLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'kind': instance.kind,
      'label': instance.label,
      'addedAt': instance.addedAt,
    };

_MediaEntry _$MediaEntryFromJson(Map<String, dynamic> json) => _MediaEntry(
  name: json['name'] as String,
  path: json['path'] as String,
  isDir: json['isDir'] as bool,
  sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
  exists: json['exists'] as bool? ?? true,
);

Map<String, dynamic> _$MediaEntryToJson(_MediaEntry instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'isDir': instance.isDir,
      'sizeBytes': instance.sizeBytes,
      'exists': instance.exists,
    };
