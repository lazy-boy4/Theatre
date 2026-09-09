# data-contract.md — Theatre

**Version:** 1.0.0
**Status:** Agent-ready. This document is the **executable specification** of the Rust↔Flutter boundary (the `api/` module of `theatre-core` and its `flutter_rust_bridge` projection). The TUI consumes the same `api/` surface directly, so this contract is binding on both frontends.
**For AI agents:** No type, function, event, or error variant may cross the FFI boundary unless it is defined in this document first. Implementation tasks must cite the contract item they implement (e.g., "implements `resolve()` per data-contract §5.2"). When a task requires a contract change, the change lands in this document *in the same task*, following §13 (Change Policy).

**Related:** `prd.md` v1.1 (product scope) · `architecture.md` v1.0 (system design)

---

## 1. Conventions

| Topic | Rule |
|---|---|
| Naming | Rust `snake_case` → Dart `camelCase` (frb v2 automatic【turn0search8】) |
| Nullability | Rust `Option<T>` → Dart `T?` |
| Collections | `Vec<T>` → `List<T>`; `HashMap<String,String>` → `Map<String,String>` |
| Enums | Rust enums → Dart sealed classes; match exhaustively |
| Timestamps | `u64`, Unix epoch seconds |
| Durations | `u64`, seconds (playback position, runtime) |
| IDs | Opaque `String`s; never parsed by frontends |
| Paths & URIs | `String`. Android SAF `content://…` URIs are opaque strings; desktop paths are native strings |
| Async | Every function is async and non-blocking (architecture §6); no function blocks on network or disk beyond short DB access |
| Threading | All functions callable from any thread/isolate; the core serializes via its runtime |
| Progress throttling | Progress-bearing events are throttled to ≤ 4 Hz per entity at the core boundary (architecture §21) |
| Snapshot streams | Every `*_events()` stream emits a `Snapshot` event immediately on subscribe, then deltas (§8) |

## 2. Lifecycle

### 2.1 `init(config: InitConfig) → InitResult`
Starts the tokio runtime, opens SQLite (creating + migrating if needed), binds the proxy (if enabled), loads source registry. Must be called once before anything else; violations return `TheatreError::NotInitialized`. Called twice → returns the existing `InitResult` (idempotent).

```rust
struct InitConfig {
    data_dir: String,          // platform data dir supplied by the frontend
    app_version: String,       // for diagnostics/migration bookkeeping
    proxy_enabled: bool,       // false in tests
}

struct InitResult {
    db_path: String,
    proxy_port: Option<u16>,   // None when proxy disabled
    core_version: String,
    contract_version: String,  // "1.0.0" — frontends may assert compatibility
}
```

### 2.2 `shutdown() → ()`
Graceful stop: cancels pending DB writes, stops proxy listener. The *UI* must check `list_proxy_sessions()` and warn before calling this (PRD F10 exit guard). Safe to call twice.

## 3. Content Domain

```rust
enum SourceKind { Standard, Live, Addon }   // Addon reserved P1

struct SourceInfo {
    id: String,               // "moviebox" | "4khdhub" | "bdix" | P1: "addon:<id>"
    name: String,
    enabled: bool,
    kind: SourceKind,
    status: SourceStatus,
}

enum SourceStatus {
    Healthy,
    Degraded  { since: u64, last_error: String },
    Unavailable { since: u64, last_error: String },
}

enum ContentKind { Movie, Series, Episode }

struct ContentRef {
    source: String,           // SourceInfo.id
    content_id: String,       // opaque per-source ID
    kind: ContentKind,
}

struct SearchResult {
    content: ContentRef,
    title: String,
    year: Option<u16>,
    poster_url: Option<String>,
    quality_badges: Vec<String>,   // e.g. "1080p", "4K" as surfaced by source
}

struct SearchPage {
    results: Vec<SearchResult>,
    has_more: bool,
    partial: bool,                  // true if some sources timed out/failed
}

struct Details {
    content: ContentRef,
    title: String,
    year: Option<u16>,
    synopsis: Option<String>,
    poster_url: Option<String>,
    backdrop_url: Option<String>,
    genres: Vec<String>,
    cast: Vec<String>,
    seasons: Vec<Season>,
}

struct Season { number: u32, episodes: Vec<Episode> }

struct Episode {
    content: ContentRef,      // kind: Episode
    number: u32,
    title: Option<String>,
}
```

### 3.1 `search(query: String, source_filter: Option<Vec<String>>) → SearchPage`
Fan-out across enabled `Standard` sources in parallel, per-source timeout 8s; merged, stable order (source-major). A failing source **never fails the call** — it is reflected in `partial: true` and on the health stream (§8.1). All sources failing → `TheatreError::Source`. Brief result cache (60 s, per query+filter) is core-internal.

### 3.2 `get_details(content: ContentRef) → Details`
Single-source fetch. Source failure → `TheatreError::Source`.

### 3.3 `list_sources() → Vec<SourceInfo>` · `set_source_enabled(id: String, enabled: bool) → SourceInfo`
Persisted in settings. BDIX starts disabled (PRD D8).

## 4. Resolver Domain

```rust
enum StreamKind { Direct, Hls }

struct Variant {
    id: String,               // opaque; e.g. playlist variant id
    label: String,            // "1080p"
    width: Option<u32>,
    height: Option<u32>,
    bitrate_kbps: Option<u32>,
}

struct ResolvedStream {
    url: String,
    headers: Map<String, String>,   // auth headers; forwarded to player/proxy
    kind: StreamKind,
    variants: Vec<Variant>,         // empty for Direct; master variants for Hls
    selected_variant: Option<String>,
    filename_hint: Option<String>,  // e.g. "Title.S01E02.1080p.mp4"
    size_bytes: Option<u64>,        // Direct only, when origin reports it
}
```

### 4.1 `resolve(content: ContentRef, variant: Option<String>, force_refresh: bool) → ResolvedStream`
Resolve-on-demand only — links are never resolved at search time (PRD §8). `force_refresh: true` re-resolves bypassing any short-lived cache; the Flutter player calls it this way on a 403/network playback error (one retry, then surface). Downloader/proxy perform their own re-resolve internally and never expose it here.

## 5. Subtitles Domain

```rust
struct SubtitleCandidate {
    provider: String,
    id: String,
    language: String,          // ISO 639 code
    title: Option<String>,
    score: Option<u32>,        // provider relevance, when available
    downloads: Option<u64>,
}

enum SubtitleFormat { Srt, Ass, Vtt }

enum SubtitleOrigin { Auto, Manual, Sibling }

struct SubtitleFile {
    path: String,              // local file, frontend passes to player as external track
    language: String,
    format: SubtitleFormat,
    origin: SubtitleOrigin,
}

struct SubtitleQuery {
    content: Option<ContentRef>,
    video_path: Option<String>,      // local playback (F11): filename matching
    language: String,                // ISO 639
}
```

### 5.1 `find_best_subtitle(query: SubtitleQuery) → Option<SubtitleFile>`
One-shot auto-subtitle (PRD F3): search providers, pick best by score, download, return. None found → `None` (UI falls back to manual search).

### 5.2 `search_subtitles(query: SubtitleQuery) → Vec<SubtitleCandidate>`
Manual search UI.

### 5.3 `download_subtitle(candidate: SubtitleCandidate) → SubtitleFile`

### 5.4 `find_sibling_subtitles(video_path: String) → Vec<SubtitleFile>`
Same basename, `.srt/.ass/.vtt` etc. (F11/F3).

## 6. History Domain

```rust
enum PlayableRef {
    Stream  { content: ContentRef, variant: Option<String> },
    LocalFile { path: String },
}

struct HistoryMeta {
    title: String,
    poster_url: Option<String>,
    duration_sec: Option<u64>,
    content: Option<ContentRef>,   // for dedupe keying on streams
}

struct HistoryEntry {
    playable: PlayableRef,
    title: String,
    poster_url: Option<String>,
    position_sec: u64,
    duration_sec: Option<u64>,
    updated_at: u64,
    available: bool,               // false when local file missing (PRD §8)
}
```

### 6.1 `record_play_started(playable: PlayableRef, meta: HistoryMeta) → ()`
Upsert; dedupes Stream entries on metadata key, LocalFile on path (PRD F5).

### 6.2 `update_playback_position(playable: PlayableRef, position_sec: u64, duration_sec: Option<u64>) → ()`
Frontend throttles calls: every 5 s during playback + on pause/stop/exit. Core additionally persists on graceful shutdown.

### 6.3 `list_continue_watching(limit: u32) → Vec<HistoryEntry>`
Newest-first, completed items (position ≥ 98% of duration) excluded.

### 6.4 `remove_history_entry(playable: PlayableRef) → ()` · `clear_history() → ()`

## 7. Downloads Domain

```rust
struct DownloadRequest {
    content: ContentRef,
    variant: Option<String>,
    dest_override: Option<String>,    // full path; None → PRD folder scheme
    auto_subtitle: bool,              // also fetch best subtitle (§5.1)
}

enum DownloadStatus {
    Queued,
    Preparing,                        // resolving / building HLS plan
    Running,
    Paused,
    Failed { resumable: bool, reason: String },
    Done,
}

enum DownloadStage { Fetching, Remuxing, Finalizing }

struct DownloadProgress {
    bytes_done: u64,
    total_bytes: Option<u64>,         // None for HLS-until-complete
    segments_done: Option<u32>,
    total_segments: Option<u32>,
    speed_bps: Option<u64>,
    stage: DownloadStage,
}

struct DownloadJob {
    id: String,
    request: DownloadRequest,
    status: DownloadStatus,
    progress: DownloadProgress,
    dest_path: String,
    created_at: u64,
}

struct DownloadFilter { status: Option<DownloadStatus>, include_done: bool }
```

### Functions
| Function | Semantics |
|---|---|
| `enqueue_download(request: DownloadRequest) → DownloadJob` | Adds to queue (concurrency from settings); returns immediately with `Queued` |
| `pause_download(id: String) → DownloadJob` | Persists resume state (range offset / segment index + remux point) |
| `resume_download(id: String) → DownloadJob` | Transparent re-resolve if link expired while dead (PRD F9) |
| `cancel_download(id: String) → ()` | Stops + removes partial files + job row |
| `delete_download(id: String, delete_file: bool) → ()` | For `Done` jobs; library/missing bookkeeping is history-side |
| `list_downloads(filter: Option<DownloadFilter>) → Vec<DownloadJob>` | |

### Events — `download_events() → Stream<DownloadEvent>` (§1 snapshot rule)
```rust
enum DownloadEvent {
    Snapshot(Vec<DownloadJob>),
    Started    { id: String },
    Progress   { id: String, progress: DownloadProgress },   // ≤ 4 Hz/job
    Paused     { id: String },
    Failed     { id: String, resumable: bool, reason: String },
    Done       { id: String, dest_path: String },
    Removed    { id: String },
}
```

## 8. Source Health — `source_health_events() → Stream<SourceHealthEvent>`
```rust
enum SourceHealthEvent {
    Snapshot(Vec<SourceInfo>),
    Changed { source: SourceInfo },
}
```
Emitted on status transitions (Healthy → Degraded → Unavailable, recovery, enable/disable).

## 9. Proxy Domain

```rust
struct ProxyLink {
    url: String,               // http://127.0.0.1:<port>/d/<token>/<job>/<filename>
    filename: String,
    kind: StreamKind,
    session_id: String,
    lifetime_note: String,     // user-facing: "valid while Theatre is running"
}

struct ProxySession {
    id: String,
    filename: String,
    bytes_served: u64,
    started_at: u64,
    active: bool,              // client connected
    prep: Option<DownloadProgress>,   // HLS prep job progress while building
}
```

### Functions
| Function | Semantics |
|---|---|
| `generate_download_link(content: ContentRef, variant: Option<String>) → ProxyLink` | Direct → pass-through session; HLS → starts prep job (spool+remux) and returns link immediately. Resolve errors → `TheatreError::Resolve` |
| `list_proxy_sessions() → Vec<ProxySession>` | Exit guard uses this (PRD F10) |
| `cancel_proxy_session(id: String) → ()` | Ends session, deletes spool |
| `proxy_status() → ProxyStatus` | Diagnostics panel: port + active count. Token never exposed here |

```rust
struct ProxyStatus { port: u16, active_sessions: u32, spool_bytes: u64 }
```

### Events — `proxy_events() → Stream<ProxyEvent>` (snapshot rule)
```rust
enum ProxyEvent {
    Snapshot(Vec<ProxySession>),
    SessionStarted  { session: ProxySession },
    SessionProgress { id: String, prep: Option<DownloadProgress>, bytes_served: u64 },
    SessionEnded    { id: String, reason: String },
}
```

## 10. Library Domain (local media)

```rust
struct LibraryLocation {
    id: String,
    display_name: String,
    root_uri: String,          // desktop: path; Android: content://… (SAF)
    added_at: u64,
}

struct LibraryEntry {
    name: String,              // display name
    uri: String,               // full URI/path to open
    is_dir: bool,
    is_playable: bool,         // video/audio extension filter
    size_bytes: Option<u64>,
}

struct BrowseResult { entries: Vec<LibraryEntry>, truncated: bool }
```

### Functions
| Function | Semantics |
|---|---|
| `add_library_location(root_uri: String, display_name: Option<String>) → LibraryLocation` | Desktop: path validation; Android: SAF grant persistence handled by frontend, URI stored here |
| `remove_library_location(id: String) → ()` | History entries remain (marked unavailable) |
| `list_library_locations() → Vec<LibraryLocation>` | |
| `browse_location(location_id: String, subpath: Option<String>) → BrowseResult` | Live view, no index; async; internal soft budget 3 s → `truncated: true` beyond (PRD F12) |
| `prepare_local_playback(path_or_uri: String) → LocalPlayback` | **S-1 spike seam (architecture §24).** Desktop: pass-through. Android: resolved URI, or cache-copied path when media_kit cannot open `content://` |

```rust
struct LocalPlayback {
    playable_uri: String,      // hand to media_kit
    siblings: Vec<SubtitleFile>,
    cache_copied: bool,        // true → frontend must not assume original path reachability
}
```

## 11. Settings Domain

```rust
enum VariantPreference { Ask, Highest, Lowest }

struct Settings {
    subtitle_language: String,        // ISO 639
    auto_subtitles: bool,
    download_root: String,
    download_concurrency: u8,         // 1–5, default 3
    default_variant: VariantPreference,
    theme: String,                    // "system" | palette ids
    minimize_to_tray: bool,           // desktop
    sources_enabled: Map<String, bool>,
}

struct SettingsPatch {                 // all Optional; only set fields update
    subtitle_language: Option<String>,
    auto_subtitles: Option<bool>,
    download_root: Option<String>,
    download_concurrency: Option<u8>,
    default_variant: Option<VariantPreference>,
    theme: Option<String>,
    minimize_to_tray: Option<bool>,
}
```

### Functions
`get_settings() → Settings` · `update_settings(patch: SettingsPatch) → Settings` (validates, persists, returns merged result) · `reset_settings() → Settings`

## 12. Error Catalog

```rust
enum TheatreError {
    NotInitialized,
    InvalidArgument { field: String, reason: String },
    Source   { source: String, detail: String },
    Resolve  { detail: String, source: Option<String> },
    Network  { detail: String },
    Download { job_id: Option<String>, reason: String, resumable: bool },
    Proxy    { session_id: Option<String>, reason: String },
    Storage  { reason: String },
    Library  { path: String, reason: String },
    Subtitle { reason: String },
    Internal { message: String },
}
```

Rules: panics are converted to `Internal` at the boundary (architecture §6); every variant carries enough context to render its PRD-specified UI state; frontends never retry — retry policy lives in the core.

## 13. Change Policy

- **Within contract v1:** additive changes only — new functions, new optional fields, new enum variants *only if* frontends handle unknown variants (mandated: exhaustive matching is forbidden at the UI edge; default-case to a generic error/toast).
- **Breaking changes** (renames, removed fields, semantic changes) → contract major version bump + a migration section here, in the same task that changes code.
- **The contract is executable:** every type and function in this document requires a passing round-trip seam test (architecture §19) before its implementation task is considered done.

## 14. Milestone Requirements

| Milestone (architecture §23) | Required contract items |
|---|---|
| M1 — seam prototype | `init`, `shutdown`, `search` (fixture-backed stubs returning real types), `resolve` (stub), §3/§4 types, error round-trip |
| M2 — core extraction | `search`, `get_details`, `list_sources`, `set_source_enabled`, health stream (real) |
| M3 — playback slice | `resolve` (real), §5 subtitles, §6 history, `prepare_local_playback` (desktop path), `get/update_settings` |
| M4 — downloader | §7 complete |
| M5 — proxy | §9 complete |
| M6 — local media | §10 complete (Android path after S-1 spike) |
| M7 — TUI | consumes `api/` directly; no new items — parity verification only |
| M8 — release | full surface green on seam tests |

## 15. Reserved — P1+ Surface (defined now, **not** implemented in P0)

```rust
// F14 Live TV
struct Channel { id: String, name: String, logo_url: Option<String>, stream_url: String, headers: Map<String,String> }
fn load_iptv_playlist(uri: String) → Vec<Channel>

// F15 Stremio addons
fn add_addon(manifest_url: String) → SourceInfo          // id: "addon:<id>"
fn remove_addon(id: String) → ()

// F13 batch
fn enqueue_season(content: ContentRef, season: u32, episodes: Option<Vec<u32>>) → Vec<DownloadJob>

// F16 yt-dlp — resolver chain internal; no surface change. Reserved for:
fn check_ytdlp_update() → Option<String>                 // version string if update available
```

---
