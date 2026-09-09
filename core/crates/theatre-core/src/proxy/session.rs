//! Proxy session management — per-app-launch token, session tracking.

use crate::state::{now, Db};
use rand::Rng;
use std::collections::HashMap;
use std::sync::Mutex;

/// A 128-bit random token generated per app launch.
#[derive(Clone)]
pub struct LaunchToken(String);

impl LaunchToken {
    pub fn generate() -> Self {
        let bytes: [u8; 16] = rand::rng().random();
        Self(hex::encode(&bytes))
    }
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

/// Proxy session tracking — persisted to SQLite.
pub struct ProxySessionStore {
    // Reserved for session persistence (M5); tracking is in-memory today.
    #[allow(dead_code)]
    db: Db,
    token: LaunchToken,
    active: Mutex<HashMap<String, ActiveSession>>,
}

#[derive(Clone)]
struct ActiveSession {
    job_id: String,
    created: i64,
    bytes: u64,
}

impl ProxySessionStore {
    pub fn new(db: Db) -> Self {
        Self {
            db,
            token: LaunchToken::generate(),
            active: Mutex::new(HashMap::new()),
        }
    }

    pub fn token(&self) -> &LaunchToken {
        &self.token
    }

    /// Validate a URL token. Returns `true` if valid.
    pub fn validate_token(&self, t: &str) -> bool {
        t == self.token.as_str()
    }

    /// Generate a proxy URL for a job.
    /// Format: http://127.0.0.1:PORT/d/<token>/<job-id>/<filename>
    pub fn generate_url(&self, port: u16, job_id: &str, filename: &str) -> String {
        format!(
            "http://127.0.0.1:{}/d/{}/{}/{}",
            port,
            self.token.as_str(),
            job_id,
            filename
        )
    }

    pub fn start_session(&self, session_id: &str, job_id: &str) {
        let mut active = self.active.lock().unwrap();
        active.insert(
            session_id.to_owned(),
            ActiveSession {
                job_id: job_id.to_owned(),
                created: now(),
                bytes: 0,
            },
        );
    }

    pub fn end_session(&self, session_id: &str) {
        let mut active = self.active.lock().unwrap();
        active.remove(session_id);
    }

    pub fn active_count(&self) -> usize {
        self.active.lock().unwrap().len()
    }

    pub fn list_active(&self) -> Vec<ProxySession> {
        self.active
            .lock()
            .unwrap()
            .iter()
            .map(|(id, s)| ProxySession {
                id: id.clone(),
                job_id: s.job_id.clone(),
                created_at: s.created,
                bytes_served: s.bytes,
            })
            .collect()
    }
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct ProxySession {
    pub id: String,
    pub job_id: String,
    pub created_at: i64,
    pub bytes_served: u64,
}

// hex encoding without external dep
mod hex {
    pub fn encode(bytes: &[u8]) -> String {
        bytes.iter().map(|b| format!("{:02x}", b)).collect()
    }
}
