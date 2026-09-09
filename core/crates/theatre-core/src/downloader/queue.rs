//! Download queue — SQLite-backed, survives restarts.

use crate::{
    error::Result,
    state::{now, Db},
};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum JobStatus {
    Queued,
    Preparing,
    Running,
    Paused,
    Failed,
    Done,
    Cancelled,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum JobKind {
    Direct,
    Hls,
}

/// Persisted as plain strings via serde (`"queued"`); unknown values fall
/// back to the queue default instead of failing the read.
fn status_str(s: &JobStatus) -> String {
    serde_json::to_string(s)
        .map(|j| j.trim_matches('"').to_owned())
        .unwrap_or_else(|_| "queued".into())
}
fn status_parse(s: &str) -> JobStatus {
    serde_json::from_str(&format!("\"{s}\"")).unwrap_or(JobStatus::Queued)
}
fn kind_str(k: &JobKind) -> String {
    serde_json::to_string(k)
        .map(|j| j.trim_matches('"').to_owned())
        .unwrap_or_else(|_| "direct".into())
}
fn kind_parse(s: &str) -> JobKind {
    serde_json::from_str(&format!("\"{s}\"")).unwrap_or(JobKind::Direct)
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct DownloadJob {
    pub id: String,
    pub content_id: String,
    pub source_id: String,
    pub title: String,
    pub variant: Option<String>,
    pub kind: JobKind,
    pub dest_path: String,
    pub status: JobStatus,
    pub bytes_done: i64,
    pub total_bytes: Option<i64>,
    pub segments_done: i64,
    pub total_segments: Option<i64>,
    pub error_msg: Option<String>,
    pub created_at: i64,
    pub updated_at: i64,
    pub resume_offset: i64,
    pub resume_segment: i64,
    // Runtime fields (not in DB, re-populated on load)
    pub stream_url: String,
    pub stream_headers: HashMap<String, String>,
}

pub struct DownloadQueue {
    db: Db,
}

impl DownloadQueue {
    pub fn new(db: Db) -> Self {
        Self { db }
    }

    pub fn insert(&self, job: &DownloadJob) -> Result<()> {
        self.db.with(|c| {
            c.execute(
                "INSERT INTO downloads(
                    id, content_id, source_id, title, variant, kind,
                    dest_path, status, bytes_done, total_bytes,
                    segments_done, total_segments, created_at, updated_at,
                    resume_offset, resume_segment
                ) VALUES (?1,?2,?3,?4,?5,?6,?7,?8,0,?9,0,?10,?11,?12,0,0)",
                rusqlite::params![
                    job.id,
                    job.content_id,
                    job.source_id,
                    job.title,
                    job.variant,
                    kind_str(&job.kind),
                    job.dest_path,
                    status_str(&job.status),
                    job.total_bytes,
                    job.total_segments,
                    job.created_at,
                    job.updated_at,
                ],
            )?;
            Ok(())
        })
    }

    pub fn get(&self, id: &str) -> Result<Option<DownloadJob>> {
        self.db.with(|c| {
            let mut stmt = c.prepare_cached(
                "SELECT id,content_id,source_id,title,variant,kind,dest_path,status,
                        bytes_done,total_bytes,segments_done,total_segments,
                        error_msg,created_at,updated_at,resume_offset,resume_segment
                   FROM downloads WHERE id=?1",
            )?;
            let mut rows = stmt.query(rusqlite::params![id])?;
            if let Some(row) = rows.next()? {
                Ok(Some(row_to_job(row)?))
            } else {
                Ok(None)
            }
        })
    }

    pub fn list_all(&self) -> Result<Vec<DownloadJob>> {
        self.db.with(|c| {
            let mut stmt = c.prepare_cached(
                "SELECT id,content_id,source_id,title,variant,kind,dest_path,status,
                        bytes_done,total_bytes,segments_done,total_segments,
                        error_msg,created_at,updated_at,resume_offset,resume_segment
                   FROM downloads ORDER BY created_at DESC",
            )?;
            let rows = stmt
                .query_map([], |r| Ok(row_to_job(r)))?
                .collect::<Vec<_>>();
            let mut jobs = Vec::new();
            for r in rows {
                jobs.push(r?.unwrap());
            }
            Ok(jobs)
        })
    }

    #[allow(clippy::too_many_arguments)]
    pub fn update_progress(
        &self,
        id: &str,
        bytes_done: i64,
        total_bytes: Option<i64>,
        segments_done: i64,
        total_segments: Option<i64>,
        resume_offset: i64,
        resume_segment: i64,
    ) -> Result<()> {
        let n = now();
        self.db.with(|c| {
            c.execute(
                "UPDATE downloads SET bytes_done=?1,total_bytes=?2,
                        segments_done=?3,total_segments=?4,
                        resume_offset=?5,resume_segment=?6,
                        status='running',updated_at=?7
                  WHERE id=?8",
                rusqlite::params![
                    bytes_done,
                    total_bytes,
                    segments_done,
                    total_segments,
                    resume_offset,
                    resume_segment,
                    n,
                    id,
                ],
            )?;
            Ok(())
        })?;
        Ok(())
    }

    pub fn set_status(&self, id: &str, status: JobStatus) -> Result<()> {
        let n = now();
        self.db.with(|c| {
            c.execute(
                "UPDATE downloads SET status=?1, updated_at=?2 WHERE id=?3",
                rusqlite::params![status_str(&status), n, id],
            )?;
            Ok(())
        })
    }

    pub fn set_failed(&self, id: &str, reason: &str) -> Result<()> {
        let n = now();
        self.db.with(|c| {
            c.execute(
                "UPDATE downloads SET status='failed', error_msg=?1, updated_at=?2 WHERE id=?3",
                rusqlite::params![reason, n, id],
            )?;
            Ok(())
        })
    }
}

fn row_to_job(row: &rusqlite::Row<'_>) -> rusqlite::Result<DownloadJob> {
    Ok(DownloadJob {
        id: row.get(0)?,
        content_id: row.get(1)?,
        source_id: row.get(2)?,
        title: row.get(3)?,
        variant: row.get(4)?,
        kind: kind_parse(&row.get::<_, String>(5)?),
        dest_path: row.get(6)?,
        status: status_parse(&row.get::<_, String>(7)?),
        bytes_done: row.get(8)?,
        total_bytes: row.get(9)?,
        segments_done: row.get(10)?,
        total_segments: row.get(11)?,
        error_msg: row.get(12)?,
        created_at: row.get(13)?,
        updated_at: row.get(14)?,
        resume_offset: row.get(15)?,
        resume_segment: row.get(16)?,
        stream_url: String::new(),
        stream_headers: HashMap::new(),
    })
}
