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

    pub async fn get(
        &self,
        url: &str,
        headers: &HashMap<String, String>,
    ) -> Result<reqwest::Response> {
        let builder = apply_headers(self.client.get(url), headers);
        self.send(builder, url).await
    }

    pub async fn get_range(
        &self,
        url: &str,
        headers: &HashMap<String, String>,
        offset: u64,
    ) -> Result<reqwest::Response> {
        let builder = apply_headers(self.client.get(url), headers)
            .header("Range", format!("bytes={}-", offset));
        self.send(builder, url).await
    }

    /// POST with a pre-encoded body string (MovieBox signed JSON calls).
    /// The signed header map already carries Content-Type: application/json.
    pub async fn post_raw(
        &self,
        url: &str,
        headers: &HashMap<String, String>,
        body: &str,
    ) -> Result<reqwest::Response> {
        let builder = apply_headers(self.client.post(url).body(body.to_owned()), headers);
        self.send(builder, url).await
    }

    /// POST with a JSON body (BDIX DhakaFlix file-browser API).
    pub async fn post_json(
        &self,
        url: &str,
        headers: &HashMap<String, String>,
        body: &serde_json::Value,
    ) -> Result<reqwest::Response> {
        let builder = apply_headers(self.client.post(url).json(body), headers);
        self.send(builder, url).await
    }

    /// Sole send path: politeness gate, transport, slot release.
    async fn send(&self, builder: reqwest::RequestBuilder, url: &str) -> Result<reqwest::Response> {
        let host = host_of(url);
        self.politeness_wait(&host).await;
        let resp = builder.send().await.map_err(|e| TheatreError::Network {
            detail: e.to_string(),
        })?;
        // Headers received — free the concurrency slot (body streams after).
        self.release(&host);
        Ok(resp)
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

/// Attach headers, dropping CR/LF-injected values (security: header guard).
fn apply_headers(
    mut builder: reqwest::RequestBuilder,
    headers: &HashMap<String, String>,
) -> reqwest::RequestBuilder {
    for (k, v) in headers {
        if v.contains('\r') || v.contains('\n') {
            continue;
        }
        builder = builder.header(k.as_str(), v.as_str());
    }
    builder
}

fn host_of(url: &str) -> String {
    url::Url::parse(url)
        .ok()
        .and_then(|u| u.host_str().map(|h| h.to_owned()))
        .unwrap_or_default()
}
