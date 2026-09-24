# roadmap.md — Theatre

**Version:** 1.0
**Status:** Agent-ready. This document is the delivery plan: every milestone from `architecture.md` §23 broken into agent-sized tasks. It is also the progress tracker — statuses live here.
**For AI agents:** Work ONLY tasks in your lane marked `todo`, in listed order, respecting dependencies. One task per session, one demoable outcome per task. Every completed task must (a) demo its outcome, (b) pass its seam tests, (c) update this file's status, and (d) update the docs listed in its row. Never skip a Gate. If a task conflicts with `prd.md`/`architecture.md`/`data-contract.md`, stop and escalate to the human.

**Related:** `prd.md` v1.1 · `architecture.md` v1.0 · `data-contract.md` 1.0.0 · `tech-stack.md` 1.0

---

## 1. How This Roadmap Works

**Lanes.** Until M1's gate passes, all work is single-lane (sequential). After **Gate-M1**, two lanes open:

| Lane | Domain | Owns |
|---|---|---|
| **CORE** | Rust | `core/`, `tui/`, `vendor/`, scrapers, downloader, proxy, state, FFI crate |
| **UI** | Flutter | `app/`, design token layer, features, playback integration, settings screens |

**Gates.** `Gate-Mx` tasks are cross-lane checkpoints executed in a dedicated session (the human driving, or one agent with both lanes merged): merge both lanes, run the full seam-test suite, run the milestone demo, mark milestone done. Lanes do not proceed past an unpassed gate.

**Task size legend.** S = one agent session · M = 1–2 sessions · L = multi-session (split further when starting).

**Status legend.** `todo` → `doing` → `done` · `blocked` (with reason comment). Agents update statuses as part of task completion; the human may re-order within a lane.

**QA order (binding, per user decision):** every milestone's manual gate runs **Windows first**; **Android** joins the gate from its listed milestone; **Linux** is CI-verified throughout and receives its first *manual* gate at M7, full device-matrix runs at M8. The human is the device matrix.

**Doc-update rule.** A task is not done until its listed docs are updated in the same commit.

## 2. Milestone M0 — Foundation (single-lane, public repo from day one)

| ID | Status | Task | Lane | Size | Outcome & verification | Docs to update |
|---|---|---|---|---|---|---|
| T0.1 | `done` | Create public GitHub repo: dual MIT/Apache-2.0 LICENSE files, README stub (vision + doc index), CONTRIBUTING, SECURITY.md, .gitignore | — | S | Repo live with community scaffolding | README |
| T0.2 | `done` | Commit the doc set: `docs/{prd,architecture,data-contract,tech-stack,roadmap}.md` + root `AGENTS.md` (agent instructions: read docs first, this file's rules) | — | S | All docs in repo; AGENTS.md references them | — |
| T0.3 | `done` | Scaffold Cargo workspace: `core/crates/theatre-core` (empty `api/` + stub `init`), `theatre-ffi` (empty), `tui/` placeholder; `rust-toolchain.toml` pinned | CORE | S | `cargo build --workspace` green | architecture §4 (deviations) |
| T0.4 | `done` | Scaffold Flutter app: riverpod + go_router + adaptive shell (empty screens), `lib/design/` token-layer skeleton with `TButton`/`TCard` stubs; lint rule forbidding direct `material_3_expressive` imports in `lib/features/` | UI | M | `flutter run` shows adaptive empty shell on Windows | tech-stack §3 (exact pins), design (when created) |
| T0.5 | `done` | CI skeleton: GitHub Actions matrix — ubuntu (core+app linux build), windows (core+app), android (cargo-ndk ×3 ABIs + APK build), macOS (core compile + tests only); all `--locked`/`--frozen` | — | M | Green CI on a trivial commit | architecture §20 |
| T0.6 | `done` | **Pin the stack:** resolve every "locked at M0" entry in tech-stack.md, commit `pubspec.lock` + `Cargo.lock`, record exact versions in tech-stack.md tables | — | S | Lockfiles committed; tech-stack has zero "latest" entries | tech-stack |
| T0.7 | `done` | Quality gates in CI: clippy, rustfmt, `dart analyze`, unit-test runners both sides | — | S | CI enforces lints | — |

**Gate-M0:** repo public, CI green on all four runners, docs committed. Demo: clone → build → run empty app on Windows. (awaiting-human)

## 3. Milestone M1 — Seam Prototype (single-lane; opens two lanes at its gate)

| ID | Task | Lane | Size | Outcome & verification | Contract | Docs |
|---|---|---|---|---|---|---|
| T1.1 | frb wiring: `theatre-ffi` with real codegen setup; `init`/`shutdown` implemented (runtime, DB open, proxy stub-bind); `search` stub returning fixture `SearchPage`; `resolve` stub | CORE | M | `flutter_rust_bridge_codegen` output committed; init called at app start | §2, §3, §4 | data-contract (deviations) |
| T1.2 | UI: search screen calls stub `search`, renders results list via token-layer widgets | UI | S | Typing "test" → fixture results render on Windows | §3 | — |
| T1.3 | Playback: media_kit plays a public test MP4 **and** a public HLS test stream from the search screen | UI | S | Both test URLs play with controls | — | architecture §10 (findings) |
| T1.4 | Android seam: cargo-ndk builds `theatre_core.so` ×3 ABIs, APK loads core, stub search renders, test video plays on the user's Android phone | CORE | M | Same demo as T1.2/T1.3 on device | — | tech-stack (ABIs) |
| T1.5 | Seam tests: round-trip tests for every §2/§3/§4/§12 type & function (fixture-backed), wired into CI | CORE | M | CI runs seam suite; contract violations fail builds | §14-M1 | data-contract |

**Gate-M1 (user QA: Windows + Android):** search→results→play test video, both platforms. **This gate retires the FFI + playback risk (PRD §10) and authorizes two-lane work.**

## 4. Milestone M2 — Core Extraction (two-lane)

| ID | Task | Lane | Size | Outcome | Contract | Docs |
|---|---|---|---|---|---|---|
| T2.1 | Fork MovieBox-TUI into the project's GitHub org, add `upstream` remote, create extraction branch; inventory its scraper/subtitle/download modules in a migration note | CORE | S | Fork + inventory doc | — | architecture §15 |
| T2.2 | Extract MovieBox source behind the `Source` trait with recorded-HTML fixture tests | CORE | L | `search`/`get_details` real for moviebox source; fixtures green | §3.1, §3.2 | — |
| T2.3 | Extract 4KHDHub source + fixtures | CORE | M | Second source live | §3.1 | — |
| T2.4 | Extract BDIX source (default-off) + fixtures | CORE | M | Opt-in source live | §3.3 | — |
| T2.5 | Source health tracking + `source_health_events` stream | CORE | M | Health snapshot + transitions flow | §8.1 | — |
| T2.6 | Search aggregation: parallel fan-out, 8s per-source timeout, `partial` flag, 60s cache | CORE | M | One dead source doesn't fail search (test with fixture) | §3.1 | — |
| T2.7 | Search screen, real: loading/partial states, per-source badges, in-place provider switch on details | UI | M | Real multi-source search UX | §3 | — |
| T2.8 | Details screen: poster/synopsis/seasons/episodes | UI | M | Real details render | §3 | — |
| T2.9 | Source management screen: list, enable/disable, health status pills | UI | S | BDIX can be toggled on/off | §3.3, §8.1 | — |

**Gate-M2 (user QA: Windows):** real search across 2+ sources, one source killed via hosts-file → others unaffected, health pill degrades. *Opens recurring lane (§9).*

## 5. Milestone M3 — Playback Vertical Slice (two-lane)

| ID | Task | Lane | Size | Outcome | Contract | Docs |
|---|---|---|---|---|---|---|
| T3.1 | Real `resolver/`: resolve-on-demand, headers, variant list, short cache, `force_refresh` | CORE | M | Playback consumes real resolved URLs | §4.1 | — |
| T3.2 | 403 re-resolve flow: player error → force_refresh once → retry (UI-side orchestration per contract §4.1) | UI | S | Simulated 403 auto-recovers once | §4.1 | — |
| T3.3 | Extract `subtitles/` from upstream: `find_best_subtitle`, search, download, sibling detection | CORE | L | Auto-sub works for a popular title | §5 | — |
| T3.4 | `history/`: record/position/continue-watching, dedupe keys, persistence | CORE | M | History survives restart | §6 | — |
| T3.5 | `prepare_local_playback` (desktop path) + `get/update_settings` | CORE | S | Local file prep + settings round-trip | §10, §11 | — |
| T3.6 | Player screen: full controls (seek, speed, audio/sub tracks, fill modes), headers passed to media_kit | UI | L | PRD F2 behaviors demo | — | — |
| T3.7 | Subtitle UX: auto-load + manual search/pick | UI | M | Auto + manual sub flows | §5 | — |
| T3.8 | Home: continue-watching row + resume | UI | S | Exit mid-video → resume within ±2s | §6 | — |
| T3.9 | Settings hub: player defaults, subtitle language, download folder field | UI | M | PRD F6 subset live | §11 | — |
| T3.10 | Open file (Windows): picker → `prepare_local_playback` → play + history | UI | S | Local MKV + sibling .srt plays | §10 | — |

**Gate-M3 (user QA: Windows full, Android smoke):** PRD primary journey complete — search→details→play w/ subs→exit→resume. Preview tag not yet.

## 6. Milestone M4 — Downloader (two-lane)

| ID | Task | Lane | Size | Outcome | Contract | Docs |
|---|---|---|---|---|---|---|
| T4.1 | FFmpeg sidecar: vendor per-platform/ABI binaries + SHA256 MANIFEST, runtime path resolution, CI verify | CORE | M | `vendor/ffmpeg` complete; remux smoke test | — | tech-stack §5 |
| T4.2 | Direct-file download pipeline: queue, range resume, atomic rename | CORE | M | Kill mid-download → resume exact | §7 | — |
| T4.3 | HLS pipeline: segment fetch, ≤3 retries, playlist re-resolve, spool | CORE | L | Injected 403 → transparent recovery | §7 | — |
| T4.4 | Remux orchestration: `-c copy`, progress parsing, MP4→MKV fallback | CORE | M | 1-hr HLS → single MP4 | §7 | — |
| T4.5 | Queue persistence + resume matrix (kill at every state) | CORE | M | Restart resumes any state | §7 | — |
| T4.6 | `download_events` stream (snapshot+delta, 4Hz) + pause/resume/cancel | CORE | M | Events drive UI live | §7 | — |
| T4.7 | Android foreground service for active downloads | CORE | M | Download survives screen-off + app switch | §7 | — |
| T4.8 | Downloads screen: queue, progress, actions | UI | M | Full queue UX | §7 | — |
| T4.9 | Download flow: variant picker + auto-subtitle toggle from details | UI | S | PRD F2→F9 handoff | §7 | — |
| T4.10 | Downloaded library section (Movies/Series browse) | UI | M | Offline playback from library | — | — |

**Gate-M4 (user QA: Windows + Android):** PRD F9 DoD — 1-hr HLS unattended incl. injected expiry; Android background download survives.

## 7. Milestone M5 — Download Proxy (two-lane)

| ID | Task | Lane | Size | Outcome | Contract | Docs |
|---|---|---|---|---|---|---|
| T5.1 | Proxy server: loopback bind, token, 403 rules, live-port surface | CORE | M | Token-miss → 403 (test) | §9 | — |
| T5.2 | Direct pass-through: Range forwarding + upstream re-resolve | CORE | M | curl/IDM direct download works | §9 | — |
| T5.3 | HLS prep + spool serving: Range-on-spool, backpressure, no Content-Length until done | CORE | L | Manager resumes spool mid-build | §9 | — |
| T5.4 | `generate_download_link`, session tracking, cancel | CORE | M | Link + session lifecycle | §9 | — |
| T5.5 | `proxy_events` + `proxy_status` | CORE | S | Sessions stream to UI | §9 | — |
| T5.6 | Exit guard + desktop tray (tray_manager) + Android external-session foreground | CORE | M | PRD F10 lifetime behaviors | §9 | — |
| T5.7 | "Copy link" flow: variant picker, link dialog w/ lifetime note | UI | S | PRD journey 2b complete | §9 | — |
| T5.8 | Proxy sessions screen + cancel | UI | S | Session visibility | §9 | — |
| T5.9 | Exit-guard dialog + tray setting | UI | S | Close-with-session warns | §9 | — |

**Gate-M5 (user QA: Windows w/ IDM, Android w/ manager app):** PRD F10 DoD — IDM completes HLS title via link; link survives upstream expiry. **→ Tag `v0.1.0-alpha` preview release** (release pipeline live: per-ABI APKs, installers, SHA256SUMS).

## 8. Milestone M6 — Local Media (two-lane)

| ID | Task | Lane | Size | Outcome | Contract | Docs |
|---|---|---|---|---|---|---|
| T6.1 | **Spike S-1:** media_kit `content://` playback test on Android; record verdict | CORE | S | Decision recorded | — | architecture §24, §10 |
| T6.2 | `library/`: locations, live browse, truncation, missing detection | CORE | M | Browse reflects external deletions | §10 | — |
| T6.3 | `prepare_local_playback` Android path per S-1 verdict (+cache-copy fallback if needed) | CORE | M | SAF file plays on device | §10 | — |
| T6.4 | Local history integration + sibling subs on Android | CORE | S | F11/F12 history + subs | §5.4, §6 | — |
| T6.5 | Library UI: locations, add via SAF/file_picker, folder browse | UI | M | PRD F12 UX | §10 | — |
| T6.6 | Open file on Android + missing-file states | UI | S | PRD §8 local states render | §10 | — |

**Gate-M6 (user QA: Windows + Android):** PRD F11/F12 DoD. **→ Tag `v0.2.0-alpha`.**

## 9. Recurring Lane (opens after Gate-M2; one session each, monthly)

| ID | Task | Cadence | Outcome |
|---|---|---|---|
| R1 | Upstream sync: fetch MovieBox-TUI upstream, cherry-pick scraper fixes, refresh affected fixtures, re-run suite | Monthly | Scrapers stay alive without app releases |
| R2 | Dependency-bump PR per tech-stack §8 (standalone, never with features) | Monthly | Stack current, CI green |

## 10. Milestone M7 — TUI (two-lane; first manual Linux gate)

| ID | Task | Lane | Size | Outcome | Contract | Docs |
|---|---|---|---|---|---|---|
| T7.1 | Strip fork's internals; wire its frontend to `theatre-core` `api/` | CORE | L | TUI builds from workspace | — | architecture §13 |
| T7.2 | TUI parity: search, external-player launch, history, download queue, proxy-link display | CORE | M | PRD F7 DoD | §14-M7 | — |
| T7.3 | Termux build script + README section | CORE | S | Termux path documented | — | README |
| T7.4 | Desktop bundling: installer includes `theatre-tui` + ffmpeg sidecar | CORE | M | One installer, two frontends | — | architecture §20 |
| T7.5 | Shared-state verification: TUI + GUI concurrent SQLite (WAL) | CORE | S | Both see each other's history | — | — |

**Gate-M7 (user QA: Windows + Linux, Android-Termux optional):** TUI completes the primary journey; **→ Tag `v0.3.0-alpha`.**

## 11. Milestone M8 — Polish & 1.0 Release

| ID | Task | Lane | Size | Outcome | Contract | Docs |
|---|---|---|---|---|---|---|
| T8.1 | Settings completeness audit vs PRD F6; system/dark/light theming (6-palette pack stays P1) | UI | M | Every P0 setting configurable | §11 | PRD note: palette pack post-1.0 |
| T8.2 | Error-surface audit vs PRD §8 (all states render correctly) | UI | M | No silent failures | §12 | — |
| T8.3 | Performance-budget measurement vs architecture §21 | CORE | M | Budgets met or documented | — | architecture §21 |
| T8.4 | First-run legal disclaimer | UI | S | PRD §11 positioning surfaced | — | — |
| T8.5 | Name availability check (GitHub org/naming, domains; pub.dev irrelevant until a package exists) | — | S | D1 resolved pre-release | — | PRD §12 |
| T8.6 | Final packaging: Windows installer, Linux AppImage+deb, Android per-ABI APKs + universal | — | M | Release artifacts | — | architecture §20 |
| T8.7 | Device matrix run: Windows 10/11, user's Android, second Linux distro (VM acceptable per QA order) | — | M | PRD §9 verified | — | — |
| T8.8 | IzzyOnDroid/F-Droid submission prep | — | M | Submission ready | — | — |
| T8.9 | Release `v1.0.0`: tag, SHA256SUMS, notes, publish | — | S | **Shipped.** | — | — |

**Gate-M8:** PRD §9 success criteria all verified → release.

## 12. Rules for Agents Consuming This File

1. Pick the first `todo` task in **your lane** (or the single lane pre-Gate-M1). Subject to the lookahead clause (§12.7), never work ahead of an unpassed gate.
2. Read the task's contract/docs columns *before* coding; cite the contract item in your PR/commit.
3. A task is done when: outcome demoed, seam tests pass, statuses updated, docs updated — all in one change set.
4. `blocked` requires a reason and a note in this file; the human resolves blockers.
5. L-sized tasks must be split into sub-tasks (recorded here) before starting.
6. Recurring lane tasks (R1/R2) may interleave any time after Gate-M2 but never preempt an in-flight milestone task.
7. **Lookahead clause:** The UI lane may begin the next milestone's UI tasks against contract stubs while the CORE lane closes the current milestone; CORE never builds ahead; gates still run strictly in order and are passed by the human only. *(Regularizing work already done, per maintainer decision.)*

---
