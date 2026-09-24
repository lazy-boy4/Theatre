# Test seam that locks the sources deepening

Type: grilling
Status: resolved
Blocked by: 01

## Question

What aggregate test at the registry module's interface locks the deepening (two stub adapters behind the `Source` trait seam — one succeeding, one failing — asserting merged results, `partial: true`, and the failing search source marked degraded), keeping all existing per-search-source fixture tests untouched — and if the registry interface cannot host stub adapters without live tasks or sleeps, is that itself the finding that the seam needs narrowing first?

## Answer

Aggregate test, in-test stubs, in `registry.rs`'s own `#[cfg(test)]` mod. Two hand-written fakes implementing the `Source` trait seam (one `Ok` page, one `Err`), no fixture files, no I/O: assert merged results, `partial: true`, failing search source marked degraded. Existing fixture tests untouched. No code landed (planning-only map) — the test rides with the implementer handoff.
