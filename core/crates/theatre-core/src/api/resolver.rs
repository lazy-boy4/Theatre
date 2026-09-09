//! data-contract.md §4 — resolver.

use crate::{
    api::{lifecycle, types::*},
    error::Result,
};

pub async fn resolve(
    content: ContentRef,
    variant: Option<String>,
    force_refresh: bool,
) -> Result<ResolvedStream> {
    lifecycle::state()
        .sources
        .resolve(&content, variant.as_deref(), force_refresh)
        .await
}
