// Theatre FFI bridge adapter — hand-written, over FRB-generated `api.dart`.
//
// Transport: complex contract types cross FFI as JSON (see
// core/crates/theatre-ffi/src/api.rs). Rust structs use camelCase JSON keys
// to match these freezed models 1:1. Two shapes need manual mapping:
//  - SourceStatus (Rust tagged map → Dart plain enum)
//  - Details.seasons (Rust nested → Dart flat episodes)

import 'dart:convert';

import 'api.dart' as frb;
import '../api/types.dart';
export '../api/types.dart';

Map<String, dynamic> _decode(String json) => jsonDecode(json) as Map<String, dynamic>;
List<dynamic> _decodeList(String json) => jsonDecode(json) as List<dynamic>;

// Lifecycle
Future<InitResult> theatreInit(InitConfig config) async {
  final json = await frb.theatreInit(configJson: jsonEncode(config.toJson()));
  return InitResult.fromJson(_decode(json));
}

Future<void> theatreShutdown() => frb.theatreShutdown();

// Search
Future<SearchPage> theatreSearch({required String query, List<String>? sourceFilter}) async {
  final json = await frb.theatreSearch(query: query, sourceFilter: sourceFilter);
  return SearchPage.fromJson(_decode(json));
}

Future<Details> theatreGetDetails({required ContentRef content}) async {
  final json = await frb.theatreGetDetails(contentJson: jsonEncode(content.toJson()));
  return _detailsFromRust(_decode(json));
}

Future<List<SourceInfo>> theatreListSources() async {
  final json = await frb.theatreListSources();
  return _decodeList(json).map((e) => _sourceInfoFromRust(e as Map<String, dynamic>)).toList();
}

SourceInfo _sourceInfoFromRust(Map<String, dynamic> j) {
  final status = j['status'];
  final healthy = status is String
      ? status == 'healthy'
      : (status as Map<String, dynamic>)['kind'] == 'healthy';
  return SourceInfo(
    id: j['id'] as String,
    name: j['name'] as String,
    enabled: (j['enabled'] as bool?) ?? true,
    status: healthy ? SourceStatus.healthy : SourceStatus.degraded,
  );
}

Details _detailsFromRust(Map<String, dynamic> j) {
  final episodes = <Episode>[];
  final seasons = j['seasons'] as List<dynamic>? ?? [];
  for (final s in seasons) {
    final sm = s as Map<String, dynamic>;
    final seasonNum = (sm['number'] as num).toInt();
    for (final e in (sm['episodes'] as List<dynamic>? ?? [])) {
      final em = e as Map<String, dynamic>;
      final epNum = (em['number'] as num).toInt();
      final content = em['content'] as Map<String, dynamic>;
      episodes.add(Episode(
        content: ContentRef(
          source: content['source'] as String,
          contentId: content['contentId'] as String,
          kind: ContentKind.episode,
        ),
        season: seasonNum,
        episode: epNum,
        title: (em['title'] as String?) ?? 'Episode $epNum',
      ));
    }
  }
  final content = j['content'] as Map<String, dynamic>;
  return Details(
    content: ContentRef.fromJson(content),
    title: j['title'] as String,
    description: j['synopsis'] as String?,
    year: (j['year'] as num?)?.toInt(),
    posterUrl: j['posterUrl'] as String?,
    backdropUrl: j['backdropUrl'] as String?,
    genres: (j['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
    episodes: episodes,
  );
}

// Resolver
Future<ResolvedStream> theatreResolve({
  required ContentRef content,
  String? variant,
  bool forceRefresh = false,
}) async {
  final json = await frb.theatreResolve(
    contentJson: jsonEncode(content.toJson()),
    variant: variant,
    forceRefresh: forceRefresh,
  );
  return ResolvedStream.fromJson(_decode(json));
}

// Downloads
Future<String> theatreEnqueueDownload({
  required ContentRef content,
  required ResolvedStream stream,
  required String title,
  String? variant,
}) =>
    frb.theatreEnqueueDownload(
      contentJson: jsonEncode(content.toJson()),
      streamJson: jsonEncode(stream.toJson()),
      title: title,
      variant: variant,
    );

Future<List<DownloadJob>> theatreListDownloads() async {
  final json = await frb.theatreListDownloads();
  return _decodeList(json).map((e) => DownloadJob.fromJson(e as Map<String, dynamic>)).toList();
}

Future<void> theatrePauseDownload({required String id}) => frb.theatrePauseDownload(id: id);
Future<void> theatreCancelDownload({required String id}) => frb.theatreCancelDownload(id: id);
Future<void> theatreResumeDownload({required String id}) => frb.theatreResumeDownload(id: id);

// History
Future<void> theatreRecordPlayback({required HistoryEntry entry}) =>
    frb.theatreRecordPlayback(entryJson: jsonEncode(entry.toJson()));

Future<List<HistoryEntry>> theatreContinueWatching({required int limit}) async {
  final json = await frb.theatreContinueWatching(limit: limit);
  return _decodeList(json).map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
}

Future<List<HistoryEntry>> theatreAllHistory({required int limit, required int offset}) async {
  final json = await frb.theatreAllHistory(limit: limit, offset: offset);
  return _decodeList(json).map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
}

Future<void> theatreDeleteHistory({required String id}) => frb.theatreDeleteHistory(id: id);

// Library
Future<List<LibraryLocation>> theatreListLocations() async {
  final json = await frb.theatreListLocations();
  return _decodeList(json).map((e) => LibraryLocation.fromJson(e as Map<String, dynamic>)).toList();
}

Future<LibraryLocation> theatreAddLocation({required String path, String? label, bool isSaf = false}) async {
  final json = await frb.theatreAddLocation(path: path, label: label, isSaf: isSaf);
  return LibraryLocation.fromJson(_decode(json));
}

Future<void> theatreRemoveLocation({required String id}) => frb.theatreRemoveLocation(id: id);

Future<List<MediaEntry>> theatreBrowseFolder({required String path}) async {
  final json = await frb.theatreBrowseFolder(path: path);
  return _decodeList(json).map((e) => MediaEntry.fromJson(e as Map<String, dynamic>)).toList();
}

// Settings
Future<String?> theatreGetSetting({required String key}) => frb.theatreGetSetting(key: key);
Future<void> theatreSetSetting({required String key, required String value}) =>
    frb.theatreSetSetting(key: key, value: value);
