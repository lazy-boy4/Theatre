# Theatre — Build Guide

## Prerequisites

| Tool                    | Version       | Install |
|-------------------------|---------------|---------|
| Rust                    | 1.83+         | `rustup` |
| Flutter                 | 3.24+         | flutter.dev |
| flutter_rust_bridge_codegen | 2.12+   | `cargo install flutter_rust_bridge_codegen` |
| Android NDK             | r26d (Android)| Android Studio SDK Manager |
| ffmpeg sidecar          | 7.x           | See [Vendor FFmpeg](#vendor-ffmpeg) |

## Quick Start

```bash
# 1. Clone
git clone <your-repo>
cd theatre

# 2. Generate Dart FFI bridge
cd core
flutter_rust_bridge_codegen generate
cd ..

# 3. Run Flutter code-gen (freezed + json)
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cd ..

# 4. Add scraper impls (T2.2-T2.4)
# Fork github.com/mesamirh/MovieBox-Tui, extract sources, see CONTRIBUTING.md

# 5. Run desktop
cd app && flutter run -d linux  # or macos / windows
```

## Android APK

```bash
cargo build --release --target aarch64-linux-android -p theatre-ffi
cd app && flutter build apk --release
```

## Rust Tests

```bash
cd core
cargo test --workspace               # unit + security tests
cargo bench -p theatre-core          # performance benchmarks
```

## Vendor FFmpeg

The ffmpeg sidecar must be placed beside the compiled binary:

```
app/
  bin/  (or platform bundle dir)
    theatre         # main executable
    ffmpeg          # ffmpeg 7.x static build
    ffprobe         # (optional)
```

Download a pre-built static binary from [ffmpeg.org/download](https://ffmpeg.org/download.html)
or build from `vendor/ffmpeg/` (see `vendor/ffmpeg/MANIFEST.md`).

## Generating Scraper Implementations (T2.2-T2.4)

1. Fork `github.com/mesamirh/MovieBox-Tui`
2. `git remote add upstream https://github.com/mesamirh/MovieBox-Tui.git`
3. Extract scraper logic into:
   - `core/crates/theatre-core/src/sources/moviebox.rs`
   - `core/crates/theatre-core/src/sources/khddhub.rs`
   - `core/crates/theatre-core/src/sources/bdix.rs`
4. Implement the `Source` trait for each.
5. Add fixture-backed tests (no live network in tests).

## Architecture Overview

```
 Flutter app (Dart)
     ↓ FFI (flutter_rust_bridge 2.x)
 Rust Core (theatre-ffi → theatre-core)
     ├── SourceRegistry  (fan-out search, health tracking)
     ├── Resolver        (resolve-on-demand, re-resolve on 403)
     ├── Downloader      (direct + HLS + ffmpeg remux, resume)
     ├── Proxy           (loopback Axum, 128-bit token)
     ├── Library         (lazy folder browsing, SAF on Android)
     ├── History         (SQLite, resume positions)
     ├── Subtitles       (provider search + download, sibling detect)
     └── State/DB        (SQLite WAL, 5s busy_timeout, migrations)
```
