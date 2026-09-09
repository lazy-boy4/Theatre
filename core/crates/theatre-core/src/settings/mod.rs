//! Settings KV store — data-contract.md §11.
//! All settings persisted in SQLite `settings` table.

use crate::{error::Result, state::Db};
use serde::{de::DeserializeOwned, Serialize};

pub const KEY_SUBTITLE_LANGUAGE: &str = "subtitle_language";
pub const KEY_DOWNLOAD_ROOT: &str = "download_root";
pub const KEY_PLAYER_SPEED: &str = "player_speed";
pub const KEY_PLAYER_FILL: &str = "player_fill";
pub const KEY_SOURCES: &str = "sources_config";
pub const KEY_PROXY_ENABLED: &str = "proxy_enabled";
pub const KEY_DOWNLOAD_CONCURRENCY: &str = "download_concurrency";
pub const KEY_THEME: &str = "theme";

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

    pub fn get_bool(&self, key: &str, default: bool) -> Result<bool> {
        Ok(self.get::<bool>(key)?.unwrap_or(default))
    }

    pub fn get_u32(&self, key: &str, default: u32) -> Result<u32> {
        Ok(self.get::<u32>(key)?.unwrap_or(default))
    }
}
