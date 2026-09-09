//! TheatreError — the single error type that crosses all module boundaries.
//! Architecture §18; data-contract.md §13.
//! Manual Display impl: the `Source.source` field name collides with
//! thiserror's `source()` convention, so this enum does not derive Display.

use std::fmt;

#[derive(Debug)]
pub enum TheatreError {
    NotInitialized,

    Source {
        source: String,
        detail: String,
    },

    Resolve {
        detail: String,
        source: Option<String>,
    },

    Network {
        detail: String,
    },

    Download {
        job_id: String,
        reason: String,
        resumable: bool,
    },

    Proxy {
        session: String,
        reason: String,
    },

    Storage {
        reason: String,
    },

    Library {
        path: Option<String>,
        reason: String,
    },

    Subtitle {
        reason: String,
    },

    Internal {
        panic_message: String,
    },
}

impl fmt::Display for TheatreError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::NotInitialized => write!(f, "not initialized — call init() first"),
            Self::Source { source, detail } => write!(f, "source error ({}): {}", source, detail),
            Self::Resolve { detail, source } => match source {
                Some(s) => write!(f, "resolve error ({}): {}", s, detail),
                None => write!(f, "resolve error: {}", detail),
            },
            Self::Network { detail } => write!(f, "network error: {}", detail),
            Self::Download {
                job_id,
                reason,
                resumable,
            } => write!(
                f,
                "download error (job {}): {} (resumable: {})",
                job_id, reason, resumable
            ),
            Self::Proxy { session, reason } => {
                write!(f, "proxy error (session {}): {}", session, reason)
            }
            Self::Storage { reason } => write!(f, "storage error: {}", reason),
            Self::Library { path, reason } => {
                write!(f, "library error (path {:?}): {}", path, reason)
            }
            Self::Subtitle { reason } => write!(f, "subtitle error: {}", reason),
            Self::Internal { panic_message } => write!(f, "internal error: {}", panic_message),
        }
    }
}

impl std::error::Error for TheatreError {}

impl From<rusqlite::Error> for TheatreError {
    fn from(e: rusqlite::Error) -> Self {
        TheatreError::Storage {
            reason: e.to_string(),
        }
    }
}

impl From<reqwest::Error> for TheatreError {
    fn from(e: reqwest::Error) -> Self {
        TheatreError::Network {
            detail: e.to_string(),
        }
    }
}

impl From<std::io::Error> for TheatreError {
    fn from(e: std::io::Error) -> Self {
        TheatreError::Storage {
            reason: e.to_string(),
        }
    }
}

pub type Result<T> = std::result::Result<T, TheatreError>;
