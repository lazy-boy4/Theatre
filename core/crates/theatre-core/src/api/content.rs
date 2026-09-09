//! data-contract.md §3 — search, details, source management.

use crate::{
    api::{lifecycle, types::*},
    error::Result,
};

pub async fn search(query: String, source_filter: Option<Vec<String>>) -> Result<SearchPage> {
    let filter = source_filter.as_deref();
    lifecycle::state().sources.search(&query, filter).await
}

pub async fn get_details(content: ContentRef) -> Result<Details> {
    lifecycle::state().sources.get_details(&content).await
}

pub async fn list_sources() -> Result<Vec<SourceInfo>> {
    Ok(lifecycle::state().sources.list_sources())
}

pub async fn set_source_enabled(id: String, _enabled: bool) -> Result<SourceInfo> {
    // Persist preference in settings, return updated SourceInfo
    // TODO: propagate enabled flag to registry at T2.9
    list_sources()
        .await?
        .into_iter()
        .find(|s| s.id == id)
        .ok_or_else(|| crate::error::TheatreError::Source {
            source: id,
            detail: "not found".into(),
        })
}
