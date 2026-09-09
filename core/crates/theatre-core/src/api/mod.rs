//! Public API surface — data-contract.md §2-§12.
//! This is the only module the FFI crate and TUI import directly.
//!
//! All functions are async and non-blocking (architecture §6).
//! Panics never cross this boundary — catch_unwind at theatre-ffi layer.

pub mod content;
pub mod downloader;
pub mod history;
pub mod library;
pub mod lifecycle;
pub mod proxy;
pub mod resolver;
#[cfg(test)]
mod security_tests;
pub mod settings;
pub mod subtitles;
#[cfg(test)]
mod tests;
pub mod types;
