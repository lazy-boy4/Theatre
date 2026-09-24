# Seam placement for the narrowed sources module

Type: grilling
Status: resolved
Blocked by: none

## Question

With narrow-parse + internal-health settled, where does the seam live: visibility-only (`pub mod health` → `pub(crate) mod health` in `sources/mod.rs`, `Source` trait untouched, 1-line diff) or a file fold (move `health.rs` into `registry.rs` so the registry module physically owns the health locality)?

## Answer

Visibility-only. `sources/mod.rs`: `pub mod health` → `pub(crate) mod health`; `Source` trait untouched; `util` already `pub(crate)` — no other changes. Rationale: depth comes from removing health from the interface callers learn, not from moving the file; fold deferred until a second health writer appears (one adapter = hypothetical seam). No code landed (planning-only map) — the edit rides with the implementer handoff.
