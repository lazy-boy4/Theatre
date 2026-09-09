# prd.md — Theatre

**Version:** 1.1 (Final — all product decisions resolved; adds local media playback & library per D10)
**Status:** Agent-ready. This document is the single source of truth for product scope.
**For AI agents and contributors:** Implement exactly what is specified here, in the stated priority order. Do not invent features. If a task appears to conflict with this document, escalate via Section 12 rather than improvising. Every implementation task must leave the relevant sibling doc (`architecture.md`, `design.md`, `data-contract.md`, `tech-stack.md`) updated.

**Related documents:** `architecture.md` (system design), `design.md` (UI/UX spec), `data-contract.md` (Rust↔Flutter API), `tech-stack.md` (pinned dependencies), `roadmap.md` (milestones), `AGENTS.md` (agent instructions).

---

## 1. Vision

**Theatre** is a cross-platform app (Windows, Linux, Android) for finding, streaming, and downloading movies, TV shows, anime, and live TV from user-selected community sources — and for playing media you already own. It pairs the battle-tested Rust scraping engine of MovieBox-TUI with a modern Material 3 Expressive graphical interface, hardware-accelerated in-app playback (libmpv), a unified local download pipeline (in-app downloads + external download-manager hand-off), local media playback and folder browsing, and an optional terminal interface for power users.

**One-line pitch:** *"MovieBox-TUI's engine, with a face — finds it, plays it, downloads it, and plays what you already have."*

## 2. Problem Statement

| User pain today | Why it persists | Theatre's answer |
|---|---|---|
| Streaming sites are ad-heavy, slow, hostile in mobile browsers | Sites monetize via ads; no incentive to improve | Client-side scraping: clean search, direct playback, zero ads |
| MovieBox-TUI is powerful but terminal-only | TUIs exclude most users | GUI frontend sharing the same Rust core |
| Android players play well but can't *find* content | Finders and players are separate apps | Search → play → download in one app |
| Downloading from these sources with external tools (IDM etc.) is fragile: links expire, HLS doesn't paste, auth headers are missing | No tool bridges scrapers and download managers | Built-in download proxy serving a clean, direct, unexpiring-to-the-customer link |
| Your existing collection and your streaming tools live in different apps | Library managers (Kodi/Jellyfin) are heavyweight; players are dumb | Lightweight folder browsing + open-file playback built into the same app |

## 3. Target Users

| Persona | Device | Behavior | Needs |
|---|---|---|---|
| **Couch Streamer** | Android phone/tablet | Search, watch, download for offline; zero configuration tolerance | Touch-first M3E UI, auto-subs, continue-watching, reliable downloads |
| **Desktop Power User** | Windows/Linux | Keyboard-driven, downloads whole seasons, may prefer terminal, may use IDM, has an existing collection | TUI option, shortcuts, download manager, proxy links, folder library |
| **Tinkerer** | Any | Adds custom IPTV playlists, Stremio addons, experiments with sources | Source management UI, addon mode, settings depth |

**Anti-persona (explicitly not served):** users seeking a licensed official content catalog (Netflix-style), or users wanting a full home-media server (Plex/Jellyfin-style scanning, posters, transcoding). Theatre is a *client*, not a media server or library manager.

## 4. Platforms

| Platform | Priority | Notes |
|---|---|---|
| Android (arm64-v8a, armeabi-v7a, x86_64) | P0 | Split-ABI APKs; libmpv+FFmpeg bundle size managed via modular native libs; scoped-storage compliant folder access (SAF) |
| Windows (x64) | P0 | GUI + bundled TUI binary in one installer |
| Linux (x64) | P0 | AppImage + deb; GUI + bundled TUI |
| macOS / iOS | Deferred to P2 | **Not in v1.** Codebase must remain portable: no platform-specific shortcuts that block later adoption. No packaging work in v1. |
| Web | Non-goal | media_kit's web backend cannot forward auth headers; scraping breaks under CORS |
| Android TV / lean-back | Non-goal v1 | Different interaction paradigm |
| Termux (Android) | Supported via companion | The TUI runs in Termux as a separate install; the Android APK cannot embed a terminal app |

## 5. Core User Journeys

1. **Search & stream (primary):** open Theatre → type query → results grid → details (poster, synopsis, cast, episodes) → play → controls (seek, speed, tracks, subs) → exit → resume from history later.
2. **Download & watch offline:** details → choose quality (if multi-variant) → **either** in-app download (progress, pause/resume) **or** "Copy link for external manager" → paste into IDM/aria2/browser, which sees an ordinary resumable file → watch from library without network.
3. **Play your own media:** "Open file" from anywhere → plays instantly with auto-loaded sibling subtitles; **or** add a folder as a Library location → browse it inside Theatre → play; watched local files appear in Continue Watching.
4. **Live TV (P1):** settings → add IPTV playlist (M3U URL/file) → Live TV mode → channel grid → zap.
5. **Source management:** settings → enable/disable sources → per-source health status → switch provider in-place from details screen.
6. **Terminal flow (desktop):** identical core journeys via the bundled TUI binary (parity defined in F7; local playback by file path).

## 6. Feature Specification

### P0 — Required for v1.0

| # | Feature | Description | Definition of done |
|---|---|---|---|
| F1 | Multi-source search & browse | Sources: MovieBox, 4KHDHub (default-on), BDIX (opt-in; geo/ISP-locked). Search, paged results, details with seasons/episodes, in-place provider switching | Search on 2+ sources returns results < 5 s on broadband |
| F2 | In-app playback (libmpv via media_kit) | Hardware-accelerated decode with software fallback, audio-track & subtitle-track switching, auth-header forwarding, seek, playback speed, aspect/fill modes | 1080p smooth on mid-range Android; header-protected sources play; live streams play |
| F3 | Automatic subtitles | Search subtitle providers, download, load, sync; language preference; manual search fallback UI; applies to streams **and local files** (matched by filename) | Subtitle auto-loads for popular titles in chosen language; sibling-file subtitles auto-load |
| F4 | Adaptive Material 3 Expressive UI | Community `material_3_expressive` package behind a **token-abstraction layer** (swap path to official Flutter M3E when it ships). Responsive window-size classes: NavigationBar (compact) → NavigationRail (medium) → NavigationDrawer (expanded) | One codebase renders correctly on phone, tablet, desktop window |
| F5 | Local watch history & resume | Continue-watching row; resume position per item — streams/downloads keyed on metadata (dedupe across sources), local files keyed on file path | Resuming returns within ±2 s; history survives restarts |
| F6 | Settings hub | Player defaults, download root folder, Library locations, subtitle language, sources on/off, themes, modes | All P0 features configurable; settings persist and migrate across versions |
| F7 | TUI sibling frontend | Ratatui frontend sharing the Rust core; bundled in Windows/Linux installers; Termux path documented on Android | Core parity: search (F1), playback launch (F2), history (F5), downloads (F9), proxy link display (F10), local playback by path (F11) |
| F8 | Source-level failure isolation | One broken source never blocks others; per-source health status (healthy/degraded/unavailable); auto re-resolve on playback failure | Killing one source's network in testing leaves others fully functional |
| F9 | In-app download manager | Unified pipeline: **direct-file streams** (native HTTP, range resume) **and HLS streams** (segment fetch + remux). Queue with configurable concurrency, pause/resume/cancel, speed/ETA progress, restart-surviving queue, transparent re-resolve of expired links on resume. Storage: user-selectable root, `Movies/` & `Series/` structure, collision-safe naming, pre-flight space check. Background: Android foreground service with progress notification; desktop continues while app runs | A 1-hr HLS title downloads end-to-end without manual intervention, including recovery from an injected link expiry |
| F10 | Download proxy | Built-in local HTTP server (Rust core): loopback-only, auto-selected free port, per-session random token in URL. "Copy download link" on any downloadable title yields `http://127.0.0.1:PORT/…` that any external manager (IDM, aria2, FDM, curl, browser) treats as a normal resumable file. Proxy responsibilities: inject source auth headers, transparently refresh expiring upstream links (re-resolve on 403/expiry), convert HLS to a single progressive file on the fly (MP4; MKV fallback when codecs require), honor HTTP Range where the underlying file allows. Quality/variant picker honored for multi-variant HLS. Lifetime: served while Theatre runs — desktop "minimize to tray" option keeps it alive; Android foreground service during active external sessions. Exit guard warns when sessions are active. URLs invalid after restart (tokens rotate) | External manager (e.g., IDM) completes an HLS title via generated link while Theatre runs; link survives an upstream link-expiry event |
| F11 | Local media playback ("Open file") | System file picker → play any local video/audio file through the same libmpv engine; sibling subtitle files (`.srt`, `.ass`, etc.) auto-load; watched files enter history (F5) | Any common format (MKV/MP4/AVI/WebM…) plays from picker; sibling `.srt` loads automatically |
| F12 | Local library browsing | User adds device folders as **Library locations** (Android: SAF folder grants; desktop: filesystem paths). Library screen lists locations and browses folder contents with video-file filtering; live view — no database index, contents reflect the folder on each browse; deleted/moved files show a graceful "missing" state; scans are lazy/async so huge folders never freeze the UI. Library locations browsed alongside downloads in one library area | A folder of mixed media browses and plays on Android (scoped storage) and desktop; deleting a file externally is reflected without crash or stale entry |

### P1 — Fast-follow (v1.x)

| # | Feature | Notes |
|---|---|---|
| F13 | Season batch downloads | One-tap enqueue of entire season/episode ranges (queue engine already P0; this is the convenience layer) |
| F14 | Live TV mode | Custom IPTV playlists (M3U URL/file), channel grid, zapping, last-channel memory. Playback only — no live recording |
| F15 | Stremio HTTP addon support | Addon catalogs browsable alongside built-in sources |
| F16 | yt-dlp sidecar fallback (desktop) | Resolver chain: primary scrapers → yt-dlp (`--dump-json` parsed in Rust); auto-update for the sidecar binary |
| F17 | PiP + background playback (Android) | Audio continues in background; picture-in-picture video |
| F18 | Theme pack | 6 palettes (Catppuccin, Tokyo Night, Nord, Dracula, Gruvbox, Rosé Pine) as M3E color schemes; terminal-theme autodetect on desktop |
| F19 | External player hand-off | Optional "open in mpv/VLC" preserving MovieBox-TUI's original model |

### P2 — Future

macOS/iOS ports · network shares (SMB/NFS/WebDAV library locations) · Trakt/AniList sync · Chromecast · remote/OTA scraper updates (decouple source fixes from app releases) · UI localization · profiles/parental controls · Android TV lean-back UI.

## 7. Non-Goals

- **No content hosting, indexing, or server component.** Pure client. Zero content shipped, nothing indexed.
- **No DRM content.** DRM'd streams are neither playable nor downloadable; AES-128 HLS *is* supported (standard HLS encryption with source-provided keys).
- **No torrent/P2P streaming.**
- **No media-server features** (transcoding, library sharing, remote access — Jellyfin/Plex territory).
- **No full local-library manager.** No metadata scraping, poster walls, or watch-state management for the user's own collection (Kodi/Emby territory). Theatre's local library is folder browsing + playback, not collection management.
- **No network shares in v1** (SMB/NFS/WebDAV). Local storage only; network locations are a P2 candidate.
- **No live-stream recording.** Proxy HLS→file conversion applies to VOD only; live channels are playback-only.
- **No proxy as a sharing server.** Loopback-only, single-user, no LAN exposure.
- **No accounts, cloud sync, monetization, ads, or trackers.**
- **No Google Play distribution** (incompatible with store policy for scraping clients); GitHub Releases + IzzyOnDroid/F-Droid only.
- **No web build.**

## 8. Edge Cases & Failure Handling

This section is binding — these behaviors are requirements.

**Sources & content:**
- Source layout change → scraper fails → source marked *degraded*, status surfaced, others unaffected. Never a global error state.
- Geo/ISP-locked source (BDIX outside coverage) → not enabled by default; explanatory status when enabled and unreachable, not generic failure.
- Signed/expiring upstream links → resolve-on-play and resolve-on-download (never resolve-on-search); on 403/expiry, auto re-resolve once before surfacing an error; mid-download segment failures retry then re-resolve the playlist.
- Auth-required sources → headers flow from scraper → core → player engine (playback) and → proxy (downloads).
- Rate limiting → polite request spacing; brief search-result caching; never hammer a source in retry loops.

**Playback:**
- Hardware decode unavailable → automatic software decode via libmpv; noted in playback info.
- Live vs VOD → control set adapts (no seek bar on live).
- No network at launch → offline mode: local library, history, downloads accessible, clear connectivity banner, search disabled gracefully.

**Local media (F11/F12):**
- Android scoped storage → Library folders via SAF grants; "Open file" via system picker; permission denial → actionable guidance, never a crash. (Evaluate `MANAGE_EXTERNAL_STORAGE` in `architecture.md` given non-Play distribution; SAF is the compliant baseline.)
- Sibling subtitles → `.srt`/`.ass`/`.vtt` with matching basename auto-load; user can pick a different subtitle file manually.
- Missing/moved/deleted files → Library shows "missing" state on next browse; history entries for missing local files display but mark the file unavailable.
- Large folders → lazy, async, cancellable scans; UI never blocks; no full-disk indexing.
- Exotic filenames (unicode, very long paths) → handled; on Android, SAF document IDs abstract real paths.
- Same title as a stream/download → local playback keeps its own history entry (keyed on path); stream/download entries dedupe on metadata (F5).

**Download manager (F9):**
- Interruption (network/app kill/OS kill) → queue survives restart; resume via range (direct) or segment-index (HLS).
- Link expired while paused → transparent re-resolve then resume; user never sees the link lifecycle.
- Segment failures → ≤ 3 retries per segment with backoff; persistent failure → download marked failed at a resumable point, surfaced with reason.
- Remux failure (corrupt segment after retries) → partial file kept with resume metadata; error surfaced.
- Storage full / permission denied (Android scoped storage) → pre-flight check, actionable error.
- Filename collisions → suffix scheme, never overwrite.
- > 4 GB download onto FAT32 target → detected and warned before start.

**Download proxy (F10):**
- Default port occupied → auto-select a free port; generated links always reflect the live port.
- Security → loopback bind only; per-session random token; non-token requests rejected; no directory listing; tokens rotate per app launch.
- External manager disconnects mid-download (user pauses in IDM) → proxy session stays alive while Theatre runs; reconnect resumes.
- Multiple concurrent proxy sessions → allowed; upstream fetching queued politely.
- App exit with active sessions → desktop: warning dialog; Android: foreground-service notification; sessions end at exit, re-offered on relaunch.
- HLS with multiple variants → quality picker before link generation; remembered preference.
- HLS with embedded audio tracks → default track selection honors playback preferences; advanced track picking is P1.

**State:**
- App update changes config format → settings migration with defaults for new keys; history/folders/Library locations never lost.
- Same title on two sources → single history entry keyed on metadata; resume remembers last-used source.
- Scraper API changes with app version → scrapers versioned with the app; remote updates are the P2 decoupling.

## 9. Success Criteria (v1.0)

- Search → playback ≤ 10 s on mid-range Android over Wi-Fi.
- 1080p smooth on mid-range Android; 4K on capable desktops.
- One source breaking never degrades another (verifiable in test).
- In-app download of a 1-hour HLS title completes unattended, including recovery from an injected link expiry.
- An external manager (e.g., IDM) completes an HLS title via a generated proxy link while Theatre runs.
- A local MKV plays via Open file with auto-loaded sibling subtitles; a Library folder browses and plays under Android scoped storage.
- Crash-free sessions > 99 %.
- Offline playback of downloads and local files fully functional.
- TUI and GUI both complete the primary journey end-to-end.

## 10. Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| The download proxy + HLS pipeline is the largest P0 subsystem | High (scope) | It is *the* unified pipeline — one code path for in-app and external downloads; milestone-ordered immediately after the FFI seam prototype; local-server + remux is a proven pattern (Stremio-style local servers, yt-dlp-style HLS handling) |
| Source rot (sites change/break) | High, certain over time | Scraper module isolation; shared maintenance with upstream MovieBox-TUI; P2 remote updates |
| Android storage permission friction (scoped storage vs. folder browsing) | Medium | SAF folder grants as the compliant baseline; document MANAGE_EXTERNAL_STORAGE trade-off in architecture given non-Play distribution |
| Legal posture | Medium | Client-only architecture, zero bundled content, first-run disclaimer, GitHub/F-Droid distribution only; name availability check pre-release |
| `material_3_expressive` community package drifts while official M3E is pending in Flutter | Medium | Mandatory token-abstraction layer (F4); swap path to official Material |
| Rust↔Flutter FFI complexity in a beginner-led, AI-built codebase | Medium | Phase-1 throwaway prototype validates the seam before build-out; seam tests required |
| libmpv loading quirks on some Android devices | Medium | Split-ABI builds; device test matrix; modular native libs |
| AI-agent code drift | Medium | This PRD + sibling docs as agent context; one-demoable-outcome-per-task; doc updates mandated per task |

## 11. Distribution & Positioning

- **Desktop:** GitHub Releases — Windows installer + Linux AppImage/deb, each bundling GUI + TUI.
- **Android:** GitHub Releases (per-ABI APKs) + IzzyOnDroid/F-Droid repository.
- **Positioning:** personal-use, open-source media *client* for user-selected community sources and the user's own local files; not affiliated with any source; provides no content. First-run in-app disclaimer.
- **License:** dual MIT/Apache-2.0 (matches upstream MovieBox-TUI, compatible with all planned dependencies).

## 12. Decision Log (all resolved)

| ID | Decision | Resolution |
|---|---|---|
| D1 | App name | **Theatre** (working name confirmed; availability check on pub.dev/GitHub/domains is a pre-release task, not a dev blocker) |
| D2 | Platforms v1 | Windows, Linux, Android. macOS/iOS deferred to P2; portability preserved |
| D3 | Downloads | P0 with unified local-proxy pipeline |
| D4 | External download mechanism | **Option B — built-in proxy** (chosen over clipboard-copy) |
| D5 | HLS downloads in v1 | **Yes — both direct and HLS in v1** (chosen) |
| D6 | Live TV | P1 |
| D7 | License | Dual MIT/Apache-2.0 |
| D8 | Default sources | MovieBox + 4KHDHub default-on; BDIX opt-in; addons opt-in |
| D9 | Batch downloads | Queue engine P0; one-tap season batch P1 (promotable on request) |
| D10 | Local media | Tier A (open-file) + Tier B (folder library) at **P0**; Tier C (full library manager) is a non-goal; local storage only |
| D11 | Network shares | Non-goal v1; SMB/NFS/WebDAV listed as P2 candidates |

## 13. Glossary

- **Source / provider:** scraped site or API yielding searchable content and stream links.
- **Resolver:** core logic converting a content ID into a playable/downloadable stream URL.
- **Direct stream:** single resumable file URL (MP4/MKV over HTTP).
- **HLS:** HTTP Live Streaming — `.m3u8` playlist pointing to short segments; downloaded by fetching segments and remuxing into one file.
- **Remux:** re-packaging stream data into a container (MP4, or MKV when codecs require) without re-encoding.
- **Variant:** one quality option (resolution/bitrate) within a multi-variant HLS master playlist.
- **Proxy (Theatre's):** built-in loopback HTTP server serving clean, direct, token-protected download URLs to any download manager.
- **Sidecar:** bundled external binary invoked by the core (yt-dlp, P1).
- **Stremio addon:** HTTP catalog addon protocol, optional source type.
- **IPTV / M3U:** user-supplied live-TV playlist format.
- **Library location:** a user-added local folder browsable in Theatre's library (no indexing, live view).
- **SAF:** Android Storage Access Framework — the scoped-storage mechanism for granting per-folder access.
- **M3E:** Material 3 Expressive.
- **Token abstraction:** internal theming layer isolating M3E specifics for future swap to official Flutter Material.
- **Foreground service (Android):** OS mechanism keeping work alive with a user-visible notification while Theatre is backgrounded.

---
