//! Settings KV store — data-contract.md §11.
//! All settings persisted in SQLite `settings` table.

use crate::{error::Result, state::Db};
use serde::{de::DeserializeOwned, Serialize};

pub const KEY_DOWNLOAD_ROOT: &str = "download_root";

pub struct Settings(Db);

impl Settings {
    pub fn new(db: Db) -> Self {
        Self(db)
    }

    pub fn get<T: DeserializeOwned>(&self, key: &str) -> Result<Option<T>> {
        let json: Option<String> = self.0.with(|c| {
            let mut stmt = c.prepare_cached("SELECT value FROM settings WHERE key = ?1")?;
            let mut rows = stmt.query(rusqlite::params![key])?;
            if let Some(row) = rows.next()? {
                Ok(Some(row.get::<_, String>(0)?))
            } else {
                Ok(None)
            }
        })?;
        match json {
            None => Ok(None),
            Some(j) => {
                let val: T =
                    serde_json::from_str(&j).map_err(|e| crate::error::TheatreError::Storage {
                        reason: format!("decode setting {}: {}", key, e),
                    })?;
                Ok(Some(val))
            }
        }
    }

    pub fn set<T: Serialize>(&self, key: &str, value: &T) -> Result<()> {
        let json =
            serde_json::to_string(value).map_err(|e| crate::error::TheatreError::Storage {
                reason: e.to_string(),
            })?;
        let now = crate::state::now();
        self.0.with(|c| {
            c.execute(
                "INSERT INTO settings(key, value, updated_at) VALUES(?1,?2,?3)
                 ON CONFLICT(key) DO UPDATE SET value=excluded.value, updated_at=excluded.updated_at",
                rusqlite::params![key, json, now],
            )?;
            Ok(())
        })
    }

    pub fn get_str(&self, key: &str, default: &str) -> Result<String> {
        Ok(self
            .get::<String>(key)?
            .unwrap_or_else(|| default.to_string()))
    }
}
