//! Direct-file HTTP download with range resume.

use super::queue::{DownloadJob, DownloadQueue, JobStatus};
use crate::{
    api::types::ResolvedStream,
    error::{Result, TheatreError},
    net::NetClient,
};
use futures::StreamExt;
use std::{path::Path, sync::Arc};

const PROGRESS_EVERY: u64 = 512 * 1024; // update DB every 512 KB

pub async fn download_direct(
    job: &DownloadJob,
    stream: &ResolvedStream,
    net: &NetClient,
    queue: &Arc<DownloadQueue>,
) -> Result<()> {
    let dest = Path::new(&job.dest_path);
    let part = dest.with_extension("part");
    let offset = job.resume_offset as u64;

    // Open file for writing / appending
    let file = if offset > 0 {
        tokio::fs::OpenOptions::new()
            .write(true)
            .append(true)
            .open(&part)
            .await
    } else {
        tokio::fs::File::create(&part).await
    }
    .map_err(|e| TheatreError::Download {
        job_id: job.id.clone(),
        reason: e.to_string(),
        resumable: true,
    })?;

    let response = if offset > 0 {
        net.get_range(&stream.url, &stream.headers, offset).await
    } else {
        net.get(&stream.url, &stream.headers).await
    }?;

    let total = response.content_length().map(|l| (l + offset) as i64);

    let mut writer = tokio::io::BufWriter::new(file);
    let mut bytes_done = offset as i64;
    let mut since_last_update = 0u64;
    let mut body = response.bytes_stream();

    use tokio::io::AsyncWriteExt;
    while let Some(chunk) = body.next().await {
        let chunk = chunk.map_err(|e| TheatreError::Download {
            job_id: job.id.clone(),
            reason: e.to_string(),
            resumable: true,
        })?;
        writer
            .write_all(&chunk)
            .await
            .map_err(|e| TheatreError::Download {
                job_id: job.id.clone(),
                reason: e.to_string(),
                resumable: true,
            })?;
        bytes_done += chunk.len() as i64;
        since_last_update += chunk.len() as u64;

        if since_last_update >= PROGRESS_EVERY {
            queue
                .update_progress(&job.id, bytes_done, total, 0, None, bytes_done, 0)
                .ok();
            since_last_update = 0;

            // Check for pause/cancel
            if is_paused_or_cancelled(queue, &job.id) {
                let _ = writer.flush().await;
                return Ok(());
            }
        }
    }

    writer.flush().await.map_err(|e| TheatreError::Download {
        job_id: job.id.clone(),
        reason: e.to_string(),
        resumable: true,
    })?;

    // Atomic rename
    tokio::fs::rename(&part, dest)
        .await
        .map_err(|e| TheatreError::Download {
            job_id: job.id.clone(),
            reason: e.to_string(),
            resumable: false,
        })?;

    queue.set_status(&job.id, JobStatus::Done)?;
    Ok(())
}

fn is_paused_or_cancelled(queue: &Arc<DownloadQueue>, id: &str) -> bool {
    queue
        .get(id)
        .ok()
        .flatten()
        .map(|j| {
            matches!(
                j.status,
                super::queue::JobStatus::Paused | super::queue::JobStatus::Cancelled
            )
        })
        .unwrap_or(false)
}
