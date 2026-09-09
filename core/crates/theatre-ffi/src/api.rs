//! Theatre FFI bridge — flutter_rust_bridge 2.x.
//!
//! Transport design (see flutter_rust_bridge.yaml): complex contract types
//! cross the FFI boundary as JSON strings. FRB 2.x only emits concrete Dart
//! codecs for types *defined* in this crate; the contract types live in
//! `theatre-core` (shared with the TUI), so re-declaring them here would fork
//! the contract. The JSON pipe keeps one type system per side — Rust
//! (`theatre-core::api::types`, serde) and Dart (`app/lib/api/types.dart`,
//! freezed) — with function names and payload shapes per data-contract.md.
//! Errors are strings at the boundary (architecture §6 invariant).

use theatre_core::api::{self};
use theatre_core::api::types::*;

fn from_json<T: serde::de::DeserializeOwned>(s: &str) -> Result<T, String> {
    serde_json::from_str(s).map_err(|e| format!("bad argument json: {}", e))
}

fn to_json<T: serde::Serialize>(v: &T) -> Result<String, String> {
    serde_json::to_string(v).map_err(|e| e.to_string())
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

// ── Lifecycle ───────────────────────────────────────────────────
#[flutter_rust_bridge::frb]
pub async fn theatre_init(config_json: String) -> Result<String, String> {
    let config: InitConfig = from_json(&config_json)?;
    api::lifecycle::init(config)
        .await
        .map_err(|e| e.to_string())
        .and_then(|r| to_json(&r))
}

#[flutter_rust_bridge::frb]
pub async fn theatre_shutdown() {
    api::lifecycle::shutdown().await;
}

// ── Search & content ──────────────────────────────────────────
#[flutter_rust_bridge::frb]
pub async fn theatre_search(
    query: String,
    source_filter: Option<Vec<String>>,
) -> Result<String, String> {
    api::content::search(query, source_filter)
        .await
        .map_err(|e| e.to_string())
        .and_then(|p| to_json(&p))
}

#[flutter_rust_bridge::frb]
pub async fn theatre_get_details(content_json: String) -> Result<String, String> {
    let content: ContentRef = from_json(&content_json)?;
    api::content::get_details(content)
        .await
        .map_err(|e| e.to_string())
        .and_then(|d| to_json(&d))
}

#[flutter_rust_bridge::frb]
pub async fn theatre_list_sources() -> Result<String, String> {
    api::content::list_sources()
        .await
        .map_err(|e| e.to_string())
        .and_then(|v| to_json(&v))
}

// ── Resolver ───────────────────────────────────────────────────────
#[flutter_rust_bridge::frb]
pub async fn theatre_resolve(
    content_json: String,
    variant: Option<String>,
    force_refresh: bool,
) -> Result<String, String> {
    let content: ContentRef = from_json(&content_json)?;
    api::resolver::resolve(content, variant, force_refresh)
        .await
        .map_err(|e| e.to_string())
        .and_then(|s| to_json(&s))
}

// ── Downloads ───────────────────────────────────────────────────
#[flutter_rust_bridge::frb]
pub async fn theatre_enqueue_download(
    content_json: String,
    stream_json: String,
    title: String,
    variant: Option<String>,
) -> Result<String, String> {
    let content: ContentRef = from_json(&content_json)?;
    let stream: ResolvedStream = from_json(&stream_json)?;
    api::downloader::enqueue_download(content, stream, title, variant)
        .await
        .map_err(|e| e.to_string())
}

#[flutter_rust_bridge::frb]
pub async fn theatre_list_downloads() -> Result<String, String> {
    api::downloader::list_downloads()
        .await
        .map_err(|e| e.to_string())
        .and_then(|v| to_json(&v))
}

#[flutter_rust_bridge::frb]
pub async fn theatre_pause_download(id: String) -> Result<(), String> {
    api::downloader::pause_download(id)
        .await
        .map_err(|e| e.to_string())
}

#[flutter_rust_bridge::frb]
pub async fn theatre_cancel_download(id: String) -> Result<(), String> {
    api::downloader::cancel_download(id)
        .await
        .map_err(|e| e.to_string())
}

#[flutter_rust_bridge::frb]
pub async fn theatre_resume_download(id: String) -> Result<(), String> {
    api::downloader::resume_download(id)
        .await
        .map_err(|e| e.to_string())
}

// ── History ─────────────────────────────────────────────────────
#[flutter_rust_bridge::frb]
pub async fn theatre_record_playback(entry_json: String) -> Result<(), String> {
    let entry: theatre_core::history::HistoryEntry = from_json(&entry_json)?;
    api::history::record_playback(entry)
        .await
        .map_err(|e| e.to_string())
}

#[flutter_rust_bridge::frb]
pub async fn theatre_continue_watching(limit: u32) -> Result<String, String> {
    api::history::continue_watching(limit)
        .await
        .map_err(|e| e.to_string())
        .and_then(|v| to_json(&v))
}

#[flutter_rust_bridge::frb]
pub async fn theatre_all_history(limit: u32, offset: u32) -> Result<String, String> {
    api::history::all_history(limit, offset)
        .await
        .map_err(|e| e.to_string())
        .and_then(|v| to_json(&v))
}

#[flutter_rust_bridge::frb]
pub async fn theatre_delete_history(id: String) -> Result<(), String> {
    api::history::delete_history(id)
        .await
        .map_err(|e| e.to_string())
}

// ── Library ─────────────────────────────────────────────────────
#[flutter_rust_bridge::frb]
pub async fn theatre_list_locations() -> Result<String, String> {
    api::library::list_library_locations()
        .await
        .map_err(|e| e.to_string())
        .and_then(|v| to_json(&v))
}

#[flutter_rust_bridge::frb]
pub async fn theatre_add_location(
    path: String,
    label: Option<String>,
    is_saf: bool,
) -> Result<String, String> {
    api::library::add_library_location(path, label, is_saf)
        .await
        .map_err(|e| e.to_string())
        .and_then(|v| to_json(&v))
}

#[flutter_rust_bridge::frb]
pub async fn theatre_remove_location(id: String) -> Result<(), String> {
    api::library::remove_library_location(id)
        .await
        .map_err(|e| e.to_string())
}

#[flutter_rust_bridge::frb]
pub async fn theatre_browse_folder(path: String) -> Result<String, String> {
    api::library::browse_folder(path)
        .await
        .map_err(|e| e.to_string())
        .and_then(|v| to_json(&v))
}

// ── Settings ───────────────────────────────────────────────────
#[flutter_rust_bridge::frb]
pub async fn theatre_get_setting(key: String) -> Result<Option<String>, String> {
    api::settings::get_setting(key)
        .await
        .map_err(|e| e.to_string())
}

#[flutter_rust_bridge::frb]
pub async fn theatre_set_setting(key: String, value: String) -> Result<(), String> {
    api::settings::set_setting(key, value)
        .await
        .map_err(|e| e.to_string())
}
