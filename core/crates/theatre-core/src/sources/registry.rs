//! Source registry — manages enabled sources, fan-out search,
//! per-source health tracking.

use super::{health::HealthTracker, Source};
use crate::{
    api::types::*,
    error::{Result, TheatreError},
    net::NetClient,
    settings::Settings,
    state::Db,
};
use std::{collections::HashMap, sync::Arc, time::Duration};
use tokio::time::timeout;

const SEARCH_TIMEOUT_SECS: u64 = 8;

pub struct SourceRegistry {
    sources: HashMap<String, Arc<dyn Source>>,
    health: Arc<HealthTracker>,
}

impl SourceRegistry {
    pub fn new(db: Db, settings: Arc<Settings>, net: NetClient) -> Self {
        let health = Arc::new(HealthTracker::new(db));
        let mut sources: HashMap<String, Arc<dyn Source>> = HashMap::new();
        let _ = settings;

        // Register built-in sources (T2.2-T2.4: real scrapers).
        sources.insert(
            "moviebox".into(),
            Arc::new(super::moviebox::MovieBoxSource::new(net.clone())),
        );
        sources.insert(
            "4khdhub".into(),
            Arc::new(super::khddhub::KhddhubSource::new(net.clone())),
        );
        sources.insert(
            "bdix".into(),
            Arc::new(super::bdix::BdixSource::new(net.clone())),
        );

        Self { sources, health }
    }

    /// Fan-out search — parallel, 8s per-source timeout.
    /// A failing source never fails the call (partial: true instead).
    pub async fn search(
        &self,
        query: &str,
        source_filter: Option<&[String]>,
    ) -> Result<SearchPage> {
        let enabled: Vec<Arc<dyn Source>> = self
            .sources
            .values()
            .filter(|s| {
                let id = s.id();
                // BDIX default-off (PRD D8)
                if id == "bdix" && source_filter.is_none() {
                    return false;
                }
                if let Some(filter) = source_filter {
                    return filter.iter().any(|f| f == id);
                }
                true
            })
            .cloned()
            .collect();

        if enabled.is_empty() {
            return Err(TheatreError::Source {
                source: "all".into(),
                detail: "no sources enabled".into(),
            });
        }

        let tasks: Vec<_> = enabled
            .iter()
            .map(|src| {
                let src = src.clone();
                let query = query.to_owned();
                let health = self.health.clone();
                tokio::spawn(async move {
                    let result = timeout(
                        Duration::from_secs(SEARCH_TIMEOUT_SECS),
                        src.search(&query, 1),
                    )
                    .await;
                    let source_id = src.id().to_owned();
                    match result {
                        Ok(Ok(page)) => {
                            health.mark_healthy(&source_id);
                            (source_id, Some(page))
                        }
                        Ok(Err(e)) => {
                            health.mark_degraded(&source_id, &e.to_string());
                            (source_id, None)
                        }
                        Err(_timeout) => {
                            health.mark_degraded(&source_id, "timeout");
                            (source_id, None)
                        }
                    }
                })
            })
            .collect();

        let mut all_results = Vec::new();
        let mut partial = false;
        for task in tasks {
            if let Ok((_, Some(page))) = task.await {
                all_results.extend(page.results);
            } else {
                partial = true;
            }
        }

        if all_results.is_empty() && partial {
            return Err(TheatreError::Source {
                source: "all".into(),
                detail: "all sources failed".into(),
            });
        }

        let page = SearchPage {
            results: all_results,
            has_more: false,
            partial,
        };
        Ok(page)
    }

    pub async fn get_details(&self, content: &ContentRef) -> Result<Details> {
        let source = self
            .sources
            .get(&content.source)
            .ok_or_else(|| TheatreError::Source {
                source: content.source.clone(),
                detail: "unknown source".into(),
            })?;
        source.get_details(&content.content_id).await
    }

    pub async fn resolve(
        &self,
        content: &ContentRef,
        variant: Option<&str>,
        _force: bool,
    ) -> Result<ResolvedStream> {
        let source = self
            .sources
            .get(&content.source)
            .ok_or_else(|| TheatreError::Source {
                source: content.source.clone(),
                detail: "unknown source".into(),
            })?;
        source.resolve(&content.content_id, variant).await
    }

    pub fn list_sources(&self) -> Vec<SourceInfo> {
        self.sources
            .values()
            .map(|s| SourceInfo {
                id: s.id().to_owned(),
                name: s.name().to_owned(),
                kind: s.kind(),
                enabled: true,
                status: self.health.get_status(s.id()),
            })
            .collect()
    }
}
