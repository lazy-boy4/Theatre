# Graph Report - theatre  (2026-09-25)

## Corpus Check
- 22 files · ~73,596 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1561 nodes · 2503 edges · 163 communities (60 shown, 96 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 36 edges (avg confidence: 0.87)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Dart FRB Bridge Codegen
- Download Queue Management
- Core Error & Diagnostics
- Windows Native C++ Embedder
- Rust FRB SSE Serialization
- KHDDHUB Scraper & Parser
- Domain Model Freezed Types
- Loopback HTTP Streaming Proxy
- Direct Stream Downloader
- Media Player Screen & Controller
- Material 3 Expressive UI Tokens
- BDIX Scraper & Circles
- Dart FFI Bridge Decoding
- Dart IO Codegen Deserializers
- Async Network Client & Headers
- Dart Web Codegen Deserializers
- Governance Architecture & Specs
- Watch History UI & Provider
- Local Library Management UI
- FFmpeg Sidecar Transcoding
- Scraper Sources Registry
- Design Tokens & Library Bridge
- Flutter Core FFI Client
- Media Detail UI & Episodes
- Search Screen UI & Flow
- Detail & Settings Providers
- Watch History Core Store
- Main App Shell & Navigation
- Local Media File Scanner
- SQLite Database & Migrations
- HLS Stream Segment Downloader
- Subtitle Detection & Extraction
- Settings Configuration UI
- Application Bootstrap Service
- Core Application Lifecycle
- Download Progress State
- Rust FFI API Crate Root
- Persistent Settings Storage
- Scraper Health Diagnostics
- Source Deepening & Seams
- Media Stream Resolver Core
- MovieBox Scraper Source
- Security Seam Test Suite
- Core Domain DTO Definitions
- Home Screen Dashboard
- Database Integration Tests
- Flutter Contract Unit Tests
- Flutter Pubspec Dependencies
- Agents Component
- Types.Freezed Component
- Types.Freezed Component
- Frb Generated.Io Component
- Core Bench Component
- Frb Generated.Web Component
- Build Component
- Frb Generated.Io Component
- Cargo Component
- Moviebox Component
- Lib Component
- Main Component
- ../api/theatre_api.d Module
- Analysis Options Component
- Types.Freezed Component
- Color Module
- String Module
- String Module
- String Module
- Db Module
- String Module
- String Module
- NetClient Module
- String Module
- NetClient Module
- Db Module
- NetClient Module
- String Module
- Db Module
- String Module
- String Module
- Db Module
- String Module
- Lib Component
- Db Module
- String Module
- Db Module
- NetClient Module
- NetClient Module
- String Module
- Db Module
- Db Module
- String Module
- SourceStatus Module
- Db Module
- String Module
- SourceStatus Module
- SourceStatus Module
- Db Module
- Mutex Module
- String Module
- NetClient Module
- Result Module
- String Module
- Vec Module
- ContentRef Module
- Details Module
- DownloadJob Module
- HistoryEntry Module
- InitConfig Module
- InitResult Module
- LibraryLocation Module
- MediaEntry Module
- Option Module
- ResolvedStream Module
- Result Module
- SearchPage Module
- SourceInfo Module
- String Module
- Vec Module
- Ci Component
- Release Component
- ContentRef Module
- Details Module
- DownloadJob Module
- Episode Module
- HistoryEntry Module
- InitConfig Module
- InitResult Module
- LibraryLocation Module
- MediaEntry Module
- ResolvedStream Module
- SearchPage Module
- SearchResult Module
- SourceInfo Module
- State Module
- String? Module
- T Module
- package:flutter/foun Module
- Receiver Module
- Response Module
- RwLock Module
- Readme Component
- Readme Component
- Send Module
- Sender Module
- Sync Module
- Readme Component
- Widget Module
- WidgetRef Module
- Community 155
- Community 156
- Community 157
- Community 158
- Community 159
- Community 160
- Community 161
- Community 162

## God Nodes (most connected - your core abstractions)
1. `_` - 41 edges
2. `NetClient` - 35 edges
3. `MovieBoxSource` - 29 edges
4. `()` - 28 edges
5. `pde_ffi_dispatcher_primary_impl()` - 25 edges
6. `KhddhubSource` - 22 edges
7. `Win32Window` - 21 edges
8. `Db` - 21 edges
9. `ProxySessionStore` - 20 edges
10. `BdixSource` - 18 edges

## Surprising Connections (you probably didn't know these)
- `Resolver Chain` --references--> `MovieBoxSource`  [INFERRED]
  docs/architecture.md → core/crates/theatre-core/src/sources/moviebox.rs
- `Sources Seam Placement Research` --conceptually_related_to--> `SourceRegistry`  [INFERRED]
  docs/agents/research-sources-seam-20260910.md → core/crates/theatre-core/src/sources/registry.rs
- `Resolver Chain` --implements--> `SourceRegistry`  [INFERRED]
  docs/architecture.md → core/crates/theatre-core/src/sources/registry.rs
- `KHDDHUB Detail HTML Fixture` --references--> `KhddhubSource`  [INFERRED]
  core/crates/theatre-core/tests/fixtures/khddhub_detail_movie.html → core/crates/theatre-core/src/sources/khddhub.rs
- `KHDDHUB Search HTML Fixture` --references--> `KhddhubSource`  [INFERRED]
  core/crates/theatre-core/tests/fixtures/khddhub_search_inception.html → core/crates/theatre-core/src/sources/khddhub.rs

## Import Cycles
- None detected.

## Communities (163 total, 96 thin omitted)

### Community 0 - "Dart FRB Bridge Codegen"
Cohesion: 0.02
Nodes (90): ApiImplConstructor, apiImplConstructor, codegenVersion, crateApiInitApp, crateApiTheatreAddLocation, crateApiTheatreAllHistory, crateApiTheatreBrowseFolder, crateApiTheatreCancelDownload (+82 more)

### Community 1 - "Download Queue Management"
Cohesion: 0.07
Nodes (43): AtomicUsize, Option, Result, Self, TheatreError, canonical(), clean_title(), client_token() (+35 more)

### Community 2 - "Core Error & Diagnostics"
Cohesion: 0.05
Nodes (58): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+50 more)

### Community 3 - "Windows Native C++ Embedder"
Cohesion: 0.10
Nodes (41): (), bool, i32, Option<String>, Option<Vec<String>>, pde_ffi_dispatcher_primary_impl(), pde_ffi_dispatcher_sync_impl(), Self (+33 more)

### Community 4 - "Rust FRB SSE Serialization"
Cohesion: 0.06
Nodes (30): AsRef, Connection, Library, LibraryLocation, LocationKind, MediaEntry, Option, Result (+22 more)

### Community 5 - "KHDDHUB Scraper & Parser"
Cohesion: 0.04
Nodes (50): ContentKind, fromJson, JobKind, JobStatus, SourceStatus, StreamKind, _, class (+42 more)

### Community 6 - "Domain Model Freezed Types"
Cohesion: 0.07
Nodes (30): Body, Result, start(), AppState, handle_download(), JobInfo, ProxyServer, Arc (+22 more)

### Community 7 - "Loopback HTTP Streaming Proxy"
Cohesion: 0.09
Nodes (35): Bytes, download_direct(), is_paused_or_cancelled(), Arc, DownloadJob, ResolvedStream, Result, download_hls() (+27 more)

### Community 8 - "Direct Stream Downloader"
Cohesion: 0.11
Nodes (25): badge_rank(), BdixSource, direct_stream(), load_fixture(), parse_movie_details_from_fixture(), parse_search_results_from_fixture(), parse_series_details_from_fixture(), percent_decode() (+17 more)

### Community 9 - "Media Player Screen & Controller"
Cohesion: 0.08
Nodes (26): Source, fanout_search_merges_results_and_marks_degraded(), Arc, ContentRef, Details, HashMap, Option, ResolvedStream (+18 more)

### Community 10 - "Material 3 Expressive UI Tokens"
Cohesion: 0.05
Nodes (41): build, _changeVariant, content, _controller, _controlsVisible, createState, current, currentVariant (+33 more)

### Community 11 - "BDIX Scraper & Circles"
Cohesion: 0.06
Nodes (35): build, TButton, build, TCard, build, TNavBar, build, TNavDrawer (+27 more)

### Community 12 - "Dart FFI Bridge Decoding"
Cohesion: 0.05
Nodes (39): ../api/types.dart, content, _decode, _decodeList, _detailsFromRust, episodes, forceRefresh, fromJson (+31 more)

### Community 13 - "Dart IO Codegen Deserializers"
Cohesion: 0.06
Nodes (34): api.dart, dco_decode_bool, dco_decode_list_prim_u_8_strict, dco_decode_list_String, dco_decode_opt_list_String, dco_decode_opt_String, dco_decode_String, dco_decode_u_32 (+26 more)

### Community 14 - "Async Network Client & Headers"
Cohesion: 0.11
Nodes (23): Client, apply_headers(), host_of(), NetClient, Arc, Default, HashMap, Mutex (+15 more)

### Community 15 - "Dart Web Codegen Deserializers"
Cohesion: 0.06
Nodes (33): _, dco_decode_bool, dco_decode_list_prim_u_8_strict, dco_decode_list_String, dco_decode_opt_list_String, dco_decode_opt_String, dco_decode_String, dco_decode_u_32 (+25 more)

### Community 16 - "Governance Architecture & Specs"
Cohesion: 0.12
Nodes (26): find_metadata(), is_archive(), is_genre(), load_fixture(), non_empty_or(), parse_movie_details_from_fixture(), parse_releases_from_fixture(), parse_search_results_from_fixture() (+18 more)

### Community 17 - "Watch History UI & Provider"
Cohesion: 0.07
Nodes (30): Android NDK Cross-Compilation, flutter_rust_bridge Codegen, Theatre Build Guide, Contribution Rules & Workflow, flutter_rust_bridge FFI Boundary, Loopback Download & Stream Proxy, Single-Process Architecture, Resolver Chain (+22 more)

### Community 18 - "Local Library Management UI"
Cohesion: 0.19
Nodes (27): from_json(), Option, Result, T, Vec, theatre_add_location(), theatre_all_history(), theatre_browse_folder() (+19 more)

### Community 19 - "FFmpeg Sidecar Transcoding"
Cohesion: 0.12
Nodes (15): FfmpegSidecar, Option, PathBuf, Result, Self, Downloader, Arc, ContentRef (+7 more)

### Community 20 - "Scraper Sources Registry"
Cohesion: 0.09
Nodes (25): allHistoryProvider, HistoryEntry, build, _confirmClearAll, entry, HistoryScreen, _BrowseGrid, _BrowseTile (+17 more)

### Community 21 - "Design Tokens & Library Bridge"
Cohesion: 0.09
Nodes (22): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+14 more)

### Community 22 - "Flutter Core FFI Client"
Cohesion: 0.09
Nodes (24): resolveProvider, content, createState, _descriptionBlock, _DetailBody, _DetailBodyState, details, _download (+16 more)

### Community 23 - "Media Detail UI & Episodes"
Cohesion: 0.10
Nodes (19): playContent, stream, allHistoryProvider, continueWatchingProvider, config, dir, initProvider, theatreInit (+11 more)

### Community 24 - "Search Screen UI & Flow"
Cohesion: 0.10
Nodes (22): theatre_design, Flutter Application Guide, add_library_location(), browse_folder(), list_library_locations(), remove_library_location(), LibraryLocation, MediaEntry (+14 more)

### Community 25 - "Detail & Settings Providers"
Cohesion: 0.08
Nodes (23): theatreAddLocation, theatreAllHistory, theatreBrowseFolder, theatreCancelDownload, theatreContinueWatching, theatreDeleteHistory, theatreEnqueueDownload, theatreGetDetails (+15 more)

### Community 26 - "Watch History Core Store"
Cohesion: 0.10
Nodes (22): _addFolder, _basename, _browsePath, build, _confirmDetach, createState, _EmptyLibrary, _fmt (+14 more)

### Community 27 - "Main App Shell & Navigation"
Cohesion: 0.12
Nodes (20): detailProvider, sourcesProvider, settingsProvider, build, DetailScreen, _EpisodeTile, _ErrorBody, _StreamMetaRow (+12 more)

### Community 28 - "Local Media File Scanner"
Cohesion: 0.10
Nodes (21): searchProvider, build, createState, _ctrl, dispose, _EmptyState, hasQuery, initState (+13 more)

### Community 29 - "SQLite Database & Migrations"
Cohesion: 0.21
Nodes (21): ContentKind, ContentRef, Details, Episode, InitConfig, InitResult, ResolvedStream, Episode (+13 more)

### Community 30 - "HLS Stream Segment Downloader"
Cohesion: 0.20
Nodes (10): KhddhubSource, Into, ResolvedStream, Result, SearchPage, Url, split_episode_id(), validate_playback_url() (+2 more)

### Community 31 - "Subtitle Detection & Extraction"
Cohesion: 0.10
Nodes (20): _AppDrawer, build, createState, _index, main, onSettings, _screens, TheatreApp (+12 more)

### Community 32 - "Settings Configuration UI"
Cohesion: 0.17
Nodes (10): History, HistoryEntry, row_to_entry(), ContentRef, HistoryEntry, Option, Result, Row (+2 more)

### Community 33 - "Application Bootstrap Service"
Cohesion: 0.15
Nodes (15): DownloadJob, downloadProvider, build, DownloadsScreen, _DownloadTile, _isFinal, job, _JobActions (+7 more)

### Community 34 - "Core Application Lifecycle"
Cohesion: 0.13
Nodes (14): build, cancel, DownloadNotifier, enqueue, pause, _refresh, resume, _timer (+6 more)

### Community 35 - "Download Progress State"
Cohesion: 0.17
Nodes (13): AppState, init(), init_result(), Arc, InitConfig, InitResult, Option, Result (+5 more)

### Community 36 - "Rust FFI API Crate Root"
Cohesion: 0.15
Nodes (13): @JsonSerializable, _ContentRef, _Details, _DownloadJob, _Episode, _HistoryEntry, _InitConfig, _InitResult (+5 more)

### Community 37 - "Persistent Settings Storage"
Cohesion: 0.15
Nodes (12): kTheatreSeed, lg, md, scheme, sm, theatreTheme, TSpace, xl (+4 more)

### Community 38 - "Scraper Health Diagnostics"
Cohesion: 0.24
Nodes (9): wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), _In_, _In_opt_ (+1 more)

### Community 39 - "Source Deepening & Seams"
Cohesion: 0.26
Nodes (11): get_details(), list_sources(), ContentRef, Details, Option, Result, SearchPage, SourceInfo (+3 more)

### Community 40 - "Media Stream Resolver Core"
Cohesion: 0.23
Nodes (11): cancel_download(), enqueue_download(), list_downloads(), pause_download(), resume_download(), ContentRef, DownloadJob, Option (+3 more)

### Community 41 - "MovieBox Scraper Source"
Cohesion: 0.21
Nodes (4): concurrent_settings_writes_no_corruption(), make_db(), settings_sql_injection_via_key(), settings_sql_injection_via_value()

### Community 42 - "Security Seam Test Suite"
Cohesion: 0.22
Nodes (11): @freezed, ContentRef, Details, Episode, InitConfig, InitResult, LibraryLocation, MediaEntry (+3 more)

### Community 43 - "Core Domain DTO Definitions"
Cohesion: 0.20
Nodes (10): build, clear, copyWith, page, query, search, SearchNotifier, SearchState (+2 more)

### Community 45 - "Home Screen Dashboard"
Cohesion: 0.32
Nodes (8): AppShell, _AppShellState, _OverlayControls, _OverlayControlsState, _SpeedButton, _SpeedButtonState, State, StatefulWidget

### Community 46 - "Database Integration Tests"
Cohesion: 0.25
Nodes (6): main, main, package:flutter_test/flutter_test.dart, package:test/test.dart, package:theatre/api/types.dart, package:theatre/main.dart

### Community 47 - "Flutter Contract Unit Tests"
Cohesion: 0.50
Nodes (7): all_history(), continue_watching(), delete_history(), record_playback(), HistoryEntry, Result, Vec

### Community 48 - "Flutter Pubspec Dependencies"
Cohesion: 0.40
Nodes (6): RustLib, RustLibApi, RustLibApiImpl, BaseApi, BaseEntrypoint, RustLibApiImplPlatform

### Community 49 - "Agents Component"
Cohesion: 0.33
Nodes (5): resolve(), ContentRef, Option, ResolvedStream, Result

### Community 50 - "Types.Freezed Component"
Cohesion: 0.50
Nodes (4): get_setting(), Option, Result, set_setting()

### Community 51 - "Types.Freezed Component"
Cohesion: 0.50
Nodes (4): Agent Guidelines & Session Bootstrap, Domain Documentation Protocol, Local Markdown Issue Tracker, Canonical Triage Labels

### Community 52 - "Frb Generated.Io Component"
Cohesion: 0.50
Nodes (4): _SearchResult, SearchResult, SearchResultPatterns, SearchResult

### Community 53 - "Core Bench Component"
Cohesion: 0.50
Nodes (4): _Variant, Variant, VariantPatterns, Variant

### Community 54 - "Frb Generated.Web Component"
Cohesion: 0.67
Nodes (4): RustLibApiImplPlatform, RustLibApiImplPlatform, BaseApiImpl, RustLibWire

### Community 55 - "Build Component"
Cohesion: 0.83
Nodes (3): bench_history_record(), bench_settings_rw(), Criterion

### Community 56 - "Frb Generated.Io Component"
Cohesion: 0.67
Nodes (3): @anonymous, @JS, RustLibWasmModule

### Community 58 - "Moviebox Component"
Cohesion: 0.67
Nodes (3): Freezed Code Generation Config, Flutter Pubspec Dependencies, Pinned Dependencies & Upgrade Rules

### Community 59 - "Lib Component"
Cohesion: 0.67
Nodes (3): RustLibWire, RustLibWire, BaseWire

### Community 60 - "Main Component"
Cohesion: 0.67
Nodes (3): Windows Desktop CMake Configuration, Windows Flutter Subproject CMake, Windows Native Runner CMake

### Community 61 - "../api/theatre_api.d Module"
Cohesion: 0.67
Nodes (3): theatre-core, theatre-ffi, theatre-tui

## Knowledge Gaps
- **456 isolated node(s):** `apiImplConstructor`, `codegenVersion`, `crateApiInitApp`, `crateApiTheatreAddLocation`, `crateApiTheatreAllHistory` (+451 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 794 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **96 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `String` connect `Local Library Management UI` to `Settings Configuration UI`, `Download Queue Management`, `Windows Native C++ Embedder`, `Rust FRB SSE Serialization`, `Domain Model Freezed Types`, `Source Deepening & Seams`, `Media Stream Resolver Core`, `Loopback HTTP Streaming Proxy`, `Direct Stream Downloader`, `Async Network Client & Headers`, `Flutter Contract Unit Tests`, `Governance Architecture & Specs`, `Agents Component`, `Types.Freezed Component`, `FFmpeg Sidecar Transcoding`, `Search Screen UI & Flow`, `HLS Stream Segment Downloader`?**
  _High betweenness centrality (0.133) - this node is a cross-community bridge._
- **Why does `MovieBoxSource` connect `Download Queue Management` to `Media Player Screen & Controller`, `Local Library Management UI`, `Async Network Client & Headers`, `Watch History UI & Provider`?**
  _High betweenness centrality (0.044) - this node is a cross-community bridge._
- **Why does `_` connect `Dart Web Codegen Deserializers` to `Core Application Lifecycle`, `Dart IO Codegen Deserializers`, `Frb Generated.Web Component`, `Frb Generated.Io Component`, `Detail & Settings Providers`, `Lib Component`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **What connects `apiImplConstructor`, `codegenVersion`, `crateApiInitApp` to the rest of the system?**
  _456 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Dart FRB Bridge Codegen` be split into smaller, more focused modules?**
  _Cohesion score 0.02197802197802198 - nodes in this community are weakly interconnected._
- **Should `Download Queue Management` be split into smaller, more focused modules?**
  _Cohesion score 0.06873706004140787 - nodes in this community are weakly interconnected._
- **Should `Core Error & Diagnostics` be split into smaller, more focused modules?**
  _Cohesion score 0.050724637681159424 - nodes in this community are weakly interconnected._