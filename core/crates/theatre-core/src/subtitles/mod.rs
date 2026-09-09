//! Subtitle search & download — data-contract.md §5.
//! Provider extraction lands at T3.3; sibling-file lookup lives in
//! `crate::library::Library::find_sibling_subtitles` (call it directly).

use crate::net::NetClient;
use std::path::PathBuf;

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct SubtitleCandidate {
    pub provider: String,
    pub id: String,
    pub language: String,
    pub title: Option<String>,
    pub score: Option<u32>,
    pub downloads: Option<u64>,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum SubtitleFormat {
    Srt,
    Ass,
    Vtt,
    Ssa,
    Sub,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum SubtitleOrigin {
    Auto,
    Manual,
    Sibling,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct SubtitleFile {
    pub path: String,
    pub language: String,
    pub format: SubtitleFormat,
    pub origin: SubtitleOrigin,
}

#[derive(Debug)]
pub struct SubtitleQuery {
    pub title: String,
    pub year: Option<u16>,
    pub language: String,
    pub video_path: Option<String>,
}

pub struct SubtitleManager {
    // Wired for provider extraction at T3.3; search() is a stub today.
    #[allow(dead_code)]
    net: NetClient,
    #[allow(dead_code)]
    cache_dir: PathBuf,
}

impl SubtitleManager {
    pub fn new(net: NetClient, cache_dir: PathBuf) -> Self {
        Self { net, cache_dir }
    }
}
