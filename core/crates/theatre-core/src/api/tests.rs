//! Seam tests — data-contract.md §14-M1.
//! Round-trip tests for every contract type & function (fixture-backed).
//! Never hit live network in tests.

#[cfg(test)]
#[allow(clippy::module_inception)]
mod tests {
    use crate::{api::types::*, error::TheatreError};

    // ── Serialization round-trips ────────────────────────────────
    #[test]
    fn init_config_roundtrip() {
        let c = InitConfig {
            data_dir: "/tmp/theatre".into(),
            app_version: "0.1.0".into(),
            proxy_enabled: true,
        };
        let j = serde_json::to_string(&c).unwrap();
        let c2: InitConfig = serde_json::from_str(&j).unwrap();
        assert_eq!(c.data_dir, c2.data_dir);
    }

    #[test]
    fn search_page_roundtrip() {
        let p = SearchPage {
            results: vec![SearchResult {
                content: ContentRef {
                    source: "moviebox".into(),
                    content_id: "abc".into(),
                    kind: ContentKind::Movie,
                },
                title: "Test Movie".into(),
                year: Some(2024),
                poster_url: Some("https://example.com/poster.jpg".into()),
                quality_badges: vec!["1080p".into()],
            }],
            has_more: false,
            partial: false,
        };
        let j = serde_json::to_string(&p).unwrap();
        let p2: SearchPage = serde_json::from_str(&j).unwrap();
        assert_eq!(p2.results.len(), 1);
        assert_eq!(p2.results[0].title, "Test Movie");
    }

    #[test]
    fn resolved_stream_roundtrip() {
        let s = ResolvedStream {
            url: "https://example.com/stream.m3u8".into(),
            headers: [("X-Auth".into(), "token123".into())].into_iter().collect(),
            kind: StreamKind::Hls,
            variants: vec![Variant {
                id: "v1".into(),
                label: "1080p".into(),
                width: Some(1920),
                height: Some(1080),
                bitrate_kbps: Some(4000),
            }],
            selected_variant: Some("v1".into()),
            filename_hint: Some("Movie.2024.1080p.mp4".into()),
            size_bytes: None,
        };
        let j = serde_json::to_string(&s).unwrap();
        let s2: ResolvedStream = serde_json::from_str(&j).unwrap();
        assert_eq!(s2.url, s.url);
        assert_eq!(s2.headers.get("X-Auth"), Some(&"token123".to_string()));
    }

    #[test]
    fn theatre_error_display() {
        let e = TheatreError::Source {
            source: "moviebox".into(),
            detail: "HTTP 404".into(),
        };
        assert!(e.to_string().contains("moviebox"));
    }

    // ── SQLite state tests ────────────────────────────────
    #[test]
    fn db_open_and_migrate() {
        let dir = tempfile::tempdir().unwrap();
        let _db = crate::state::Db::open(dir.path().join("test.db")).unwrap();
        // Should survive a second open (migration idempotent)
        let _db2 = crate::state::Db::open(dir.path().join("test.db")).unwrap();
    }

    #[test]
    fn history_record_and_retrieve() {
        let dir = tempfile::tempdir().unwrap();
        let db = crate::state::Db::open(dir.path().join("test.db")).unwrap();
        let history = crate::history::History::new(db);

        let content = ContentRef {
            source: "moviebox".into(),
            content_id: "t1".into(),
            kind: ContentKind::Movie,
        };
        let mut entry = crate::history::HistoryEntry::for_stream(&content, "Test Movie", None);
        entry.position_s = 120;
        history.record(&entry).unwrap();

        let list = history.continue_watching(10).unwrap();
        assert_eq!(list.len(), 1);
        assert_eq!(list[0].title, "Test Movie");
        assert_eq!(list[0].position_s, 120);
    }

    #[test]
    fn settings_set_and_get() {
        let dir = tempfile::tempdir().unwrap();
        let db = crate::state::Db::open(dir.path().join("test.db")).unwrap();
        let settings = crate::settings::Settings::new(db);

        settings.set("my_key", &"hello".to_string()).unwrap();
        let val: Option<String> = settings.get("my_key").unwrap();
        assert_eq!(val, Some("hello".to_string()));
    }

    #[test]
    fn library_find_sibling_subtitles() {
        let dir = tempfile::tempdir().unwrap();
        let video = dir.path().join("Movie.2024.mkv");
        let sub = dir.path().join("Movie.2024.en.srt");
        std::fs::write(&video, b"").unwrap();
        std::fs::write(&sub, b"").unwrap();

        let subs = crate::library::Library::find_sibling_subtitles(&video.to_string_lossy());
        assert_eq!(subs.len(), 1);
        assert!(subs[0].ends_with(".srt"));
    }
}
