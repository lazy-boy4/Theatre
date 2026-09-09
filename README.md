# Theatre

> **"MovieBox-TUI's engine, with a face — finds it, plays it, downloads it, and plays what you already have."**

[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Windows%20%7C%20Linux-blue)](docs/prd.md)
[![License](https://img.shields.io/badge/license-MIT%20%2F%20Apache--2.0-green)](LICENSE-MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter)](app/pubspec.yaml)
[![Rust](https://img.shields.io/badge/Rust-1.83%2B-orange?logo=rust)](core/Cargo.toml)

Theatre is a cross-platform, open-source media *client* for finding, streaming, and downloading movies, TV shows, anime, and live TV from user-selected community sources — and for playing media you already own. It pairs the battle-tested Rust scraping engine of [MovieBox-TUI](https://github.com/mesamirh/MovieBox-Tui) with a modern Material 3 Expressive interface, hardware-accelerated in-app playback, a unified download pipeline with an external-manager proxy, and an optional terminal frontend for power users.

**Status:** in active development. See [docs/roadmap.md](docs/roadmap.md) for milestones and progress.

---

## Features

- **Multi-source search & browse** — MovieBox and 4KHDHub on by default, BDIX opt-in; paged results, details with seasons/episodes, in-place provider switching, per-source health.
- **In-app playback** — hardware-accelerated via libmpv (`media_kit`), audio/subtitle tracks, auth-header forwarding, seek, speed, aspect modes, auto re-resolve on expired links.
- **Automatic subtitles** — provider search, download, sync, and sibling-file detection for local media.
- **Download manager + proxy** — direct and HLS downloads with pause/resume, plus a loopback HTTP proxy that hands any external manager (IDM, aria2, curl) a clean, resumable link.
- **Local library** — open any file, or add folders as library locations (SAF on Android); watched files join Continue Watching.
- **Adaptive UI** — one codebase renders phone, tablet, and desktop (`NavigationBar → NavigationRail → NavigationDrawer`), governed by [docs/design.md](docs/design.md).
- **TUI sibling** — a Ratatui terminal frontend sharing the same Rust core (desktop + Termux).

What Theatre is *not*: a content host, a DRM circumvention tool, a torrent client, a media server, or a Play Store app. See [docs/prd.md §7](docs/prd.md) (non-goals) and the first-run in-app disclaimer.

---

## Repository layout

This is a **monorepo with three builds**. Commands run from the directory shown — not the repo root.

| Directory | What lives here | Commands run from |
|---|---|---|
| [`app/`](app/) | Flutter UI (Riverpod, `media_kit`, M3E token layer in `lib/design/`) | `cd app` → `flutter …`, `dart …` |
| [`core/`](core/) | Rust workspace (`theatre-core`, `theatre-ffi`, FFI codegen config) | `cd core` → `cargo …`, `flutter_rust_bridge_codegen …` |
| [`tui/`](tui/) | Ratatui terminal frontend | `cd tui` → `cargo …` |
| [`vendor/`](vendor/) | Pinned sidecar binaries (ffmpeg, yt-dlp) + SHA256 manifests | — (binaries, not builds) |
| [`docs/`](docs/) | PRD, architecture, data contract, tech stack, roadmap, design system | — |
| [`scripts/`](scripts/) | Build/CI helper scripts | see [scripts/README.md](scripts/README.md) |

> **"No pubspec.yaml file found"?** You ran a Flutter command from the repo root. Flutter commands must run from `app/` (`cd app` first); Rust commands from `core/`. The root holds no Flutter or Cargo project by design.

---

## Getting started

### Prerequisites

| Tool | Version | Install |
|---|---|---|
| Rust | 1.83+ | `rustup` |
| Flutter | 3.24+ | [flutter.dev](https://flutter.dev) |
| `flutter_rust_bridge_codegen` | 2.13.0 (pinned, must equal runtime) | `cargo install flutter_rust_bridge_codegen --version 2.13.0` |
| Android NDK | r26d (Android builds only) | Android Studio SDK Manager |
| ffmpeg sidecar | 7.x | [BUILD.md](BUILD.md#vendor-ffmpeg) |

### Run the app (Windows / Linux)

```bash
# 1. Generate the Rust↔Dart bridge (from core/)
cd core
flutter_rust_bridge_codegen generate

# 2. Get packages + generate models (from app/)
cd ../app
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 3. Run
flutter run -d windows   # or: linux
```

### Run the TUI

```bash
cd core && cargo build --workspace --locked
cargo run -p theatre-tui
```

### Android APK (per-ABI)

```bash
cd core
cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 \
  -o ../app/android/app/src/main/jniLibs build --release
cd ../app
flutter build apk --split-per-abi
```

### Verify a change

```bash
# Rust (from core/)
cargo test --workspace --locked
cargo clippy --workspace --all-targets -- -D warnings

# Flutter (from app/)
flutter analyze
flutter test
```

Full details (scraper extraction, benchmarks, sidecar vendoring) live in [BUILD.md](BUILD.md).

---

## Documentation

| Document | Purpose |
|---|---|
| [docs/prd.md](docs/prd.md) | Product requirements & feature spec (**source of truth for scope**) |
| [docs/architecture.md](docs/architecture.md) | System design & component boundaries |
| [docs/data-contract.md](docs/data-contract.md) | Rust↔Flutter FFI surface (types, functions, events, errors) |
| [docs/tech-stack.md](docs/tech-stack.md) | Pinned dependencies & upgrade policy |
| [docs/roadmap.md](docs/roadmap.md) | Milestones, task queue, gates, progress |
| [docs/design.md](docs/design.md) | UI/UX system — "The Honest Projector" (tokens, states, copy rules) |
| [AGENTS.md](AGENTS.md) | Instructions for AI-agent sessions in this repo |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution rules |
| [SECURITY.md](SECURITY.md) | Security policy |

---

## Distribution

- **Desktop:** GitHub Releases — Windows installer + Linux AppImage/deb, each bundling GUI + TUI.
- **Android:** GitHub Releases (per-ABI APKs) + IzzyOnDroid/F-Droid repository.
- **Never** Google Play (incompatible with store policy for scraping clients).

## License

Dual-licensed under [MIT](LICENSE-MIT) and [Apache 2.0](LICENSE-APACHE) — matching upstream MovieBox-TUI. See [docs/prd.md §11](docs/prd.md) for distribution policy and positioning.
