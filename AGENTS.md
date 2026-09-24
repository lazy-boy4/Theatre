# AGENTS.md — Theatre

**This file is binding for every AI agent session** (opencode, Antigravity, or any other tool) working in this repository. If your tool auto-loads `AGENTS.md`, treat this as your session bootstrap. If it doesn't, the human's opening prompt will direct you here. Read this file fully before your first action in any session.

---

## 1. What You Are Building (orientation)

**Theatre** is a cross-platform media app (Windows, Linux, Android): a Material 3 Expressive Flutter GUI and a Ratatui terminal frontend, both served by one Rust core (scrapers extracted from MovieBox-TUI, a resolver, a unified download engine, a loopback download proxy), connected to Flutter via `flutter_rust_bridge`. You are **one session in a long chain of sessions**. The project's state lives in the documents and the repo — never in your memory. When in doubt: re-read, don't recall.

## 2. The Document System — read before acting

| Document | Governs | Read when |
|---|---|---|
| `docs/prd.md` | **WHAT** — features, priorities, edge cases (binding), non-goals | Before any feature task; whenever scope is unclear |
| `docs/architecture.md` | **HOW** — structure, boundaries, tech decisions, spikes | Before any structural decision; before touching modules |
| `docs/data-contract.md` | The exact FFI surface (types, functions, events, errors) | Before touching `theatre-ffi`/`api/`; contract changes land here *first* |
| `docs/tech-stack.md` | Pinned dependencies + upgrade policy | Before adding or bumping any dependency |
| `docs/roadmap.md` | Task queue, lanes, gates, progress statuses | At session start — your task comes from here |
| `docs/design.md` | UI/UX spec (created/extended during first UI tasks) | Before any UI-lane view work |

**Rules of precedence:** documents > code comments > your prior-session memory > your training priors. If two documents conflict, **stop and escalate** (§7) — do not pick a winner yourself. Never modify PRD scope, non-goals, or platform targets without explicit human instruction.

## 3. Session Lifecycle (the loop)

1. **Start:** read `docs/roadmap.md`; take the first `todo` task in your assigned lane (**CORE** or **UI**; before Gate-M1 there is a single lane). L-sized tasks must be split into sub-tasks recorded in the roadmap before starting. If the graphify skill is available, refresh the project index.
2. **Before coding:** read the docs listed in the task's row; cite the contract/architecture sections you're implementing in your commit message.
3. **Implement** the smallest change that produces the task's outcome. No drive-by refactors, no "while I'm here" improvements — if you spot something, add a `todo` note to `roadmap.md` instead.
4. **Test:** contract items need seam tests; scraper work uses recorded HTML fixtures — **never live network in tests**.
5. **Demo:** the outcome must be runnable or observable, not merely compiling.
6. **Update docs and roadmap status** (`todo`→`done`, or `blocked`+reason) **in the same change set** — a task without its doc update is not done.
7. **Review pass** — see §5 triggers; mandatory for M/L tasks and anything security-adjacent.
8. **Commit** on a feature branch with a conventional-commit message (`feat(core): …`, `fix(ui): …`), then stop. One task per session unless the remaining task is trivially small.

## 4. Hard Rules (violating any of these fails the task)

1. **No dependency exists unless `tech-stack.md` says so.** Adding one = update tech-stack + lockfiles in the same task, with rationale and fallback.
2. **Never import `material_3_expressive` or `material` directly in `lib/features/`** — token layer (`lib/design/`) only. CI lint enforces this.
3. **The data contract is additive-only within v1.** New fields must be optional; breaking changes require a major contract bump + migration section, and a human checkpoint.
4. **Never skip or self-pass a `Gate-Mx`.** Gates are passed by the human only. Marking any Gate-Mx passed is reserved for the human; agents set gates to 'awaiting-human' and stop.
5. **Never network in scraper tests.** Fixtures only.
6. **Never widen scope** beyond the roadmap task. Log suggestions as roadmap todos.
7. **Never force-push `main`.** Never commit secrets, tokens, or large binaries (sidecars live in `vendor/` per its MANIFEST rules).
8. **Escalate instead of improvising** when: docs conflict, the task is impossible as specified, a new dependency seems required, or a security concern appears.

## 5. Skills & Plugins Protocol

The maintainer runs these skills alongside you. **Skills are advisors; the docs are law.** When a skill's suggestion conflicts with the PRD/architecture/contract, follow the docs and report the conflict in your session summary.

| Skill | Invoke | What it guards here |
|---|---|---|
| **graphify** | Session start, after milestone merges, or when navigating unfamiliar areas | Project map/index for context. Use it to locate code fast — but the index is a *map, not truth*: verify against source before editing |
| **ponytail** | Before completing any task that **adds abstractions/modules**, or touches **proxy, session tokens, subprocess (ffmpeg/yt-dlp), file paths, SAF/Android storage, SQL, or FFI** | Over-engineering (kill unneeded abstraction — this codebase is beginner-maintained; YAGNI is law) and security (loopback-only binding, path-traversal in library/proxy serving, parameterized SQL, untrusted scraped HTML, subprocess argument safety) |
| **impeccable** | Every UI-lane task touching `lib/design/` or feature views | M3E fidelity: tokens, spacing, motion, shape. **Create/extend `docs/design.md` alongside the implementation** — it is the design source of truth |
| **mattpocock skills** | Writing/adjusting Dart code, especially contract types and view models | Typing and test discipline: strict types, no dynamic escapes, tests as executable spec. (TypeScript-origin — apply the *principles*; Rust enforces most of this natively) |

## 6. Build Commands (indicative — prefer `scripts/` once M0 creates them)

```bash
# Rust core (from core/)
cargo build --workspace --locked
cargo test --workspace --locked
cargo clippy --workspace --all-targets -- -D warnings

# FFI codegen (version must equal runtime — see tech-stack)
flutter_rust_bridge_codegen generate

# Flutter (from app/)
flutter run -d windows
flutter build apk --split-per-abi

# Android core cross-build (from core/)
cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 \
  -o ../app/android/app/src/main/jniLibs build --release
```

Green CI is necessary but not sufficient — the task's demoable outcome is the real bar.

## 7. Escalation & Blockers

Stop the task, mark it `blocked` in `roadmap.md` with a one-line reason, and end the session with a handoff note in the task row describing: what you tried, what the docs say, where the conflict is. Do not "fix" a doc unilaterally to unblock yourself.

## 8. Definition of Done (per task)

- [ ] Outcome demoed (runnable/observable)
- [ ] Seam/unit tests pass; CI green
- [ ] `roadmap.md` status updated + all task-listed docs updated
- [ ] Review pass completed per §5 triggers
- [ ] Conventional-commit on a branch; no unrelated changes in the diff

## 9. If You Are Reading This Without a Task Prompt

Read `docs/roadmap.md`, take the first `todo` task in your assigned lane (pre-Gate-M1: the single lane), and execute the lifecycle in §3. If no lane was assigned, ask the human whether this is a CORE or UI session.

---

## Agent skills

### Issue tracker

Issues live as local markdown files under `.scratch/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five canonical labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout (`CONTEXT.md` + `docs/adr/`). See `docs/agents/domain.md`.
