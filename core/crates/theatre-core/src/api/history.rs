//! data-contract.md §6 — watch history.

use crate::history::HistoryEntry;
use crate::{api::lifecycle, error::Result};

pub async fn record_playback(entry: HistoryEntry) -> Result<()> {
    lifecycle::history().record(&entry)
}

pub async fn continue_watching(limit: u32) -> Result<Vec<HistoryEntry>> {
    lifecycle::history().continue_watching(limit as usize)
}

pub async fn all_history(limit: u32, offset: u32) -> Result<Vec<HistoryEntry>> {
    lifecycle::history().all(limit as usize, offset as usize)
}

pub async fn delete_history(id: String) -> Result<()> {
    lifecycle::history().delete(&id)
}
