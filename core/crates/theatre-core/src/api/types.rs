//! Shared domain types — data-contract.md §3-§12.
//! These are the types serialized across the FFI boundary.

use serde::{Deserialize, Serialize};

// ── Lifecycle ──────────────────────────────────────────────────────────

#[derive(Debug, Serialize, Deserialize)]
pub struct InitConfig {
    pub data_dir: String,
    pub app_version: String,
    pub proxy_enabled: bool,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct InitResult {
    pub db_path: String,
    pub proxy_port: Option<u16>,
    pub core_version: String,
    pub contract_version: String,
}

// ── Content domain ─────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum SourceKind {
    Standard,
    Live,
    Addon,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SourceInfo {
    pub id: String,
    pub name: String,
    pub enabled: bool,
    pub kind: SourceKind,
    pub status: SourceStatus,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case", tag = "kind")]
pub enum SourceStatus {
    Healthy,
    Degraded { since: u64, last_error: String },
    Unavailable { since: u64, last_error: String },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ContentKind {
    Movie,
    Series,
    Episode,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ContentRef {
    pub source: String,
    pub content_id: String,
    pub kind: ContentKind,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SearchResult {
    pub content: ContentRef,
    pub title: String,
    pub year: Option<u16>,
    pub poster_url: Option<String>,
    pub quality_badges: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SearchPage {
    pub results: Vec<SearchResult>,
    pub has_more: bool,
    pub partial: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Details {
    pub content: ContentRef,
    pub title: String,
    pub year: Option<u16>,
    pub synopsis: Option<String>,
    pub poster_url: Option<String>,
    pub backdrop_url: Option<String>,
    pub genres: Vec<String>,
    pub cast: Vec<String>,
    pub seasons: Vec<Season>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Season {
    pub number: u32,
    pub episodes: Vec<Episode>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Episode {
    pub content: ContentRef,
    pub number: u32,
    pub title: Option<String>,
}

// ── Resolver ───────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum StreamKind {
    Direct,
    Hls,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Variant {
    pub id: String,
    pub label: String,
    pub width: Option<u32>,
    pub height: Option<u32>,
    pub bitrate_kbps: Option<u32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ResolvedStream {
    pub url: String,
    pub headers: std::collections::HashMap<String, String>,
    pub kind: StreamKind,
    pub variants: Vec<Variant>,
    pub selected_variant: Option<String>,
    pub filename_hint: Option<String>,
    pub size_bytes: Option<u64>,
}
