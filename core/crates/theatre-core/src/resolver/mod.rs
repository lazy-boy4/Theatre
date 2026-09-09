//! Resolver — data-contract.md §4, architecture §7.
//! Links are NEVER resolved at search time — only at play/download/proxy time.
//! Re-resolve on 403: one automatic retry, then surface error.
//! Delegates to the sources registry (each source implements resolve()).

// The resolver logic lives in api/resolver.rs — this module is
// kept for future extraction of caching + re-resolve logic.
