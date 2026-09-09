# Theatre

> **"MovieBox-TUI's engine, with a face — finds it, plays it, downloads it,
> and plays what you already have."**

Theatre is a cross-platform app (Windows, Linux, Android) for finding,
streaming, and downloading movies, TV shows, anime, and live TV from
user-selected community sources — and for playing media you already own.

## Documentation Index

| Document | Purpose |
|---|---|
| [docs/prd.md](docs/prd.md) | Product requirements & feature spec |
| [docs/architecture.md](docs/architecture.md) | System design & component boundaries |
| [docs/data-contract.md](docs/data-contract.md) | Rust↔Flutter FFI surface |
| [docs/tech-stack.md](docs/tech-stack.md) | Pinned dependencies & upgrade policy |
| [docs/roadmap.md](docs/roadmap.md) | Milestones, tasks, and progress |
| [AGENTS.md](AGENTS.md) | AI agent session instructions |

## Platforms
- **Android** (arm64-v8a, armeabi-v7a, x86_64) — P0
- **Windows** (x64) — P0
- **Linux** (x64) — P0
- macOS / iOS — deferred to P2

## Tech Stack
- **Backend:** Rust (Tokio, Axum, rusqlite, flutter_rust_bridge)
- **Frontend:** Flutter (Riverpod, GoRouter, media_kit, Material 3 Expressive)
- **TUI:** Ratatui (from MovieBox-TUI fork)

## Build
```bash
# Rust core
cd core && cargo build --workspace --locked

# Flutter app
cd app && flutter run -d windows

# Android core (cross-compile)
cd core && cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 \
    -o ../app/android/app/src/main/jniLibs build --release
```

## License
Dual-licensed under [MIT](LICENSE-MIT) and [Apache 2.0](LICENSE-APACHE).
See the [docs/prd.md](docs/prd.md) §11 for distribution policy.
