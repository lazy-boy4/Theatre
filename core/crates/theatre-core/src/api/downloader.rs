//! data-contract.md §7 — download queue.

use crate::{
    api::{lifecycle, types::*},
    downloader::queue::DownloadJob,
    error::Result,
};

pub async fn enqueue_download(
    content: ContentRef,
    stream: ResolvedStream,
    title: String,
    variant: Option<String>,
) -> Result<String> {
    lifecycle::downloader()
        .enqueue(content, stream, &title, variant)
        .await
}

pub async fn list_downloads() -> Result<Vec<DownloadJob>> {
    lifecycle::downloader().list_jobs()
}

pub async fn pause_download(id: String) -> Result<()> {
    lifecycle::downloader().pause(&id)
}
pub async fn cancel_download(id: String) -> Result<()> {
    lifecycle::downloader().cancel(&id)
}
pub async fn resume_download(id: String) -> Result<()> {
    lifecycle::downloader().resume(&id)
}
