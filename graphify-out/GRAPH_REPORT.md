# Graph Report - theatre  (2026-09-24)

## Corpus Check
- 11 files · ~72,799 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1521 nodes · 2457 edges · 165 communities (59 shown, 102 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 34 edges (avg confidence: 0.87)
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
- Search Query State Provider
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
- Types.Freezed Component
- Color Module
- String Module
- String Module
- String Module
- String Module
- Db Module
- Mod Component
- String Module
- Db Module
- String Module
- NetClient Module
- String Module
- NetClient Module
- String Module
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
- String Module
- Db Module
- String Module
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
- Community 163
- Community 164

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
- `Resolver Chain` --implements--> `SourceRegistry`  [INFERRED]
  docs/architecture.md → core/crates/theatre-core/src/sources/registry.rs
- `Sources Seam Placement Research` --conceptually_related_to--> `SourceRegistry`  [INFERRED]
  docs/agents/research-sources-seam-20260910.md → core/crates/theatre-core/src/sources/registry.rs
- `KHDDHUB Detail HTML Fixture` --references--> `KhddhubSource`  [INFERRED]
  core/crates/theatre-core/tests/fixtures/khddhub_detail_movie.html → core/crates/theatre-core/src/sources/khddhub.rs
- `KHDDHUB Search HTML Fixture` --references--> `KhddhubSource`  [INFERRED]
  core/crates/theatre-core/tests/fixtures/khddhub_search_inception.html → core/crates/theatre-core/src/sources/khddhub.rs

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Repository Agent Governance and Issue Tracking System** — agents_md_agent_guidelines_updated, docs_agents_issue_tracker_protocol, docs_agents_triage_labels_protocol, docs_agents_domain_docs_protocol [EXTRACTED 0.95]
- **FFI Data Contract and Cross-Language Bridge** — docs_data_contract_ffi_contract, docs_architecture_ffi_boundary, docs_data_contract_lifecycle_api [EXTRACTED 0.95]
- **Scraper Source Deepening, Seams and Fixture Testing** — docs_agents_research_sources_seam, scratch_sources_deepening_issue_seam, scratch_sources_deepening_test_seam, tests_fixtures_khddhub_detail, tests_fixtures_khddhub_search [EXTRACTED 0.95]
- **Theatre Cross-Platform Media Engine Architecture** — docs_architecture_system_overview, docs_architecture_rust_core, docs_architecture_ffi_boundary, docs_prd_dual_frontends, docs_prd_platform_targets [EXTRACTED 0.95]
- **Material 3 Expressive Design System & UI Architecture** — docs_design_system_tokens, docs_design_m3e_expressive, docs_design_motion_spec, impeccable_critique_app_lib_screens, app_readme_flutter_overview [EXTRACTED 0.95]

## Communities (165 total, 102 thin omitted)

### Community 0 - "Dart FRB Bridge Codegen"
Cohesion: 0.02
Nodes (90): ApiImplConstructor, apiImplConstructor, codegenVersion, crateApiInitApp, crateApiTheatreAddLocation, crateApiTheatreAllHistory, crateApiTheatreBrowseFolder, crateApiTheatreCancelDownload (+82 more)

### Community 1 - "Download Queue Management"
Cohesion: 0.06
Nodes (51): AppState, init(), init_result(), Arc, Option, Result, state(), ContentKind (+43 more)

### Community 2 - "Core Error & Diagnostics"
Cohesion: 0.07
Nodes (43): AtomicUsize, Option, Result, Self, TheatreError, canonical(), clean_title(), client_token() (+35 more)

### Community 3 - "Windows Native C++ Embedder"
Cohesion: 0.05
Nodes (58): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+50 more)

### Community 4 - "Rust FRB SSE Serialization"
Cohesion: 0.10
Nodes (41): (), bool, i32, Option<String>, Option<Vec<String>>, pde_ffi_dispatcher_primary_impl(), pde_ffi_dispatcher_sync_impl(), Self (+33 more)

### Community 5 - "KHDDHUB Scraper & Parser"
Cohesion: 0.08
Nodes (38): find_metadata(), is_archive(), is_genre(), KhddhubSource, load_fixture(), non_empty_or(), parse_movie_details_from_fixture(), parse_releases_from_fixture() (+30 more)

### Community 6 - "Domain Model Freezed Types"
Cohesion: 0.04
Nodes (50): ContentKind, fromJson, JobKind, JobStatus, SourceStatus, StreamKind, _, class (+42 more)

### Community 7 - "Loopback HTTP Streaming Proxy"
Cohesion: 0.05
Nodes (45): build, _changeVariant, content, _controller, _controlsVisible, createState, current, currentVariant (+37 more)

### Community 8 - "Direct Stream Downloader"
Cohesion: 0.09
Nodes (35): Bytes, download_direct(), is_paused_or_cancelled(), Arc, DownloadJob, ResolvedStream, Result, download_hls() (+27 more)

### Community 9 - "Media Player Screen & Controller"
Cohesion: 0.13
Nodes (23): badge_rank(), BdixSource, direct_stream(), load_fixture(), parse_movie_details_from_fixture(), parse_search_results_from_fixture(), parse_series_details_from_fixture(), percent_decode() (+15 more)

### Community 10 - "Material 3 Expressive UI Tokens"
Cohesion: 0.05
Nodes (39): ../api/types.dart, content, _decode, _decodeList, _detailsFromRust, episodes, forceRefresh, fromJson (+31 more)

### Community 11 - "BDIX Scraper & Circles"
Cohesion: 0.06
Nodes (34): build, TButton, build, TCard, build, TNavBar, build, TNavDrawer (+26 more)

### Community 12 - "Dart FFI Bridge Decoding"
Cohesion: 0.06
Nodes (34): api.dart, dco_decode_bool, dco_decode_list_prim_u_8_strict, dco_decode_list_String, dco_decode_opt_list_String, dco_decode_opt_String, dco_decode_String, dco_decode_u_32 (+26 more)

### Community 13 - "Dart IO Codegen Deserializers"
Cohesion: 0.11
Nodes (23): Client, apply_headers(), host_of(), NetClient, Arc, Default, HashMap, Mutex (+15 more)

### Community 14 - "Async Network Client & Headers"
Cohesion: 0.06
Nodes (33): _, dco_decode_bool, dco_decode_list_prim_u_8_strict, dco_decode_list_String, dco_decode_opt_list_String, dco_decode_opt_String, dco_decode_String, dco_decode_u_32 (+25 more)

### Community 15 - "Dart Web Codegen Deserializers"
Cohesion: 0.09
Nodes (30): detailProvider, resolveProvider, sourcesProvider, build, content, createState, _descriptionBlock, _DetailBody (+22 more)

### Community 16 - "Governance Architecture & Specs"
Cohesion: 0.08
Nodes (28): allHistoryProvider, continueWatchingProvider, build, _confirmClearAll, entry, HistoryScreen, _HistoryTile, _BrowseGrid (+20 more)

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
Cohesion: 0.08
Nodes (25): build, cancel, DownloadNotifier, downloadProvider, enqueue, pause, _refresh, resume (+17 more)

### Community 21 - "Design Tokens & Library Bridge"
Cohesion: 0.09
Nodes (26): searchProvider, PlayerScreen, _PlayerScreenState, build, createState, _ctrl, dispose, hasQuery (+18 more)

### Community 22 - "Flutter Core FFI Client"
Cohesion: 0.10
Nodes (22): theatre_design, Flutter Application Guide, add_library_location(), browse_folder(), list_library_locations(), remove_library_location(), LibraryLocation, MediaEntry (+14 more)

### Community 23 - "Media Detail UI & Episodes"
Cohesion: 0.08
Nodes (23): theatreAddLocation, theatreAllHistory, theatreBrowseFolder, theatreCancelDownload, theatreContinueWatching, theatreDeleteHistory, theatreEnqueueDownload, theatreGetDetails (+15 more)

### Community 24 - "Search Screen UI & Flow"
Cohesion: 0.09
Nodes (23): _AppDrawer, AppShell, _AppShellState, build, createState, _index, main, onSettings (+15 more)

### Community 25 - "Detail & Settings Providers"
Cohesion: 0.10
Nodes (22): browseFolderProvider, libraryLocationsProvider, _addFolder, _basename, _browsePath, build, _confirmDetach, createState (+14 more)

### Community 26 - "Watch History Core Store"
Cohesion: 0.14
Nodes (19): Body, Result, start(), AppState, handle_download(), JobInfo, ProxyServer, Arc (+11 more)

### Community 27 - "Main App Shell & Navigation"
Cohesion: 0.11
Nodes (15): playContent, stream, config, dir, theatreInit, main, main, package:flutter_riverpod/flutter_riverpod.dart (+7 more)

### Community 28 - "Local Media File Scanner"
Cohesion: 0.13
Nodes (16): build, _keys, SettingsNotifier, settingsProvider, subtitleLabel, build, _pickFromList, _sectionHeader (+8 more)

### Community 29 - "SQLite Database & Migrations"
Cohesion: 0.18
Nodes (8): ActiveSession, encode(), LaunchToken, ProxySessionStore, Default, HashMap, Mutex, Self

### Community 30 - "HLS Stream Segment Downloader"
Cohesion: 0.25
Nodes (9): Library, LibraryLocation, LocationKind, MediaEntry, Option, Result, Self, Vec (+1 more)

### Community 31 - "Subtitle Detection & Extraction"
Cohesion: 0.17
Nodes (11): AsRef, Connection, Db, Arc, Mutex, Path, Result, Send (+3 more)

### Community 32 - "Settings Configuration UI"
Cohesion: 0.15
Nodes (13): @freezed, ContentRef, Details, DownloadJob, Episode, HistoryEntry, InitConfig, InitResult (+5 more)

### Community 33 - "Application Bootstrap Service"
Cohesion: 0.15
Nodes (13): @JsonSerializable, _ContentRef, _Details, _DownloadJob, _Episode, _HistoryEntry, _InitConfig, _InitResult (+5 more)

### Community 34 - "Core Application Lifecycle"
Cohesion: 0.15
Nodes (12): kTheatreSeed, lg, md, scheme, sm, theatreTheme, TSpace, xl (+4 more)

### Community 35 - "Download Progress State"
Cohesion: 0.24
Nodes (9): wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), _In_, _In_opt_ (+1 more)

### Community 36 - "Rust FFI API Crate Root"
Cohesion: 0.26
Nodes (11): get_details(), list_sources(), ContentRef, Details, Option, Result, SearchPage, SourceInfo (+3 more)

### Community 37 - "Persistent Settings Storage"
Cohesion: 0.23
Nodes (11): cancel_download(), enqueue_download(), list_downloads(), pause_download(), resume_download(), ContentRef, DownloadJob, Option (+3 more)

### Community 38 - "Scraper Health Diagnostics"
Cohesion: 0.21
Nodes (4): concurrent_settings_writes_no_corruption(), make_db(), settings_sql_injection_via_key(), settings_sql_injection_via_value()

### Community 39 - "Source Deepening & Seams"
Cohesion: 0.20
Nodes (10): build, clear, copyWith, page, query, search, SearchNotifier, SearchState (+2 more)

### Community 40 - "Media Stream Resolver Core"
Cohesion: 0.25
Nodes (6): HistoryEntry, row_to_entry(), ContentRef, Option, Row, Self

### Community 41 - "MovieBox Scraper Source"
Cohesion: 0.27
Nodes (5): Option, Result, Self, T, Settings

### Community 42 - "Security Seam Test Suite"
Cohesion: 0.22
Nodes (5): HealthTracker, HashMap, Mutex, Self, SourceStatus

### Community 44 - "Search Query State Provider"
Cohesion: 0.42
Nodes (4): History, HistoryEntry, Result, Vec

### Community 45 - "Home Screen Dashboard"
Cohesion: 0.50
Nodes (7): all_history(), continue_watching(), delete_history(), record_playback(), HistoryEntry, Result, Vec

### Community 46 - "Database Integration Tests"
Cohesion: 0.40
Nodes (6): RustLib, RustLibApi, RustLibApiImpl, BaseApi, BaseEntrypoint, RustLibApiImplPlatform

### Community 47 - "Flutter Contract Unit Tests"
Cohesion: 0.33
Nodes (5): resolve(), ContentRef, Option, ResolvedStream, Result

### Community 48 - "Flutter Pubspec Dependencies"
Cohesion: 0.50
Nodes (4): get_setting(), Option, Result, set_setting()

### Community 49 - "Agents Component"
Cohesion: 0.40
Nodes (3): Vec, ProxySession, Vec

### Community 50 - "Types.Freezed Component"
Cohesion: 0.50
Nodes (4): Agent Guidelines & Session Bootstrap, Domain Documentation Protocol, Local Markdown Issue Tracker, Canonical Triage Labels

### Community 51 - "Types.Freezed Component"
Cohesion: 0.50
Nodes (4): SearchResult, _SearchResult, SearchResultPatterns, SearchResult

### Community 52 - "Frb Generated.Io Component"
Cohesion: 0.50
Nodes (4): Variant, _Variant, VariantPatterns, Variant

### Community 53 - "Core Bench Component"
Cohesion: 0.67
Nodes (4): RustLibApiImplPlatform, RustLibApiImplPlatform, BaseApiImpl, RustLibWire

### Community 54 - "Frb Generated.Web Component"
Cohesion: 0.83
Nodes (3): bench_history_record(), bench_settings_rw(), Criterion

### Community 55 - "Build Component"
Cohesion: 0.67
Nodes (3): @anonymous, @JS, RustLibWasmModule

### Community 56 - "Frb Generated.Io Component"
Cohesion: 0.67
Nodes (3): Freezed Code Generation Config, Flutter Pubspec Dependencies, Pinned Dependencies & Upgrade Rules

### Community 57 - "Cargo Component"
Cohesion: 0.67
Nodes (3): RustLibWire, RustLibWire, BaseWire

### Community 58 - "Moviebox Component"
Cohesion: 0.67
Nodes (3): Windows Desktop CMake Configuration, Windows Flutter Subproject CMake, Windows Native Runner CMake

### Community 59 - "Lib Component"
Cohesion: 0.67
Nodes (3): theatre-core, theatre-ffi, theatre-tui

## Knowledge Gaps
- **449 isolated node(s):** `apiImplConstructor`, `codegenVersion`, `crateApiInitApp`, `crateApiTheatreAddLocation`, `crateApiTheatreAllHistory` (+444 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 780 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **102 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `String` connect `Local Library Management UI` to `Core Error & Diagnostics`, `Rust FRB SSE Serialization`, `KHDDHUB Scraper & Parser`, `Direct Stream Downloader`, `Media Player Screen & Controller`, `Dart IO Codegen Deserializers`, `FFmpeg Sidecar Transcoding`, `Flutter Core FFI Client`, `Watch History Core Store`, `SQLite Database & Migrations`, `HLS Stream Segment Downloader`, `Rust FFI API Crate Root`, `Persistent Settings Storage`, `Media Stream Resolver Core`, `MovieBox Scraper Source`, `Security Seam Test Suite`, `Home Screen Dashboard`, `Flutter Contract Unit Tests`, `Flutter Pubspec Dependencies`, `Agents Component`?**
  _High betweenness centrality (0.133) - this node is a cross-community bridge._
- **Why does `MovieBoxSource` connect `Core Error & Diagnostics` to `Download Queue Management`, `Local Library Management UI`, `Dart IO Codegen Deserializers`, `Watch History UI & Provider`?**
  _High betweenness centrality (0.051) - this node is a cross-community bridge._
- **Why does `NetClient` connect `Dart IO Codegen Deserializers` to `Core Error & Diagnostics`, `KHDDHUB Scraper & Parser`, `Direct Stream Downloader`, `Media Player Screen & Controller`, `FFmpeg Sidecar Transcoding`, `Watch History Core Store`?**
  _High betweenness centrality (0.033) - this node is a cross-community bridge._
- **What connects `apiImplConstructor`, `codegenVersion`, `crateApiInitApp` to the rest of the system?**
  _449 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Dart FRB Bridge Codegen` be split into smaller, more focused modules?**
  _Cohesion score 0.02197802197802198 - nodes in this community are weakly interconnected._
- **Should `Download Queue Management` be split into smaller, more focused modules?**
  _Cohesion score 0.05672926447574335 - nodes in this community are weakly interconnected._
- **Should `Core Error & Diagnostics` be split into smaller, more focused modules?**
  _Cohesion score 0.06873706004140787 - nodes in this community are weakly interconnected._