//! HLS segment downloader + remux via ffmpeg sidecar.
//! architecture §8: fetch segments, retry ≤3 times, re-resolve on 403,
//! remux concatenated TS into MP4 (MKV fallback).

use super::{
    ffmpeg::FfmpegSidecar,
    queue::{DownloadJob, DownloadQueue, JobStatus},
};
use crate::{
    api::types::ResolvedStream,
    error::{Result, TheatreError},
    net::NetClient,
};
use std::{path::Path, sync::Arc, time::Duration};

const MAX_SEGMENT_RETRIES: u32 = 3;
// ponytail: sequential fetch for now; raise to a semaphore pool if slow.
const _SEGMENT_CONCURRENCY: usize = 2;

pub async fn download_hls(
    job: &DownloadJob,
    stream: &ResolvedStream,
    net: &NetClient,
    ffmpeg: &Arc<FfmpegSidecar>,
    queue: &Arc<DownloadQueue>,
) -> Result<()> {
    let spool_path = format!("{}.spool.ts", job.dest_path);
    let dest_path = Path::new(&job.dest_path);

    // 1. Parse master/variant playlist
    let playlist_url = &stream.url;
    let segments = fetch_segment_urls(net, playlist_url, &stream.headers).await?;
    let total = segments.len() as i64;

    // Update total segment count
    queue
        .update_progress(
            &job.id,
            0,
            None,
            job.resume_segment,
            Some(total),
            0,
            job.resume_segment,
        )
        .ok();

    // Open spool file for writing/appending
    let start_seg = job.resume_segment as usize;
    let file = if start_seg > 0 {
        tokio::fs::OpenOptions::new()
            .write(true)
            .append(true)
            .open(&spool_path)
            .await
    } else {
        tokio::fs::File::create(&spool_path).await
    }
    .map_err(|e| TheatreError::Download {
        job_id: job.id.clone(),
        reason: e.to_string(),
        resumable: true,
    })?;

    use tokio::io::AsyncWriteExt;
    let mut writer = tokio::io::BufWriter::new(file);
    let mut done_bytes: i64 = 0;

    for (idx, seg_url) in segments.iter().enumerate().skip(start_seg) {
        if is_cancelled(queue, &job.id) {
            let _ = writer.flush().await;
            return Ok(());
        }
        if is_paused(queue, &job.id) {
            let _ = writer.flush().await;
            // Persist progress and return — resume will re-call us
            return Ok(());
        }

        // Retry loop per segment
        let seg_data = fetch_segment_with_retry(net, seg_url, &stream.headers, MAX_SEGMENT_RETRIES)
            .await
            .map_err(|e| TheatreError::Download {
                job_id: job.id.clone(),
                reason: format!("segment {}: {}", idx, e),
                resumable: true,
            })?;

        done_bytes += seg_data.len() as i64;
        writer
            .write_all(&seg_data)
            .await
            .map_err(|e| TheatreError::Download {
                job_id: job.id.clone(),
                reason: e.to_string(),
                resumable: true,
            })?;

        let done_segs = (idx + 1) as i64;
        queue
            .update_progress(
                &job.id,
                done_bytes,
                None,
                done_segs,
                Some(total),
                0,
                done_segs,
            )
            .ok();
    }

    writer.flush().await.map_err(|e| TheatreError::Download {
        job_id: job.id.clone(),
        reason: e.to_string(),
        resumable: true,
    })?;

    // 2. Remux TS spool → MP4
    let dest_str = dest_path.to_string_lossy().into_owned();
    ffmpeg
        .remux(&spool_path, &dest_str)
        .await
        .map_err(|e| TheatreError::Download {
            job_id: job.id.clone(),
            reason: format!("remux: {}", e),
            resumable: false,
        })?;

    // 3. Cleanup spool
    tokio::fs::remove_file(&spool_path).await.ok();
    queue.set_status(&job.id, JobStatus::Done)?;
    Ok(())
}

async fn fetch_segment_urls(
    net: &NetClient,
    url: &str,
    headers: &std::collections::HashMap<String, String>,
) -> Result<Vec<String>> {
    let resp = net.get(url, headers).await?;
    let text = resp.text().await.map_err(|e| TheatreError::Network {
        detail: e.to_string(),
    })?;
    let base = url::Url::parse(url).map_err(|e| TheatreError::Network {
        detail: format!("bad playlist url: {}", e),
    })?;
    let mut segments = Vec::new();

    for line in text.lines() {
        let line = line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        let seg = resolve_segment_url(&base, line)?;
        let seg = seg.to_string();
        // If this is a sub-playlist (variant), recurse once
        if line.ends_with(".m3u8") {
            return Box::pin(fetch_segment_urls(net, &seg, headers)).await;
        }
        segments.push(seg);
    }
    Ok(segments)
}

/// Join a playlist line against its base URL, enforcing the architecture
/// invariant: HLS segments only over http(s) — never file://, data:, etc.
pub(crate) fn resolve_segment_url(base: &url::Url, line: &str) -> Result<url::Url> {
    let seg = base.join(line).map_err(|e| TheatreError::Network {
        detail: format!("bad segment url: {}", e),
    })?;
    if seg.scheme() != "http" && seg.scheme() != "https" {
        return Err(TheatreError::Network {
            detail: format!("rejected non-http segment: {}", seg.scheme()),
        });
    }
    Ok(seg)
}

async fn fetch_segment_with_retry(
    net: &NetClient,
    url: &str,
    headers: &std::collections::HashMap<String, String>,
    retries: u32,
) -> std::result::Result<bytes::Bytes, String> {
    let mut last_err = String::new();
    for attempt in 0..=retries {
        if attempt > 0 {
            tokio::time::sleep(Duration::from_millis(500 * 2u64.pow(attempt))).await;
        }
        match net.get(url, headers).await {
            Ok(resp) => match resp.bytes().await {
                Ok(b) => return Ok(b),
                Err(e) => last_err = e.to_string(),
            },
            Err(e) => last_err = e.to_string(),
        }
    }
    Err(last_err)
}

fn is_paused(queue: &Arc<DownloadQueue>, id: &str) -> bool {
    queue
        .get(id)
        .ok()
        .flatten()
        .map(|j| j.status == JobStatus::Paused)
        .unwrap_or(false)
}

fn is_cancelled(queue: &Arc<DownloadQueue>, id: &str) -> bool {
    queue
        .get(id)
        .ok()
        .flatten()
        .map(|j| j.status == JobStatus::Cancelled)
        .unwrap_or(false)
}
