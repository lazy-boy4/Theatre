//! Source abstraction — architecture §15, data-contract.md §3.
//! Scraper implementations are extracted from the MovieBox-TUI fork.
//! See T2.1 (roadmap) — fork github.com/mesamirh/MovieBox-Tui, then:
//!   1. Add `upstream` remote
//!   2. Extract sources/moviebox.rs, sources/4khdhub.rs, sources/bdix.rs
//!   3. Implement the `Source` trait below for each

pub mod bdix;
pub mod health;
pub mod khddhub;
pub mod moviebox;
pub mod registry;

pub use registry::SourceRegistry;

use crate::{api::types::*, error::Result};
use async_trait::async_trait;

/// The Source trait — one impl per scraped site.
#[async_trait]
pub trait Source: Send + Sync {
    fn id(&self) -> &str;
    fn name(&self) -> &str;
    fn kind(&self) -> SourceKind {
        SourceKind::Standard
    }

    async fn search(&self, query: &str, page: u32) -> Result<SearchPage>;

    async fn get_details(&self, content_id: &str) -> Result<Details>;

    async fn resolve(&self, content_id: &str, variant: Option<&str>) -> Result<ResolvedStream>;

    async fn health_check(&self) -> SourceStatus;
}
