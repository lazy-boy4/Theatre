#![allow(unexpected_cfgs)]

//! Theatre FFI bridge — flutter_rust_bridge 2.x.
//!
//! Thin crate: `api` holds the #[frb] functions (codegen scans
//! `crate::api`); `frb_generated` is codegen-owned glue.
//!
//! Run: `flutter_rust_bridge_codegen generate` from the `core/` directory
//! to regenerate the Dart bridge.

pub mod api;
mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
