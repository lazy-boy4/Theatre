//! Theatre-core performance benchmarks — architecture §14-M1 (P50/P99 targets).
//!
//! Run: `cargo bench -p theatre-core`
//!
//! Target regressions:
//!   • DB read (settings get)    ≤ 5ms  P99
//!   • DB write (history record) ≤ 10ms P99
//!   • HLS URL parse (1000 segs) ≤ 1ms  P99

use criterion::{criterion_group, criterion_main, Criterion};
use std::hint::black_box;
use theatre_core::api::types::{ContentKind, ContentRef};
use theatre_core::{
    history::{History, HistoryEntry},
    settings::Settings,
    state::Db,
};

fn bench_settings_rw(c: &mut Criterion) {
    let dir = tempfile::tempdir().unwrap();
    let db = Db::open(dir.path().join("bench.db")).unwrap();
    let settings = Settings::new(db);

    c.bench_function("settings_set", |b| {
        b.iter(|| {
            settings
                .set(
                    black_box("bench_key"),
                    &black_box("bench_value".to_string()),
                )
                .unwrap()
        })
    });

    settings.set("bench_key", &"hello".to_string()).unwrap();
    c.bench_function("settings_get", |b| {
        b.iter(|| {
            let _: Option<String> = settings.get(black_box("bench_key")).unwrap();
        })
    });
}

fn bench_history_record(c: &mut Criterion) {
    let dir = tempfile::tempdir().unwrap();
    let db = Db::open(dir.path().join("bench2.db")).unwrap();
    let history = History::new(db);
    let content = ContentRef {
        source: "moviebox".into(),
        content_id: "m1".into(),
        kind: ContentKind::Movie,
    };

    c.bench_function("history_record", |b| {
        b.iter(|| {
            let mut e = HistoryEntry::for_stream(black_box(&content), "Bench Movie", None);
            e.position_s = 300;
            history.record(black_box(&e)).unwrap();
        })
    });

    c.bench_function("history_continue_watching", |b| {
        b.iter(|| history.continue_watching(black_box(20)).unwrap())
    });
}

criterion_group!(benches, bench_settings_rw, bench_history_record);
criterion_main!(benches);
