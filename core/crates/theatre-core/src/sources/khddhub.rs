//! 4KHDHub source — HTML scraper ported from the MovieBox-TUI fork
//! (`src/providers/fourkhdhub/`). Search/details/release parsing mirrors
//! upstream `parser.rs`; mirror resolution is simplified (direct https
//! mirrors used as-is; hubcloud/hubdrive pages resolved by extracting the
//! first media link — upstream's full drive-page dance is out of scope).
//! data-contract.md §3.1/§3.2/§4.1.

use crate::{
    api::types::*,
    error::{Result, TheatreError},
    net::NetClient,
    state,
};
use async_trait::async_trait;
use scraper::{Html, Selector};
use std::collections::HashMap;

const DEFAULT_BASE: &str = "https://4khdhub.one/";
const BROWSER_UA: &str = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

pub struct KhddhubSource {
    net: NetClient,
    base: String,
}

impl KhddhubSource {
    pub fn new(net: NetClient) -> Self {
        let base = std::env::var("MOVIEBOX_FOURKHDHUB_URL").unwrap_or_else(|_| DEFAULT_BASE.into());
        Self { net, base }
    }

    fn err(&self, detail: impl Into<String>) -> TheatreError {
        TheatreError::Source {
            source: "4khdhub".into(),
            detail: detail.into(),
        }
    }

    fn base_url(&self) -> Result<url::Url> {
        let u = url::Url::parse(&self.base).map_err(|e| self.err(e.to_string()))?;
        if u.scheme() != "https" {
            return Err(self.err("4khdhub base must be https"));
        }
        Ok(u)
    }

    fn headers(&self) -> HashMap<String, String> {
        [("User-Agent".to_owned(), BROWSER_UA.to_owned())].into()
    }

    async fn fetch(&self, url: &str) -> Result<String> {
        let resp = self.net.get(url, &self.headers()).await?;
        if !resp.status().is_success() {
            return Err(self.err(format!("HTTP {}", resp.status().as_u16())));
        }
        resp.text().await.map_err(|e| TheatreError::Network {
            detail: e.to_string(),
        })
    }

    fn search_url(&self, query: &str) -> Result<String> {
        let mut u = self.base_url()?;
        u.query_pairs_mut().append_pair("s", query);
        Ok(u.to_string())
    }

    fn detail_url(&self, id: &str) -> Result<String> {
        let u = self
            .base_url()?
            .join(id.trim_start_matches('/'))
            .map_err(|e| self.err(e.to_string()))?;
        if u.host_str() != self.base_url()?.host_str() {
            return Err(self.err("cross-host link rejected"));
        }
        Ok(u.to_string())
    }

    // ── pure parsers (fixture-testable) ──────────────────────
    pub(crate) fn parse_search_results(base: &str, html: &str) -> Result<Vec<SearchResult>> {
        let base_url = url::Url::parse(base).map_err(|e| TheatreError::Source {
            source: "4khdhub".into(),
            detail: e.to_string(),
        })?;
        let doc = Html::parse_document(html);
        let card = Selector::parse("a.movie-card").unwrap();
        let title_sel = Selector::parse(".movie-card-title").unwrap();
        let meta_sel = Selector::parse(".movie-card-meta").unwrap();
        let img_sel = Selector::parse("img").unwrap();
        let mut out = Vec::new();
        for node in doc.select(&card) {
            let Some(href) = node.value().attr("href") else {
                continue;
            };
            let Ok(url) = base_url.join(href) else {
                continue;
            };
            if url.host_str() != base_url.host_str() {
                continue;
            }
            let title = node
                .select(&title_sel)
                .next()
                .map(|n| text_of(n))
                .unwrap_or_default();
            if title.is_empty() {
                continue;
            }
            let meta = node
                .select(&meta_sel)
                .next()
                .map(|n| text_of(n))
                .unwrap_or_default();
            out.push(SearchResult {
                content: ContentRef {
                    source: "4khdhub".into(),
                    content_id: url.path().to_owned(),
                    kind: if href.contains("-series-") {
                        ContentKind::Series
                    } else {
                        ContentKind::Movie
                    },
                },
                title,
                year: first_year(&meta),
                poster_url: node
                    .select(&img_sel)
                    .next()
                    .and_then(|img| img.value().attr("src"))
                    .map(|s| s.to_owned()),
                quality_badges: detect_quality(&node.inner_html())
                    .map(|q| vec![q])
                    .unwrap_or_default(),
            });
        }
        Ok(out)
    }

    pub(crate) fn parse_details(content_id: &str, html: &str) -> Result<Details> {
        let doc = Html::parse_document(html);
        let h1 = Selector::parse("h1").unwrap();
        let raw = doc
            .select(&h1)
            .next()
            .map(|n| text_of(n))
            .filter(|t| !t.is_empty())
            .ok_or_else(|| TheatreError::Source {
                source: "4khdhub".into(),
                detail: "title missing".into(),
            })?;
        let title = strip_trailing_year(&raw);
        let is_series = content_id.contains("-series-");
        let desc_sel = Selector::parse(".content-section p.mt-4").unwrap();
        let synopsis = doc.select(&desc_sel).next().map(|n| text_of(n));
        let poster_url = Selector::parse("meta[property=\"og:image\"]")
            .ok()
            .and_then(|sel| doc.select(&sel).next())
            .and_then(|n| n.value().attr("content"))
            .map(|s| s.to_owned());
        let genres = Selector::parse(".badge-outline a")
            .ok()
            .map(|sel| {
                doc.select(&sel)
                    .map(|n| text_of(n))
                    .filter(|g| is_genre(g))
                    .collect()
            })
            .unwrap_or_default();
        let year = find_metadata(&doc, "Release:")
            .as_deref()
            .and_then(first_year)
            .or_else(|| first_year(&raw));
        let cast = find_metadata(&doc, "Stars:")
            .map(|s| split_list(&s))
            .unwrap_or_default();

        // Seasons from episode items (SxxEyy in file titles).
        let mut seasons_map: std::collections::BTreeMap<u32, Vec<Episode>> =
            std::collections::BTreeMap::new();
        if let Ok(item_sel) = Selector::parse("#episodes .episode-download-item") {
            if let Ok(t_sel) = Selector::parse(".episode-file-title") {
                for node in doc.select(&item_sel) {
                    let name = node
                        .select(&t_sel)
                        .next()
                        .map(|n| text_of(n))
                        .unwrap_or_default();
                    if let Some((s, e)) = parse_season_episode(&name) {
                        seasons_map.entry(s).or_default().push(Episode {
                            content: ContentRef {
                                source: "4khdhub".into(),
                                content_id: format!("{}#{}:{}", content_id, s, e),
                                kind: ContentKind::Episode,
                            },
                            number: e,
                            title: Some(name),
                        });
                    }
                }
            }
        }
        let mut seasons: Vec<Season> = seasons_map
            .into_iter()
            .map(|(number, mut episodes)| {
                episodes.sort_by_key(|e| e.number);
                Season { number, episodes }
            })
            .collect();
        seasons.sort_by_key(|s| s.number);

        Ok(Details {
            content: ContentRef {
                source: "4khdhub".into(),
                content_id: content_id.into(),
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
            cast,
            seasons,
        })
    }

    /// Parse download/release items into candidate streams (best first).
    pub(crate) fn parse_releases(html: &str, season: u32, episode: u32) -> Vec<ReleaseInfo> {
        let doc = Html::parse_document(html);
        let (item_q, title_q) = if season > 0 {
            ("#episodes .episode-download-item", ".episode-file-title")
        } else {
            (".download-item", ".file-title")
        };
        let (Ok(item_sel), Ok(title_sel), Ok(link_sel), Ok(size_sel)) = (
            Selector::parse(item_q),
            Selector::parse(title_q),
            Selector::parse("a[href]"),
            Selector::parse(".badge-size, .badge"),
        ) else {
            return Vec::new();
        };
        let mut out: Vec<ReleaseInfo> = Vec::new();
        let mut seen = std::collections::HashSet::new();
        for item in doc.select(&item_sel) {
            let filename = item
                .select(&title_sel)
                .next()
                .map(|n| text_of(n))
                .unwrap_or_default();
            if filename.is_empty() || is_archive(&filename) {
                continue;
            }
            if season > 0 && parse_season_episode(&filename) != Some((season, episode)) {
                continue;
            }
            let mut mirrors = Vec::new();
            for link in item.select(&link_sel) {
                if let Some(href) = link.value().attr("href") {
                    if !href.starts_with("https://") || href.contains("logout") {
                        continue;
                    }
                    mirrors.push((text_of(link).or("Source"), href.to_owned()));
                }
            }
            if mirrors.is_empty() {
                continue;
            }
            let key: String = filename
                .to_ascii_lowercase()
                .chars()
                .filter(|c| c.is_ascii_alphanumeric())
                .collect();
            if !seen.insert(key) {
                continue;
            }
            let size = item
                .select(&size_sel)
                .map(|n| text_of(n))
                .find_map(|t| parse_size(&t));
            out.push(ReleaseInfo {
                filename,
                mirrors,
                size_bytes: size,
            });
        }
        out.sort_by_key(|r| std::cmp::Reverse(quality_rank(&r.filename)));
        out
    }

    /// Resolve a mirror to a playable URL (range-probe preflight).
    async fn resolve_mirror(&self, mirror_url: &str) -> Result<String> {
        validate_playback_url(mirror_url)?;
        // hubcloud/hubdrive drive-pages: extract first media link.
        let page_url = if mirror_url.contains("hubcloud.") || mirror_url.contains("hubdrive.") {
            let html = self.fetch(mirror_url).await?;
            let doc = Html::parse_document(&html);
            let sel = Selector::parse("a[href]").unwrap();
            doc.select(&sel)
                .filter_map(|n| n.value().attr("href"))
                .find(|h| {
                    h.starts_with("https://")
                        && (h.contains(".mp4")
                            || h.contains(".mkv")
                            || h.contains(".m3u8")
                            || h.contains(".mpd"))
                })
                .map(|s| s.to_owned())
                .ok_or_else(|| self.err("mirror page has no media link"))?
        } else {
            mirror_url.to_owned()
        };
        validate_playback_url(&page_url)?;
        // Preflight: 8KB range probe must not return an error page.
        let mut headers = self.headers();
        headers.insert("Range".into(), "bytes=0-8191".into());
        let resp = self.net.get(&page_url, &headers).await?;
        if !resp.status().is_success() && resp.status().as_u16() != 206 {
            return Err(self.err(format!("mirror probe HTTP {}", resp.status().as_u16())));
        }
        Ok(page_url)
    }
}

pub(crate) struct ReleaseInfo {
    filename: String,
    mirrors: Vec<(String, String)>,
    size_bytes: Option<u64>,
}

fn text_of(n: scraper::ElementRef<'_>) -> String {
    n.text()
        .collect::<Vec<_>>()
        .join(" ")
        .split_whitespace()
        .collect::<Vec<_>>()
        .join(" ")
}

trait OrLabel {
    fn or(self, label: &str) -> String;
}
impl OrLabel for String {
    fn or(self, label: &str) -> String {
        if self.is_empty() {
            label.to_owned()
        } else {
            self
        }
    }
}

fn first_year(s: &str) -> Option<u16> {
    let b = s.as_bytes();
    for i in 0..b.len().saturating_sub(3) {
        if b[i].is_ascii_digit()
            && b[i + 1].is_ascii_digit()
            && b[i + 2].is_ascii_digit()
            && b[i + 3].is_ascii_digit()
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

fn strip_trailing_year(v: &str) -> String {
    let t = v.trim();
    if t.len() > 7 && t.ends_with(')') {
        let start = t.len() - 6;
        if t.is_char_boundary(start)
            && t.as_bytes()[start] == b'('
            && t[start + 1..t.len() - 1]
                .chars()
                .all(|c| c.is_ascii_digit())
        {
            return t[..start].trim_end().to_owned();
        }
    }
    t.to_owned()
}

fn is_genre(v: &str) -> bool {
    matches!(
        v.to_ascii_lowercase().as_str(),
        "action"
            | "adventure"
            | "animation"
            | "comedy"
            | "crime"
            | "documentary"
            | "drama"
            | "family"
            | "fantasy"
            | "history"
            | "horror"
            | "music"
            | "mystery"
            | "romance"
            | "science fiction"
            | "sci-fi"
            | "thriller"
            | "war"
            | "western"
    )
}

fn find_metadata(doc: &Html, label: &str) -> Option<String> {
    let item = Selector::parse(".metadata-item").ok()?;
    let lab = Selector::parse(".metadata-label").ok()?;
    let val = Selector::parse(".metadata-value").ok()?;
    doc.select(&item).find_map(|n| {
        let cur = n.select(&lab).next().map(text_of)?;
        if cur == label {
            n.select(&val).next().map(text_of)
        } else {
            None
        }
    })
}

fn split_list(s: &str) -> Vec<String> {
    s.split(',')
        .map(|p| p.trim().to_owned())
        .filter(|p| !p.is_empty())
        .collect()
}

fn parse_season_episode(v: &str) -> Option<(u32, u32)> {
    let u = v.to_ascii_uppercase();
    let b = u.as_bytes();
    let mut i = 0;
    while i + 4 < b.len() {
        if b[i] != b'S' {
            i += 1;
            continue;
        }
        let mut j = i + 1;
        while j < b.len() && b[j].is_ascii_digit() {
            j += 1;
        }
        if j == i + 1 || j >= b.len() || b[j] != b'E' {
            i += 1;
            continue;
        }
        let mut k = j + 1;
        while k < b.len() && b[k].is_ascii_digit() {
            k += 1;
        }
        if k == j + 1 {
            i += 1;
            continue;
        }
        if let (Ok(s), Ok(e)) = (u[i + 1..j].parse(), u[j + 1..k].parse()) {
            return Some((s, e));
        }
        i += 1;
    }
    None
}

fn parse_size(v: &str) -> Option<u64> {
    let n = v.replace(' ', "").to_ascii_uppercase();
    for (suf, mul) in [
        ("GB", 1024u64.pow(3)),
        ("MB", 1024u64.pow(2)),
        ("KB", 1024u64),
    ] {
        if let Some(num) = n.strip_suffix(suf) {
            if let Ok(f) = num.parse::<f64>() {
                return Some((f * mul as f64) as u64);
            }
        }
    }
    None
}

fn detect_quality(name: &str) -> Option<String> {
    ["2160p", "1080p", "720p", "480p"]
        .into_iter()
        .find(|q| name.to_ascii_lowercase().contains(q))
        .map(|s| s.to_owned())
}

fn quality_rank(name: &str) -> u32 {
    let l = name.to_ascii_lowercase();
    if l.contains("2160p") {
        4
    } else if l.contains("1080p") {
        3
    } else if l.contains("720p") {
        2
    } else if l.contains("480p") {
        1
    } else {
        0
    }
}

fn is_archive(v: &str) -> bool {
    let l = v.to_ascii_lowercase();
    l.ends_with(".zip") || l.contains("season pack")
}

fn validate_playback_url(url: &str) -> Result<()> {
    if url.starts_with("https://") {
        return Ok(());
    }
    Err(TheatreError::Resolve {
        detail: format!(
            "4khdhub: rejected non-https segment {}",
            &url[..url.len().min(24)]
        ),
        source: Some("4khdhub".into()),
    })
}

fn split_episode_id(content_id: &str) -> (String, u32, u32) {
    if let Some((base, tail)) = content_id.rsplit_once('#') {
        let mut it = tail.split(':');
        if let (Some(s), Some(e)) = (it.next(), it.next()) {
            if let (Ok(s), Ok(e)) = (s.parse::<u32>(), e.parse::<u32>()) {
                return (base.to_owned(), s, e);
            }
        }
    }
    (content_id.to_owned(), 0, 0)
}

#[async_trait]
impl super::Source for KhddhubSource {
    fn id(&self) -> &str {
        "4khdhub"
    }
    fn name(&self) -> &str {
        "4KHDHub"
    }

    async fn search(&self, query: &str, _page: u32) -> Result<SearchPage> {
        let url = self.search_url(query)?;
        let html = self.fetch(&url).await?;
        let results = Self::parse_search_results(&self.base, &html)?;
        Ok(SearchPage {
            results,
            has_more: false,
            partial: false,
        })
    }

    async fn get_details(&self, content_id: &str) -> Result<Details> {
        let (page_id, _, _) = split_episode_id(content_id);
        let url = self.detail_url(&page_id)?;
        let html = self.fetch(&url).await?;
        Self::parse_details(&page_id, &html)
    }

    async fn resolve(&self, content_id: &str, _variant: Option<&str>) -> Result<ResolvedStream> {
        let (page_id, season, episode) = split_episode_id(content_id);
        let url = self.detail_url(&page_id)?;
        let html = self.fetch(&url).await?;
        let releases = Self::parse_releases(&html, season, episode);
        let mut last_err = "no releases on page".to_owned();
        for rel in releases.iter().take(4) {
            for (_, mirror) in &rel.mirrors {
                match self.resolve_mirror(mirror).await {
                    Ok(playable) => {
                        let kind = if playable.contains(".m3u8") || playable.contains(".mpd") {
                            StreamKind::Hls
                        } else {
                            StreamKind::Direct
                        };
                        let label =
                            detect_quality(&rel.filename).unwrap_or_else(|| "HD".to_owned());
                        return Ok(ResolvedStream {
                            url: playable,
                            headers: self.headers(),
                            kind,
                            variants: vec![Variant {
                                id: "v0".into(),
                                label,
                                width: None,
                                height: None,
                                bitrate_kbps: None,
                            }],
                            selected_variant: Some("v0".into()),
                            filename_hint: Some(rel.filename.clone()),
                            size_bytes: rel.size_bytes,
                        });
                    }
                    Err(e) => {
                        last_err = e.to_string();
                    }
                }
            }
        }
        Err(TheatreError::Resolve {
            detail: format!("4khdhub: {}", last_err),
            source: Some("4khdhub".into()),
        })
    }

    async fn health_check(&self) -> SourceStatus {
        match self.net.get(&self.base, &self.headers()).await {
            Ok(r) if r.status().is_success() => SourceStatus::Healthy,
            Ok(r) => SourceStatus::Degraded {
                since: state::now() as u64,
                last_error: format!("HTTP {}", r.status().as_u16()),
            },
            Err(e) => SourceStatus::Degraded {
                since: state::now() as u64,
                last_error: e.to_string(),
            },
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn load_fixture(name: &str) -> String {
        std::fs::read_to_string(
            std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
                .join("tests/fixtures")
                .join(name),
        )
        .unwrap_or_else(|_| panic!("fixture {} not found", name))
    }

    #[test]
    fn parse_search_results_from_fixture() {
        let html = load_fixture("khddhub_search_inception.html");
        let results = KhddhubSource::parse_search_results(DEFAULT_BASE, &html).unwrap();
        assert!(!results.is_empty());
        assert!(results
            .iter()
            .any(|r| r.title.to_lowercase().contains("inception")));
        assert_eq!(results[0].content.source, "4khdhub");
    }

    #[test]
    fn parse_movie_details_from_fixture() {
        let html = load_fixture("khddhub_detail_movie.html");
        let details = KhddhubSource::parse_details("/movie/inception-2010", &html).unwrap();
        assert!(!details.title.is_empty());
        assert_eq!(details.year, Some(2010));
        assert!(!details.genres.is_empty());
    }

    #[test]
    fn parse_releases_from_fixture() {
        let html = load_fixture("khddhub_detail_movie.html");
        let rels = KhddhubSource::parse_releases(&html, 0, 0);
        assert!(!rels.is_empty(), "detail page must list releases");
        assert!(rels.iter().all(|r| !r.mirrors.is_empty()));
    }

    #[test]
    fn rejects_cross_host_detail_url() {
        let src = KhddhubSource {
            net: NetClient::new(),
            base: DEFAULT_BASE.into(),
        };
        assert!(src.detail_url("https://evil.com/movie").is_err());
    }
}
