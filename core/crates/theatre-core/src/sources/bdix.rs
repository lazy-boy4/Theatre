//! BDIX source — opt-in (PRD D8, geo/ISP-locked), merging the two upstream
//! BDIX backends behind the single `"bdix"` id (registry default-off kept):
//! CircleFTP first (internet JSON API), DhakaFlix fallback (ISP-LAN
//! file-browser POST API on 172.16.50.x — unreachable outside BDIX coverage,
//! in which case it yields nothing and CircleFTP results win).
//! Ported from upstream `src/providers/bdix/{circleftp,dhakaflix}`.
//! data-contract.md §3.1/§3.2/§3.3/§4.1.

use super::util::{detect_quality, extract_year, quality_rank, sanitize_filename};
use crate::{
    api::types::*,
    error::{Result, TheatreError},
    net::NetClient,
};
use async_trait::async_trait;
use std::collections::HashMap;

const CIRCLE_BASE: &str = "http://new.circleftp.net:5000/api";
const DFLIX_SERVERS: &[(&str, &str)] = &[
    ("http://172.16.50.7", "/DHAKA-FLIX-7/"),
    ("http://172.16.50.14", "/DHAKA-FLIX-14/"),
    ("http://172.16.50.12", "/DHAKA-FLIX-12/"),
    ("http://172.16.50.9", "/DHAKA-FLIX-9/"),
];
const UA: &str = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

/// Content-id namespaces: `circle:<post-id>` | `dflix:<base>::<path>`.
const NS_CIRCLE: &str = "circle:";
const NS_DFLIX: &str = "dflix:";

pub struct BdixSource {
    net: NetClient,
}

impl BdixSource {
    pub fn new(net: NetClient) -> Self {
        Self { net }
    }

    fn err(&self, detail: impl Into<String>) -> TheatreError {
        TheatreError::Source {
            source: "bdix".into(),
            detail: detail.into(),
        }
    }

    fn headers() -> HashMap<String, String> {
        [("User-Agent".to_owned(), UA.to_owned())].into()
    }

    // ── CircleFTP ────────────────────────────────────────────
    async fn circle_search(&self, query: &str) -> Result<Vec<SearchResult>> {
        let url = format!(
            "{}/posts?searchTerm={}&order=desc",
            CIRCLE_BASE,
            url_encode(query)
        );
        let resp = self.net.get(&url, &Self::headers()).await?;
        if !resp.status().is_success() {
            return Err(self.err(format!("circleftp HTTP {}", resp.status().as_u16())));
        }
        let body: serde_json::Value = resp.json().await.map_err(|e| TheatreError::Network {
            detail: e.to_string(),
        })?;
        Self::parse_circle_search(&body)
    }

    async fn circle_details(&self, post_id: &str) -> Result<Details> {
        let url = format!("{}/posts/{}", CIRCLE_BASE, post_id);
        let resp = self.net.get(&url, &Self::headers()).await?;
        if resp.status().as_u16() == 404 {
            return Err(self.err("not found"));
        }
        if !resp.status().is_success() {
            return Err(self.err(format!("circleftp HTTP {}", resp.status().as_u16())));
        }
        let body: serde_json::Value = resp.json().await.map_err(|e| TheatreError::Network {
            detail: e.to_string(),
        })?;
        Self::parse_circle_details(post_id, &body)
    }

    async fn circle_resolve(&self, post_id: &str) -> Result<ResolvedStream> {
        let url = format!("{}/posts/{}", CIRCLE_BASE, post_id);
        let resp = self.net.get(&url, &Self::headers()).await?;
        if !resp.status().is_success() {
            return Err(self.err(format!("circleftp HTTP {}", resp.status().as_u16())));
        }
        let body: serde_json::Value = resp.json().await.map_err(|e| TheatreError::Network {
            detail: e.to_string(),
        })?;
        // Series: content is [{episodes:[{link}]}], movies: content is a link string.
        let rtype = body.get("type").and_then(|v| v.as_str()).unwrap_or("");
        if rtype == "series" {
            return Err(TheatreError::Resolve {
                detail: "bdix: pick an episode to resolve".into(),
                source: Some("bdix".into()),
            });
        }
        if let Some(link) = body.get("content").and_then(|v| v.as_str()) {
            if link.starts_with("http") {
                let title = body
                    .get("title")
                    .and_then(|v| v.as_str())
                    .unwrap_or("BDIX video");
                return Ok(direct_stream(link, title, None));
            }
        }
        Err(TheatreError::Resolve {
            detail: "bdix: no direct link on post".into(),
            source: Some("bdix".into()),
        })
    }

    // ── DhakaFlix (ISP-LAN POST API) ─────────────────────────
    async fn dflix_search(&self, query: &str) -> Vec<SearchResult> {
        let mut out = Vec::new();
        for (base, href) in DFLIX_SERVERS {
            let url = format!("{}{}", base, href);
            let body = serde_json::json!({
                "action": "get",
                "search": {"href": href, "pattern": query, "ignorecase": true},
            });
            let Ok(resp) = self.net.post_json(&url, &Self::headers(), &body).await else {
                continue; // LAN host unreachable outside BDIX coverage — skip.
            };
            let Ok(json): std::result::Result<serde_json::Value, _> = resp.json().await else {
                continue;
            };
            let items = json.get("search").and_then(|v| v.as_array());
            for item in items.into_iter().flatten() {
                let Some(item_href) = item.get("href").and_then(|v| v.as_str()) else {
                    continue;
                };
                let is_dir = item_href.ends_with('/');
                let mut parts: Vec<&str> = item_href.split('/').filter(|p| !p.is_empty()).collect();
                if !is_dir && parts.len() > 1 {
                    parts.pop();
                }
                let Some(name) = parts.last() else { continue };
                let decoded = percent_decode(name);
                let (title, year) = split_title_year(&decoded);
                let folder = format!("/{}/", parts.join("/"));
                out.push(SearchResult {
                    content: ContentRef {
                        source: "bdix".into(),
                        content_id: format!(
                            "{}{}::{}",
                            NS_DFLIX,
                            base,
                            folder.trim_start_matches('/')
                        ),
                        kind: ContentKind::Movie,
                    },
                    title,
                    year,
                    poster_url: None,
                    quality_badges: detect_quality(&decoded)
                        .map(|q| vec![q])
                        .unwrap_or_default(),
                });
            }
        }
        // Dedup best-quality per (title, year).
        let mut best: HashMap<(String, Option<u16>), SearchResult> = HashMap::new();
        for r in out {
            let key = (r.title.to_lowercase(), r.year);
            match best.get(&key) {
                Some(e) if badge_rank(&e.quality_badges) >= badge_rank(&r.quality_badges) => {}
                _ => {
                    best.insert(key, r);
                }
            }
        }
        let mut v: Vec<_> = best.into_values().collect();
        v.sort_by_key(|a| a.title.to_lowercase());
        v
    }

    async fn dflix_resolve(&self, base: &str, path: &str) -> Result<ResolvedStream> {
        let api_href = DFLIX_SERVERS
            .iter()
            .find(|(b, _)| *b == base)
            .map(|(_, h)| *h)
            .unwrap_or("/");
        let url = format!("{}{}", base, api_href);
        let body = serde_json::json!({"action": "get", "items": {"href": path, "what": 1}});
        let resp = self.net.post_json(&url, &Self::headers(), &body).await?;
        if !resp.status().is_success() {
            return Err(self.err("dhakaflix items failed"));
        }
        let json: serde_json::Value = resp.json().await.map_err(|e| TheatreError::Network {
            detail: e.to_string(),
        })?;
        let mut best: Option<(String, u64)> = None;
        for item in json
            .get("items")
            .and_then(|v| v.as_array())
            .into_iter()
            .flatten()
        {
            let (Some(href), Some(size)) = (
                item.get("href").and_then(|v| v.as_str()),
                item.get("size").and_then(|v| v.as_u64()),
            ) else {
                continue;
            };
            let l = href.to_ascii_lowercase();
            if !(l.ends_with(".mkv")
                || l.ends_with(".mp4")
                || l.ends_with(".avi")
                || l.ends_with(".webm"))
            {
                continue;
            }
            let name = percent_decode(href.split('/').next_back().unwrap_or("video"));
            let score = quality_rank(&name) as u64;
            if best.as_ref().map(|b| b.1) < Some(score) || best.is_none() {
                best = Some((format!("{}{}", base, href), score));
            }
            let _ = size;
        }
        match best {
            Some((link, _)) => {
                let title = percent_decode(
                    path.split('/')
                        .rfind(|p| !p.is_empty())
                        .unwrap_or("BDIX video"),
                );
                Ok(direct_stream(&link, &title, None))
            }
            None => Err(TheatreError::Resolve {
                detail: "bdix: no media file in folder".into(),
                source: Some("bdix".into()),
            }),
        }
    }

    // ── pure parsers (fixture-testable) ──────────────────────
    pub(crate) fn parse_circle_search(body: &serde_json::Value) -> Result<Vec<SearchResult>> {
        let arr: &[serde_json::Value] = body
            .as_array()
            .map(|a| a.as_slice())
            .or_else(|| {
                body.get("data")
                    .and_then(|d| d.as_array())
                    .map(|a| a.as_slice())
            })
            .or_else(|| {
                body.get("posts")
                    .and_then(|d| d.as_array())
                    .map(|a| a.as_slice())
            })
            .unwrap_or(&[]);
        let mut out = Vec::new();
        for p in arr {
            let Some(id) = p.get("id").and_then(|v| {
                v.as_i64()
                    .map(|n| n.to_string())
                    .or_else(|| v.as_str().map(|s| s.to_owned()))
            }) else {
                continue;
            };
            let title = p
                .get("title")
                .or_else(|| p.get("name"))
                .and_then(|v| v.as_str())
                .unwrap_or("Unknown")
                .to_owned();
            let rtype = p.get("type").and_then(|v| v.as_str()).unwrap_or("");
            let year = p.get("year").and_then(|v| {
                if let Some(n) = v.as_u64() {
                    Some(n as u16)
                } else {
                    v.as_str().and_then(extract_year)
                }
            });
            let poster_url = p
                .get("image")
                .or_else(|| p.get("imageSm"))
                .and_then(|v| v.as_str())
                .map(|s| {
                    if s.starts_with("http") {
                        s.to_owned()
                    } else {
                        format!("http://new.circleftp.net:5000/uploads/{}", s)
                    }
                });
            let (clean, y2) = split_title_year(&title);
            out.push(SearchResult {
                content: ContentRef {
                    source: "bdix".into(),
                    content_id: format!("{}{}", NS_CIRCLE, id),
                    kind: if rtype == "series" {
                        ContentKind::Series
                    } else {
                        ContentKind::Movie
                    },
                },
                title: clean,
                year: year.or(y2),
                poster_url,
                quality_badges: p
                    .get("quality")
                    .and_then(|v| v.as_str())
                    .map(|q| vec![q.to_owned()])
                    .unwrap_or_default(),
            });
        }
        Ok(out)
    }

    pub(crate) fn parse_circle_details(post_id: &str, body: &serde_json::Value) -> Result<Details> {
        let title_raw = body
            .get("title")
            .or_else(|| body.get("name"))
            .and_then(|v| v.as_str())
            .unwrap_or("Unknown");
        let (title, year_from_title) = split_title_year(title_raw);
        let rtype = body.get("type").and_then(|v| v.as_str()).unwrap_or("");
        let is_series = rtype == "series";
        let year = body
            .get("year")
            .and_then(|v| {
                if let Some(n) = v.as_u64() {
                    Some(n as u16)
                } else {
                    v.as_str().and_then(extract_year)
                }
            })
            .or(year_from_title);
        let poster_url = body
            .get("image")
            .or_else(|| body.get("imageSm"))
            .and_then(|v| v.as_str())
            .map(|s| {
                if s.starts_with("http") {
                    s.to_owned()
                } else {
                    format!("http://new.circleftp.net:5000/uploads/{}", s)
                }
            });
        let synopsis = body
            .get("metaData")
            .and_then(|v| v.as_str())
            .map(|s| s.to_owned());
        let genres = body
            .get("categories")
            .and_then(|v| v.as_array())
            .map(|arr| {
                arr.iter()
                    .filter_map(|c| c.get("name").and_then(|n| n.as_str()).map(|s| s.to_owned()))
                    .collect()
            })
            .unwrap_or_default();

        let mut seasons = Vec::new();
        if is_series {
            if let Some(content) = body.get("content").and_then(|v| v.as_array()) {
                for (si, sval) in content.iter().enumerate() {
                    let se = si as u32 + 1;
                    let mut eps = Vec::new();
                    if let Some(arr) = sval.get("episodes").and_then(|v| v.as_array()) {
                        for (ei, eval) in arr.iter().enumerate() {
                            let n = ei as u32 + 1;
                            eps.push(Episode {
                                content: ContentRef {
                                    source: "bdix".into(),
                                    content_id: format!("{}{}:{}:{}", NS_CIRCLE, post_id, se, n),
                                    kind: ContentKind::Episode,
                                },
                                number: n,
                                title: eval
                                    .get("title")
                                    .and_then(|v| v.as_str())
                                    .map(|s| s.to_owned()),
                            });
                        }
                    }
                    seasons.push(Season {
                        number: se,
                        episodes: eps,
                    });
                }
            }
        }
        Ok(Details {
            content: ContentRef {
                source: "bdix".into(),
                content_id: format!("{}{}", NS_CIRCLE, post_id),
                kind: if is_series {
                    ContentKind::Series
                } else {
                    ContentKind::Movie
                },
            },
            title,
            year,
            synopsis,
            poster_url,
            backdrop_url: None,
            genres,
            cast: Vec::new(),
            seasons,
        })
    }
}

fn direct_stream(url: &str, title: &str, size: Option<u64>) -> ResolvedStream {
    ResolvedStream {
        url: url.to_owned(),
        headers: HashMap::new(),
        kind: StreamKind::Direct,
        variants: vec![],
        selected_variant: None,
        filename_hint: Some(sanitize_filename(title)),
        size_bytes: size,
    }
}

/// Split "Title (2010)" / "Title 1080p" noise → (clean title, year?).
fn split_title_year(raw: &str) -> (String, Option<u16>) {
    let mut title = raw.to_owned();
    let mut year = None;
    if let Some(start) = title.rfind('(') {
        if title.ends_with(')') && start + 5 == title.len() - 1 {
            if let Ok(y) = title[start + 1..title.len() - 1].parse::<u16>() {
                if (1900..=2100).contains(&y) {
                    year = Some(y);
                    title = title[..start].trim().to_owned();
                }
            }
        }
    }
    let l = title.to_ascii_lowercase();
    for q in [" 1080p", " 720p", " 480p", " 2160p", " 4k", " hd"] {
        if l.ends_with(q) {
            title = title[..title.len() - q.len()].trim().to_owned();
            break;
        }
    }
    (title, year.or_else(|| extract_year(raw)))
}

fn badge_rank(badges: &[String]) -> u32 {
    badges.first().map(|q| quality_rank(q)).unwrap_or(0)
}

fn percent_decode(s: &str) -> String {
    percent_encoding::percent_decode_str(s)
        .decode_utf8_lossy()
        .into_owned()
}

fn url_encode(query: &str) -> String {
    url::form_urlencoded::byte_serialize(query.as_bytes()).collect()
}

fn split_id(content_id: &str) -> (u8, String) {
    // Returns (backend, rest): 0=circle (+post id or post:S:E), 1=dflix.
    if let Some(rest) = content_id.strip_prefix(NS_CIRCLE) {
        (0, rest.to_owned())
    } else if let Some(rest) = content_id.strip_prefix(NS_DFLIX) {
        (1, rest.to_owned())
    } else {
        // Back-compat: bare ids are CircleFTP posts.
        (0, content_id.to_owned())
    }
}

#[async_trait]
impl super::Source for BdixSource {
    fn id(&self) -> &str {
        "bdix"
    }
    fn name(&self) -> &str {
        "BDIX"
    }

    async fn search(&self, query: &str, _page: u32) -> Result<SearchPage> {
        // CircleFTP first; DhakaFlix (LAN) appends when reachable.
        let mut results = match self.circle_search(query).await {
            Ok(r) => r,
            Err(e) => {
                // Outside BDIX coverage CircleFTP fails — fall through to LAN.
                let lan = self.dflix_search(query).await;
                if lan.is_empty() {
                    return Err(e);
                }
                lan
            }
        };
        // Best-effort LAN merge (cheap: skipped fast when unreachable).
        let lan = self.dflix_search(query).await;
        results.extend(lan);
        Ok(SearchPage {
            results,
            has_more: false,
            partial: false,
        })
    }

    async fn get_details(&self, content_id: &str) -> Result<Details> {
        match split_id(content_id) {
            (1, rest) => {
                // dflix:<base>::<path> → lightweight details from path name.
                let (base, path) = rest.split_once("::").unwrap_or(("", &rest));
                let name = path
                    .split('/')
                    .rfind(|p| !p.is_empty())
                    .unwrap_or("BDIX video");
                let (title, year) = split_title_year(&percent_decode(name));
                Ok(Details {
                    content: ContentRef {
                        source: "bdix".into(),
                        content_id: content_id.into(),
                        kind: ContentKind::Movie,
                    },
                    title,
                    year,
                    synopsis: Some(format!("DhakaFlix folder on {}", base)),
                    poster_url: None,
                    backdrop_url: None,
                    genres: Vec::new(),
                    cast: Vec::new(),
                    seasons: Vec::new(),
                })
            }
            _ => {
                // circle:<post>[:S:E] — episode links live inside the post.
                let rest = split_id(content_id).1;
                let post_id = rest.split(':').next().unwrap_or(&rest);
                let mut d = self.circle_details(post_id).await?;
                d.content.content_id = content_id.into();
                Ok(d)
            }
        }
    }

    async fn resolve(&self, content_id: &str, _variant: Option<&str>) -> Result<ResolvedStream> {
        match split_id(content_id) {
            (1, rest) => {
                let (base, path) = rest
                    .split_once("::")
                    .ok_or_else(|| self.err("bad dflix id"))?;
                self.dflix_resolve(base, path).await
            }
            _ => {
                let rest = split_id(content_id).1;
                let mut parts = rest.split(':');
                let post_id = parts.next().unwrap_or("");
                let (s, e) = match (parts.next(), parts.next()) {
                    (Some(s), Some(e)) => (
                        s.parse::<usize>().unwrap_or(0),
                        e.parse::<usize>().unwrap_or(0),
                    ),
                    _ => (0, 0),
                };
                if s > 0 && e > 0 {
                    // Episode link inside series post content.
                    let url = format!("{}/posts/{}", CIRCLE_BASE, post_id);
                    let resp = self.net.get(&url, &Self::headers()).await?;
                    let body: serde_json::Value =
                        resp.json().await.map_err(|e| TheatreError::Network {
                            detail: e.to_string(),
                        })?;
                    if let Some(content) = body.get("content").and_then(|v| v.as_array()) {
                        if let Some(sval) = content.get(s.saturating_sub(1)) {
                            if let Some(arr) = sval.get("episodes").and_then(|v| v.as_array()) {
                                if let Some(eval) = arr.get(e.saturating_sub(1)) {
                                    if let Some(link) = eval.get("link").and_then(|v| v.as_str()) {
                                        let t = eval
                                            .get("title")
                                            .and_then(|v| v.as_str())
                                            .unwrap_or("BDIX episode");
                                        return Ok(direct_stream(link, t, None));
                                    }
                                }
                            }
                        }
                    }
                    return Err(TheatreError::Resolve {
                        detail: "bdix: episode link missing".into(),
                        source: Some("bdix".into()),
                    });
                }
                self.circle_resolve(post_id).await
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn load_fixture(name: &str) -> serde_json::Value {
        let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests/fixtures")
            .join(name);
        serde_json::from_str(
            &std::fs::read_to_string(&path)
                .unwrap_or_else(|_| panic!("fixture {} not found", name)),
        )
        .unwrap()
    }

    #[test]
    fn parse_search_results_from_fixture() {
        let body = load_fixture("bdix_search.json");
        let results = BdixSource::parse_circle_search(&body).unwrap();
        assert!(!results.is_empty());
        assert!(results
            .iter()
            .any(|r| r.title.to_lowercase().contains("inception")));
        assert!(results[0].content.content_id.starts_with(NS_CIRCLE));
    }

    #[test]
    fn parse_movie_details_from_fixture() {
        let body = load_fixture("bdix_detail_movie.json");
        let d = BdixSource::parse_circle_details("42", &body).unwrap();
        assert!(!d.title.is_empty());
        assert!(d.seasons.iter().all(|s| s.episodes.is_empty()));
    }

    #[test]
    fn parse_series_details_from_fixture() {
        let body = load_fixture("bdix_detail_series.json");
        let d = BdixSource::parse_circle_details("77", &body).unwrap();
        assert!(!d.seasons.is_empty());
        assert!(!d.seasons[0].episodes.is_empty());
    }

    #[test]
    fn id_namespaces_split() {
        assert_eq!(split_id("circle:42"), (0, "42".to_owned()));
        assert_eq!(split_id("circle:77:1:2"), (0, "77:1:2".to_owned()));
        assert_eq!(
            split_id("dflix:http://x::/a/b"),
            (1, "http://x::/a/b".to_owned())
        );
        assert_eq!(split_id("42"), (0, "42".to_owned()));
    }

    #[test]
    fn title_year_split() {
        assert_eq!(
            split_title_year("Inception (2010)"),
            ("Inception".to_owned(), Some(2010))
        );
        assert_eq!(split_title_year("Show 1080p"), ("Show".to_owned(), None));
    }
}
