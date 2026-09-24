# Research: sources seam (2026-09-10) — primary sources only

## Q1: Should `sources/` own fetch+parse+error-mapping per source, or parse helpers only?

Evidence:
- `sources/mod.rs:20-34` — `Source` trait = `search/get_details/resolve` per site (fetch+parse implied).
- `moviebox.rs:106-206,925-960` — fetch (`request_hosts`, 7-host fallback, 401/403 re-login) + `Source` impl in same file; `286-296` maps to `Source`/`Network`; `299+` pure `parse_*` (fixture-testable).
- `khddhub.rs:47-59,502-563` — `headers/fetch/search_url/detail_url` + `Source` impl; `32-37,468-479` error mapping (`Source`/`Resolve`); `79+` pure parsers via `util`.
- `bdix.rs:52-66,116-178,480-501` — `circle_*`/`dflix_*` fetch + merged `search`; `40-45` error mapping; `240+` pure parsers; `9` uses `util::{detect_quality,extract_year,quality_rank,sanitize_filename}`.
- `sources/util.rs:1-2,5,24,40,51` — "shared parsing primitives", all `pub(crate)`; no fetch, no errors.
- `net/mod.rs:1-4,104-132,142-154` — ALL HTTP via `NetClient`; per-host max-2 + 500ms; CR/LF header guard.
- `architecture.md §5` — `sources/` = "trait + per-source impls, search aggregation, health tracking"; `§15` — per-source impls isolated so one break degrades itself only; `§16` — politeness in `net/`.
- `prd.md F1/F8/§8/D8` — 3 sources (BDIX opt-in), failure isolation, resolve-on-play/download never search, polite spacing.
- `data-contract.md §3.1/§3.2/§4.1` — fan-out 8s + `partial`, single-source details, resolve-on-demand.
- `tech-stack.md §4/§7` — `scraper` crate inherits upstream; monthly upstream sync; `async-trait` minimal (`Source` only).

What sources actually say: per-file fetch+parse+error-mapping is the documented shape; `util/` is parse-only; transport policy lives in `net/`, aggregation/timeout in `registry.rs`.

Recommendation Q1: keep fetch+parse+error-mapping per source file; keep `util/` parse-only `pub(crate)`; no new parse-only seam.

## Q2: Should health stay a separate module interface or become registry-internal?

Evidence:
- `registry.rs:17-24,91-99,167` — owns `Arc<HealthTracker>`; only `mark_healthy/mark_degraded` (fan-out) + `get_status` (`list_sources`) call sites.
- `health.rs:1,9-12,22-55,57-64` — cache + `source_health` writes; default `Healthy`; header cites `data-contract.md §8`.
- `state/mod.rs:123-129` — `source_health(source_id,status,since,last_error,updated_at)` table.
- Grep `HealthTracker|mark_healthy|mark_degraded|get_status|source_health` (core/): only hits are the three files above — no other callers.
- `data-contract.md §8` — health is an event stream, no standalone API; `architecture.md §5` lists health under `sources/`, but `§15`'s `health()` trait sketch is NOT in `mod.rs:22-34` (divergence).

What sources actually say: health is persistence + cache backing `list_sources`/fan-out only; nothing else consumes `HealthTracker`.

Recommendation Q2: demote to registry-internal detail — keep `health.rs` file but `pub(crate)`, or fold into `registry.rs`; no public `pub mod health` interface.
