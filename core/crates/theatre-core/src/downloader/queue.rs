//! Download queue — SQLite-backed, survives restarts.

use crate::{
    error::Result,
    state::{now, Db},
};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use tokio::sync::broadcast;

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

impl JobStatus {
    fn as_str(&self) -> &'static str {
        match self {
            Self::Queued => "queued",
            Self::Preparing => "preparing",
            Self::Running => "running",
            Self::Paused => "paused",
            Self::Failed => "failed",
            Self::Done => "done",
            Self::Cancelled => "cancelled",
        }
    }
    fn from_str(s: &str) -> Self {
        match s {
            "preparing" => Self::Preparing,
            "running" => Self::Running,
            "paused" => Self::Paused,
            "failed" => Self::Failed,
            "done" => Self::Done,
            "cancelled" => Self::Cancelled,
            _ => Self::Queued,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum JobKind {
    Direct,
    Hls,
}

impl JobKind {
    fn as_str(&self) -> &'static str {
        match self {
            Self::Direct => "direct",
            Self::Hls => "hls",
        }
    }
    fn from_str(s: &str) -> Self {
        if s == "hls" {
            Self::Hls
        } else {
            Self::Direct
        }
    }
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

#[derive(Debug, Clone)]
pub enum DownloadEvent {
    Snapshot(Vec<DownloadJob>),
    Progress {
        id: String,
        bytes_done: i64,
        total_bytes: Option<i64>,
        segments_done: i64,
        total_segments: Option<i64>,
    },
    StatusChanged {
        id: String,
        status: JobStatus,
    },
}

pub struct DownloadQueue {
    db: Db,
    tx: broadcast::Sender<DownloadEvent>,
}

impl DownloadQueue {
    pub fn new(db: Db) -> Self {
        let (tx, _) = broadcast::channel(256);
        Self { db, tx }
    }

    pub fn subscribe(&self) -> broadcast::Receiver<DownloadEvent> {
        self.tx.subscribe()
    }

    pub fn insert(&self, job: &DownloadJob) -> Result<()> {
        let _headers_json = serde_json::to_string(&job.stream_headers).unwrap_or_default();
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
                    job.kind.as_str(),
                    job.dest_path,
                    job.status.as_str(),
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
        self.tx
            .send(DownloadEvent::Progress {
                id: id.to_owned(),
                bytes_done,
                total_bytes,
                segments_done,
                total_segments,
            })
            .ok();
        Ok(())
    }

    pub fn set_status(&self, id: &str, status: JobStatus) -> Result<()> {
        let n = now();
        self.db.with(|c| {
            c.execute(
                "UPDATE downloads SET status=?1, updated_at=?2 WHERE id=?3",
                rusqlite::params![status.as_str(), n, id],
            )?;
            Ok(())
        })?;
        self.tx
            .send(DownloadEvent::StatusChanged {
                id: id.to_owned(),
                status,
            })
            .ok();
        Ok(())
    }

    pub fn set_done(&self, id: &str) -> Result<()> {
        self.set_status(id, JobStatus::Done)
    }

    pub fn set_failed(&self, id: &str, reason: &str) -> Result<()> {
        let n = now();
        self.db.with(|c| {
            c.execute(
                "UPDATE downloads SET status='failed', error_msg=?1, updated_at=?2 WHERE id=?3",
                rusqlite::params![reason, n, id],
            )?;
            Ok(())
        })?;
        self.tx
            .send(DownloadEvent::StatusChanged {
                id: id.to_owned(),
                status: JobStatus::Failed,
            })
            .ok();
        Ok(())
    }
}

fn row_to_job(row: &rusqlite::Row<'_>) -> rusqlite::Result<DownloadJob> {
    Ok(DownloadJob {
        id: row.get(0)?,
        content_id: row.get(1)?,
        source_id: row.get(2)?,
        title: row.get(3)?,
        variant: row.get(4)?,
        kind: JobKind::from_str(&row.get::<_, String>(5)?),
        dest_path: row.get(6)?,
        status: JobStatus::from_str(&row.get::<_, String>(7)?),
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
