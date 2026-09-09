# Graph Report - theatre  (2026-09-09)

## Corpus Check
- Corpus is ~32,353 words - fits in a single context window. You may not need a graph.

## Summary
- 890 nodes · 1367 edges · 73 communities (45 shown, 19 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 11 edges (avg confidence: 0.94)
- Token cost: 12,450 input · 2,850 output

## Community Hubs (Navigation)
- Loopback HTTP Proxy Server
- Flutter Main App Shell
- MovieBox Scraper Source
- FFI C-API Bindings & DTOs
- Rust Application Lifecycle
- Direct Stream Downloader
- FFmpeg Transcoding Sidecar
- Flutter TheatreApi Client
- Core Error Handling & Library
- Dart FFI Bridge Calls
- Governance & Architecture Docs
- Freezed Dart Data Models
- Core Rust Domain Types
- Playback History Management
- Local Media Library Views
- Design Tokens & Library Bridge
- App Settings State & UI
- Flutter Browse & Media UI
- HLS Segment Downloader
- BDIX Scraper Source
- KHDDHUB Scraper Source
- Expressive UI Design Components
- Content Search UI State
- Home Screen & Continue Watching
- Persistent App Settings Storage
- Media Detail & Episode UI
- Download Queue Screen
- Scraped Content & Search Registry
- Download Queue Management
- Security & Sanitisation Test Suite
- Detail & History State Providers
- Application Bootstrap & Initialization
- Search State Management
- Scraper Source Health Tracking
- Watch History Screen & Dialogs
- Download Riverpod Provider
- Playback & Action Controls
- Playback History FFI Service
- Flutter Unit & Contract Tests
- Media Stream Resolver Engine
- Video Player & Search Views
- Settings Configuration FFI Service
- Core Performance Benchmarks
- CI & Ecosystem Dependencies
- Expressive Card UI Component
- Cargo Workspace Member Crates
- Flutter Analysis & Lint Rules
- GitHub Release Workflow
- Content Reference Freezed Type
- Content Details Freezed Type
- Download Job Freezed Type
- Episode Freezed Type
- History Entry Freezed Type
- Init Config Freezed Model
- Init Result Freezed Model
- Library Location Freezed Model
- Media Entry Freezed Model
- Resolved Stream Freezed Model
- Search Page Freezed Model
- Source Info Freezed Model
- Downloader State Model
- Nullable String Type
- Developer Automation Scripts
- Ratatui TUI Interface Overview

## God Nodes (most connected - your core abstractions)
1. `ProxySessionStore` - 20 edges
2. `DownloadQueue` - 19 edges
3. `Downloader` - 18 edges
4. `SourceRegistry` - 17 edges
5. `download_hls()` - 12 edges
6. `DownloadJob` - 11 edges
7. `HealthTracker` - 11 edges
8. `AppState` - 10 edges
9. `Library` - 10 edges
10. `AppState` - 10 edges

## Surprising Connections (you probably didn't know these)
- `flutter_rust_bridge FFI Boundary` --implements--> `theatre_init()`  [INFERRED]
  docs/architecture.md → core/crates/theatre-ffi/src/lib.rs
- `Search & Discovery APIs` --implements--> `theatre_search()`  [INFERRED]
  docs/data-contract.md → core/crates/theatre-ffi/src/lib.rs
- `Download Management APIs` --implements--> `theatre_enqueue_download()`  [INFERRED]
  docs/data-contract.md → core/crates/theatre-ffi/src/lib.rs
- `Playback & History APIs` --implements--> `theatre_record_playback()`  [INFERRED]
  docs/data-contract.md → core/crates/theatre-ffi/src/lib.rs
- `flutter_rust_bridge FFI Boundary` --implements--> `init`  [INFERRED]
  docs/architecture.md → app/lib/api/theatre_api.dart

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Theatre Cross-Platform Media Engine Architecture** — docs_architecture_system_overview, docs_architecture_rust_core, docs_architecture_ffi_boundary, docs_prd_dual_frontends, docs_prd_platform_targets [EXTRACTED 0.95]
- **FFI Data Contract and Cross-Language Bridge** — docs_data_contract_ffi_contract, docs_architecture_ffi_boundary, docs_data_contract_lifecycle_api, core_crates_theatre_ffi_src_lib_theatre_init, app_lib_api_theatre_api_theatreapi [EXTRACTED 0.95]
- **Repository Governance, Document System & Roadmapping** — agents_md_agent_guidelines, agents_md_hard_rules, docs_roadmap_milestones, docs_roadmap_milestone_gates, docs_prd_theatre_overview [EXTRACTED 0.95]

## Communities (73 total, 19 thin omitted)

### Community 0 - "Loopback HTTP Proxy Server"
Cohesion: 0.08
Nodes (35): Body, Db, NetClient, Result, start(), AppState, handle_download(), JobInfo (+27 more)

### Community 1 - "Flutter Main App Shell"
Cohesion: 0.05
Nodes (47): _AppDrawer, AppShell, _AppShellState, _buildTheme, createState, _index, main, onHistory (+39 more)

### Community 2 - "MovieBox Scraper Source"
Cohesion: 0.07
Nodes (28): Source, MovieBoxSource, Details, Option, ResolvedStream, Result, SearchPage, Self (+20 more)

### Community 3 - "FFI C-API Bindings & DTOs"
Cohesion: 0.11
Nodes (41): ContentRef, Details, DownloadJob, HistoryEntry, InitConfig, InitResult, LibraryLocation, MediaEntry (+33 more)

### Community 4 - "Rust Application Lifecycle"
Cohesion: 0.10
Nodes (30): AppState, downloader(), history(), init(), library(), proxy_port(), Arc, Db (+22 more)

### Community 5 - "Direct Stream Downloader"
Cohesion: 0.11
Nodes (23): download_direct(), is_paused_or_cancelled(), Arc, DownloadJob, NetClient, ResolvedStream, Result, DownloadEvent (+15 more)

### Community 6 - "FFmpeg Transcoding Sidecar"
Cohesion: 0.10
Nodes (21): FfmpegSidecar, Option, PathBuf, Result, Self, String, Downloader, nix_statvfs() (+13 more)

### Community 7 - "Flutter TheatreApi Client"
Cohesion: 0.06
Nodes (30): addLocation, allHistory, browseFolder, cancelDownload, continueWatching, deleteHistory, enqueueDownload, getDetails (+22 more)

### Community 8 - "Core Error Handling & Library"
Cohesion: 0.13
Nodes (18): ByteStream, Option, String, TheatreError, Library, LibraryLocation, LocationKind, MediaEntry (+10 more)

### Community 9 - "Dart FFI Bridge Calls"
Cohesion: 0.08
Nodes (24): ../api/types.dart, forceRefresh, theatreAddLocation, theatreAllHistory, theatreBrowseFolder, theatreCancelDownload, theatreContinueWatching, theatreDeleteHistory (+16 more)

### Community 10 - "Governance & Architecture Docs"
Cohesion: 0.09
Nodes (24): Agent Operating Guidelines, Document Precedence Hierarchy, Repository Invariants & Hard Rules, Agent Session Lifecycle, Contribution Rules & Workflow, Loopback Download & Stream Proxy, Single-Process Architecture, Rust Core Engine (+16 more)

### Community 11 - "Freezed Dart Data Models"
Cohesion: 0.14
Nodes (22): @freezed, ContentKind, ContentRef, Details, DownloadJob, Episode, fromJson, HistoryEntry (+14 more)

### Community 12 - "Core Rust Domain Types"
Cohesion: 0.21
Nodes (21): ContentKind, ContentRef, Details, Episode, InitConfig, InitResult, ResolvedStream, Episode (+13 more)

### Community 13 - "Playback History Management"
Cohesion: 0.16
Nodes (12): History, HistoryEntry, row_to_entry(), ContentRef, Db, HistoryEntry, Option, Result (+4 more)

### Community 14 - "Local Media Library Views"
Cohesion: 0.11
Nodes (19): browseFolderProvider, libraryLocationsProvider, _addFolder, _browsePath, build, createState, _EmptyLibrary, _fmt (+11 more)

### Community 15 - "Design Tokens & Library Bridge"
Cohesion: 0.15
Nodes (17): theatre_design, add_library_location(), browse_folder(), list_library_locations(), remove_library_location(), LibraryLocation, MediaEntry, Option (+9 more)

### Community 16 - "App Settings State & UI"
Cohesion: 0.13
Nodes (16): DownloadNotifier, build, _keys, SettingsNotifier, settingsProvider, build, _pickFromList, _SectionHeader (+8 more)

### Community 17 - "Flutter Browse & Media UI"
Cohesion: 0.14
Nodes (16): _BackdropAppBar, _BrowseGrid, _BrowseTile, _VariantButton, _VariantSheet, _EmptyState, _PosterCard, _ResultsGrid (+8 more)

### Community 18 - "HLS Segment Downloader"
Cohesion: 0.24
Nodes (16): Bytes, base_url(), download_hls(), fetch_segment_urls(), fetch_segment_with_retry(), is_cancelled(), is_paused(), resolve_url() (+8 more)

### Community 19 - "BDIX Scraper Source"
Cohesion: 0.14
Nodes (8): BdixSource, Details, Option, ResolvedStream, Result, SearchPage, Self, SourceStatus

### Community 20 - "KHDDHUB Scraper Source"
Cohesion: 0.14
Nodes (8): KhddhubSource, Details, Option, ResolvedStream, Result, SearchPage, Self, SourceStatus

### Community 21 - "Expressive UI Design Components"
Cohesion: 0.13
Nodes (10): build, TButton, build, TNavBar, build, TNavDrawer, build, TNavRail (+2 more)

### Community 22 - "Content Search UI State"
Cohesion: 0.14
Nodes (14): searchProvider, build, createState, _ctrl, dispose, hasQuery, initState, partial (+6 more)

### Community 23 - "Home Screen & Continue Watching"
Cohesion: 0.14
Nodes (13): color, _ContinueCard, _ContinueWatchingSection, entries, entry, icon, label, _PromoBanner (+5 more)

### Community 24 - "Persistent App Settings Storage"
Cohesion: 0.21
Nodes (7): Db, Option, Result, Self, String, Settings, T

### Community 25 - "Media Detail & Episode UI"
Cohesion: 0.15
Nodes (12): _BackdropPlaceholder, content, _DescriptionBlock, details, ep, _EpisodeList, error, _ErrorBody (+4 more)

### Community 26 - "Download Queue Screen"
Cohesion: 0.15
Nodes (12): build, _EmptyDownloads, _isFinal, job, _JobActions, notifier, _progress, _sizeLabel (+4 more)

### Community 27 - "Scraped Content & Search Registry"
Cohesion: 0.24
Nodes (12): get_details(), list_sources(), ContentRef, Details, Option, Result, SearchPage, SourceInfo (+4 more)

### Community 28 - "Download Queue Management"
Cohesion: 0.24
Nodes (12): cancel_download(), enqueue_download(), list_downloads(), pause_download(), resume_download(), ContentRef, DownloadJob, Option (+4 more)

### Community 29 - "Security & Sanitisation Test Suite"
Cohesion: 0.22
Nodes (7): concurrent_settings_writes_no_corruption(), make_db(), proxy_rejects_wrong_token(), proxy_tokens_differ_across_instances(), Db, settings_sql_injection_via_key(), settings_sql_injection_via_value()

### Community 30 - "Detail & History State Providers"
Cohesion: 0.18
Nodes (10): ../api/theatre_api.dart, detailProvider, continueWatchingProvider, build, DetailScreen, _play, build, HomeScreen (+2 more)

### Community 31 - "Application Bootstrap & Initialization"
Cohesion: 0.18
Nodes (10): bootstrapCore, dir, build, TheatreApp, config, dir, initProvider, package:flutter/foundation.dart (+2 more)

### Community 32 - "Search State Management"
Cohesion: 0.18
Nodes (11): build, clear, copyWith, page, query, search, SearchNotifier, searchQueryProvider (+3 more)

### Community 33 - "Scraper Source Health Tracking"
Cohesion: 0.20
Nodes (7): HealthTracker, Db, HashMap, Mutex, Self, SourceStatus, String

### Community 34 - "Watch History Screen & Dialogs"
Cohesion: 0.22
Nodes (10): allHistoryProvider, build, _confirmClearAll, entry, HistoryScreen, _HistoryTile, ref, package:intl/intl.dart (+2 more)

### Community 35 - "Download Riverpod Provider"
Cohesion: 0.20
Nodes (9): build, cancel, enqueue, pause, _refresh, resume, _timer, dart:async (+1 more)

### Community 36 - "Playback & Action Controls"
Cohesion: 0.33
Nodes (9): resolveProvider, downloadProvider, _DetailBody, _download, _EpisodeTile, _PlayButtons, DownloadsScreen, _DownloadTile (+1 more)

### Community 37 - "Playback History FFI Service"
Cohesion: 0.42
Nodes (8): all_history(), continue_watching(), delete_history(), record_playback(), HistoryEntry, Result, String, Vec

### Community 39 - "Flutter Unit & Contract Tests"
Cohesion: 0.25
Nodes (6): main, main, package:flutter_test/flutter_test.dart, package:test/test.dart, package:theatre/api/types.dart, package:theatre/main.dart

### Community 40 - "Media Stream Resolver Engine"
Cohesion: 0.29
Nodes (6): resolve(), ContentRef, Option, ResolvedStream, Result, String

### Community 41 - "Video Player & Search Views"
Cohesion: 0.40
Nodes (6): PlayerScreen, _PlayerScreenState, SearchScreen, _SearchScreenState, ConsumerState, ConsumerStatefulWidget

### Community 42 - "Settings Configuration FFI Service"
Cohesion: 0.47
Nodes (5): get_setting(), Option, Result, String, set_setting()

### Community 43 - "Core Performance Benchmarks"
Cohesion: 0.70
Nodes (4): bench_concurrent_reads(), bench_history_record(), bench_settings_rw(), Criterion

### Community 44 - "CI & Ecosystem Dependencies"
Cohesion: 0.50
Nodes (4): Flutter Pubspec Configuration, Flutter Ecosystem (Riverpod, media_kit), Rust Core Crates (Tokio, Reqwest, Rusqlite), CI Automation Pipeline

### Community 46 - "Cargo Workspace Member Crates"
Cohesion: 0.67
Nodes (3): theatre-core, theatre-ffi, theatre-tui

## Knowledge Gaps
- **171 isolated node(s):** `TheatreApi`, `instance`, `shutdown`, `search`, `getDetails` (+166 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 370 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **19 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppState` connect `Rust Application Lifecycle` to `MovieBox Scraper Source`, `FFmpeg Transcoding Sidecar`, `Core Error Handling & Library`, `Playback History Management`, `Persistent App Settings Storage`?**
  _High betweenness centrality (0.140) - this node is a cross-community bridge._
- **Why does `SourceRegistry` connect `MovieBox Scraper Source` to `Scraper Source Health Tracking`, `Rust Application Lifecycle`?**
  _High betweenness centrality (0.136) - this node is a cross-community bridge._
- **Why does `Resolver Chain` connect `MovieBox Scraper Source` to `Governance & Architecture Docs`?**
  _High betweenness centrality (0.088) - this node is a cross-community bridge._
- **What connects `TheatreApi`, `instance`, `shutdown` to the rest of the system?**
  _171 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Loopback HTTP Proxy Server` be split into smaller, more focused modules?**
  _Cohesion score 0.07767722473604827 - nodes in this community are weakly interconnected._
- **Should `Flutter Main App Shell` be split into smaller, more focused modules?**
  _Cohesion score 0.045068027210884355 - nodes in this community are weakly interconnected._
- **Should `MovieBox Scraper Source` be split into smaller, more focused modules?**
  _Cohesion score 0.06666666666666667 - nodes in this community are weakly interconnected._