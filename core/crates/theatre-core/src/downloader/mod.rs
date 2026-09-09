//! Unified download engine — data-contract.md §7, architecture §8.
//! Handles: direct-HTTP range resume, HLS segment fetch + remux via ffmpeg sidecar.
//! Queue: persist every state transition to SQLite; resume after kill.

pub mod direct;
pub mod ffmpeg;
pub mod hls;
pub mod queue;

pub use queue::{DownloadJob, DownloadQueue, JobKind, JobStatus};

use crate::{
    api::types::{ContentRef, ResolvedStream, StreamKind},
    error::{Result, TheatreError},
    net::NetClient,
    sources::util::sanitize_filename,
    state::Db,
};
use std::{path::PathBuf, sync::Arc};
use uuid::Uuid;

/// Main download manager — one per app lifetime.
#[derive(Clone)]
pub struct Downloader {
    net: NetClient,
    queue: Arc<DownloadQueue>,
    ffmpeg: Arc<ffmpeg::FfmpegSidecar>,
    root: PathBuf,
}

impl Downloader {
    pub fn new(db: Db, net: NetClient, root: PathBuf, ffmpeg: Arc<ffmpeg::FfmpegSidecar>) -> Self {
        let queue = Arc::new(DownloadQueue::new(db));
        Self {
            net,
            queue,
            ffmpeg,
            root,
        }
    }

    /// Enqueue a new download. Returns the job ID.
    pub async fn enqueue(
        &self,
        content: ContentRef,
        stream: ResolvedStream,
        title: &str,
        variant: Option<String>,
    ) -> Result<String> {
        let id = Uuid::now_v7().to_string();
        let kind = match stream.kind {
            StreamKind::Direct => JobKind::Direct,
            StreamKind::Hls => JobKind::Hls,
        };

        // Determine destination path
        let filename = stream
            .filename_hint
            .clone()
            .unwrap_or_else(|| sanitize_filename(title));
        let dir = self.dest_dir(&content);
        std::fs::create_dir_all(&dir).ok();
        let dest_path = dir.join(&filename);

        let job = DownloadJob {
            id: id.clone(),
            content_id: content.content_id.clone(),
            source_id: content.source.clone(),
            title: title.to_owned(),
            variant: variant.clone(),
            kind: kind.clone(),
            dest_path: dest_path.to_string_lossy().into_owned(),
            status: JobStatus::Queued,
            bytes_done: 0,
            total_bytes: stream.size_bytes.map(|b| b as i64),
            segments_done: 0,
            total_segments: None,
            error_msg: None,
            created_at: crate::state::now(),
            updated_at: crate::state::now(),
            resume_offset: 0,
            resume_segment: 0,
            stream_url: stream.url.clone(),
            stream_headers: stream.headers.clone(),
        };

        self.queue.insert(&job)?;
        self.spawn_job(job, stream);
        Ok(id)
    }

    fn dest_dir(&self, content: &ContentRef) -> PathBuf {
        use crate::api::types::ContentKind;
        match content.kind {
            ContentKind::Movie => self.root.join("Movies"),
            ContentKind::Series | ContentKind::Episode => self.root.join("Series"),
        }
    }

    fn spawn_job(&self, job: DownloadJob, stream: ResolvedStream) {
        let queue = self.queue.clone();
        let net = self.net.clone();
        let ffmpeg = self.ffmpeg.clone();

        tokio::spawn(async move {
            let result = match job.kind {
                JobKind::Direct => direct::download_direct(&job, &stream, &net, &queue).await,
                JobKind::Hls => hls::download_hls(&job, &stream, &net, &ffmpeg, &queue).await,
            };
            if let Err(e) = result {
                queue.set_failed(&job.id, &e.to_string()).ok();
            }
        });
    }

    pub fn list_jobs(&self) -> Result<Vec<DownloadJob>> {
        self.queue.list_all()
    }

    pub fn pause(&self, id: &str) -> Result<()> {
        self.queue.set_status(id, JobStatus::Paused)
    }
    pub fn cancel(&self, id: &str) -> Result<()> {
        self.queue.set_status(id, JobStatus::Cancelled)
    }

    pub fn resume(&self, id: &str) -> Result<()> {
        let job = self.queue.get(id)?.ok_or_else(|| TheatreError::Download {
            job_id: id.to_owned(),
            reason: "not found".into(),
            resumable: false,
        })?;
        // Re-resolve is handled by caller if needed; here we just re-spawn.
        let stream = ResolvedStream {
            url: job.stream_url.clone(),
            headers: job.stream_headers.clone(),
            kind: match job.kind {
                JobKind::Direct => StreamKind::Direct,
                JobKind::Hls => StreamKind::Hls,
            },
            variants: vec![],
            selected_variant: job.variant.clone(),
            filename_hint: None,
            size_bytes: job.total_bytes.map(|b| b as u64),
        };
        self.queue.set_status(id, JobStatus::Queued)?;
        self.spawn_job(job, stream);
        Ok(())
    }
}
