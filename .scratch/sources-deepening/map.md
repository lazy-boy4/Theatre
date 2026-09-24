# Map: Sources module deepening — decided route to handoff

## Destination

The `sources/` deepening is fully decided and ready to hand off: narrow-parse + internal-health locked, seam placement and test shape resolved, so an implementer can land it in one session with no new decisions and no behavior change.

## Notes

- Domain: search, resolve, details, search sources (moviebox, khddhub, bdix), registry fan-out, health — per `docs/prd.md` F1/F8 and `docs/architecture.md` §5/§15/§16. No `CONTEXT.md` exists; use these terms exactly.
- Skills every session should consult: `grilling` + `domain-modeling` (grilling ticket type always calls both).
- Standing preferences: planning-only map — no code lands from these tickets; the handoff is decisions + pointers. Another agent is mid-cleanup in `app/`; touch nothing under `app/` and land no `core/` edits until handoff.
- Settled in R1 (grilling, on research evidence): narrow-parse (fetch+parse+error-mapping stays per search-source file; `util/` stays parse-only `pub(crate)`) + internal-health (health demoted to registry-internal detail). Evidence: `docs/agents/research-sources-seam-20260910.md` (primary sources only).
- Priority order for tickets below: [Seam placement for the narrowed sources module](issues/01-seam-placement.md) first, then [Test seam that locks the sources deepening](issues/02-test-seam.md) — the test targets the settled layout.

## Decisions so far

- [Seam placement for the narrowed sources module](issues/01-seam-placement.md): visibility-only — `pub(crate) mod health`, trait untouched, fold deferred.
- [Test seam that locks the sources deepening](issues/02-test-seam.md): aggregate registry test, in-test stub adapters, existing fixture tests untouched.

## Not yet specified

*(none — all fog graduated into tickets and resolved)*

## Out of scope

- `downloader/` lifecycle depth — beyond this map's destination; deserves its own effort.
- FFI contract fixtures — beyond this map's destination; deserves its own effort.
- `net/` retry + typed-response depth — beyond this map's destination; deserves its own effort.
- `proxy/` URL/token/spool co-location — beyond this map's destination; deserves its own effort (pre-M5 at latest).
- Lifecycle `STATE` + Flutter provider pass-throughs — beyond this map's destination; speculative until candidates 1–3 settle.
