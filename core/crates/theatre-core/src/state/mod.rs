//! SQLite state store — architecture §12, data-contract.md §11.
//! Single `theatre.db` file, WAL mode, `busy_timeout=5s` for TUI+GUI sharing.
//! Access rule: `Db::with()` closure only — never hold a connection outside it.

use crate::error::{Result, TheatreError};
use rusqlite::Connection;
use std::{
    path::Path,
    sync::{Arc, Mutex},
    time::{SystemTime, UNIX_EPOCH},
};

/// Unix epoch seconds as stored in all `*_at` columns.
pub fn now() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs() as i64)
        .unwrap_or(0)
}

/// SQLite handle. Clone = shared connection behind a mutex.
/// rusqlite connections are `Send` (single-thread use enforced by the mutex).
#[derive(Clone)]
pub struct Db {
    inner: Arc<Mutex<Connection>>,
}

// SAFETY: all access goes through the mutex; rusqlite Connection is Send.
unsafe impl Send for Db {}
unsafe impl Sync for Db {}

impl Db {
    /// Open (creating + migrating if needed). Idempotent.
    pub fn open(path: impl AsRef<Path>) -> Result<Db> {
        let path = path.as_ref();
        if let Some(parent) = path.parent() {
            if !parent.as_os_str().is_empty() {
                std::fs::create_dir_all(parent).map_err(|e| TheatreError::Storage {
                    reason: format!("create data dir: {}", e),
                })?;
            }
        }
        let conn = Connection::open(path).map_err(|e| TheatreError::Storage {
            reason: format!("open db: {}", e),
        })?;
        conn.busy_timeout(std::time::Duration::from_secs(5))
            .map_err(|e| TheatreError::Storage {
                reason: format!("busy_timeout: {}", e),
            })?;
        conn.execute_batch("PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;")
            .map_err(|e| TheatreError::Storage {
                reason: format!("pragmas: {}", e),
            })?;
        let db = Db {
            inner: Arc::new(Mutex::new(conn)),
        };
        db.migrate()?;
        Ok(db)
    }

    /// Run a closure against the connection. The connection never escapes.
    pub fn with<T>(&self, f: impl FnOnce(&Connection) -> rusqlite::Result<T>) -> Result<T> {
        let conn = self.inner.lock().map_err(|e| TheatreError::Storage {
            reason: format!("db lock poisoned: {}", e),
        })?;
        f(&conn).map_err(|e| TheatreError::Storage {
            reason: e.to_string(),
        })
    }

    /// Forward-only, additive migrations. Every CREATE is IF NOT EXISTS so a
    /// second open of the same file is a no-op (see `db_open_and_migrate`).
    fn migrate(&self) -> Result<()> {
        self.with(|c| {
            c.execute_batch(
                "CREATE TABLE IF NOT EXISTS settings(
                    key        TEXT PRIMARY KEY,
                    value      TEXT NOT NULL,
                    updated_at INTEGER NOT NULL
                );
                CREATE TABLE IF NOT EXISTS history(
                    id           TEXT PRIMARY KEY,
                    kind         TEXT NOT NULL,
                    source_id    TEXT,
                    content_id   TEXT,
                    local_path   TEXT,
                    title        TEXT NOT NULL,
                    poster_url   TEXT,
                    variant      TEXT,
                    position_s   INTEGER NOT NULL DEFAULT 0,
                    duration_s   INTEGER,
                    last_watched INTEGER NOT NULL,
                    play_count   INTEGER NOT NULL DEFAULT 0,
                    completed    INTEGER NOT NULL DEFAULT 0
                );
                CREATE INDEX IF NOT EXISTS idx_history_watched ON history(last_watched DESC);
                CREATE TABLE IF NOT EXISTS downloads(
                    id             TEXT PRIMARY KEY,
                    content_id     TEXT NOT NULL,
                    source_id      TEXT NOT NULL,
                    title          TEXT NOT NULL,
                    variant        TEXT,
                    kind           TEXT NOT NULL,
                    dest_path      TEXT NOT NULL,
                    status         TEXT NOT NULL,
                    bytes_done     INTEGER NOT NULL DEFAULT 0,
                    total_bytes    INTEGER,
                    segments_done  INTEGER NOT NULL DEFAULT 0,
                    total_segments INTEGER,
                    error_msg      TEXT,
                    created_at     INTEGER NOT NULL,
                    updated_at     INTEGER NOT NULL,
                    resume_offset  INTEGER NOT NULL DEFAULT 0,
                    resume_segment INTEGER NOT NULL DEFAULT 0
                );
                CREATE TABLE IF NOT EXISTS library_locations(
                    id       TEXT PRIMARY KEY,
                    path     TEXT NOT NULL,
                    kind     TEXT NOT NULL,
                    label    TEXT,
                    added_at INTEGER NOT NULL
                );
                CREATE TABLE IF NOT EXISTS source_health(
                    source_id  TEXT PRIMARY KEY,
                    status     TEXT NOT NULL,
                    since      INTEGER,
                    last_error TEXT,
                    updated_at INTEGER NOT NULL
                );",
            )?;
            Ok(())
        })
    }
}
