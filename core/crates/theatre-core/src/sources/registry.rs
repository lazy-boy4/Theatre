//! Source registry — manages enabled sources, fan-out search,
//! per-source health tracking.

use super::{health::HealthTracker, Source};
use crate::{
    api::types::*,
    error::{Result, TheatreError},
    net::NetClient,
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
    pub fn new(db: Db, net: NetClient) -> Self {
        let health = Arc::new(HealthTracker::new(db));
        let mut sources: HashMap<String, Arc<dyn Source>> = HashMap::new();

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

    #[cfg(test)]
    pub(crate) fn with_sources(db: Db, custom_sources: Vec<Arc<dyn Source>>) -> Self {
        let health = Arc::new(HealthTracker::new(db));
        let mut sources = HashMap::new();
        for s in custom_sources {
            sources.insert(s.id().to_owned(), s);
        }
        Self { sources, health }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use async_trait::async_trait;

    struct StubOkSource;
    #[async_trait]
    impl Source for StubOkSource {
        fn id(&self) -> &str {
            "stub_ok"
        }
        fn name(&self) -> &str {
            "Stub OK"
        }
        async fn search(&self, _query: &str, _page: u32) -> Result<SearchPage> {
            Ok(SearchPage {
                results: vec![SearchResult {
                    content: ContentRef {
                        source: "stub_ok".into(),
                        content_id: "1".into(),
                        kind: ContentKind::Movie,
                    },
                    title: "Test Movie".into(),
                    year: Some(2025),
                    poster_url: None,
                    quality_badges: vec!["1080p".into()],
                }],
                has_more: false,
                partial: false,
            })
        }
        async fn get_details(&self, _content_id: &str) -> Result<Details> {
            Err(TheatreError::Source {
                source: "stub_ok".into(),
                detail: "not implemented".into(),
            })
        }
        async fn resolve(
            &self,
            _content_id: &str,
            _variant: Option<&str>,
        ) -> Result<ResolvedStream> {
            Err(TheatreError::Source {
                source: "stub_ok".into(),
                detail: "not implemented".into(),
            })
        }
    }

    struct StubErrSource;
    #[async_trait]
    impl Source for StubErrSource {
        fn id(&self) -> &str {
            "stub_err"
        }
        fn name(&self) -> &str {
            "Stub Err"
        }
        async fn search(&self, _query: &str, _page: u32) -> Result<SearchPage> {
            Err(TheatreError::Source {
                source: "stub_err".into(),
                detail: "scrape failed".into(),
            })
        }
        async fn get_details(&self, _content_id: &str) -> Result<Details> {
            Err(TheatreError::Source {
                source: "stub_err".into(),
                detail: "not implemented".into(),
            })
        }
        async fn resolve(
            &self,
            _content_id: &str,
            _variant: Option<&str>,
        ) -> Result<ResolvedStream> {
            Err(TheatreError::Source {
                source: "stub_err".into(),
                detail: "not implemented".into(),
            })
        }
    }

    #[tokio::test]
    async fn fanout_search_merges_results_and_marks_degraded() {
        let dir = std::env::temp_dir().join(format!("theatre_reg_test_{}", uuid::Uuid::now_v7()));
        let db = Db::open(dir.join("test.db")).unwrap();
        let registry =
            SourceRegistry::with_sources(db, vec![Arc::new(StubOkSource), Arc::new(StubErrSource)]);

        let page = registry.search("anything", None).await.unwrap();
        assert_eq!(page.results.len(), 1);
        assert_eq!(page.results[0].title, "Test Movie");
        assert!(page.partial, "failing source should trigger partial: true");

        assert_eq!(registry.health.get_status("stub_ok"), SourceStatus::Healthy);
        match registry.health.get_status("stub_err") {
            SourceStatus::Degraded { last_error, .. } => {
                assert!(last_error.contains("scrape failed"));
            }
            other => panic!("expected degraded status, got {:?}", other),
        }

        std::fs::remove_dir_all(&dir).ok();
    }
}
