import 'types.dart';
// Generated FFI bridge (run `flutter_rust_bridge_codegen` to regenerate).
// Until codegen runs, this stub re-exports types and provides the contract.
import '../ffi/bridge.dart' as ffi;
export 'types.dart';

/// Theatre API — thin wrapper over the generated FFI bridge.
/// All calls are async — backed by the Rust Tokio runtime.
class TheatreApi {
  TheatreApi._();
  static final instance = TheatreApi._();

  // ─ Lifecycle (data-contract.md §2) ─────────────────────
  Future<InitResult> init(InitConfig config)   => ffi.theatreInit(config);
  Future<void>       shutdown()                => ffi.theatreShutdown();

  // ─ Search & details (data-contract.md §3) ──────────────
  Future<SearchPage> search(String query, {List<String>? sources}) =>
      ffi.theatreSearch(query: query, sourceFilter: sources);
  Future<Details>    getDetails(ContentRef content) =>
      ffi.theatreGetDetails(content: content);
  Future<List<SourceInfo>> listSources() => ffi.theatreListSources();

  // ─ Resolver (data-contract.md §4) ────────────────────
  Future<ResolvedStream> resolve(
    ContentRef content, {
    String? variant,
    bool forceRefresh = false,
  }) => ffi.theatreResolve(content: content, variant: variant, forceRefresh: forceRefresh);

  // ─ Downloads (data-contract.md §7) ───────────────────
  Future<String>          enqueueDownload(ContentRef c, ResolvedStream s, String title, {String? variant}) =>
      ffi.theatreEnqueueDownload(content: c, stream: s, title: title, variant: variant);
  Future<List<DownloadJob>> listDownloads()       => ffi.theatreListDownloads();
  Future<void>              pauseDownload(String id)  => ffi.theatrePauseDownload(id: id);
  Future<void>              cancelDownload(String id) => ffi.theatreCancelDownload(id: id);
  Future<void>              resumeDownload(String id) => ffi.theatreResumeDownload(id: id);

  // ─ History (data-contract.md §6) ─────────────────────
  Future<void>               recordPlayback(HistoryEntry e) => ffi.theatreRecordPlayback(entry: e);
  Future<List<HistoryEntry>> continueWatching({int limit = 20}) =>
      ffi.theatreContinueWatching(limit: limit);
  Future<List<HistoryEntry>> allHistory({int limit = 50, int offset = 0}) =>
      ffi.theatreAllHistory(limit: limit, offset: offset);
  Future<void>               deleteHistory(String id) => ffi.theatreDeleteHistory(id: id);

  // ─ Library (data-contract.md §10) ───────────────────
  Future<List<LibraryLocation>> listLocations()      => ffi.theatreListLocations();
  Future<LibraryLocation>       addLocation(String path, {String? label, bool isSaf = false}) =>
      ffi.theatreAddLocation(path: path, label: label, isSaf: isSaf);
  Future<void>                  removeLocation(String id) => ffi.theatreRemoveLocation(id: id);
  Future<List<MediaEntry>>      browseFolder(String path) => ffi.theatreBrowseFolder(path: path);

  // ─ Settings (data-contract.md §11) ──────────────────
  Future<String?> getSetting(String key)                => ffi.theatreGetSetting(key: key);
  Future<void>    setSetting(String key, String value)  => ffi.theatreSetSetting(key: key, value: value);
}
