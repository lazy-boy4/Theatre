//! Per-source health tracking — data-contract.md §8.

use crate::{
    api::types::SourceStatus,
    state::{now, Db},
};
use std::{collections::HashMap, sync::Mutex};

pub struct HealthTracker {
    db: Db,
    cache: Mutex<HashMap<String, SourceStatus>>,
}

impl HealthTracker {
    pub fn new(db: Db) -> Self {
        Self {
            db,
            cache: Mutex::new(HashMap::new()),
        }
    }

    pub fn mark_healthy(&self, source_id: &str) {
        let mut c = self.cache.lock().unwrap();
        c.insert(source_id.to_owned(), SourceStatus::Healthy);
        let n = now();
        self.db.with(|conn| {
            conn.execute(
                "INSERT INTO source_health(source_id, status, updated_at)
                 VALUES(?1,'healthy',?2)
                 ON CONFLICT(source_id) DO UPDATE SET status='healthy', last_error=NULL, updated_at=?2",
                rusqlite::params![source_id, n],
            )?;
            Ok(())
        }).ok();
    }

    pub fn mark_degraded(&self, source_id: &str, reason: &str) {
        let n = now() as u64;
        let status = SourceStatus::Degraded {
            since: n,
            last_error: reason.to_owned(),
        };
        let mut c = self.cache.lock().unwrap();
        c.insert(source_id.to_owned(), status);
        let now_i = n as i64;
        self.db.with(|conn| {
            conn.execute(
                "INSERT INTO source_health(source_id, status, since, last_error, updated_at)
                 VALUES(?1,'degraded',?2,?3,?2)
                 ON CONFLICT(source_id) DO UPDATE SET status='degraded', since=?2, last_error=?3, updated_at=?2",
                rusqlite::params![source_id, now_i, reason],
            )?;
            Ok(())
        }).ok();
    }

    pub fn get_status(&self, source_id: &str) -> SourceStatus {
        self.cache
            .lock()
            .unwrap()
            .get(source_id)
            .cloned()
            .unwrap_or(SourceStatus::Healthy)
    }
}
