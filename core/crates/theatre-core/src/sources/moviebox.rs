//! MovieBox source — primary source, ported from the MovieBox-TUI fork
//! (`github.com/mesamirh/MovieBox-Tui`, `src/providers/moviebox/`).
//! Implements `Source` (sources/mod.rs) over the MovieBox JSON API:
//! signed requests (HMAC-MD5 `x-tr-signature`, `x-client-token`), visitor-login
//! session token, 7-host fallback pool. data-contract.md §3.1/§3.2/§4.1.
//!
//! Deviations from upstream (deliberate, minimal):
//! - Session token is in-memory only (upstream persists to disk cache).
//!   Visitor tokens are short-lived; re-login is cheap.
//! - All HTTP goes through `crate::net::NetClient` (politeness + header
//!   sanitising); upstream's bespoke reqwest client is not used.
//! - Episode addressing uses composite content ids `"<id>:<S>:<E>"`
//!   (see `split_content_id`); movies use the plain subject id.

use crate::{
    api::types::*,
    error::{Result, TheatreError},
    net::NetClient,
    state,
};
use async_trait::async_trait;
use std::{
    collections::HashMap,
    sync::{
        atomic::{AtomicUsize, Ordering},
        RwLock,
    },
};

const HOST_POOL: &[&str] = &[
    "https://api6.aoneroom.com",
    "https://api5.aoneroom.com",
    "https://api4.aoneroom.com",
    "https://api4sg.aoneroom.com",
    "https://api3.aoneroom.com",
    "https://api6sg.aoneroom.com",
    "https://api.inmoviebox.com",
];
const RETRY_STATUS: &[u16] = &[403, 406, 407, 429, 500, 502, 503, 504];
const SEARCH_PATH: &str = "/wefeed-mobile-bff/subject-api/search/v2";

pub struct MovieBoxSource {
    net: NetClient,
    session: RwLock<Option<String>>,
    active_base_idx: AtomicUsize,
    user_agent: String,
    client_info: String,
    spoofed_ip: String,
}

impl MovieBoxSource {
    pub fn new(net: NetClient) -> Self {
        let (user_agent, client_info) = crypto::generate_client_info_and_ua();
        Self {
            net,
            session: RwLock::new(None),
            active_base_idx: AtomicUsize::new(0),
            user_agent,
            client_info,
            spoofed_ip: crypto::random_spoofed_ip(),
        }
    }

    // ── session ──────────────────────────────────────────────
    async fn ensure_session(&self) -> Result<String> {
        if let Some(t) = self.session.read().unwrap().clone() {
            return Ok(t);
        }
        let val = self
            .request_hosts(
                "POST",
                "/wefeed-mobile-bff/user-api/visitor-login",
                Some("{}"),
                None,
            )
            .await?;
        let token = val
            .get("token")
            .and_then(|t| t.as_str())
            .filter(|t| !t.trim().is_empty())
            .ok_or_else(|| self.err("visitor-login: missing token"))?;
        *self.session.write().unwrap() = Some(token.to_owned());
        Ok(token.to_owned())
    }

    fn invalidate_session(&self) {
        *self.session.write().unwrap() = None;
    }

    fn absorb_x_user(&self, headers: &reqwest::header::HeaderMap) {
        let Some(v) = headers.get("x-user") else {
            return;
        };
        let Ok(s) = v.to_str() else { return };
        let Ok(json): std::result::Result<serde_json::Value, _> = serde_json::from_str(s) else {
            return;
        };
        if let Some(token) = json.get("token").and_then(|t| t.as_str()) {
            if !token.is_empty() {
                *self.session.write().unwrap() = Some(token.to_owned());
            }
        }
    }

    // ── low-level request with host fallback ─────────────────
    async fn get(&self, path: &str) -> Result<serde_json::Value> {
        let token = self.ensure_session().await?;
        match self.request_hosts("GET", path, None, Some(&token)).await {
            Err(TheatreError::Source { detail, .. })
                if detail.starts_with("HTTP 401") || detail.starts_with("HTTP 403") =>
            {
                self.invalidate_session();
                let fresh = self.ensure_session().await?;
                self.request_hosts("GET", path, None, Some(&fresh)).await
            }
            r => r,
        }
    }

    async fn post(&self, path: &str, body: &serde_json::Value) -> Result<serde_json::Value> {
        let body_str =
            serde_json::to_string(body).map_err(|e| self.err(&format!("encode body: {}", e)))?;
        let token = self.ensure_session().await?;
        match self
            .request_hosts("POST", path, Some(&body_str), Some(&token))
            .await
        {
            Err(TheatreError::Source { detail, .. })
                if detail.starts_with("HTTP 401") || detail.starts_with("HTTP 403") =>
            {
                self.invalidate_session();
                let fresh = self.ensure_session().await?;
                self.request_hosts("POST", path, Some(&body_str), Some(&fresh))
                    .await
            }
            r => r,
        }
    }

    async fn request_hosts(
        &self,
        method: &str,
        path: &str,
        body: Option<&str>,
        token: Option<&str>,
    ) -> Result<serde_json::Value> {
        let start = self.active_base_idx.load(Ordering::Relaxed);
        let mut last_err = "all hosts exhausted".to_owned();
        for i in 0..HOST_POOL.len() {
            if i > 0 {
                tokio::time::sleep(std::time::Duration::from_millis(50)).await;
            }
            let idx = (start + i) % HOST_POOL.len();
            let url = format!("{}{}", HOST_POOL[idx], path);
            let headers = crypto::signed_headers(
                method,
                &url,
                body,
                token,
                &self.user_agent,
                &self.client_info,
                &self.spoofed_ip,
            );
            let resp = if method == "POST" {
                match &body {
                    Some(b) => self.net.post_raw(&url, &headers, b).await,
                    None => self.net.post_raw(&url, &headers, "").await,
                }
            } else {
                self.net.get(&url, &headers).await
            };
            let resp = match resp {
                Ok(r) => r,
                Err(e) => {
                    last_err = e.to_string();
                    continue;
                }
            };
            self.absorb_x_user(resp.headers());
            let status = resp.status().as_u16();
            if status == 401 || status == 403 {
                return Err(self.src_err(&format!("HTTP {}", status)));
            }
            if RETRY_STATUS.contains(&status) {
                last_err = format!("HTTP {}", status);
                continue;
            }
            if !resp.status().is_success() {
                last_err = format!("HTTP {}", status);
                continue;
            }
            let text = resp
                .text()
                .await
                .map_err(|e| self.net_err(&e.to_string()))?;
            let body_val: serde_json::Value = serde_json::from_str(&text)
                .map_err(|e| self.src_err(&format!("bad json: {}", e)))?;
            self.active_base_idx.store(idx, Ordering::Relaxed);
            // Envelope: most endpoints nest payload under `data`.
            if let Some(data) = body_val.get("data") {
                return Ok(data.clone());
            }
            return Ok(body_val);
        }
        Err(self.src_err(&last_err))
    }

    // ── high-level endpoints ─────────────────────────────────
    async fn api_search(&self, query: &str, page: u32) -> Result<serde_json::Value> {
        self.post(
            SEARCH_PATH,
            &serde_json::json!({
                "keyword": query, "page": page, "perPage": 15, "subjectType": 0
            }),
        )
        .await
    }

    async fn api_details(&self, subject_id: &str) -> Result<serde_json::Value> {
        let mut details = self
            .get(&format!(
                "/wefeed-mobile-bff/subject-api/get?subjectId={}",
                subject_id
            ))
            .await?;
        let stype = details
            .get("subjectType")
            .and_then(|s| s.as_i64())
            .unwrap_or(1);
        if stype == 2 {
            if let Ok(seasons) = self
                .get(&format!(
                    "/wefeed-mobile-bff/subject-api/season-info?subjectId={}",
                    subject_id
                ))
                .await
            {
                if let serde_json::Value::Object(ref mut map) = details {
                    map.insert("seasons".to_owned(), seasons);
                }
            }
        }
        Ok(details)
    }

    async fn api_play_info(
        &self,
        subject_id: &str,
        season: u32,
        episode: u32,
    ) -> Result<serde_json::Value> {
        let path = if season == 0 && episode == 0 {
            format!(
                "/wefeed-mobile-bff/subject-api/play-info/v2?subjectId={}",
                subject_id
            )
        } else {
            format!(
                "/wefeed-mobile-bff/subject-api/play-info/v2?subjectId={}&se={}&ep={}",
                subject_id, season, episode
            )
        };
        self.get(&path).await
    }

    async fn api_resources(
        &self,
        subject_id: &str,
        season: u32,
        episode: u32,
    ) -> Result<serde_json::Value> {
        let path = if season == 0 && episode == 0 {
            format!(
                "/wefeed-mobile-bff/subject-api/resource?subjectId={}&page=1&perPage=20",
                subject_id
            )
        } else {
            format!(
                "/wefeed-mobile-bff/subject-api/resource?subjectId={}&se={}&ep={}&page=1&perPage=20",
                subject_id, season, episode
            )
        };
        self.get(&path).await
    }

    fn err(&self, detail: &str) -> TheatreError {
        TheatreError::Source {
            source: "moviebox".into(),
            detail: detail.into(),
        }
    }
    fn src_err(&self, detail: &str) -> TheatreError {
        self.err(detail)
    }
    fn net_err(&self, detail: &str) -> TheatreError {
        TheatreError::Network {
            detail: detail.into(),
        }
    }

    // ── pure parsers (fixture-testable, no network) ──────────
    pub(crate) fn parse_search_results(payload: &serde_json::Value) -> Result<Vec<SearchResult>> {
        // Accept both enveloped {data:{results:[{subjects}]}} and bare shapes.
        let subjects: Vec<&serde_json::Value> = payload
            .get("data")
            .and_then(|d| d.get("results"))
            .or_else(|| payload.get("results"))
            .and_then(|r| r.as_array())
            .and_then(|arr| arr.first())
            .and_then(|first| first.get("subjects"))
            .and_then(|s| s.as_array())
            .map(|a| a.iter().collect())
            .or_else(|| {
                payload
                    .get("data")
                    .and_then(|d| d.get("list"))
                    .or_else(|| payload.get("list"))
                    .and_then(|l| l.as_array())
                    .map(|a| a.iter().collect())
            })
            .unwrap_or_default();

        let mut out = Vec::new();
        for s in subjects {
            let Some(id) = str_field(s, &["subjectId", "id"]) else {
                continue;
            };
            let title = s
                .get("title")
                .or_else(|| s.get("name"))
                .and_then(|t| t.as_str())
                .unwrap_or("Unknown")
                .to_owned();
            if title.trim().is_empty() {
                continue;
            }
            let stype = s
                .get("subjectType")
                .or_else(|| s.get("stype"))
                .and_then(|v| v.as_i64())
                .unwrap_or(1);
            let kind = if stype == 2 {
                ContentKind::Series
            } else {
                ContentKind::Movie
            };
            let year = s
                .get("releaseDate")
                .or_else(|| s.get("year"))
                .and_then(|y| y.as_str())
                .and_then(extract_year);
            let poster_url = s
                .get("cover")
                .and_then(|c| c.get("url"))
                .or_else(|| s.get("coverUrl"))
                .or_else(|| s.get("poster"))
                .and_then(|u| u.as_str())
                .map(|u| u.to_owned());
            // ponytail: quality badges unknown at search time; surfaced from
            // resource resolutions only when present on the subject payload.
            let quality_badges = s
                .get("resolution")
                .and_then(|r| r.as_u64())
                .map(|r| vec![format!("{}p", r)])
                .unwrap_or_default();
            out.push(SearchResult {
                content: ContentRef {
                    source: "moviebox".into(),
                    content_id: id,
                    kind,
                },
                title: clean_title(&title),
                year,
                poster_url,
                quality_badges,
            });
        }
        Ok(out)
    }

    pub(crate) fn parse_details(subject_id: &str, payload: &serde_json::Value) -> Result<Details> {
        let subject = payload
            .get("data")
            .and_then(|d| d.get("subject"))
            .or_else(|| payload.get("subject"))
            .unwrap_or(payload);
        let title = subject
            .get("title")
            .and_then(|t| t.as_str())
            .unwrap_or("Unknown")
            .to_owned();
        let stype = subject
            .get("subjectType")
            .or_else(|| subject.get("stype"))
            .and_then(|s| s.as_i64())
            .unwrap_or(1);
        let is_series = stype == 2;
        let year = subject
            .get("releaseDate")
            .or_else(|| subject.get("year"))
            .and_then(|y| y.as_str())
            .and_then(extract_year);
        let synopsis = subject
            .get("description")
            .or_else(|| subject.get("intro"))
            .and_then(|d| d.as_str())
            .map(|d| d.to_owned());
        let poster_url = subject
            .get("cover")
            .and_then(|c| c.get("url"))
            .or_else(|| subject.get("coverUrl"))
            .and_then(|u| u.as_str())
            .map(|u| u.to_owned());
        let genres = subject
            .get("genre")
            .or_else(|| subject.get("genres"))
            .and_then(|g| g.as_array())
            .map(|arr| {
                arr.iter()
                    .filter_map(|v| v.as_str().map(|s| s.to_owned()))
                    .collect()
            })
            .unwrap_or_default();
        let cast = subject
            .get("stars")
            .and_then(|s| s.as_str())
            .map(|s| {
                s.split(',')
                    .map(|p| p.trim().to_owned())
                    .filter(|p| !p.is_empty())
                    .collect()
            })
            .unwrap_or_default();

        let mut seasons = Vec::new();
        if let Some(arr) = subject
            .get("seasons")
            .and_then(|s| s.get("seasons").or(Some(s)))
            .and_then(|s| s.as_array())
        {
            for s in arr {
                let se = s.get("se").and_then(|v| v.as_u64()).unwrap_or(1) as u32;
                let mut eps = Vec::new();
                if let Some(nums) = s.get("episodeNumbers").and_then(|e| e.as_array()) {
                    for ep in nums {
                        if let Some(n) = ep.as_u64() {
                            eps.push(Episode {
                                content: ContentRef {
                                    source: "moviebox".into(),
                                    content_id: format!("{}:{}:{}", subject_id, se, n),
                                    kind: ContentKind::Episode,
                                },
                                number: n as u32,
                                title: None,
                            });
                        }
                    }
                } else if let Some(max) = s.get("maxEp").and_then(|m| m.as_u64()) {
                    for n in 1..=max {
                        eps.push(Episode {
                            content: ContentRef {
                                source: "moviebox".into(),
                                content_id: format!("{}:{}:{}", subject_id, se, n),
                                kind: ContentKind::Episode,
                            },
                            number: n as u32,
                            title: None,
                        });
                    }
                }
                eps.sort_by_key(|e| e.number);
                seasons.push(Season {
                    number: se,
                    episodes: eps,
                });
            }
        }
        seasons.sort_by_key(|s| s.number);

        Ok(Details {
            content: ContentRef {
                source: "moviebox".into(),
                content_id: subject_id.into(),
                kind: if is_series {
                    ContentKind::Series
                } else {
                    ContentKind::Movie
                },
            },
            title: clean_title(&title),
            year,
            synopsis,
            poster_url,
            backdrop_url: None,
            genres,
            cast,
            seasons,
        })
    }

    /// Pick the best playable stream from a play-info payload (+ resource
    /// fallback list). Pure — fixture-testable.
    pub(crate) fn parse_play_info(
        payload: &serde_json::Value,
        season: u32,
        episode: u32,
        user_agent: &str,
    ) -> Result<ResolvedStream> {
        let data = payload.get("data").unwrap_or(payload);
        let title_prefix = data
            .get("title")
            .and_then(|t| t.as_str())
            .map(clean_title)
            .unwrap_or_else(|| "MovieBox Stream".to_owned());
        let empty = Vec::new();
        let streams = data
            .get("streams")
            .and_then(|s| s.as_array())
            .unwrap_or(&empty);

        let mut best: Option<StreamCandidate> = None;
        for stream in streams {
            let stream_url = stream.get("url").and_then(|u| u.as_str()).unwrap_or("");
            let sign_cookie = stream
                .get("signCookie")
                .and_then(|c| c.as_str())
                .unwrap_or("");
            let playable = match dash_manifest_from_policy(sign_cookie) {
                Some(m) => m,
                None => {
                    if is_notice_url(stream_url) || !stream_url.starts_with("http") {
                        continue;
                    }
                    stream_url.to_owned()
                }
            };
            let resolutions = stream
                .get("resolutions")
                .or_else(|| data.get("displayResolutions"))
                .and_then(|r| r.as_str())
                .unwrap_or("1080,720,480");
            let max_res: u32 = resolutions
                .split(',')
                .filter_map(|s| s.trim().parse::<u32>().ok())
                .max()
                .unwrap_or(480);
            let is_multi = playable.ends_with(".mpd")
                || resolutions
                    .split(',')
                    .filter(|s| !s.trim().is_empty())
                    .count()
                    > 1;
            let mut headers = vec![
                ("Referer".to_owned(), "https://sportslive.wine".to_owned()),
                ("User-Agent".to_owned(), user_agent.to_owned()),
            ];
            if !sign_cookie.is_empty() {
                let clean = sign_cookie
                    .trim_end_matches(';')
                    .split(';')
                    .map(|s| s.trim())
                    .filter(|s| !s.is_empty())
                    .collect::<Vec<_>>()
                    .join("; ");
                headers.push(("Cookie".to_owned(), clean));
            }
            let size = stream.get("size").and_then(|s| {
                if let Some(n) = s.as_u64() {
                    Some(n)
                } else if let Some(n) = s.as_i64() {
                    Some(n as u64)
                } else {
                    s.as_str().and_then(|v| v.parse::<u64>().ok())
                }
            });
            let codec = stream
                .get("codecName")
                .or_else(|| stream.get("codec"))
                .and_then(|c| c.as_str())
                .unwrap_or("MP4")
                .to_owned();
            let label = if is_multi {
                "multi".to_owned()
            } else {
                format!("{}p", max_res)
            };
            let filename = if season > 0 && episode > 0 {
                format!(
                    "{} S{:02}E{:02} {} {}",
                    title_prefix, season, episode, label, codec
                )
            } else {
                format!("{} {} {}", title_prefix, label, codec)
            };
            let score = if is_multi { u32::MAX } else { max_res };
            if best.as_ref().map(|b| b.0) < Some(score) || best.is_none() {
                best = Some((score, playable, headers, size, filename));
            }
        }

        if let Some((_, url, headers, size, filename)) = best {
            let kind = if url.ends_with(".m3u8") || url.ends_with(".mpd") {
                StreamKind::Hls
            } else {
                StreamKind::Direct
            };
            return Ok(ResolvedStream {
                url,
                headers: headers.into_iter().collect(),
                kind,
                variants: vec![],
                selected_variant: None,
                filename_hint: Some(filename),
                size_bytes: size,
            });
        }

        // Legacy fallback: resource list mirrors.
        let items: &[serde_json::Value] = payload
            .get("list")
            .and_then(|l| l.as_array())
            .map(|a| a.as_slice())
            .unwrap_or(&[]);
        for item in items {
            if let Some(link) = item
                .get("resourceLink")
                .or_else(|| item.get("url"))
                .and_then(|l| l.as_str())
                .filter(|s| s.starts_with("http"))
            {
                let filename = item
                    .get("fileName")
                    .or_else(|| item.get("title"))
                    .and_then(|v| v.as_str())
                    .unwrap_or(&title_prefix)
                    .to_owned();
                return Ok(ResolvedStream {
                    url: link.to_owned(),
                    headers: HashMap::new(),
                    kind: StreamKind::Direct,
                    variants: vec![],
                    selected_variant: None,
                    filename_hint: Some(filename),
                    size_bytes: None,
                });
            }
        }
        Err(TheatreError::Resolve {
            detail: "moviebox: no playable stream".into(),
            source: Some("moviebox".into()),
        })
    }
}

/// (score, playable url, headers, size, filename) for play-info picking.
type StreamCandidate = (
    u32,
    String,
    Vec<(String, String)>,
    Option<u64>,
    String,
);

/// Split composite content ids `"subject:S:E"`; movies are plain `"subject"`.
fn split_content_id(content_id: &str) -> (String, u32, u32) {
    let parts: Vec<&str> = content_id.split(':').collect();
    if parts.len() == 3 {
        if let (Ok(s), Ok(e)) = (parts[1].parse::<u32>(), parts[2].parse::<u32>()) {
            return (parts[0].to_owned(), s, e);
        }
    }
    (content_id.to_owned(), 0, 0)
}

fn str_field(v: &serde_json::Value, keys: &[&str]) -> Option<String> {
    for k in keys {
        if let Some(val) = v.get(*k) {
            if let Some(n) = val.as_i64() {
                return Some(n.to_string());
            }
            if let Some(n) = val.as_u64() {
                return Some(n.to_string());
            }
            if let Some(s) = val.as_str() {
                if !s.is_empty() {
                    return Some(s.to_owned());
                }
            }
        }
    }
    None
}

fn extract_year(s: &str) -> Option<u16> {
    // First 4-digit run (handles "2010-07-16", "2010", "Released 2010").
    let bytes = s.as_bytes();
    for i in 0..bytes.len().saturating_sub(3) {
        if bytes[i].is_ascii_digit()
            && bytes[i + 1].is_ascii_digit()
            && bytes[i + 2].is_ascii_digit()
            && bytes[i + 3].is_ascii_digit()
        {
            if let Ok(y) = s[i..i + 4].parse::<u16>() {
                if (1900..=2100).contains(&y) {
                    return Some(y);
                }
            }
        }
    }
    None
}

fn clean_title(t: &str) -> String {
    // Strip quality/site suffix noise ("Movie 1080p WEB-DL", "[MovieBox]").
    let mut out = t.to_owned();
    for noise in ["[MovieBox]", "(MovieBox)", " - MovieBox"] {
        out = out.replace(noise, "");
    }
    out.split_whitespace().collect::<Vec<_>>().join(" ")
}

fn is_notice_url(url: &str) -> bool {
    let l = url.to_ascii_lowercase();
    l.contains("1c7de0bd3393702d9191801f15f88f8d")
        || l.contains("9a0461bc39da389663bf3dbb17091d3f")
        || l.contains("/notice.mp4")
        || (l.contains("macdn.aoneroom.com") && l.contains("/other/"))
}

fn dash_manifest_from_policy(sign_cookie: &str) -> Option<String> {
    use base64::Engine;
    for part in sign_cookie.split(';') {
        let policy_raw = part.trim().strip_prefix("CloudFront-Policy=")?;
        let mut normalized: String = policy_raw
            .trim()
            .chars()
            .map(|c| match c {
                '-' => '+',
                '_' => '=',
                '~' => '/',
                o => o,
            })
            .collect();
        let pad = (4 - normalized.len() % 4) % 4;
        normalized.push_str(&"=".repeat(pad));
        let decoded = base64::engine::general_purpose::STANDARD
            .decode(normalized.as_bytes())
            .ok()?;
        let json: serde_json::Value = serde_json::from_slice(&decoded).ok()?;
        let resource = json
            .get("Statement")?
            .as_array()?
            .first()?
            .get("Resource")?
            .as_str()?;
        let base = resource.trim_end_matches('*').trim_end_matches('/');
        if base.starts_with("http://") || base.starts_with("https://") {
            return Some(format!("{}/index.mpd", base));
        }
    }
    None
}

// ── request signing (ported from upstream crypto.rs) ─────────
mod crypto {
    use base64::Engine;
    use hmac::{Hmac, Mac};
    use md5::Md5;
    use std::collections::BTreeMap;
    use std::time::{SystemTime, UNIX_EPOCH};

    const SECRET_B64: &str = "76iRl07s0xSN9jqmEWAt79EBJZulIQIsV64FZr2O";
    const BODY_MAX: usize = 102_400;

    type HmacMd5 = Hmac<Md5>;

    fn md5_hex(data: &[u8]) -> String {
        use md5::Digest;
        let mut h = Md5::new();
        h.update(data);
        let d = h.finalize();
        let mut s = String::with_capacity(32);
        for b in d {
            use std::fmt::Write;
            let _ = write!(&mut s, "{:02x}", b);
        }
        s
    }

    fn secret() -> Vec<u8> {
        let mut p = SECRET_B64.to_owned();
        let pad = (4 - p.len() % 4) % 4;
        p.push_str(&"=".repeat(pad));
        base64::engine::general_purpose::STANDARD
            .decode(p)
            .unwrap_or_default()
    }

    fn client_token(ts: u64) -> String {
        let rev: String = ts.to_string().chars().rev().collect();
        format!("{},{}", ts, md5_hex(rev.as_bytes()))
    }

    fn sorted_query(url: &str) -> String {
        let Ok(parsed) = url::Url::parse(url) else {
            return String::new();
        };
        let mut params = BTreeMap::new();
        for (k, v) in parsed.query_pairs() {
            params
                .entry(k.into_owned())
                .or_insert_with(Vec::new)
                .push(v.into_owned());
        }
        params
            .into_iter()
            .flat_map(|(k, vs)| vs.into_iter().map(move |v| format!("{}={}", k, v)))
            .collect::<Vec<_>>()
            .join("&")
    }

    fn canonical(method: &str, url: &str, body: Option<&str>, ts: u64) -> String {
        let curl = if let Ok(p) = url::Url::parse(url) {
            let q = sorted_query(url);
            if q.is_empty() {
                p.path().to_owned()
            } else {
                format!("{}?{}", p.path(), q)
            }
        } else {
            url.to_owned()
        };
        let (hash, len) = match body {
            Some(b) => {
                let bytes = b.as_bytes();
                let cut = if bytes.len() > BODY_MAX {
                    &bytes[..BODY_MAX]
                } else {
                    bytes
                };
                (md5_hex(cut), bytes.len().to_string())
            }
            None => (String::new(), String::new()),
        };
        format!(
            "{}\n{}\n{}\n{}\n{}\n{}\n{}",
            method.to_uppercase(),
            "application/json",
            "application/json",
            len,
            ts,
            hash,
            curl
        )
    }

    pub fn signed_headers(
        method: &str,
        url: &str,
        body: Option<&str>,
        token: Option<&str>,
        user_agent: &str,
        client_info: &str,
        spoofed_ip: &str,
    ) -> std::collections::HashMap<String, String> {
        let ts = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map(|d| d.as_millis() as u64)
            .unwrap_or(0);
        let canon = canonical(method, url, body, ts);
        let sig = match HmacMd5::new_from_slice(&secret()) {
            Ok(mut mac) => {
                mac.update(canon.as_bytes());
                let b64 =
                    base64::engine::general_purpose::STANDARD.encode(mac.finalize().into_bytes());
                format!("{}|2|{}", ts, b64)
            }
            Err(_) => format!("{}|2|", ts),
        };
        let mut h = std::collections::HashMap::new();
        h.insert("User-Agent".into(), user_agent.into());
        h.insert("Accept".into(), "application/json".into());
        h.insert("Content-Type".into(), "application/json".into());
        h.insert("Connection".into(), "keep-alive".into());
        h.insert("x-client-token".into(), client_token(ts));
        h.insert("x-tr-signature".into(), sig);
        h.insert("x-client-info".into(), client_info.into());
        h.insert("x-client-status".into(), "0".into());
        h.insert("x-forwarded-for".into(), spoofed_ip.into());
        if let Some(t) = token {
            h.insert("Authorization".into(), format!("Bearer {}", t));
        }
        h
    }

    pub fn generate_client_info_and_ua() -> (String, String) {
        use rand::Rng;
        let mut rng = rand::rng();
        let android = [
            ("9", "PQ3A.190605.03081104"),
            ("10", "QP1A.191005.007.A3"),
            ("11", "RP1A.200720.011"),
            ("12", "S1B.220414.015"),
            ("13", "TQ2A.230405.003"),
        ];
        let devices = [
            ("23078RKD5C", "Redmi"),
            ("2201117TY", "Redmi"),
            ("M2012K11AG", "Redmi"),
        ];
        let codes = [50020117, 50020118, 50020119, 50020120, 50020121];
        let a = android[rng.random_range(0..android.len())];
        let d = devices[rng.random_range(0..devices.len())];
        let code = codes[rng.random_range(0..codes.len())];
        let ua = format!("com.community.oneroom/{} (Linux; U; Android {}; en_US; {}; Build/{}; Cronet/135.0.7012.3)", code, a.0, d.0, a.1);
        let info = format!(
            r#"{{"package_name":"com.community.oneroom","version_name":"4.0.01.0813.03","version_code":{},"os":"android","os_version":"{}","install_ch":"ps","device_id":"{}","install_store":"ps","gaid":"{}","brand":"{}","model":"{}","system_language":"en","net":"NETWORK_WIFI","region":"US","timezone":"Asia/Kolkata","sp_code":"40401","X-Play-Mode":"2"}}"#,
            code,
            a.0,
            hex32(),
            uuid(),
            d.1,
            d.0
        );
        (ua, info)
    }

    fn hex32() -> String {
        use rand::Rng;
        let mut rng = rand::rng();
        (0..32)
            .map(|_| format!("{:x}", rng.random_range(0..16)))
            .collect()
    }
    fn uuid() -> String {
        format!(
            "{}-{}-{}-{}-{}",
            hex32()[..8].to_owned(),
            hex32()[..4].to_owned(),
            hex32()[..4].to_owned(),
            hex32()[..4].to_owned(),
            hex32()[..12].to_owned()
        )
    }

    pub fn random_spoofed_ip() -> String {
        use rand::Rng;
        let mut rng = rand::rng();
        let prefixes = [
            "103.241", "49.36", "117.195", "106.198", "122.162", "157.32", "182.70",
        ];
        let p = prefixes[rng.random_range(0..prefixes.len())];
        format!(
            "{}.{}.{}",
            p,
            rng.random_range(1..254),
            rng.random_range(1..254)
        )
    }
}

#[async_trait]
impl super::Source for MovieBoxSource {
    fn id(&self) -> &str {
        "moviebox"
    }
    fn name(&self) -> &str {
        "MovieBox"
    }

    async fn search(&self, query: &str, page: u32) -> Result<SearchPage> {
        let payload = self.api_search(query, page.max(1)).await?;
        let results = Self::parse_search_results(&payload)?;
        // Upstream has no total-page signal on this endpoint; has_more when
        // a full page (15) came back.
        let has_more = results.len() >= 15;
        Ok(SearchPage {
            results,
            has_more,
            partial: false,
        })
    }

    async fn get_details(&self, content_id: &str) -> Result<Details> {
        let (subject_id, _, _) = split_content_id(content_id);
        let payload = self.api_details(&subject_id).await?;
        Self::parse_details(&subject_id, &payload)
    }

    async fn resolve(&self, content_id: &str, _variant: Option<&str>) -> Result<ResolvedStream> {
        let (subject_id, season, episode) = split_content_id(content_id);
        let (play, resources) = tokio::join!(
            self.api_play_info(&subject_id, season, episode),
            self.api_resources(&subject_id, season, episode)
        );
        // Merge resource list into the play-info payload for the fallback.
        let mut merged = play.unwrap_or(serde_json::json!({}));
        if let Ok(serde_json::Value::Object(map)) = resources {
            if let Some(m) = merged.as_object_mut() {
                for (k, v) in map {
                    m.insert(k, v);
                }
            }
        }
        Self::parse_play_info(&merged, season, episode, &self.user_agent)
    }

    async fn health_check(&self) -> SourceStatus {
        let path = "/wefeed-mobile-bff/tab-operating?page=1&tabId=0&version=";
        let start = self.active_base_idx.load(Ordering::Relaxed);
        for i in 0..HOST_POOL.len() {
            let url = format!("{}{}", HOST_POOL[(start + i) % HOST_POOL.len()], path);
            let headers = crypto::signed_headers(
                "GET",
                &url,
                None,
                self.session.read().unwrap().clone().as_deref(),
                &self.user_agent,
                &self.client_info,
                &self.spoofed_ip,
            );
            match self.net.get(&url, &headers).await {
                Ok(r) if r.status().is_success() => return SourceStatus::Healthy,
                Ok(r) => {
                    if i == HOST_POOL.len() - 1 {
                        return SourceStatus::Degraded {
                            since: state::now() as u64,
                            last_error: format!("HTTP {}", r.status().as_u16()),
                        };
                    }
                }
                Err(e) => {
                    if i == HOST_POOL.len() - 1 {
                        return SourceStatus::Degraded {
                            since: state::now() as u64,
                            last_error: e.to_string(),
                        };
                    }
                }
            }
        }
        SourceStatus::Degraded {
            since: state::now() as u64,
            last_error: "all hosts exhausted".into(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // Test-only helpers (no production effect).
    impl Details {
        fn episodes_empty(&self) -> bool {
            self.seasons.iter().all(|s| s.episodes.is_empty())
        }
    }

    impl Episode {
        fn content_id_parts(&self) -> (String, u32, u32) {
            split_content_id(&self.content.content_id)
        }
    }

    fn load_fixture(name: &str) -> serde_json::Value {
        let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests")
            .join("fixtures")
            .join(name);
        let text =
            std::fs::read_to_string(&path).unwrap_or_else(|_| panic!("fixture {} not found", name));
        serde_json::from_str(&text).expect("fixture must be valid JSON")
    }

    fn test_net() -> NetClient {
        NetClient::new()
    }

    #[test]
    fn parse_search_results_from_fixture() {
        let payload = load_fixture("moviebox_search_inception.json");
        let results = MovieBoxSource::parse_search_results(&payload).unwrap();
        assert!(!results.is_empty(), "search must yield results");
        assert!(results
            .iter()
            .any(|r| r.title.to_lowercase().contains("inception")));
        let first = &results[0];
        assert_eq!(first.content.source, "moviebox");
        assert_eq!(first.year, Some(2010));
        assert!(first.poster_url.is_some());
    }

    #[test]
    fn parse_movie_details_from_fixture() {
        let payload = load_fixture("moviebox_detail_movie.json");
        let details = MovieBoxSource::parse_details("999", &payload).unwrap();
        assert!(!details.title.is_empty());
        assert_eq!(details.year, Some(2014));
        assert!(details.synopsis.is_some());
        assert!(details.episodes_empty());
        assert!(details.genres.contains(&"Sci-Fi".to_owned()));
        assert!(details
            .cast
            .iter()
            .any(|c| c.contains("Nolan") || c.contains("McConaughey")));
    }

    #[test]
    fn parse_series_episodes_from_fixture() {
        let payload = load_fixture("moviebox_detail_series.json");
        let details = MovieBoxSource::parse_details("500", &payload).unwrap();
        let eps: Vec<_> = details.seasons.iter().flat_map(|s| &s.episodes).collect();
        assert!(!eps.is_empty(), "series must have episodes");
        assert_eq!(eps[0].content_id_parts(), ("500".to_owned(), 1, 1));
        assert!(matches!(eps[0].content.kind, ContentKind::Episode));
    }

    #[test]
    fn parse_play_info_from_fixture() {
        let payload = load_fixture("moviebox_playinfo_movie.json");
        let stream = MovieBoxSource::parse_play_info(&payload, 0, 0, "TestAgent/1.0").unwrap();
        assert!(stream.url.starts_with("https://"));
        assert!(!stream.url.contains("notice.mp4"));
        assert!(stream.filename_hint.is_some());
    }

    #[test]
    fn content_id_split() {
        assert_eq!(split_content_id("12345"), ("12345".to_owned(), 0, 0));
        assert_eq!(split_content_id("12345:1:3"), ("12345".to_owned(), 1, 3));
        assert_eq!(split_content_id("abc"), ("abc".to_owned(), 0, 0));
    }

    #[test]
    fn signing_headers_present() {
        let src = MovieBoxSource::new(test_net());
        let url =
            "https://api6.aoneroom.com/wefeed-mobile-bff/tab-operating?page=1&tabId=0&version=";
        let h = crypto::signed_headers(
            "GET",
            url,
            None,
            None,
            &src.user_agent,
            &src.client_info,
            &src.spoofed_ip,
        );
        for k in [
            "x-client-token",
            "x-tr-signature",
            "x-client-info",
            "User-Agent",
        ] {
            assert!(h.contains_key(k), "missing {}", k);
        }
        assert!(h["x-tr-signature"].contains("|2|"));
    }
}
