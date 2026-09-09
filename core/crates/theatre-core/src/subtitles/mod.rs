//! Subtitle search & download — data-contract.md §5.
//! Extracted from MovieBox-TUI fork at T3.3.

use crate::{
    error::{Result, TheatreError},
    net::NetClient,
};
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

    /// Search subtitle providers, download best match.
    /// data-contract.md §5.1
    pub async fn find_best(&self, query: &SubtitleQuery) -> Result<Option<SubtitleFile>> {
        let candidates = self.search(query).await?;
        if candidates.is_empty() {
            return Ok(None);
        }

        // Best by score, then download count
        let best = candidates
            .into_iter()
            .max_by_key(|c| (c.score.unwrap_or(0), c.downloads.unwrap_or(0)));
        if let Some(candidate) = best {
            Ok(Some(self.download(&candidate).await?))
        } else {
            Ok(None)
        }
    }

    /// data-contract.md §5.2
    pub async fn search(&self, _query: &SubtitleQuery) -> Result<Vec<SubtitleCandidate>> {
        // TODO (T3.3): extract subtitle providers from MovieBox-TUI fork.
        // Providers: OpenSubtitles, Subscene, or similar.
        Ok(vec![])
    }

    /// data-contract.md §5.3
    pub async fn download(&self, _candidate: &SubtitleCandidate) -> Result<SubtitleFile> {
        // TODO (T3.3): implement download
        Err(TheatreError::Subtitle {
            reason: "not yet implemented".into(),
        })
    }

    /// Find sibling subtitle files — data-contract.md §5.4
    pub fn find_siblings(video_path: &str) -> Vec<SubtitleFile> {
        crate::library::Library::find_sibling_subtitles(video_path)
            .into_iter()
            .map(|path| {
                let format = detect_format(&path);
                SubtitleFile {
                    path,
                    language: "und".to_owned(), // undetermined
                    format,
                    origin: SubtitleOrigin::Sibling,
                }
            })
            .collect()
    }
}

fn detect_format(path: &str) -> SubtitleFormat {
    let ext = std::path::Path::new(path)
        .extension()
        .and_then(|e| e.to_str())
        .unwrap_or("")
        .to_lowercase();
    match ext.as_str() {
        "ass" | "ssa" => SubtitleFormat::Ass,
        "vtt" => SubtitleFormat::Vtt,
        "sub" => SubtitleFormat::Sub,
        _ => SubtitleFormat::Srt,
    }
}
