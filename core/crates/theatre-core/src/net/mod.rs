//! Shared HTTP client — architecture §5 (`net/`) and §16.
//! ALL outbound HTTP flows through here: per-host politeness (max 2
//! concurrent, 500ms min interval per PRD), timeouts, header sanitising.
//! Never use `reqwest::Client` directly in sources/downloader/proxy/subtitles.

use crate::error::{Result, TheatreError};
use std::{
    collections::HashMap,
    sync::{Arc, Mutex},
    time::{Duration, Instant},
};

const MAX_PER_HOST: usize = 2;
const MIN_INTERVAL: Duration = Duration::from_millis(500);

#[derive(Clone)]
pub struct NetClient {
    client: reqwest::Client,
    /// host -> (inflight count, last request start)
    state: Arc<Mutex<Inflight>>,
}

/// Per-host politeness bookkeeping.
type Inflight = HashMap<String, (usize, Option<Instant>)>;

impl Default for NetClient {
    fn default() -> Self {
        Self::new()
    }
}

impl NetClient {
    pub fn new() -> Self {
        let client = reqwest::Client::builder()
            .timeout(Duration::from_secs(20))
            .connect_timeout(Duration::from_secs(5))
            .tcp_keepalive(Duration::from_secs(30))
            .pool_idle_timeout(Duration::from_secs(90))
            .pool_max_idle_per_host(4)
            .user_agent("Theatre/0.1.0")
            .build()
            .unwrap_or_else(|_| reqwest::Client::new());
        Self {
            client,
            state: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    /// Raw handle for scraper internals that must build their own signed
    /// requests (e.g. MovieBox HMAC headers). Prefer `get`/`get_range`.
    pub fn raw(&self) -> &reqwest::Client {
        &self.client
    }

    pub async fn get(&self, url: &str, headers: &HashMap<String, String>) -> Result<NetResponse> {
        self.request(url, headers, None).await
    }

    pub async fn get_range(
        &self,
        url: &str,
        headers: &HashMap<String, String>,
        offset: u64,
    ) -> Result<NetResponse> {
        self.request(url, headers, Some(offset)).await
    }

    /// POST with a JSON body (BDIX DhakaFlix file-browser API).
    pub async fn post_json(
        &self,
        url: &str,
        headers: &HashMap<String, String>,
        body: &serde_json::Value,
    ) -> Result<NetResponse> {
        let host = host_of(url).unwrap_or_default();
        self.politeness_wait(&host).await;
        let mut builder = self.client.post(url).json(body);
        for (k, v) in headers {
            if v.contains('\r') || v.contains('\n') {
                continue;
            }
            builder = builder.header(k.as_str(), v.as_str());
        }
        let resp = builder.send().await.map_err(|e| TheatreError::Network {
            detail: e.to_string(),
        })?;
        self.release(&host);
        Ok(NetResponse(resp))
    }

    async fn request(
        &self,
        url: &str,
        headers: &HashMap<String, String>,
        range_offset: Option<u64>,
    ) -> Result<NetResponse> {
        let host = host_of(url).unwrap_or_default();
        self.politeness_wait(&host).await;

        let mut builder = self.client.get(url);
        for (k, v) in headers {
            // Header injection guard: drop values with CR/LF (security test).
            if v.contains('\r') || v.contains('\n') {
                continue;
            }
            builder = builder.header(k.as_str(), v.as_str());
        }
        if let Some(off) = range_offset {
            builder = builder.header("Range", format!("bytes={}-", off));
        }

        let resp = builder.send().await.map_err(|e| TheatreError::Network {
            detail: e.to_string(),
        })?;
        // Headers received — free the concurrency slot (body streams after).
        self.release(&host);
        Ok(NetResponse(resp))
    }

    /// Enforce max-2-concurrent + 500ms min interval per host.
    async fn politeness_wait(&self, host: &str) {
        loop {
            let wait = {
                let mut st = self.state.lock().unwrap();
                let e = st.entry(host.to_owned()).or_insert((0, None));
                let now = Instant::now();
                if e.0 >= MAX_PER_HOST {
                    Some(Duration::from_millis(50))
                } else if let Some(last) = e.1 {
                    if now.duration_since(last) < MIN_INTERVAL {
                        Some(MIN_INTERVAL - now.duration_since(last))
                    } else {
                        e.0 += 1;
                        e.1 = Some(now);
                        None
                    }
                } else {
                    e.0 += 1;
                    e.1 = Some(now);
                    None
                }
            };
            match wait {
                None => return,
                Some(d) => tokio::time::sleep(d).await,
            }
        }
    }

    fn release(&self, host: &str) {
        let mut st = self.state.lock().unwrap();
        if let Some(e) = st.get_mut(host) {
            e.0 = e.0.saturating_sub(1);
        }
    }
}

/// Thin wrapper so callers never touch reqwest types directly.
pub struct NetResponse(reqwest::Response);

impl NetResponse {
    pub async fn text(self) -> std::result::Result<String, reqwest::Error> {
        self.0.text().await
    }

    pub async fn bytes(self) -> std::result::Result<bytes::Bytes, reqwest::Error> {
        self.0.bytes().await
    }

    pub async fn json<T: serde::de::DeserializeOwned>(
        self,
    ) -> std::result::Result<T, reqwest::Error> {
        self.0.json().await
    }

    pub fn bytes_stream(
        self,
    ) -> impl futures::Stream<Item = std::result::Result<bytes::Bytes, reqwest::Error>> {
        
        self.0.bytes_stream()
    }

    pub fn status(&self) -> reqwest::StatusCode {
        self.0.status()
    }

    pub fn content_length(&self) -> Option<u64> {
        self.0.content_length()
    }

    pub fn headers(&self) -> &reqwest::header::HeaderMap {
        self.0.headers()
    }

    pub fn url(&self) -> &reqwest::Url {
        self.0.url()
    }
}

fn host_of(url: &str) -> Option<String> {
    let after_scheme = url.split("://").nth(1)?;
    Some(after_scheme.split('/').next()?.to_owned())
}
