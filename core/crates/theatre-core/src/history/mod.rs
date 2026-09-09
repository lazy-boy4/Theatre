//! Watch history & resume positions — data-contract.md §6.

use crate::{
    api::types::*,
    error::Result,
    state::{now, Db},
};

pub struct History(Db);

impl History {
    pub fn new(db: Db) -> Self {
        Self(db)
    }

    /// Record or update a history entry. Dedupes on (source_id, content_id)
    /// for streams, on local_path for local files.
    pub fn record(&self, entry: &HistoryEntry) -> Result<()> {
        let n = now();
        self.0.with(|c| {
            // Upsert by kind-specific key
            c.execute(
                "INSERT INTO history(
                    id, kind, source_id, content_id, local_path,
                    title, poster_url, variant, position_s, duration_s,
                    last_watched, play_count, completed
                 ) VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11,1,?12)
                 ON CONFLICT(id) DO UPDATE SET
                    position_s  = excluded.position_s,
                    duration_s  = excluded.duration_s,
                    last_watched= excluded.last_watched,
                    play_count  = play_count + 1,
                    completed   = excluded.completed",
                rusqlite::params![
                    entry.id,
                    entry.kind_str(),
                    entry.source_id,
                    entry.content_id,
                    entry.local_path,
                    entry.title,
                    entry.poster_url,
                    entry.variant,
                    entry.position_s,
                    entry.duration_s,
                    n,
                    entry.completed as i32,
                ],
            )?;
            Ok(())
        })
    }

    pub fn continue_watching(&self, limit: usize) -> Result<Vec<HistoryEntry>> {
        self.0.with(|c| {
            let mut stmt = c.prepare_cached(
                "SELECT id, kind, source_id, content_id, local_path,
                        title, poster_url, variant, position_s, duration_s,
                        last_watched, play_count, completed
                   FROM history
                  WHERE completed = 0
                  ORDER BY last_watched DESC
                  LIMIT ?1",
            )?;
            let rows = stmt.query_map(rusqlite::params![limit as i64], row_to_entry)?;
            rows.collect::<rusqlite::Result<Vec<_>>>()
        })
    }

    pub fn get_position(&self, id: &str) -> Result<Option<u64>> {
        self.0.with(|c| {
            let mut stmt = c.prepare_cached("SELECT position_s FROM history WHERE id = ?1")?;
            let mut rows = stmt.query(rusqlite::params![id])?;
            if let Some(row) = rows.next()? {
                Ok(Some(row.get::<_, i64>(0)? as u64))
            } else {
                Ok(None)
            }
        })
    }

    pub fn all(&self, limit: usize, offset: usize) -> Result<Vec<HistoryEntry>> {
        self.0.with(|c| {
            let mut stmt = c.prepare_cached(
                "SELECT id, kind, source_id, content_id, local_path,
                        title, poster_url, variant, position_s, duration_s,
                        last_watched, play_count, completed
                   FROM history
                  ORDER BY last_watched DESC
                  LIMIT ?1 OFFSET ?2",
            )?;
            let rows =
                stmt.query_map(rusqlite::params![limit as i64, offset as i64], row_to_entry)?;
            rows.collect::<rusqlite::Result<Vec<_>>>()
        })
    }

    pub fn delete(&self, id: &str) -> Result<()> {
        self.0.with(|c| {
            c.execute("DELETE FROM history WHERE id = ?1", rusqlite::params![id])?;
            Ok(())
        })
    }
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct HistoryEntry {
    pub id: String,
    pub source_id: Option<String>,
    pub content_id: Option<String>,
    pub local_path: Option<String>,
    pub title: String,
    pub poster_url: Option<String>,
    pub variant: Option<String>,
    pub position_s: i64,
    pub duration_s: Option<i64>,
    pub last_watched: i64,
    pub play_count: i64,
    pub completed: bool,
}

impl HistoryEntry {
    pub fn for_stream(content: &ContentRef, title: &str, poster_url: Option<&str>) -> Self {
        // Dedup key: sha256(source+content_id) truncated to UUID format
        let id = format!("stream-{}-{}", content.source, content.content_id);
        Self {
            id,
            source_id: Some(content.source.clone()),
            content_id: Some(content.content_id.clone()),
            local_path: None,
            title: title.to_owned(),
            poster_url: poster_url.map(|s| s.to_owned()),
            variant: None,
            position_s: 0,
            duration_s: None,
            last_watched: now(),
            play_count: 0,
            completed: false,
        }
    }

    pub fn for_local(path: &str, title: &str) -> Self {
        use std::hash::{Hash, Hasher};
        let mut hasher = std::collections::hash_map::DefaultHasher::new();
        path.hash(&mut hasher);
        let id = format!("local-{:x}", hasher.finish());
        Self {
            id,
            source_id: None,
            content_id: None,
            local_path: Some(path.to_owned()),
            title: title.to_owned(),
            poster_url: None,
            variant: None,
            position_s: 0,
            duration_s: None,
            last_watched: now(),
            play_count: 0,
            completed: false,
        }
    }

    fn kind_str(&self) -> &'static str {
        if self.local_path.is_some() {
            "local"
        } else {
            "stream"
        }
    }
}

fn row_to_entry(row: &rusqlite::Row<'_>) -> rusqlite::Result<HistoryEntry> {
    Ok(HistoryEntry {
        id: row.get(0)?,
        source_id: row.get(2)?,
        content_id: row.get(3)?,
        local_path: row.get(4)?,
        title: row.get(5)?,
        poster_url: row.get(6)?,
        variant: row.get(7)?,
        position_s: row.get(8)?,
        duration_s: row.get(9)?,
        last_watched: row.get(10)?,
        play_count: row.get(11)?,
        completed: row.get::<_, i32>(12)? != 0,
    })
}
