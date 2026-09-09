//! Local library locations — data-contract.md §10, PRD F12.
//! Live folder browsing — no scan database, no watcher.
//! Android: SAF content:// URIs. Desktop: filesystem paths.

use crate::{
    error::{Result, TheatreError},
    state::{now, Db},
};
use std::path::Path;
use uuid::Uuid;

/// Video/audio file extensions Theatre considers playable.
const MEDIA_EXTENSIONS: &[&str] = &[
    "mkv", "mp4", "avi", "mov", "wmv", "flv", "webm", "m4v", "ts", "m2ts", "mpeg", "mpg", "mp3",
    "flac", "aac", "ogg", "opus", "m4a", "wav",
];

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LibraryLocation {
    pub id: String,
    pub path: String,
    pub kind: LocationKind,
    pub label: Option<String>,
    pub added_at: i64,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum LocationKind {
    Filesystem,
    Saf,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct MediaEntry {
    pub name: String,
    pub path: String,
    pub is_dir: bool,
    pub size_bytes: Option<u64>,
    pub exists: bool,
}

pub struct Library(Db);

impl Library {
    pub fn new(db: Db) -> Self {
        Self(db)
    }

    pub fn list_locations(&self) -> Result<Vec<LibraryLocation>> {
        self.0.with(|c| {
            let mut stmt = c.prepare_cached(
                "SELECT id, path, kind, label, added_at FROM library_locations ORDER BY added_at",
            )?;
            let rows = stmt.query_map([], |r| {
                Ok(LibraryLocation {
                    id: r.get(0)?,
                    path: r.get(1)?,
                    kind: if r.get::<_, String>(2)? == "saf" {
                        LocationKind::Saf
                    } else {
                        LocationKind::Filesystem
                    },
                    label: r.get(3)?,
                    added_at: r.get(4)?,
                })
            })?;
            rows.collect::<rusqlite::Result<Vec<_>>>()
        })
    }

    pub fn add_location(
        &self,
        path: &str,
        kind: LocationKind,
        label: Option<&str>,
    ) -> Result<LibraryLocation> {
        let id = Uuid::now_v7().to_string();
        let kind_str = match kind {
            LocationKind::Saf => "saf",
            LocationKind::Filesystem => "filesystem",
        };
        let n = now();
        self.0.with(|c| {
            c.execute(
                "INSERT INTO library_locations(id, path, kind, label, added_at)
                 VALUES(?1, ?2, ?3, ?4, ?5)",
                rusqlite::params![id, path, kind_str, label, n],
            )?;
            Ok(())
        })?;
        Ok(LibraryLocation {
            id,
            path: path.to_owned(),
            kind,
            label: label.map(|s| s.to_owned()),
            added_at: n,
        })
    }

    pub fn remove_location(&self, id: &str) -> Result<()> {
        self.0.with(|c| {
            c.execute(
                "DELETE FROM library_locations WHERE id = ?1",
                rusqlite::params![id],
            )?;
            Ok(())
        })
    }

    /// Browse a filesystem directory. Lazy — called on browse, not cached.
    pub async fn browse_directory(path: &str) -> Result<Vec<MediaEntry>> {
        let path = path.to_owned();
        let err_path = path.clone();
        tokio::task::spawn_blocking(move || Self::browse_sync(&path))
            .await
            .map_err(|e| TheatreError::Library {
                path: Some(err_path),
                reason: e.to_string(),
            })?
    }

    fn browse_sync(path: &str) -> Result<Vec<MediaEntry>> {
        let dir = Path::new(path);
        if !dir.exists() {
            return Ok(vec![]);
        }
        let read_dir = std::fs::read_dir(dir).map_err(|e| TheatreError::Library {
            path: Some(path.to_owned()),
            reason: e.to_string(),
        })?;

        let mut entries = Vec::new();
        for entry in read_dir.flatten() {
            let p = entry.path();
            let name = p
                .file_name()
                .and_then(|n| n.to_str())
                .unwrap_or("")
                .to_owned();
            if name.starts_with('.') {
                continue;
            }

            let is_dir = p.is_dir();
            let is_media = p
                .extension()
                .and_then(|e| e.to_str())
                .map(|e| MEDIA_EXTENSIONS.contains(&e.to_lowercase().as_str()))
                .unwrap_or(false);

            if !is_dir && !is_media {
                continue;
            }

            let size_bytes = if is_dir {
                None
            } else {
                entry.metadata().ok().map(|m| m.len())
            };

            entries.push(MediaEntry {
                name,
                path: p.to_string_lossy().into_owned(),
                is_dir,
                size_bytes,
                exists: true,
            });
        }

        entries.sort_by(|a, b| b.is_dir.cmp(&a.is_dir).then(a.name.cmp(&b.name)));
        Ok(entries)
    }

    /// Find sibling subtitle files for a given video path.
    /// data-contract.md §5.4
    pub fn find_sibling_subtitles(video_path: &str) -> Vec<String> {
        let p = Path::new(video_path);
        let stem = match p.file_stem().and_then(|s| s.to_str()) {
            Some(s) => s,
            None => return vec![],
        };
        let dir = match p.parent() {
            Some(d) => d,
            None => return vec![],
        };

        let sub_exts = ["srt", "ass", "vtt", "ssa", "sub", "idx"];
        let mut subs = Vec::new();

        if let Ok(entries) = std::fs::read_dir(dir) {
            for entry in entries.flatten() {
                let ep = entry.path();
                let ext = ep
                    .extension()
                    .and_then(|e| e.to_str())
                    .unwrap_or("")
                    .to_lowercase();
                if !sub_exts.contains(&ext.as_str()) {
                    continue;
                }
                let entry_stem = ep.file_stem().and_then(|s| s.to_str()).unwrap_or("");
                // Match exact stem or stem that starts with stem + "."
                if entry_stem == stem || entry_stem.starts_with(&format!("{}.", stem)) {
                    subs.push(ep.to_string_lossy().into_owned());
                }
            }
        }
        subs.sort();
        subs
    }
}
