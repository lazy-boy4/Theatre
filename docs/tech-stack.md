# tech-stack.md — Theatre

**Version:** 1.0
**Status:** Agent-ready. This document pins every toolchain and dependency, defines fallback/swap paths, and sets upgrade policy. 
**For AI agents:** No new dependency (Dart, Rust, or binary) may be added without an entry in this document — added *in the same task*, with rationale and fallback. Dependency version bumps never ride along with feature tasks; they are standalone PRs that update this file and the lockfiles together. CI builds with `--frozen` / `--locked`; the committed lockfiles are the truth.

**Related:** `prd.md` v1.1 · `architecture.md` v1.0 · `data-contract.md` 1.0.0

---

## 1. Pinning Policy

- **Stable channels only.** Rust `stable`, Flutter `stable`. No beta, no nightly, no forks.
- **Lockfiles are committed and authoritative:** `app/pubspec.lock`, `core/Cargo.lock`, `tui/Cargo.lock` (workspace shares one). The version columns below record the *pinned-at-M0* line; the lockfiles record the exact resolution.
- **M0's first scaffold task** resolves and commits all lockfiles; any "latest" entry below becomes concrete at that moment.
- **MSRV:** current Rust stable minus two minors; CI compiles against the pinned stable only.

## 2. Toolchains

| Tool | Version line | Notes |
|---|---|---|
| Rust | stable (1.98.1, `rust-toolchain.toml` = `stable`) | rustup-managed; bumped from 1.85.0 pin to match CI + machine |
| Flutter | stable (3.47.2, Dart 3.13.2) | Desktop + Android targets; no web target【turn0search4】 |
| cargo-ndk | 4.1.x | Android cross-builds for `theatre-core`【turn0search18】 |
| Android SDK / NDK | build-tools 34.0.0+, NDK r26d | JDK 17 (temurin); NDK pinned in CI via nttld/setup-ndk@v1 |
| Gradle / AGP | Gradle 9.3.1 (wrapper), AGP 9.1.0 | Android Gradle build pipeline matching Flutter stable |
| flutter_rust_bridge_codegen | **must equal** runtime crate version exactly (2.13.0) | Codegen/runtime mismatch is a build failure, not a warning |

## 3. Flutter / Dart Dependencies (`app/`)

| Package | Pinned line | Purpose | Fallback / swap path |
|---|---|---|---|
| `flutter_riverpod` | 2.6.1 | State management (architecture §14) | None planned; versioned bumps only |
| `freezed` / `freezed_annotation` (+ `json_serializable` / `build_runner`) | 3.2.5 / 3.1.0 (json 6.9.0, runner 2.5.0) | `api/types.dart` models + `build.yaml` explicitToJson | Bumped 2.5→3.2 for Flutter 3.47 analyzer 8; `riverpod_generator` dropped (no `@riverpod` usage) |
| `json_annotation` | ^4.9.0 | Companion annotations for `json_serializable` | Standard paired dependency |
| `go_router` | current stable, locked at M0 | Adaptive shell routing | Navigator rewrite only on abandonment |
| `media_kit` | ^1.1.10 | Player API (architecture §10, PRD F2) | — |
| `media_kit_video` | ^1.2.4 | Video widget rendering surface | — |
| `media_kit_libs_video` | ^1.0.4 | libmpv+FFmpeg native bundle (video flavor — deliberately not the full audio bundle, for APK size) | `media_kit_libs` full only if a codec gap is proven in the device matrix |
| `volume_controller` | 3.6.1 (transitive via `media_kit_video`) | System volume control sync in player screen; requires `libasound2-dev` on Linux | Native platform channel or media_kit internal volume |
| `wakelock_plus` | ^1.2.9 | Screen wake lock during active playback (PRD F2) | `wakelock` if abandoned |
| `intl` | ^0.19.0 | Date, timestamp, and duration formatting for watch history and UI | Hand-rolled formatting helpers |
| `flutter_rust_bridge` (Dart runtime) | 2.13.0, matches codegen | FFI bindings runtime (JSON-string transport; see `theatre-ffi/src/api.rs`) | — |
| `material_3_expressive` | current stable, locked at M0 | **Token layer only** — features must never import it directly (PRD F4) | Swap target: official `material_ui` (pub.dev, standalone since Flutter 3.47) once M3E-expressive components ship there【turn0search4】【turn0search3】 |
| `file_picker` | current stable, locked at M0 | Open-file (F11) + Android SAF directory picking (F12) | Platform channels hand-rolled if unmaintained |
| `flutter_foreground_task` | current stable, locked at M0 | Android download/proxy foreground service (F9/F10) | `flutter_background`【earlier】 if abandoned |
| `tray_manager` | current stable, locked at M0 | Desktop minimize-to-tray (proxy lifetime, F10) | `system_tray` if abandoned |
| `path_provider` | ^2.1.4 | Data dirs for `InitConfig.data_dir` | — |
| `flutter_lints` (dev) | ^4.0.0 | Official Flutter analysis and lint rules | custom analysis_options |
| `test` (dev) | ^1.25.7 | Headless Dart test runner for contract & unit suites | `flutter_test` |

**No UI kit besides the token layer.** Feature code imports `lib/design/` widgets only — never `material_3_expressive` or `material` directly (enforced by lint rule added at M0).

## 4. Rust Dependencies (`core/`, `tui/`)

| Crate | Pinned line | Purpose | Notes |
|---|---|---|---|
| `tokio` | 1.53.x【turn0search8】 | Runtime: `rt-multi-thread`, `macros`, `net`, `fs`, `process`, `time`, `sync`, `signal` | Single runtime owned by `api/` (architecture §16) |
| `axum` | 0.8.x【turn0search15】 | Loopback proxy server | Bound `127.0.0.1:0`, token middleware (architecture §9) |
| `reqwest` | 0.12.x, locked at M0 | All outbound HTTP (sources, resolver, subtitles, proxy pass-through) | `rustls` 0.23.45 pinned (patched RUSTSEC-2026-0285); headers, redirects; per-host politeness in `net/` |
| `rusqlite` | 0.40.x【turn0search11】 | SQLite state store, **`bundled` feature** | One SQLite version everywhere; WAL + `busy_timeout=5000` |
| `serde` / `serde_json` | 1.x | Contract types, DB rows, spool manifests | — |
| `flutter_rust_bridge` | 2.13.0 | `theatre-ffi` boundary | Codegen version locked equal |
| `url` | 2.5.8 | Host parsing in `net/` + 4KHDHub link joins | `percent-encoding` 2.x direct (url's own decoder; replaces hand-rolled codec) |
| `hmac` / `md-5` (`md5`) / `base64` | 0.12.1 / 0.10.6 / 0.22.1 | MovieBox request signing, inherited from upstream `crypto.rs` | Upstream-inherited per §4 rule; no fallback (unsigned requests 403) |
| `async-trait` / `async-stream` / `bytes` | 0.1.92 / 0.3.6 / 1.12.1 | `Source` trait, spool streaming, body bytes | Were undeclared-but-used; now pinned |
| `criterion` | 0.5.1 (dev only) | `benches/core_bench.rs` | HTML reports; CI comments P50/P99 on PRs |
| `thiserror` | 2.x | `TheatreError` definitions | — |
| `ratatui` + `crossterm` | 0.30.x【turn0search18】 | TUI frontend | Inherited from upstream MovieBox-TUI patterns |
| `scraper` | current stable, locked at M0 | HTML parsing in `sources/` | **Inherit the exact crate choices of upstream MovieBox-TUI wherever its scrapers already depend on one** — divergence is re-review |
| `rand` | 0.9.x | Proxy session tokens (128-bit) | `rand::rng().random()` (0.9 API; no `getrandom` feature) |
| `uuid` | 1.x, v7 | Job/session/location IDs | — |
| `futures` | 0.3.x | StreamExt in direct downloader; `tokio-stream` was dropped during M0/M1 ponytail audit as dead dependency (`tokio::sync` + `futures` covers streaming without it) | — |

**Async-trait is used minimally** (`Source` trait only); no dyn-heavy abstraction layers in the core — scrapers stay as isolated per-source impls behind the registry.

**Note on `tokio-stream` removal:** Evaluated during M0/M1 ponytail audit; dropped from workspace dependencies as zero crates imported it and all core streaming needs are met via `futures::StreamExt` and `tokio::sync`.

## 5. Native Binaries & System Libraries

| Binary / Library | Source | Platforms | Notes |
|---|---|---|---|
| libmpv + FFmpeg (as libraries) | `media_kit_libs_video` bundles / system `libmpv-dev`【turn0search3】 | All targets | Bundled automatically on Windows/Android by the package; Linux links dynamically against system `libmpv-dev` + `mpv` (installed in CI) |
| ALSA sound headers | `libasound2-dev` (system) | Linux | Required by `volume_controller` for Linux desktop volume control (installed in CI) |
| **ffmpeg CLI sidecar** | Pinned release, checksummed in `vendor/ffmpeg/MANIFEST` (SHA256 per file) | Windows x64, Linux x64, Android arm64-v8a / armeabi-v7a / x86_64 | Desktop: well-known static builds (e.g., gyan.dev / johnvansickle lines); Android: prebuilt ARM FFmpeg binaries (mobile-ffmpeg lineage)【turn0search9】. Invoked via `tokio::process` with `-progress pipe:1` parsing (architecture §9.3) — no linked C |
| yt-dlp sidecar | *(P1)* pinned release, same MANIFEST scheme | Desktop only | Auto-update channel designed at F16 time (architecture S-3) |

Rule: sidecar binaries are located **relative to the core library at runtime, never via `PATH`** (architecture §20). The MANIFEST checksums are verified at packaging time by CI.

## 6. Explicitly Not Used

No analytics or crash-reporting SDKs · no Firebase / Google Play services · no ads SDKs · no code-push/hot-update frameworks · no telemetry of any kind (PRD §7). This list exists so agents have a documented answer when a task "would be easier with" one of these: the answer is no.

## 7. Watch Items

| Item | Trigger | Action |
|---|---|---|
| Official `material_ui` M3E-expressive components (pub.dev, standalone since Flutter 3.47)【turn0search4】 | Components Theatre uses ship there | Token-layer internals swap; features untouched (PRD F4 swap path) |
| `media_kit` web header limitations | N/A — web is a non-goal | Recorded for future reconsideration only |
| frb v2 codegen/runtime drift | Any version mismatch error in CI | Hard-fail; re-pin both together |
| Upstream MovieBox-TUI scraper crate changes | Monthly upstream sync (architecture §15) | Inherit; re-run fixture tests |

## 8. Upgrade Policy

1. Bumps are standalone PRs: this file + lockfiles + CI green in one commit.
2. Minor/patch bumps: any contributor/agent may propose.
3. Major bumps: require a `architecture.md` §22 table update in the same PR and a note here on why.
4. Never upgrade to unpin a broken integration mid-task — fix forward at the pinned version; the upgrade PR is separate.

---
